classdef Batchbvartvpsv < Batchvar
    % Batchbvartvpsv - A class to define run settings for Time varying VAR model
    %               with stochastic volatility in the errors
    %
    % Batchbvartvpsv is a child of Batchvar    
    %
    % Batchbvartvpsv Properties:
    %   priorSettings   - PriorSetting
    %
    % See also BATCHVAR, BATCH, PRIORSETTING 
    %
    % Usage: 
    %
    %   See <a href="matlab: opentoline(./help/helpFiles/htmlexamples/constructAndStoreBatchFilesSimulatedDataExample.m,1)">this example file</a>
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
        priorSettings       = PriorSetting({'tg','a0s','sigmab'},{'normal_whishart','normal_whishart','normal_whishart'});
    end           
    
    methods
        
        function obj = Batchbvartvpsv()                                    
            obj.method = 'bvartvpsv';
        end        
                        
        function x = checkBatchSettings(obj)        

            % call parent object 
            x = checkBatchSettings@Batchvar(obj);            
            
            % Check prior settings
            x = checkSettings(obj.priorSettings, obj);                                                             
            
            if obj.priorSettings.doMinnesota
                
                error([mfilename ':checkBatchSettings'],'You can not ask for Minnesota style priors for this model')                                
                
            else
                
                % Check that the priors are externally correct size
                if size(obj.priorSettings.tg.a0,1) ~= (obj.selectionA.numc*obj.nlag +1)*obj.selectionA.numc              
                    error([mfilename ':checkBatchSettings'],'The size of the tg prior specification is not consistent with selectionA and nlag')                
                end                                    
                if size(obj.priorSettings.a0s.a0,1) ~= ( obj.selectionA.numc*(obj.selectionA.numc-1)/2 )
                    if ~isnan(obj.priorSettings.a0s.a0)
                        error([mfilename ':checkBatchSettings'],'The size of the a0s prior specification is not consistent with selectionA')                
                    end
                end                                                
                if size(obj.priorSettings.sigmab.a0,1) ~= obj.selectionA.numc
                    error([mfilename ':checkBatchSettings'],'The size of the sigmab prior specification is not consistent with selectionA')                
                end
                
            end
            
        end                 
        
        function xx = checkInitialization(obj, obje)                            
            xx = checkInitialization@Batchvar(obj,obje);
        end

    end
    
end