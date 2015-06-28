classdef TransformationMapping 
    % TransformationMapping - A class for mapping transformation codes 
    %
    % TransformationMapping Properties:
    %       tm - containers.Map
    %       dm - containers.Map
    %
    % Usage: 
    %
    %   obj = TransformationMapping
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
    
    
   properties(SetAccess=private, Hidden = true)       
       % tm - Mapping between keySet (strings) and valueSet (numerics), where 
       % the keySet is strings defining a data transformation code, and the
       % valueSet are numerics defininf the same data transformation code
       tm 
       % dm - Mapping between keySet (strings) and valueSet (strings), where 
       % the keySet is strings defining a data transformation code, and the
       % valueSet are strings describing the transformation code
       dm
   end
    
   properties(Constant = true, Hidden = true)
      valueSet        = (0:13);
      keySet          = {'n',...                                        % 0
                       'log',...                                        % 1
                       'diff',...                                       % 2
                       'gr',...                                         % 3
                       'grdiffgr',...                                   % 4
                       'logdiff',...                                    % 5
                       'loggr',...                                      % 6
                       'loggrdiffgr',...                                % 7
                       'diffyoy',...                                    % 8
                       'gryoy',...                                      % 9
                       'grdiffgryoy',...                                % 10
                       'logdiffyoy',...                                 % 11
                       'loggryoy',...                                   % 12
                       'loggrdiffgryoy',...                             % 13                       
                       };
      description   = { '0 = no transformation',...
                        '1 = log                       eg. log(x)',...
                        '2 = diff                      eg. x(2)-x(1)',...
                        '3 = growth                    eg. (x(2)-x(1))/x(1)*100',...
                        '4 = growth diff growth        eg. (x(3)-x(2))/x(2)*100 - (x(2)-x(1))/x(1)*100',...
                        '5 = log diff                  eg. log(x(2))- log(x(1))',...
                        '6 = log growth                eg. (log(x(2))-log(x(1)))*100',...
                        '7 = log growth diff growth    eg. (log(x(3))-log(x(2)))*100 -(log(x(2))-log(x(1)))*100',...
                        '8 = diff yoy                  eg. x(5)-x(1)',...
                        '9 = growth yoy                eg. (x(5)-x(1))/x(1)*100',...
                        '10= growth diff growth yoy    eg. (x(6)-x(2))/x(2)*100 - (x(5)-x(1))/x(1)*100',...
                        '11= log diff yoy              eg. log(x(5))- log(x(1))',...
                        '12= log growth yoy            eg. (log(x(5))-log(x(1)))*100',...
                        '13= log growth diff growth yoy eg. (log(x(6))-log(x(2)))*100 - (log(x(5))-log(x(1)))*100',...                      
                        }; 
   end
    
    
   methods
       
       function obj = TransformationMapping()                     
           
            obj.tm = containers.Map(obj.keySet,obj.valueSet);                      
            obj.dm = containers.Map(obj.keySet,obj.description);                      
       end       
            
       
   end
    
end



