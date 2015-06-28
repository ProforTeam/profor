function result = nbX12arima(X,varargin)
% nbX12arima -Performs ARIMA forcasts or seasonal adjustment of data matrix
% (see spec[ification] scripts for the X12-ARIMA program for specifications).   
%
% Usage:
%   result = nbX12arima(X,info) or result = nbX12arima(X,'meth','x11',etc..)
% 
% INPUT:
%   X = input-data. (n x m) where n is the number of observations, and m is
%   the number of variables. The different vaiables can be of different
%   length, eg have NaN's at the end. The program adjust one series at the
%   time.
%
%   arima = structure (or string followed by argument, e.g. 'meth','x11') 
%       with the following fields: 
%       .meth = method. 
%       Either 'arima' or 'x11'. 'arima' will perform arima forecasts with auto 
%       model selection. 'x11' will perform ses. adj. with automatical selection
%       of secifications. Default='x11'.
%
%       .freq = frequency of data (value; eg.g 4 for quarterly) Default=4
%
%       .nfor = number of forecast (only if arima method) Default=4
%
%       .modelName = model name (e.g. Monthly Indicator Model) as string.
%       Default='jasidetdu'
%
%       .sign = level of significance (e.g. 0.95)(only of arima method)
%       Default=0.95
%
%       .path = string. Path for were to store spec file, meta file and output/input
%       Default=[rootDirectory '\CommonFunctions\X12arima']
%
%       .start = number, csDate format (eg 1990.01 for 1990 quarter 1).
%       Start date of observations. Default=1990.01
%
%       .fig = integer. if flag==1, produce figureof output, if flag ==0(default), 
%       not produce figure of output. Figure will be subplots of either
%       actual+forecasts or actual+ses. adj series in each plot. 
%
%       .deleteAuxFiles = logical. If true, auxiliary files that need to be
%       created for x12arima to run will be deleted. Default=true
%
% OUTPUT:
%
%   result = structure with following fields: 
%
%       .arimareport = text summary from the X12ARIMA program 
%
%   If arima.meth='arima':
%       .forecastmatrix = forcasts from arima run (nxmxp, where n=number of 
%       forecasts, m=number of variables and p=mean,lower,upper). Note that
%       all series in X are forecasted with the same number of periods. The
%       forecasts can however be for different periods depending on the
%       unbalancednes of the dataset. 
%
%       .nfor = number of forecasts 
%
%   If arima.meth='x11' 
%       .sesadj = cell structure with ses. adj variables. One cell for each
%       series 
%
%       .sesadj_f = cell structure with ses. factors
%--------------------------------------------------------------------------
%NOTE:	The function automatically writes a specification file and a meta
%		file to a designated path
%--------------------------------------------------------------------------

%% Check whether correct number of input arguments
rootDirectory = proforStartup.pfRoot;

% Defaults
default = {...
    'meth','x11',@(x) any(strcmpi(x,{'x11','arima'})),...
    'freq',4,@(x) isnumeric(x) || ischar(x),...
    'nfor',4,@isnumeric,...
    'modelName','jasidetdu',@ischar,...
    'sign',0.95,@isnumeric,...
    'path',fullfile(rootDirectory,'CommonFunctions','+X12arima'),@ischar,...
    'start',1.1,@isnumeric,...    
    'deleteAuxFiles',true,@islogical,...
    };
    
% Overwrite defautlts id varargin provided
options         = validateInput(default,varargin(1:nargin-1));
% convert frequency to numeric if string
options.freq    = convertFreqS(options.freq);
%% Specify a 'method'

method = options.meth;

switch lower(method)
     case {'arima'}
         met = 1;
     case {'x11'}
         met = 2;
end;

c = size(X,2);    
% Find columns in the data with zeros or negative values. Needs to do this
% to specify either multiplicative or additative ses. adj. spec. 
negativeIndex = find( any(X <= 0) == 1);
% Make spec file(s)
if any(negativeIndex) && met == 2
    addSpec         = 2;
    positiveIndex   = find((~any(X<=0) == 1));
else
    addSpec         = 1;
    positiveIndex   = (1:c);
end;
% loops over variables with positive and negative index. Do this to change
% between aditative and multiplicative ses. adj. 

