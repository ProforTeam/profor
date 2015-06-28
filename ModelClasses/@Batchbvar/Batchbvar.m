classdef Batchbvar < Batchvar
    % Batchbvar - A class to define run settings for BVAR models    
    %
    % Batchbvar is a child of Batchvar    
    %
    % Batchbvar Properties:
    %   priorSettings   - PriorSetting
    %
    % See also BATCHVAR, BATCH, PRIORSETTING 
    %
    % Usage: 
    %
    %   See <a href="matlab: opentoline(./help/helpFiles/htmlexamples/constructAndStoreBatchFilesExample.m,1)">this example file</a>
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

    properties        
        % priorSettings - PriorSetting object. Defines the prior settings
        %
        % See also PRIORSETTING
        priorSettings       = PriorSetting({'tr'},{'normal_whishart'});
    end       
    
    methods
        
        function obj = Batchbvar()                                    
            obj.method = 'bvar';
        end        
                        
        function x = checkBatchSettings(obj)        

            % call parent object 
            x = checkBatchSettings@Batchvar(obj);            
            
            % Check prior settings
            x = checkSettings(obj.priorSettings, obj);                                                 
            
            if ~obj.priorSettings.doMinnesota
                
                % Check that the priors are externally correct size (internal
                % consistency is ensrued by the Prior object itself)            
                if size(obj.priorSettings.tr.T,1) ~= obj.selectionA.numc || size(obj.priorSettings.tr.T,2) ~= obj.selectionA.numc*obj.nlag +1 % + constanta and exogenous
                    error([mfilename ':checkBatchSettings'],'The size of the prior specification is not consistent with selectionA and nlag')                
                end
                
            end

            
        end                 
        
        function xx = checkInitialization(obj, obje)                            
            xx = checkInitialization@Batchvar(obj,obje);
        end

    end
    
end