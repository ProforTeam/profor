classdef (ConstructOnLoad=false) CellObj
    % CellObj   Class to define a cell object. Used extensively for
    % properties in Batch classes
    %
    % CellObj Properties:
    %   numcc       - Numeric 
    %   numc        - Numeric
    %   x           - Cell
    %   type        - Numeric 
    %   xNonEmpty   - Cell 
    %
    % CellObj Methods:
    %
    %   CellObj     - Constructor
    %   getX        - get specific elements of x
    %   getXunique  - get unique elements in CellObj (when all cells are merged)
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

    properties(Dependent=true)
        numc            % Number of elements in x. Calculated by the object itself 
        numcc           % Number of elements in x{i}. Calculated by the object itself 
        xNonEmpty       % Excludes any empty "cells" from x. Calculated by the object itself 
    end
    
    properties
        x               
        sameSizeAs      = '';  % String
        % restrictions - CellObj.x should be equal in size to ... Useful
        % for testing
        restrictions
    end
    
    properties(SetAccess = private)
        type            % Cellstr (1), cell (2), cell with cellstr (3) or cell with cells (4)
        default         = true;
    end
    
    methods
        
        function obj=CellObj(x,varargin)
            % CellObj   Class contructor
            %
            % Input:
            %
            %   x = cellstr (1), cell (2), cell with cellstr (3)
            %       cell with cells (4) or cell with DataSetting elements
            %       (5) (type in parenthesis). If x is not any of these types, 
            %       program returns an error 
            %
            %   varargin = optional. String followed by argument:
            %       'type' = integer. See description for x input, and
            %       further descripton below
            %
            %       'sameSizeAs' = string. Useful for error checking in
            %       e.g. batch files. I.e. used together with other classes
            %
            %       'restrictions' = cellstr. Sets restrictions on what
            %       values x can take. Only works for x's of type 1
            %
            % Output:
            %
            %   obj = CellObj
            %
            % Usage:
            %
            %   obj = cellObj()
            %   Returns an empty CellObj object
            %
            %   obj = cellObj(x)
            %   Returns a CellObj where the type is set accroding to the
            %   type of x
            %
            %   obj = CellObj([],'type',2,'sameSizeAs','identifyVariablesx')
            %   Returns a empty CellObj where type, and restrictions are
            %   applied. I.e. if you populate obj with a different value
            %   than in accordance with type and restrictions, an error is
            %   invoked
            %
            %   On type and restrictions: These properties only apply if
            %   you generate a CellObj without specifying the x property at
            %   construction. I.e. if x is specified at construction,
            %   together with the type and restrictions properties, these
            %   will not be used. If, on the other hand, you generate an
            %   empty CellObj with restrictions and type you will not be
            %   able to set the x property to anything conflicting with
            %   type and restrictions (in case of type=1) later.
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Defaults
            defaults    = {...
                'type',         [],     @isnumeric,...
                'sameSizeAs',   '',     @ischar,...
                'restrictions', {''},   @iscellstr};
            
            options     = validateInput(defaults, varargin(1 : nargin - 1));
            
            if nargin > 0
                
                if ~isempty( x )
                    obj.x               = x;
                    obj.default         = true;
                    
                else
                    if ~isempty( options.type )
                        obj.type        = options.type;
                    end
                end
                
                if ~isempty( options.sameSizeAs )
                    obj.sameSizeAs      = options.sameSizeAs;
                end
                
                if ~isempty( options.restrictions )
                    obj.restrictions    = options.restrictions;
                end
            end
        end
        
        function obj = set.x(obj, value)
            
            if ~isempty( value )
                
                if ~iscell( value )
                    error('CellObj:setx','x must be a cell')
                    
                else
                    obj.x   = value;
                    obj     = checkType( obj );
                end
            end
        end
        
        function obj = checkType( obj )
            % cellstr (1), cell (2), cell with cellstr (3) or cell with cells (4).
            
            possibleTypes   = false(1, 5);
            
            % Test all possible types. Check all because only one should pass.            
            if obj.numc == 0
                % x.x is empty. No need to test anything
                
            else
                if iscellstr( obj.x )
                    possibleTypes(1)    = true;
                end
                
                if ~any( arrayfun(@iscellstr, obj.x) )
                    idx     = [];
                    for i = 1 : obj.numc
                        idx     = cat(1, idx, iscellstr( obj.x{i} ));
                    end
                    
                    if all( idx ) && ~isempty( idx )
                        possibleTypes(3)    = true;
                    end
                end
                
                if ~any( arrayfun( @iscellstr, obj.x) )
                    idx     = [];
                    
                    for i = 1 : obj.numc
                        idx     = cat(1, idx, isnumeric( obj.x{i} ));
                    end
                    
                    if all( idx ) && ~isempty( idx )
                        possibleTypes(2)    = true;
                    end
                end
                
                if ~any( arrayfun(@iscellstr, obj.x) )
                    idx     = [];
                    for i = 1 : obj.numc
                        
                        for j = 1 : numel( obj.x{i} )
                            
                            if iscell(obj.x{i}(j))
                                idx = cat(1, idx, isnumeric( obj.x{i}{j} ));
                            end
                            
                        end
                    end
                    
                    if all( idx ) && ~isempty( idx )
                        possibleTypes(4)    = true;
                    end
                end
                
                if ~any( arrayfun( @iscellstr, obj.x) )
                    idx         = [];
                    for i = 1 : obj.numc
                        idx     = cat(1, idx, isa( obj.x{i}, 'DataSetting' ));
                    end
                    
                    if all( idx ) && ~isempty( idx )
                        possibleTypes(5)    = true;
                    end
                end
                
                if sum( possibleTypes ) ~= 1
                    error('CellObj:setx','x has a format not possible for this class')
                    
                else
                    if isempty( obj.type )
                        obj.type    = find( possibleTypes == 1 );
                        
                    else
                        y   = obj.type;
                        if y ~= find( possibleTypes == 1 )
                            error('CellObj:setx','x has a type different than the current type. That is not allowed')
                        end
                    end
                    
                    % Check restrictions if these apply. Only possible for type 1 at
                    % the moment
                    if obj.type == 1 && ~isempty( obj.restrictions )
                        if ~isempty( obj.restrictions{1} )
                            %if ~any(strcmpi(obj.x,obj.restrictions))
                            
                            if ~any( strcmp( obj.x, obj.restrictions ) )
                                error('CellObj:setx','x has a different value than options in restrictions. That is not allowed')
                            end
                        end
                    end
                    obj.default     = false;
                end
            end
        end
        
        function x = get.numc( obj )
            x   = numel( obj.x );
        end
        
        function x = get.numcc( obj )
            
            if ~isempty( obj.type )
                
                switch obj.type
                    case {1}
                        x = ones(1, obj.numc);
                        
                        for i = 1 : obj.numc
                            if isempty( obj.x{i} )
                                x(i)    = 0;
                            end
                        end
                        
                    case {2,3,4}
                        x   = [];
                        for i = 1 : obj.numc
                            x=cat(2, x, numel( obj.x{i} ));
                        end
                        
                    otherwise
                        x   = [];
                end
                
            else
                x   = [];
            end
        end
        
        function x = get.xNonEmpty( obj )
            nums    = obj.numc;
            numss   = obj.numcc;
            y       = false(1, nums);
            
            for i = 1 : nums
            
                if numss(i) ~= 0
                    y(i)    = true;
                end
                
            end
            
            x       = obj.x(y);
        end
        
        function x = getX(obj, i, ii)
            % getX  Get content i of obj.x returned as a cell.
            %   Irrespective of wether obj.x(i) is a cell or not, output x
            %   will be a cell or cellstr;            
            %
            % Input:
            %
            %   i = numeric. Column of cell to extract. i must be i<=numc
            %
            %   ii = numeric. Column of x(i) to extract. ii must be
            %   ii<=numel x(i);
            %
            % Output:
            %
            %   x = cell.
            %
            % Usage:
            %
            %   x=obj.getX(i)
            %   x=obj.getX(i,ii)
            %   E.g. if x={{2,3},{4,5,6}} x=obj.getX(2,1) gives x={4}
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                x   = obj.x;
                
            else
                if i > obj.numc
                    error('CellObj:getX','i is larger than numc')
                    
                else
                    switch obj.type
                        case {1,2}
                            x   = obj.x(i);
                            
                        case {3,4}
                            x   = obj.x{i};
                            
                        otherwise
                            x   = {};
                            return
                    end
                end
                
                if nargin == 3
                    if ii > numel( x )
                        error('CellObj:getX','ii is larger than numel in x(i)')
                        
                    else
                        if ~isempty( x )
                            x   = x(ii);
                        end
                    end
                end
            end
        end
        
        function x = getXunique( obj )
            % getXunique	Get unque elements of obj.x ordered in according to
            %               first entry. Only works for obj.type=1 2 and 3            
            
            switch obj.type
                case {2}
                    X           = cell2mat( obj.getX );
                    [b, ~, d]   = unique(X, 'first');
                    
                    if numel(X) == numel(b)
                        x           = {d};
                        
                    else
                        X           = obj.getX;
                        x           = [];
                        
                        for i = 1 : obj.numc
                        
                            if i == 1
                                b       = unique(X{i}, 'first');
                                x       = cat(1, x, b);
                                
                            else
                                idx     = ismember( X{i}, x);
                                y       = X{i}( idx == 0 );
                                x       = cat(1, x, y);
                            end
                            
                        end
                        
                        x   = {x};
                    end
                    
                case {1}
                    X           = obj.getX;
                    b           = unique(X, 'first');
                    
                    if numel(b) == numel(X)
                        x           = X;
                        
                    else
                        x           = cell(1, numel( b ));
                        cnt         = 1;
                        
                        %reorder b so that it as the order in X
                        for i = 1 : numel( X )
                            idx     = find( strcmpi(X{i}, b) == 1);
                            
                            if ~isempty( idx )
                                x{cnt}      = b{idx(1)};
                                b{idx(1)}   = '';
                                cnt         = cnt + 1;
                            end
                            
                        end
                    end
                    
                case {3}
                    X       = obj.getX;
                    Y       = [];
                    
                    for i = 1 : obj.numc
                        Y       = cat(2, Y, X{i});
                    end
                    
                    b       = unique(Y, 'first');
                    
                    if numel(b) == numel(Y)
                        x       = Y;
                        
                    else
                        x       = cell(1, numel( b ));
                        cnt     = 1;
                        
                        %reorder b so that it as the order in X
                        for i = 1 : numel( Y )
                            idx     = find( strcmpi( Y{i}, b ) == 1);
                            
                            if ~isempty( idx )
                                x{cnt}      = b{idx(1)};
                                b{idx(1)}   = '';
                                cnt         = cnt + 1;
                            end
                        end
                        
                    end
                    
                otherwise
                    error('CellObj:getXunique','This method only works for objects of type 1 and 2')
            end            
        end
        
        function x = typeOne2Three( obj )
            % typeOne2Three     Transforms a Cellobj of type 1 to a new Obj of 
            %                   type 3
            
            y       = cell(1, obj.numc);
            for i = 1 : obj.numc
                y{i}    = obj.x(i);
            end
            
            x   = CellObj(y, 'type', 3, 'sameSizeAs', obj.sameSizeAs, ...
                            'restrictions', obj.restrictions);
        end
    end
end

