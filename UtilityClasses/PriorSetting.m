classdef PriorSetting
    % PriorSetting - A class to define prior settings. Used in
    % Batch classes 
    %
    % PriorSetting Properties:
    %   tr              - Priors
    %   obs             - Priors 
    %   zw              - Priorstvp
    %   etav            - Priorstvp
    %   tg              - Priorstvp
    %   a0s             - Priorstvp
    %   sigmab          - Priorstvp
    %   minnesota       - MinnesotaPriorSetting
    %   doMinnesota     - logical
    %   mix             - Priorsmixture
    %
    % PriorSetting Methods:
    %   PriorSetting    - Constructor         
    %
    % See also PRIORS, PRIORSTVP
    %   
    % For some definition, see <a href="./help/helpFiles/htmlexamples/html/estimationNamingConventionsExample.HTML">this description</a>
    % For usage, see <a href="matlab: opentoline(./help/helpFiles/htmlexamples/constructAndStoreBatchFilesExample.m,1)">this example file</a>
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
        % tr - Prior object. Defines priors for transition equation when no
        % time varying parameters are used
        tr      
        % obs - Prior object. Defines priors for observation equation when no
        % time varying parameters are used        
        obs
        
        % zw - Priortvp object. Used for TVP models
        %
        % See <a href="./help/helpFiles/htmlexamples/html/estimationNamingConventionsExample.HTML">for further description</a>
        zw
        % etav - Priortvp object. Used for TVP models
        %
        % See <a href="./help/helpFiles/htmlexamples/html/estimationNamingConventionsExample.HTML">for further description</a>        
        etav
        % tg - Priortvp object. Used for TVP models
        %
        % See <a href="./help/helpFiles/htmlexamples/html/estimationNamingConventionsExample.HTML">for further description</a>                
        tg
        % a0s - Priortvp object. Used for TVP models
        %
        % See <a href="./help/helpFiles/htmlexamples/html/estimationNamingConventionsExample.HTML">for further description</a>                
        a0s
        % sigmab - Priortvp object. Used for TVP models
        %
        % See <a href="./help/helpFiles/htmlexamples/html/estimationNamingConventionsExample.HTML">for further description</a>                        
        sigmab        
        % minnesotaSettings - MinnesotaPriorSetting object. 
        %
        % See also MINNESOTAPRIORSETTING
        minnesotaSettings = MinnesotaPriorSetting;
        % doMinnesota - Logical. If true, Minnesota style priors will be
        % used on the tr property (see above). Default = false. 
        % Note: if doMinnesota = true, you do not have to specify priors for 
        % the tr property (if you do an error will be recorded)
        doMinnesota = false;         
        % mix - Priormixture object. Used for Mixture models
        %
        mix 
    end
    
    methods
        
        function obj = PriorSetting(tags, types)
            % PriorSetting - Class constructor method         
            %                Populates a PriorSetting object with different
            %                Priors and/or Priorstvp objects
            %
            % Input: 
            % 
            %   tags         [Cellstr]
            %                See also PRIORS, PRIORSTVP
            %   types        [Cellstr]
            %                See also PRIORS
            %
            % Output:
            % 
            %   obj         [PriorSetting]
            %
            % Usage:
            %
            %   obj = PriorSetting( tag, types )           
            %   obj = PriorSetting( tag )           
            %
            % Note: Inputs tags and types must have same number of elements
            % if both are supplied. If types are not supplied, the type
            % will be the default as defined by the class Prior or
            % Priortvp.
            %            
            if nargin == 0               
                obj.tr = Priors({'tr'});                                                
            else                
                n = numel(tags);
                for i = 1:n                    
                    switch lower(tags{i})
                        case{'tr','obs'}
                            p = Priors(tags(i));                    
                            if nargin == 2
                                p.type = types(i);
                            end                            
                        case{'zw','etav','tg','a0s','sigmab'}
                            p = Priorstvp(tags(i));    
                        case{'mix'}
                            p = Priorsmixture(tags(i));    
                    end
                    obj.(tags{i}) = p;
                end;                                
            end            
        end        
        
        function obj = set.tr(obj,value)
            if ~isa(value,'Priors')
                error([mfilename ':settr'],'tr must be a Priors class')
            else
                if ~strcmpi(value.tag.x{:},'tr')
                    error([mfilename ':settr'],'tr must have a tr tag')
                else
                    obj.tr = value;
                end
            end
        end        
        function obj = set.obs(obj,value)
            if ~isempty(value)
                if ~isa(value,'Priors')
                    error([mfilename ':setobs'],'obs must be a Priors class')
                else
                    if ~strcmpi(value.tag.x{:},'obs')
                        error([mfilename ':setobs'],'obs must have a obs tag')
                    else
                        obj.obs = value;
                    end
                end
            end;
        end        
        function obj = set.zw(obj,value)
            if ~isempty(value)
                if ~isa(value,'Priorstvp')
                    error([mfilename ':setzw'],'zw must be a Priorstvp class')
                else
                    if ~strcmpi(value.tag.x{:},'zw')
                        error([mfilename ':setzw'],'obs must have a zw tag')
                    else
                        obj.zw = value;
                    end
                end
            end;
        end                
        function obj = set.etav(obj,value)
            if ~isempty(value)
                if ~isa(value,'Priorstvp')
                    error([mfilename ':setetav'],'etav must be a Priorstvp class')
                else
                    if ~strcmpi(value.tag.x{:},'etav')
                        error([mfilename ':setetav'],'etav must have a etav tag')
                    else
                        obj.etav = value;
                    end
                end
            end;
        end                        
        function obj = set.tg(obj,value)
            if ~isempty(value)
                if ~isa(value,'Priorstvp')
                    error([mfilename ':settg'],'tg must be a Priorstvp class')
                else
                    if ~strcmpi(value.tag.x{:},'tg')
                        error([mfilename ':settg'],'tg must have a tg tag')
                    else
                        obj.tg = value;
                    end
                end
            end;
        end                                
        function obj = set.a0s(obj,value)
            if ~isempty(value)
                if ~isa(value,'Priorstvp')
                    error([mfilename ':seta0s'],'a0s must be a Priorstvp class')
                else
                    if ~strcmpi(value.tag.x{:},'a0s')
                        error([mfilename ':seta0s'],'a0s must have a a0s tag')
                    else
                        obj.a0s = value;
                    end
                end
            end;
        end                                        
        function obj = set.sigmab(obj,value)
            if ~isempty(value)
                if ~isa(value,'Priorstvp')
                    error([mfilename ':setsigmab'],'sigmab must be a Priorstvp class')
                else
                    if ~strcmpi(value.tag.x{:},'sigmab')
                        error([mfilename ':setsigmab'],'sigmab must have a sigmab tag')
                    else
                        obj.sigmab = value;
                    end
                end
            end;
        end                
        
        function obj = set.minnesotaSettings(obj,value)
           if ~isa(value, 'MinnesotaPriorSetting')
               error([mfilename ':setminnesotaSettings'],'minnesotaSettings must be a MinnesotaPriorSetting class')               
           else
               obj.minnesotaSettings = value; 
           end            
        end
        
        function obj = set.doMinnesota(obj, value) 
            if ~islogical(value)
                error([mfilename ':setdoMinnesota'],'doMinnesota must be a logical')               
            else
                obj.doMinnesota = value; 
            end
        end
        
        function obj = set.mix(obj,value)
            if ~isempty(value)
                if ~isa(value,'Priorsmixture')
                    error([mfilename ':setmix'],'mix must be a Priorsmixture class')
                else
                    if ~strcmpi(value.tag.x{:},'mix')
                        error([mfilename ':setmix'],'mix must have a mix tag')
                    else
                        obj.mix = value;
                    end
                end
            end;
        end                        
        
        function x=checkSettings(obj,batchObj)            
            % Set all the properties once more to check if they are
            % correct.
            props = properties(obj);
            
            x = false;
            for i = 1:numel(props)          
                if ~isempty(obj.(props{i}))
                    
                    %if strcmpi(props{i}, 'tr') && obj.doMinnesota
                    %    error([mfilename ':checkSettings'],'You have asked for Minnesota prior for property tr, but tr is not empty. Not consistent')
                    %else
                        % Check internal consistency
                        if ~any(strcmpi(props{i}, {'minnesotaSettings', 'doMinnesota'}))                                                    
                            if obj.(props{i}).state ~= 1
                                error([mfilename ':checkSettings'],[mfilename ' setting: ' props{i} ' does not have state ok'])
                                return
                            end
                        end
                    %end
                    
                end
            end
            x = true;
        end                       
        
    end
    
end