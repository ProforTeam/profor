classdef SimulationSetting
    % SimulationSetting - A class to define simulation settings. Used in
    % Batch classes 
    %
    % SimulationSetting Properties:
    %        nSaveDraws       - Numeric
    %        nBurnin          - Numeric
    %        nStep            - Numeric            
    %        showProgress     - Logical
    %        bootStrapMethod  - CellObj
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
       % nSaveDraws - Number of simulations (e.g., Gibbs or Bootstrap) to actually 
       % save and use in calculations for posterior or confidence band
       % output
       nSaveDraws       = 1000; 
       % nBurnin - Number of burn-in simulations to use (Gibbs) (These are
       % not saved)
       nBurnin            = 0;
       % nStep - Number of steps to jump in the chain of simulations when
       % extracting draws to actually save. Used to avoid autocorrelation
       % (Gibbs)
       nStep            = 1;       
       % showProgress - Logical. If true, display to screen the progress.
       % Default = true. 
       showProgress     = true;       
       % bootStrapMethod - Defines which type of bootstrap method to use
       bootStrapMethod  = CellObj({'br'},'type',1,'restrictions',{'br','norm','bmb'}); 
    end       
    
    properties(Dependent)
        ntot            % nSaveDraws*nStep + nBurnin*nStep, i.e., total number of draws  
        nstepDraws
    end
    
    properties(Dependent, Hidden = true)
        nsave 
        nburn
        nstep
    end    
            
    methods
        
        function obj = SimulationSettings( nSaveDraws )
           if nargin == 1
               obj.nSaveDraws = nSaveDraws;
           end;            
        end
       
        function x = get.ntot(obj)
            x = obj.nSaveDraws*obj.nStep + obj.nBurnin*obj.nStep;  % Total number of draws            
        end;
        
        function x = get.nstepDraws(obj)
            y  = (obj.ntot - obj.nBurnin);
            yy = floor( y / obj.nSaveDraws );
            z  = floor( obj.nSaveDraws / yy );
            z  = repmat(z, [1 yy]);
            x  =[z obj.nSaveDraws - sum(z)];
            if sum(x) ~= obj.nSaveDraws
                error([mfilename ':nstepDraws'],'You have programmed you Gibbs class wrong you stupid f....!!!')
            end;
            if x(end) == 0
                x=x( 1:end-1 );
            end;
        end

        function obj = set.nSaveDraws(obj, value)        
            if ~isnumeric(value)                 
                error([mfilename ':setnSaveDraws'],'The nSaveDraws property must be numeric')
            elseif value <= 0 
                error([mfilename ':setnSaveDraws'],'The nSaveDraws property must be positive')                
            end
            obj.nSaveDraws = value;             
        end;                        
        function obj = set.nBurnin(obj, value)        
            if ~isnumeric(value)                 
                error([mfilename ':setnBurnin'],'The nBurnin property must be numeric')
            elseif value < 0 
                error([mfilename ':setnBurnin'],'The nBurnin property must be positive')                
            end
            obj.nBurnin = value;             
        end;                        
        function obj = set.nStep(obj, value)        
            if ~isnumeric(value)                 
                error([mfilename ':setnStep'],'The nStep property must be numeric')
            elseif value <= 0 
                error([mfilename ':setnStep'],'The nStep property must be positive')                
            end
            obj.nStep = value;             
        end;                           
        function obj=set.showProgress(obj,value)
            if ~islogical(value)
                error([mfilename ':setshowProgress'],'showProgress ust be a logical')
            else
                obj.showProgress=value;
            end
        end        
        function obj=set.bootStrapMethod(obj,value)
            obj.bootStrapMethod=Batch.setCellObj(obj.bootStrapMethod,value);            
        end        
        
        function x = get.nsave( obj ) 
            x = obj.nSaveDraws;            
        end
        function x = get.nburn( obj ) 
            x = obj.nBurnin;            
        end
        function x = get.nstep( obj ) 
            x = obj.nStep;            
        end        
        
    end
        
end