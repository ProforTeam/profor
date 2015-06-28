classdef (Hidden=true)proforStartup < handle
% proforStartup -  Class to initialize PROFOR Toolbox  
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

    properties(SetAccess = private)
        
        proforRoot
        computerName
        
    end
    
    properties(Constant = true)
        % default definitions
        proforVersion = 'beta 1.0';
        compatibility = 'R2014b';
    end
    
    
    methods
        
        function pf = proforStartup(poolSize)
            
            % get computer name
            pf.computerName = pf.getComputerName;
            
            % close parallel computing if possible
            % start parallel computing if possible
            if nargin == 1
                pf.parallelStart(poolSize);
            else
                pf.parallelStart(0);  % Opens local pool with defaults
            end
            
            % add paths to MATLAB search path
            root = pf.pfRoot;
            
            % add temp folder if it does not already exist. Need this for
            % temporary output for models etc.
            if ~isdir(fullfile(root, 'temp'))
                mkdir(fullfile(root, 'temp'));
            else
                % delete content of temp folder (if it already exists).
                % This is just for cleaning up. Don't want lots of stuff
                % just taking up space in this folder.
                pf.deleteTempCont(root);
            end
            
            % add the root to the property
            pf.proforRoot = root;
            
            % generate the paths needed to run the toolbox
            add = pf.nsGenpathcell(root, true);
            restoredefaultpath;
            addpath(add{:}, '-begin');
            
            % set default figure properties
            pf.setDefaultFigureSettings
            
            
        end
        
    end
    
    methods(Static)
        
        function rootDir = pfRoot()
            rootDir = fileparts(which('proforStartup'));
        end
        
        function helpDataDir = pfRootHelpData()
            helpDataDir =fullfile(proforStartup.pfRoot,'help','helpfiles','htmlexamples','data');
        end
        
        function name = getComputerName()
            [ret, name] = system('hostname');
            if ret ~= 0,
                if ispc
                    name = getenv('COMPUTERNAME');
                else
                    name = getenv('HOSTNAME');
                end
            end
            name = deblank(lower(name));
        end
        
        function pkg=nsGenpathcell(root,includeroot)
            % PURPOSE: Generate a list of paths to add to the top of the Matlab
            % search path
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            pkg = {}; % package directories
            if nargin < 1
                return
            end
            if nargin < 2
                includeroot = true;
            end
            if includeroot
                pkg{1} = root;
            end
            
            % List of all
            list = dir(root);
            if isempty(list)
                return
            end
            
            % Select only directories.
            list = list([list.isdir]);
            
            % Loop over directories and select only those that aren't in the
            % exclude index.
            for i = 1:length(list)
                name = list(i).name;
                
                % Logical array of folders that shouldn't be added to path.
                excludeIdx = [ ...
                    isempty( regexp(name, '(\.|\.\.|\.svn)', 'start', 'once') ),...
                    ~strcmpi(name, 'private'), ...
                    isempty(regexp(name, '\+|\-', 'start', 'once')), ...
                    isempty(regexp(name,'\@', 'start', 'once')), ...
                    ~strcmpi(name, 'examples') ...
                    ];
                
                % Only return the folders not in the exclude list, passes
                % recursively through this function into all subdirectories. 
                if all( excludeIdx );                    
                    pkg = cat(2, pkg, ...
                        proforStartup.nsGenpathcell(fullfile(root, name), true));
                end
            end
        end
        
        function deleteTempCont(root)
            list = dir([root '/temp']);
            if isempty(list)
                return
            end
            % Select only directories.
            list = list([list.isdir]);
            numList = numel(list);
            parfor i = 1:numList
                if ~any(strcmpi(list(i).name,{'.','..','.svn'}))
                    rmdir([root '/temp/' list(i).name],'s');
                end
            end
        end
        
        function y = doIHaveTheParallel()
            x = ver();
            y = false;
            for i = 1:numel(x)
                if strcmpi(x(i).Name,'Parallel Computing Toolbox')
                    y = true;
                    break
                end
            end
        end
        function parallelStart(poolSize)
            % PURPOSE: Starts the local matlabpool
            y = proforStartup.doIHaveTheParallel();
            
            if y
                %x=matlabpool('size');
                poolobj = gcp('nocreate'); % If no pool, do not create new one.
                % Delete the current pool if any
                delete(poolobj);
                if poolSize>0
                    % open pool
                    parpool('local',poolSize)
                    %matlabpool('open','local',poolSize)
                else
                    parpool('local')
                end
            end
        end
        
        function setDefaultFigureSettings
            
            set(0,'defaultFigureColor',[1 1 1]);
            
        end
        
    end
    
    methods
        
        function disp(pf)
            
            %! Display messages.
            fprintf(1,'     \n');
            fprintf(1,'     <a href="%s">PROFOR Toolbox</a> version %s\n',...
                fullfile(pf.proforRoot,'help','helpFiles','mytoolbox_product_page.html') ,pf.proforVersion());
            fprintf(1,'     Copyright (C) 2014  PROFOR Team\n\n');
            fprintf(1,['    This program is free software: you can redistribute it and/or modify\n',...
                '    it under the terms of the GNU General Public License as published by\n',...
                '    the Free Software Foundation, either version 3 of the License, or\n',...
                '    (at your option) any later version.\n\n']);
            fprintf(1,['    This program is distributed in the hope that it will be useful,\n',...
                '    but WITHOUT ANY WARRANTY; without even the implied warranty of\n',...
                '    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n',...
                '    GNU General Public License for more details.\n\n']);
            fprintf(1,['    You should have received a copy of the GNU General Public License\n',...
                '    along with this program.  If not, see <http://www.gnu.org/licenses/>.\n']);
            
            %fprintf(1,'     PROFOR Toolbox root: <a href="file://%s">%s</a>.\n',pf.proforRoot,pf.proforRoot);
            
            matlabVersion=sscanf(version(),'%g',3);
            if matlabVersion(1)< 7.9 && matlabVersion(3)< 0.52
                fprintf(1,'     \n');
                fprintf(1,'     Warning: This version of the Profor Toolbox is not fully compatible with your older version of Matlab.\n');
                fprintf(1,'     We recommend that you upgrade Matlab to %s or higher.\n',pf.compatibility);
                fprintf(1,'     \n');
            else
                fprintf(1,'     \n');
            end
        end
    end
end
