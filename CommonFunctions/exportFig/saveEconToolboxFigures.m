function saveEconToolboxFigures(fileName,obj)
% Short common saving function for figures produced by the EconToolbox.
% Used export_fig package
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%
% fileName = string with partial or full path name (inlcuding figure name)
% for figure. Do NOT include file extension. 
%
% obj = object of Report class (or subclass). Contains information to be
% used by export_fig
%
% Usage:
% 
% saveEconToolboxFigures(fileName,obj)
%
% Note: Function saves current gcf
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


% generate input string for export_fig function
contentForExportFig=['''' fileName '''',...
    ',''-' obj.figureFormat.x{:} ''''];
if obj.transparentFigures
    contentForExportFig=[contentForExportFig,...
        ',''-transparent'''];
    set(gca,'color','none');
end;
if isprop(obj,'renderer')
    contentForExportFig=[contentForExportFig,...
          ',''-' obj.renderer.x{:} ''''];
else
    renderer='opengl'; % zbuffer opengl  painters
    contentForExportFig=[contentForExportFig,...
          ',''-' renderer ''''];    
end;
if isprop(obj,'resolution')
    contentForExportFig=[contentForExportFig,...
          ',''-' obj.resolution.x{:} ''''];    
else
    resolution='r1000';
    contentForExportFig=[contentForExportFig,...
          ',''-' resolution ''''];        
end;
if isprop(obj,'colorspace')
    contentForExportFig=[contentForExportFig,...
          ',''-' obj.colorspace.x{:} ''''];    
else
    colorspace='RGB'; %CMYK
    contentForExportFig=[contentForExportFig,...
          ',''-' colorspace ''''];        
end;


% No image compression:
%   -q<val> - option to vary bitmap image quality (in pdf, eps and jpg
%             files only).  Larger val, in the range 0-100, gives higher
%             quality/lower compression. val > 100 gives lossless
%             compression. Default: '-q95' for jpg, ghostscript prepress
%             default for pdf & eps. Note: lossless compression can
%             sometimes give a smaller file size than the default lossy
%             compression, depending on the type of images.
qval='q101';
contentForExportFig=[contentForExportFig,...
    ',''-' qval ''''];        

funcName='export_fig';
% Use export_fig and eval to save the figure
eval([funcName '(' contentForExportFig ')']);