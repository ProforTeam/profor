classdef Estimation < handle
    % Estimation    Class for estimataion
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
    %
    
    properties(SetAccess = protected, Hidden)        
        yInfo
        xInfo
        nfor
        latentIdx
        dataSettings
        dataPath
        links
        
        estimationState = false;        
        
        thresholdVariableIndex   
        maxDecay                 
        thresholdQuantile        
        mixtureNormalOnly
    end
    
    properties(SetAccess = protected)
        tElapsed  %Total time used in estimation        
        sample
        estimationDates
        freq      %From the batch object        
        nlag
        method        
        namesY    % (1 x n) cellstr with names of endogenous variables
        namesX    % (1 x m) cellstr with exogenous variables
        namesA    % (1 x s) cellstr with state variable names
        
        y         % Observable variables
        x         % exogenous variables
        
        A         % State matrix
        T         % Companion form matrix of state dynamics
        C         % constant in transition equation
        Q         % Covaraince of state errors
        R         % To be used for singular Q
        
        D         % Exogenous stuff in observation equation
        Z         % Obseravbles related to states
        H         % Covaraince of observation errors (iid N, i.e., if obs errors are AR - the errors in this eq)
        P         % AR coefficients for observation equation errors
        
        u          % Tranisiton equation errors
        uS         % Tranisiton equation errors (simulated)
        e          % observation equation errors
        eS        % observation equation errors (simulated)
        yS         % Observable variables (simulated)      
        
        W         % Covaraince of errors in tvp process for Z
        S         % Covaraince of errors in tvp process for A0
        B         % Covaraince of errors in tvp process for Sigma
        V         % Covaraince of errors in tvp process for eta
        G         % Covaraince of errors in tvp process for T
        
        simulationSettings
        generalSettings
        
        priorSettings        
        
        modelSpecificOutput % Structure with contents specific for a given model
    end
    
    properties(Dependent=true)
        dates     % Cs date vector; covering sample
        estimationSample
    end
    
    methods        
        function obj = Estimation( )

        end        
        
        function x = get.dates( obj )
            x   = sample2ttt(obj.sample, obj.freq);
        end
        
        function x = get.estimationSample( obj )
            x   = getSample( obj.estimationDates );
        end
        
        %% Methods in separate files  
        
        obj = estimate(obj, mobj)        
        disp( obj )
                
    end
    
    methods(Access=private)                
    end
    
end




