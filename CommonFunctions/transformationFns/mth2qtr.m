function [yqtrOut, datesOut] = mth2qtr(ymthIn, varargin)
% mth2qtr - Converts monthly time-series to quarterly averages/sum/end of
% period
%
% Input:
%
%   ymthIn   = monthly time series vector or matrix (nobs x nvar)
%
%   vararing = optional.
%       method = string, followed by, either 'mean' (default), 
%       'endOfPeriod' or 'sum'. 
%   
%       date = string followed by vector with monthly observation dates. cs
%       format, eg. 2001.01 for 2001 quarter month 1. Must be same size as
%       ymthIn
%
% Output: 
%
%   yqtr = quarterly time-series vector or matrix. The length of the new
%   series will be by default: [floor(nobs/3) + 1] in length by nvar
%   columns if the monthly observations exactly maps the quarterly
%   observations. If the monthly observations do not exactly map the
%   quarterly frequency the program will take any reminders as observations
%   for the last quarter. If dates are specified as varargin, you are
%   ensured that the correct months are mapped with the corresponding
%   qaurters. By default (eg without dates), the program assumes that the
%   first observation is the first month of the first quarter!
%
%   datesOut = cell, (1 x nvar) with cs format quarterly dates vectors
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% written by:
% James P. LeSage, Dept of Economics
% University of Toledo
% 2801 W. Bancroft St,
% Toledo, OH 43606
% jpl@jpl.econ.utoledo.edu

% Updated to incorporate possibility to also use end of
% period as a means of converting the data and the stuff ensuring that
% dates are mapped etc. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% default
defaults={'method','mean',@ischar,...
    'dates',[],@isnumeric};
options=validateInput(defaults,varargin(1:nargin-1));

% get some sizes of the input matrix
[pre,nobs,qvar,robs,yqtrOut]=getSizes(options.dates,ymthIn);
% get dates to map new series to output matrix below
if ~isempty(options.dates)
    if size(options.dates,1)~=size(ymthIn,1)
        error('mth2qtr:err','The date vector provided must be same length as input data matrix')
    end;    
    
    dates=convertDatesFreq(options.dates,'m','q');
    yqtrOut=nan(size(dates,1),qvar);
    datesOut=cell(1,qvar);
else
    datesOut=[];
end;

% find any missing values. This is used to accomodate the program to
% possible missing values at begining and end
[minPanel,maxPanel]=minmaxPanel(ymthIn);

for vv=1:qvar
    
    % loop over variables since max and in panel can be different        
    if ~isempty(options.dates)
        yqtr=getQuarterly(options.dates(minPanel(vv):maxPanel(vv)),ymthIn(minPanel(vv):maxPanel(vv),vv),options);
        datesVV=convertDatesFreq(options.dates(minPanel(vv):maxPanel(vv)),'m','q');
            
        st=find(datesVV(1,1)==dates);en=find(datesVV(end,1)==dates);
        
        % Put the yqtr matrix into the ygtrOut matrix, taking into account that
        % there can be nans at the beginning and end
        yqtrOut(st:en,vv)=yqtr;
        datesOut{vv}=datesVV;
    else
        yqtr=getQuarterly([],ymthIn(:,vv),options);
        % Put the yqtr matrix into the ygtrOut matrix, taking into account that
        % there can be nans at the beginning and end
        yqtrOut(:,vv)=yqtr;
    end       
    
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yqtr=getQuarterly(dates,ymth,options)

% get some sizes of the new ymth matrix
[pre,nobs,qvar,robs]=getSizes(dates,ymth);

% Used for computing monthly means etc. below
denom = ones(1,qvar)*3.0;

if ~any(strcmpi(options.method,{'mean','sum','endOfPeriod'}));
    error('mth2qtr:err','The method you have spesified is not supported by this function')
end;

