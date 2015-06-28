function [asample, ssample, esample] = adjSample(sample, freq, varargin)
% adjSample  -  Adjust original sample for number of lags and/or number of
%               forecast
%
% USAGE: [asample, ssample, esample] = adjSample(sample, freq)
%        [asample, ssample, esample] = adjSample(sample, freq, 'nlag', 2, 'nfor', 5)
%
% Input:
%
%   sample = string, e.g. '2000.01-2010.01'
%
%   freq = string, e.g. 'q'
%
%   varargin = optional. String followed by argument
%       'nlag',2 = adjusts the sample so that two more observations are
%       added to the sample string at the start of the sample. Default=0
%
%       'nfor',5 = adjusts the sample so that 5 more observations are
%       added to the sample string at the end of the sample. Default=0
%
% Output:
%
%   asample = string. Adjusted sample with nlag and nfor added to the total
%   sample 'length'. If nlag=0 and nfor=0, asample=sample.
%
%   ssample = string. Sample that was added to start of sample (input). If
%   nlag=0, ssample=''
%
%   esample = string. Sample that was added to end of sample (input). If
%   nfor=0, esample=''
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


defaults        ={ ...
    'nlag',     0,  @isnumeric,...
    'nfor',     0,  @isnumeric};
options         = validateInput(defaults, varargin(1 : nargin - 2));

% Convert to number
freq            = convertFreqS( freq );

[startD, endD]  = getDates( sample );

byear           = floor( startD );
eyear           = floor( endD );

% Ensrues that the sample dates generated is long enough
dates           = latttt(byear - ceil(options.nlag / freq), eyear + ...
                    ceil(options.nfor / freq), 1, freq, 'freq', freq);

stOld           = find( startD == dates );
stNew           = stOld - options.nlag;
enOld           = find( endD == dates );
enNew           = enOld + options.nfor;

asample         = [num2str( dates(stNew) ) ' - ' num2str( dates(enNew) )];
if stNew ~= stOld
    ssample     = [num2str( dates(stNew) ) ' - ' num2str( dates(stOld-1) )];
else
    ssample     = '';
end
if enNew ~= enOld
    esample     = [num2str( dates(enOld+1) ) ' - ' num2str( dates(enNew) )];
else
    esample     = '';
end
