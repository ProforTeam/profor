function outModelNames = constructVarBatch(requiredVariables, auxiliaryVariables,...
                                lagVec, sample, freq, nOfSampleTruncations, ...
                                inDataSetting)
% constructVarBatch  -  Construct a set of batch files for VARs, and save them to 
%                       modelBase folder
%   NB. This function generates VAR model objects in the /myModelBatchSample
%   folder using the naming convention M1, M2 etc. It checks to see if there are
%   any other models with that naming convention and generates the new models
%   with the next available integer. 
%
% Input:
%   requiredVariables       [cellstr] 
%       Names of variables that should always be included in the VAR
%   auxiliaryVariables      [cellstr] 
%       Names that should be included in the VAR. One element of auxiliaryVariables 
%       is used together with requiredVariables in each separate VAR
%   lagVec                  [vector](1xn) 
%       Possible lag combinations. Can e.g. be [1 2] or [2 3] to construct VARs 
%       with 1 and 2 lags, or 2 and 3 lags, respectively. 
%   sample                  [string] 
%       Base sample, i.e., the longest sample chosen to estimate the VAR
%   freq                       [string]      Frequency of the VAR ('m' or 'q')
%   nOfSampleTruncations    [integer]
%       Truncates the start date of the sample n times, where n is set by 
%       nOfSampleTruncations. E.g, if nOfSampleTruncations=2 and sample =
%       '1990.01-2010.04', two VARs will be constructed from this combination. One 
%       with sample='1990.01-2010.04', and one with sample='1990.02-2010.04'
%   inDataSetting           [cell of DataSetting] (1x1 or 1xnSelectionVariables)
%       The data transformortions applied to the selection variables. If you use
%       different variable transformation for the selection variables then the
%       cell has to be of the same size as the number of selection variables.
%
% Output: 
%   modelNames              [cellstr]
%       Returns the model names. In addition a .mat file is constructed for each 
%       of the elements in modelNames, and stored. This .mat file contains a 
%       b = Batchvar object contructed according to the input from this function
%
% USAGE: modelNames = constructVarBatch(??,??,...
%                            ??, ??, ??, ??)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Return a date vector for a given period range.
dates           = sample2ttt(sample, freq);

% Return structure with contents of the directory with the current models.
dirContents     = dir([proforStartup.pfRoot '/myModelBatchSample']);
nDirContents    = numel(dirContents);

% Query the folder containing the models and 
fileList        = [];
newModeIdx      = 1;

for i = 1 : nDirContents
    
    % Ignore certain folders and file types, e.g. up one directory '..'.
    if ~any( strcmpi( dirContents(i).name, {'.','..','.svn', '.DS_Store'}) )
        
        % Create a list of all other files within the directory
        fileList        = cat(1, fileList, {dirContents(i).name});  
        
        % Find the files that match the pre-specified model naming convention,
        % M1, M2, M3 etc. 
        pat = 'M(\d*)';
        [~, matchedModelToken, ~]     = regexp(fileList{end}, pat, 'match', 'tokens');
        
        % If a model match is found, use the matched token contained in
        % parenthesis (\d*), i.e. the digit and augment the model numbering
        % convention to the next avaiable integer.
        if ~isempty( matchedModelToken{:} )
            newModeIdx   = newModeIdx + 1;
        end
    end
end

%% Generate VARs batch

nLagVec             = numel(lagVec);
nAuxiliaryVariables = numel(auxiliaryVariables);
outModelNames          = [];

% Use the max function to account for the case when there are no auxiliary
% variables.
for i = 1 : max(nAuxiliaryVariables, 1)            
    for j = 1 : nLagVec    
        for k = 1 : nOfSampleTruncations
            
            % If the sample is truncated return the appropriate dates and date
            % range.
            truncatedDates  = dates(k : end);
            truncatedSample = getSample( truncatedDates );
            
            % Initialise a var batch object and set appropriate properties.
            b               = Batchvar;
            b.nlag          = lagVec( j );
            b.freq          = freq;
            b.sample        = truncatedSample;
            
            % Construct the VARs Y selection variables accounting for the case 
            % when there are no auxiliary variables.
            if nAuxiliaryVariables == 0
                varSelectionY   = requiredVariables;
            else
                varSelectionY   = [requiredVariables auxiliaryVariables{ i }];
            end            
            b.selectionY    = varSelectionY;     
            
            % Input the data manipulations for each of the selection variables.
            % If the inDataSetting has the same number of elements as the number
            % of selection variables then use that otherwise replicate the first
            % inDataSetting. 
            if numel(inDataSetting) == numel(varSelectionY) && iscell(inDataSetting)
                b.dataSettings = inDataSetting;
            else
                b.dataSettings = repmat({inDataSetting(1)}, [1 b.selectionY.numc]);
            end
                                                            
            % Generate the next avaiable model name and save the initialised VAR
            % batch to the Model directory.            
            newModelName    = ['M' num2str(newModeIdx)];            
            
            savePath        = [proforStartup.pfRoot '/myModelBatchSample/' ...
                                newModelName '.mat'];
            save(savePath, 'b');
            
            % Store the new model names and increment model number index.
            outModelNames   = cat(2, outModelNames, {newModelName});
            newModeIdx      = newModeIdx + 1;
            
            clear b
        end
    end
end