switch robs
    % No reminders after divition; e.g full quarter with information
    case 0
        cnt = 1;
        yqtr = zeros(nobs/3,qvar);
        for i=pre+1:3:nobs-2+pre
            if strcmpi(options.method,'mean')
                yqtr(cnt,:) = (ymth(i,:) + ymth(i+1,:) + ymth(i+2,:))./denom;
            elseif strcmpi(options.method,'sum')
                yqtr(cnt,:) = (ymth(i,:) + ymth(i+1,:) + ymth(i+2,:));
            else
                yqtr(cnt,:) = ymth(i+2,:);
            end;
            cnt = cnt+1;
        end;

    % One reminder after div.; e.g one month of information of last quarter
    case 1
        cnt = 1;
        qobs = floor(nobs/3) + 1;
        yqtr = zeros(qobs,qvar);
        for i=pre+1:3:nobs-2+pre
            if strcmpi(options.method,'mean')
                yqtr(cnt,:) = (ymth(i,:) + ymth(i+1,:) + ymth(i+2,:))./denom;
            elseif strcmpi(options.method,'sum')
                yqtr(cnt,:) = (ymth(i,:) + ymth(i+1,:) + ymth(i+2,:));
            elseif strcmpi(options.method,'endOfPeriod')
                yqtr(cnt,:) = ymth(i+2,:);
            end;
            cnt = cnt+1;
        end;
        yqtr(cnt,:) = ymth(nobs+pre,:);

    % Two reminders after div.; e.g two months of infromation of last
    % quarter
    case 2
        cnt = 1;
        qobs = floor(nobs/3) + 1;
        yqtr = zeros(qobs,qvar);
        for i=pre+1:3:nobs-2+pre
            if strcmpi(options.method,'mean')
                yqtr(cnt,:) = (ymth(i,:) + ymth(i+1,:) + ymth(i+2,:))./denom;
            elseif strcmpi(options.method,'sum')
                yqtr(cnt,:) = (ymth(i,:) + ymth(i+1,:) + ymth(i+2,:));
            elseif strcmpi(options.method,'endOfPeriod')
                yqtr(cnt,:) = ymth(i+2,:);
            end;
            cnt = cnt+1;
        end;
        if strcmpi(options.method,'mean')
            yqtr(cnt,:) = (ymth(nobs-1+pre,:)+ymth(nobs+pre,:))/2;
        elseif strcmpi(options.method,'sum')
            yqtr(cnt,:) = (ymth(nobs-1+pre,:)+ymth(nobs+pre,:));
        elseif strcmpi(options.method,'endOfPeriod')
            yqtr(cnt,:) =  ymth(nobs+pre,:);
        end;
end

if pre~=0
    if strcmpi(options.method,'mean')
        st=sum(ymth(1:pre,:))/pre;
    elseif strcmpi(options.method,'sum')
        st=sum(ymth(1:pre,:));
    elseif strcmpi(options.method,'endOfPeriod')
        st=ymth(pre,:);
    end;    
    yqtr=[st;yqtr];
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pre,nobs,qvar,robs,ygtr]=getSizes(dates,ymth)
% PURPOSE: Get some needed sizes and indexes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% pre = observation to start at, ensure that it is the first motnh in the
% quarter
%
% nobs = number of observations in total - pre
%
% qvar = number of variables
%
% robs = reminders after dividing nobs/3
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the correct starting index based on the date information. If not
% provided, program starts at the first observation
if ~isempty(dates)        
    num=round(rem(dates(1),1)*100);
    if any(num==[2 5 8 11])
        pre=2;
    elseif any(num==[1 4 7 10])
        pre=0;
    else
        pre=1;
    end;    
else
    pre=0;
end;

% Get the correct counter infroamtion. If sample does not match exactly
% quarterly obs., any reminders will be indexed by robs, and added to the
% sample (see different cases...)
[nobs qvar] = size(ymth(pre+1:end,:));
robs = rem(nobs,3);

% Output matrix. Need to use the output from above since this is converted% to guarterly sizes
switch robs
    case 0
        ygtr=nan((nobs/3),qvar);
    case 1
        qobs=floor(nobs/3) + 1;
        ygtr=nan(qobs,qvar);
    case 2
        qobs=floor(nobs/3) + 1;        
        ygtr=nan(qobs,qvar);        
end;