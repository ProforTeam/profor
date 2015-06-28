classdef ParameterMatrix
    % ParameterMatrix - A class for storing parameter estimates   
    %
    % ParameterMatrix Properties:
    %
    % ParameterMatrix Methods:
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
    
    properties(SetAccess=protected)
        rows
        cols
        draws                
        t
    end;
    properties
        simulation 
        point
        restriction
    end    

    methods
        
        function obj=ParameterMatrix(rows,cols,draws,t)
            obj.rows=rows;
            obj.cols=cols;
            obj.draws=draws;
            obj.t=t;
            
            obj.simulation=zeros(obj.rows,obj.cols,obj.t,obj.draws);
            obj.point=zeros(obj.rows,obj.cols,obj.t);
            obj.restriction=ones(obj.rows,obj.cols,obj.t);            
        end;
           
        function x=getQuantile(obj,alphaSign,confidenceIntMethod)
            [~,x]=getDrawSelections(obj.simulation,alphaSign,...
                obj.draws,'method',confidenceIntMethod,...
                'value0',obj.point);  
        end;
        
        function obj=subsasgn(obj,s,b)
        
            if ~strcmpi(s(1).type,'.')
                error([mfilename ':subsasgn'],'Set must be done on object with dot notation')
            else
                switch s(1).subs
                    case{'point','restriction'}
                        [r,c,w]=size(b);
                        if r~=obj.rows || c~=obj.cols || w~=obj.t
                            error([mfilename ':set' s(1).subs],'%s value has wrong size',s(1).subs)
                        else    
                            if strcmpi(s(1).subs,'restriction')
                                if ~islogical(b)
                                    error([mfilename ':setrestriction'],'restriction should be a logical')
                                end;
                            end;
                            obj.(s(1).subs)=b;
                        end;                                                   
                    case{'simulation'}
                        [r,c,w,d]=size(b);
                        if r~=obj.rows || c~=obj.cols || w~=obj.t || d>obj.draws
                            error([mfilename ':setpoint'],'Point value has wrong size or d is bigger than draws')
                        else            
                            obj.simulation=b;
                        end;        
                end;
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
                    if s(1).subs{1}==0 
                        sref = obj.point(:,:,s(1).subs{2});
                    else
                        sref = obj.simulation(:,:,s(1).subs{2},s(1).subs{1});
                    end;
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
        
        function h = plot(obj,varargin)
            
            % Define some defaults
            defaults        = {...
                'dates',        [],             @isnumeric,...
                'name',         'Parameters',   @ischar,...
                'alphaSign',    0.05,           @isscalar,...                  
                };
            options         = validateInput(defaults, varargin);            
                        
            if obj.draws > 1
                h   = figure('name',[options.name ' . Point and simulation, ' num2str((1-options.alphaSign)*100) ' percent probability bands']);                            
                x   = getQuantile(obj,options.alphaSign,'quantile');                
                cnt = 1;
                for i = 1:obj.rows
                    for j = 1: obj.cols
                        subplot(obj.rows,obj.cols,cnt)
                        if obj.t > 1
                            jbfill((1:obj.t),permute(x(i,j,:,1),[3 1 2 4])',permute(x(i,j,:,3),[3 1 2 4])',[0.7619 0.7619 0.7619],'none',0,0.2);       
                            hold on
                            plot(permute(x(i,j,:,2),[3 1 2 4]),'k')                                                                                                                        
                        
                            if ~isempty(options.dates)
                                [~,~]=setXtickAndLabel(options.dates,'handle',gca);                                                    
                            end
                        else
                            bar(permute(x(i,j,1,:),[4 1 2 3]))
                        end
                        
                        cnt = cnt + 1;
                    end
                end                
            end                      
                
        end
                
    end

    
end