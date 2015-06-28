function obj = estimate(obj, modelObj)
% estimate      TODO:
%
% Input:
%   obj         [Estimation]
%   modelObj    [Model]
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

%% 0-1: Pre-estimation stuff

obj.estimationState = false;
tStart              = tic;

% 0) Extract settings from batch file and apply to Estimation object.
obj                 = obj.extractSettingsFromBatch(modelObj.batch);

% 1) Get the data from the input model Tsdata object, and apply transformations 
% in batch
[obj.y, obj.yInfo, ydates, obj.x, obj.xInfo] ...
                    = estimateFns.getFromTsData(obj, modelObj.data);

obj.sample          = getSample(ydates);

% 1.2) Send back to batch for final initalization check
checkInitialization(modelObj.batch, obj);

% Do a loop here because ordering is important
obj.latentIdx       = false(1,obj.namesA.numc);
for i = 1 : obj.namesA.numc
    
    if ~strcmpi( obj.namesA.x{i}, {modelObj.data.mnemonic} );
        obj.latentIdx(i)    = true;
    end
    
end

% 1) Initialize ParameterMatrix objects
nvary           = size(obj.y, 2);
st              = max(obj.yInfo.minPanel);
en              = min(obj.yInfo.maxPanel);            
nlag            = obj.nlag;
nobs            = (en - (st + nlag) + 1);
nvara           = obj.namesA.numc;
numStates       = nvara * obj.nlag;
draws           = obj.simulationSettings.nsave;

if any(strfind(obj.method, 'tvp')) || strcmpi(obj.method,'tvar')
    tidx    = nobs;    
else
    tidx    = 1;
end

obj.A       = ParameterMatrix(nobs,         numStates,  draws, tidx);
obj.T       = ParameterMatrix(numStates,    numStates,  draws, tidx);
obj.C       = ParameterMatrix(numStates,    1,          draws, tidx);
obj.Q       = ParameterMatrix(nvara,        nvara,      draws, tidx);

obj.R       = ParameterMatrix(numStates,    nvara,      draws, tidx);
tmp         = [eye(nvara); zeros(numStates - nvara, nvara)];
obj.R.point = repmat(tmp, [1 1 tidx]);
obj.R.simulation    ...
            = repmat(tmp, [1 1 tidx draws]);
obj.D       = ParameterMatrix(nvary,        1,         draws, tidx);
obj.Z       = ParameterMatrix(nvary,        numStates, draws, tidx);
obj.H       = ParameterMatrix(nvary,        nvary,     draws, tidx);

obj.P       = ParameterMatrix(nvary,        nvary,     draws, 1);
obj.W       = ParameterMatrix(nvary, nvary, draws, 1); 
obj.S       = ParameterMatrix(nvara*(nvara-1)/2, nvara*(nvara-1)/2, draws, 1);  
obj.B       = ParameterMatrix(nvara, nvara, draws, 1);
obj.V       = ParameterMatrix(nvary, nvary, draws, 1);
obj.G       = ParameterMatrix((numStates+1)*nvara, (numStates+1)*nvara, draws, 1);

% 1.1) Insert restriction into parameter matrices. Check sizes


%% 2) Estimate model
func        = str2func( ['@estimationFns.' obj.method] );
res         = func( obj );

% Update parameters values with estimation result
fnames      = fieldnames( res );
for i = 1 : numel( fnames )
    
    if any(strcmpi( fnames{i} , {'u', 'uS', 'e', 'eS', 'yS', 'estimationDates','modelSpecificOutput'}))
        obj.(fnames{i})     = res.(fnames{i});
           
    else
        if strcmpi(fnames{i}(end), 'S') && numel(fnames{i})==2
            obj.( fnames{i}(1:end-1) ).simulation = res.( fnames{i} );            
        else
            obj.( fnames{i} ).point               = res.( fnames{i} );
        end
    end
end


%% Done
obj.tElapsed    = toc(tStart);

obj.estimationState = true;
end