% Runs arima program 
% saves current directory
ccd = cd; 
for ii = 1:addSpec
    options.modelName = strcat(options.modelName,num2str(ii));
    
    % make correct spes file depending on input    
    status = makeSpecFile(options, met, ii);        
    
    if status ~= 0
        warning([mfilename ':specFile'],'The spec. file did not close successfully');
    end;
    
    % Open text file to write metafile with correct settings
    %eval(['fid=fopen(''',options.path,'\meta',options.modelName,'.dta'',''w'');']);
    fid = fopen(fullfile(options.path,['meta' options.modelName '.dta']),'w');
    if ii == 1
        for i = positiveIndex
              generateDatFile(options, i, fid, X);            
        end;
    else
        for i = negativeIndex
            generateDatFile(options, i, fid, X)            
        end;
    end;
    fprintf(fid,'\n\n');
    status = fclose('all');
    if status ~= 0
        warning([mfilename ':txtFile'],'.txt file did not close successfully');
    end;
    
    % Sets the input string to be read by the system commando below    
    arimaspes = [fullfile(rootDirectory,'CommonFunctions','+X12arima','x12a ') options.modelName ' -d meta' options.modelName];
    
    %% Run ARIMA forecast
    % Setting the directory to temp folder because I want to store my results
    % here.
    cd(options.path);
    eval(['[arima1, arimareport] = system(''',arimaspes,''');']);
    
    if arima1 ~= 0
        warning([mfilename ':statuswarning'],'The series might not be ses. adjusted. See result.arimareport');
    end;
   
    % Arima run report
    result.arimareport{ii,1} = arimareport;
    
end
%% Extract the output into Matlab again
if met == 1
    for k = 1:c
        eval(['[f',int2str(k),'.date,f',int2str(k),'.forc,f',int2str(k),'.lower,f',int2str(k),'.upper]=textread(''inn',int2str(k),'.fct'',''%u%f%f%f'',''headerlines'',2);']);
    end; 
elseif met>1
    for k = 1:c
         if exist(['inn',int2str(k),'.d11'],'file')
             eval(['[junk',int2str(k),',X_ses',int2str(k),']=textread(''inn',int2str(k),'.d11'',''%u%f'',''headerlines'',2);']);
         else
             warning([mfilename ':output'],'D11 table from X12 seasonal adjustment did not exist');
         end;
         if exist(['inn',int2str(k),'.d10'],'file')
             eval(['[junk',int2str(k),',X_ses_f',int2str(k),']=textread(''inn',int2str(k),'.d10'',''%u%f'',''headerlines'',2);']);
         else
             warning([mfilename ':output'],'D10 table from X12 seasonal adjustment did not exist');
         end;
    end;
end;
% Deletes files not needed
if options.deleteAuxFiles
    delete('*.d11','*.d10','*.dat','*.err','*.out','*.fct','*.spc','*.log','*.dta')
end;

% Store ARIMA forecasts
if met == 1
    forecastmatrix = NaN(size(f1.forc, 1), size(X, 2), 3);
    for k = 1:c
        eval(['forecastmatrix(:,k,1)=f',int2str(k),'.forc;']);
        eval(['forecastmatrix(:,k,2)=f',int2str(k),'.lower;']);
        eval(['forecastmatrix(:,k,3)=f',int2str(k),'.upper;']);
    end;
elseif met > 1 
    % NB: results are stored into a cell-structure because the series
    % probably have different length
    sesadjcell      = [];
    sesadjcell_f    = [];
    for k = 1:c        
        if exist(['X_ses',int2str(k)],'var');
            eval(['sesadjcell{k}=X_ses',int2str(k),';']);
        else
            sesadjcell{k} = NaN;
        end;
        if exist(['X_ses_f',int2str(k)],'var');
            eval(['sesadjcell_f{end+1}=X_ses_f',int2str(k),';']);
        else
            sesadjcell_f{k} = NaN;
        end;
    end;
end;

%% Result structure
if met == 1
    % Forecasting matrix (nxmx3 with upper and lower bound p=mean, lower, upper)
    result.forecast = forecastmatrix;
    % number of forecasts made
    result.nfor     = size(forecastmatrix, 1);
elseif met > 1 
    % Ses. adj series
    result.sesadj   = sesadjcell;
    % ses. factors
    result.sesadj_f = sesadjcell_f;
end

%% Restoring previous directory
cd(ccd);

 
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function status = makeSpecFile(arima, met, addSpec)
% PURPOSE: Write spec file for ses. adjustment
% status = 0 if successful and -1 if unsuccessful. 

% Open text file to write spec file with correct settings
eval(['fid=fopen(''',arima.path,'/',arima.modelName,'.spc'',''w'');']);
% Write text into file
fprintf(fid,'\n');
fprintf(fid,'series{\n');
fprintf(fid,'   DECIMALS  = 5 \n');
fprintf(fid,'   PRECISION = 5 \n');
eval(['fprintf(fid,''   title="',arima.modelName,'"\n'');']);
fprintf(fid,'   period=%g\n',arima.freq);
fprintf(fid,'   start=%g\n',arima.start);
fprintf(fid,'}\n');
if met == 1
    
    fprintf(fid,'automdl{\n');
    fprintf(fid,'maxorder=(4 2)\n');
    fprintf(fid,'maxdiff=(2 1)\n');
    fprintf(fid,'acceptdefault=no\n');
    fprintf(fid,'checkmu=yes\n');
    fprintf(fid,'ljungboxlimit=0.99\n');
    fprintf(fid,'mixed=yes\n');
    fprintf(fid,'savelog=automodel\n');
    fprintf(fid,'}\n');
    fprintf(fid,'forecast{\n');
    fprintf(fid,'maxlead=%g\n', arima.nfor);
    fprintf(fid,'maxback=0\n');
    fprintf(fid,'probability=%f\n', arima.sign);
    fprintf(fid,'exclude=0\n');
    fprintf(fid,'save=(forecasts backcasts variances)\n');
    fprintf(fid,'}\n');
    
elseif met == 2

    if addSpec == 2
        fprintf(fid,'x11{mode=add\n');
        fprintf(fid,'save=(seasadj seasonal)}\n');
    else
        fprintf(fid,'x11{save=(seasadj seasonal)}\n');
    end
    
end

status = fclose('all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function generateDatFile(options,i,fid,X)

fprintf(fid,'%s%s%s%s\n', options.path, '\inn', int2str(i),'.dat');
% Store each column of data, taking away NaNs in text files to be read by
% arima program; c=number of columns of data
eval(['tall',int2str(i),'=X(:,i);']);
eval(['tall',int2str(i),'(any(isnan(tall',int2str(i),'),2),:)=[];']);
eval(['save(''',options.path,'\inn',int2str(i),'.dat'',''tall',int2str(i),''',''-ASCII'');']);        



