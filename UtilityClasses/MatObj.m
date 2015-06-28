classdef MatObj 
    % MatObj - A class for matrix   
    %
    % MatObj Properties:
    %
    % MatObj Methods:
    %
    % Usage: 
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
       value=[];        
       sameSizeAs
    end
    properties(Dependent=true)
       default=true;  
    end
    
    
    methods
        
        function obj=MatObj(value,varargin)
        % PURPOSE: Define a parameter matrix 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % Input: 
        %
        % value = matrix/vector with numerics
        %   
        % Output:
        %
        % obj = object of parameterMatrix class
        %
        % Usage:
        %
        % obj=parameterMatrix(value)
        % 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
        
            defaults={'sameSizeAs','',@ischar};
            options=validateInput(defaults,varargin(1:nargin-1));            
                        
            if nargin>0
                if ~isempty(value)
                    obj.value=value;           
                end;
                if ~isempty(options.sameSizeAs)
                    obj.sameSizeAs=options.sameSizeAs;
                end;
            end;                                        
        end
        
        function obj=set.value(obj,value)        
            if isnumeric(value)
                obj.value=value;
            else
                error([mfilename ':setvalue'],'value must be a numeric')
            end;            
        end
        
        function obj=set.sameSizeAs(obj,value)
            if~isempty(value)
                if ischar(value)
                    obj.sameSizeAs=value;
                else
                    error([mfilename ':setsamesizeas'],'sameSizeAs must be a string')                
                end                        
            end;
        end
        
        function x=get.default(obj)
            if ~isempty(obj.value)
                x=false;
            else
                x=true;
            end;        
        end;
        
        function sref = subsref(obj,s)
        % obj(i) is equivalent to obj.Data(i)
           switch s(1).type
              % Use the built-in subsref for dot notation
              case '.'
                 sref = builtin('subsref',obj,s);
              case '()'
                 if length(s)<2
                 % Note that obj.Data is passed to subsref
                    sref = builtin('subsref',obj.value,s);
                    return
                 else
                    sref = builtin('subsref',obj,s);
                 end
              % No support for indexing using '{}'
              case '{}'
                 error([myfilename ':subsref'],...
                   'Not a supported subscripted reference')
           end 
        end                
        
        function a=double(obj)
            a=obj.value;
        end
      
        function c=eq(obj,b)
            c=double(obj)==double(b);
        end        
        
%         function obj = subsasgn(obj,s,val)
%            if isempty(s) && strcmp(class(val),'MatObj')
%                obj=MatObj(val.value,'sameSizeAs',val.sameSizeAs);              
%            end
%            switch s(1).type
%            % Use the built-in subsasagn for dot notation
%               case '.'
%                  obj = builtin('subsasgn',obj,s,val);
%               case '()'
%                  if length(s)<2
%                     if strcmp(class(val),'MatObj')
%                        error([myfilename ':subsasgn'],...
%                             'Object must be scalar')
%                     elseif strcmp(class(val),'double')
%                     % Redefine the struct s to make the call: obj.Data(i)
%                        snew = substruct('.','value','()',s(1).subs(:));
%                              obj = subsasgn(obj,snew,val);
%                     end
%                  end
%               % No support for indexing using '{}'
%               case '{}'
%                  error([myfilename ':subsasgn'],...
%                     'Not a supported subscripted assignment')
%            end     
%         end
        
    end    
end