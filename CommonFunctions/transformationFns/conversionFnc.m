function [datesOut, converted] = conversionFnc(dates, dataF, fromFreq, toFreq, conversion)
% conversionFnc - Convert frequency of variables
%
% Input:
%
% dates = vector (t x 1) with CSdates with original freq
%
% fromFreq = string with original frequency
%
% toFreq = string with new frequency
%
% dataF = vector (t x 1) with original data
%
% conversion = string. Method used for conversion
%
% Output:
%
% datesOut = vector (tt x 1) with new CSdate vector
%
% converted = vector (tt x 1) with new data values
%
% Usage:
%
% [datesOut,converted]=conversionFnc(dates,dataF,fromFreq,toFreq,conversion)
%
% Note: To be used together (inside) e.g. Tsdata etc. Therefore no error
% checking in this function (to save time). Assumed that this is done
% outside function
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fromFreq    = convertFreqN(fromFreq);
toFreq      = convertFreqN(toFreq);

datesS      = dates(1, 1);
datesOut    = convertDatesFreq(dates, fromFreq, toFreq);

if (strcmpi(fromFreq,'d') && strcmpi(toFreq,'m'))   || (strcmpi(fromFreq,'b') && strcmpi(toFreq,'m'))
    
    if strcmpi(fromFreq,'b')
        error('Business frequency not implementet yet')
    end;
    converted = day2mth(dataF, datesS, 'method', conversion, 'freq', fromFreq);
    
elseif strcmpi(fromFreq,'d') && strcmpi(toFreq,'q')   
    
    [converted1, dateMat]   = day2mth(dataF, datesS, 'method', conversion,...
                                                            'freq', fromFreq);                        
    converted               = mth2qtr(converted1,'method',conversion,...
                                    'dates', (dateMat(:,1)+dateMat(:,2)./100));                         
    
elseif strcmpi(fromFreq,'d') && strcmpi(toFreq,'a')   
    
    [converted1, dateMat]   = day2mth(dataF,datesS,'method',conversion,...
                                                            'freq',fromFreq);                        
    [converted2, datesCell] = mth2qtr(converted1,'method',conversion,...
                                    'dates', (dateMat(:,1)+dateMat(:,2)./100));                         
    converted               = latQtr2a(converted2, 'method', conversion,...
                                                     'dates', datesCell{:,1});                                                                   
    
elseif strcmpi(fromFreq,'m') && strcmpi(toFreq,'q')   
    
    converted = mth2qtr(dataF, 'method', conversion, 'dates', dates);                
    
elseif strcmpi(fromFreq,'m') && strcmpi(toFreq,'a')   
    
    [converted1, datesCell] = mth2qtr(dataF,'method',conversion,'dates',dates);                
    converted               = latQtr2a(converted1,'method',conversion,...
                                                        'dates',datesCell{:,1});                                           
    
elseif strcmpi(fromFreq,'q') && strcmpi(toFreq,'a')   
    
    converted = latQtr2a(dataF, 'method', conversion, 'dates', dates);                                           
    
end