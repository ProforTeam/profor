function [predictionsA, predictionsY] = externalempiric(estimation, dataLevel)
% externalempiric	Loads forecasts from files for the specified period and
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


%%

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
    %vintageDate = estimation.dates(find(estimation.estimationDates(end) == estimation.dates) + 1);
    vintageDate = estimation.estimationDates(end);    
    freq        = estimation.freq;
    dataPath    = estimation.dataPath;

    ii = 1;
    vblName     = [estimation.namesY.x{ii}, '_', 'empiric'];


    % Load forecast parameters for vintageDate.
    [outVintageDate, outForecastDate, empiricData] ...
        = loadEmpiricForecastFromCsv(dataPath, vblName, freq);

    % Return the required forecast sample range
    [~, ~, forecastSample]  = adjSample( estimation.estimationSample,  ...
        estimation.freq, 'nfor', nfor);

    % Generate a vector of the forecast dates
    forecastDate            = sample2ttt(forecastSample, freq);

    % Initialise a output matrix for the forecasts, keep same notation as var case.
    aForecast       = nan(nvary, nfor, draws);

    % Restrict to particular vintage
    idx     = find( outVintageDate == vintageDate);

    % Calculate the number of empirical data points
    nEmpiricDatPoints   = size(empiricData, 1);

    % Ensure that for the particular vintage data exists.
    isDataAvailable = numel(idx) > 0;
    msg = 'The vintage  %s returned zero matches';
    assert(isDataAvailable, msg, num2str(vintageDate))

    % Construct the forecast by looping over the forecast dates at the given vintage
    for ii = 1 : numel(forecastDate)

        % Get the requested forecast date.
        idxOut  = find( outForecastDate(idx, 1) == forecastDate(ii));

        if numel( idxOut ) > 2
            error([mfilename ':multipleMatch'], 'Multiple data for given vintage in the input csv file')

        elseif numel( idxOut ) < 1
            error([mfilename ':noMatch'], 'No Data Found for vintage %s', num2str(vintageDate))
        end

        % Check size of empiric distribution, if not exactly equal to draws, then
        % resample to this size with replacement.
        if nEmpiricDatPoints ~= draws
            withReplacement = true;

            % Populate the forecast matrix with the empiric forecast.
            aForecast(:, ii, :)     = randsample( empiricData( :, idx(idxOut) ), ...
                draws, withReplacement);

        else
            % Populate the forecast matrix with the empiric forecast.
            aForecast(:, ii, :) = empiricData( :, idx(idxOut) );
        end                    
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
