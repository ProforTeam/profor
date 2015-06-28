function [predictionsA, predictionsY] = externalanalytic(estimation, dataLevel)
% externalanalytic	Loads forecasts from files for the specified period and
%                   returns a Tsdataforecast objects.
%   Finds the vintage date and extracts the forecast from an csv file for this
%   vintage date.
% 
% Input:
%   estimation          [Estimation]
%   dataLevel           [Tsdata]
%
% Output:
%   predictionsA        [Tsdataforecast]
%   predictionsY        [Tsdataforecast]
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Copyright (C) 2014  PROFOR Team
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Refactor

% TODO: Take from batch
distributionType = 'splitNormal';
marketProjection = 'Constant';      % {Constant, Market}

%%
errType     = ['forecastingFns:' mfilename];

en          = min( estimation.yInfo.maxPanel );

% Extract from object to make less overhead when doing parfor
[Tt, nvary] = size(estimation.y);
y           = estimation.y;
nfor        = (Tt - en);

if nfor == 0 
    predictionsA = [];
    predictionsY = [];    
else
    nlag        = estimation.nlag;
    draws       = estimation.simulationSettings.nsave;
    
    % Adjust vintage date to account for BoE split normal timing, that the
    % vinage date produces a concurrent forecast for the period, eg. V04.01,
    % uses data to 03.04, but the 1-step forecast is for 04.01.
    if strcmpi( estimation.method, 'externalanalytic' )
        
        % In place of a method to augment a date by one period, do it this way.        
        tempDates       = sample2ttt( estimation.sample, estimation.freq );
        
        % Find the index of the date 
        idxDate         = tempDates == estimation.estimationDates(end);
        
        assert( sum(idxDate) == 1, errType, 'Problem with external analytic dates')
        
        % Shift the index by one element to select the next date to call the
        % vintage.
        idxDate         = circshift(idxDate, 1);
        
        % Select the appropriate vintage date.
        vintageDate = tempDates(idxDate);
        
    else
        vintageDate = estimation.estimationDates(end);
    end
    
    freq        = estimation.freq;
    dataPath    = estimation.dataPath;

    % Create the variable name from which the external output is read in.
    switch distributionType
        case 'splitNormal'
            ii          = 1;
            vblName     = [estimation.namesY.x{ii}, '_', distributionType];

        otherwise
            error(errType, 'Only support for split normal distribution')
    end

    % Load forecast parameters for vintageDate.
    outTable = loadSplitNormalDataFromCsv(dataPath, vblName, freq);

    % Return the required forecast sample range
    [~, ~, forecastSample]  = adjSample( estimation.estimationSample,  ...
        estimation.freq, 'nfor', nfor);

    % Generate a vector of the forecast dates
    forecastDate            = sample2ttt(forecastSample, freq);

    % Restrict table to particular vintage and market projection.
    idxForecast     = (outTable.vintage == vintageDate & outTable.marketProjection == ...
        marketProjection);
    forecastTable   = outTable(idxForecast, :);

    % Ensure that for the particular vintage and market projection, data exists.
    isDataAvailable = numel(forecastTable) > 0;
    msg = 'The vintage  %s, and market projection %s, returned zero matches';
    assert(isDataAvailable, msg, num2str(vintageDate), marketProjection)

    % Initialise a output matrix for the forecasts, keep same notation as var case.
    aForecast       = nan(nvary, nfor, draws);

    % Construct the forecast by looping over the forecast dates at the given vintage
    for ii = 1 : numel(forecastDate)
        % Get the row of the table. 
        idxForecast         = (forecastTable.evaluationDate == num2str(forecastDate(ii)));    

        if sum( idxForecast ) > 1
            error(errType, 'Multiple data for given vintage in the input csv file')

        elseif sum( idxForecast ) < 1
            error(errType, 'No Data Found for vintage %s', num2str(vintageDate))
        end

        BoE.mean            = forecastTable(idxForecast, :).Mean;
        BoE.uncert          = forecastTable(idxForecast, :).Uncertainty .^ 2;
        BoE.skew            = forecastTable(idxForecast, :).Skew;

        % Generate the split normal and the random variables.
        SN1                 = SplitNormal(BoE.mean, BoE.uncert, BoE.skew, ...
            'BoE-uncorrected-skew');
        aForecast(:, ii, :) = SN1.randSplitNormal([nvary, 1, draws]);
    end


    % Indicator of whether to store the forecast or not.
    if nargin == 2
        isStoreDataLevel = true;
    else
        isStoreDataLevel = false;
        dataLevel        = [];
    end

    % Return the forecast predictions and history if provided.
    [predictionsA, predictionsY] = ...
        forecastFns.storeForecastAndHistoryNotCombination(aForecast, forecastSample, ...
        dataLevel, estimation, isStoreDataLevel);                                
end


end
