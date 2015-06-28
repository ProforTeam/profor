function axis2str(gca, varargin)
% axis2str - Turns axis labels into string so that they get the format you
% want, i.e. easier to control than numerics



% default
defaults = {'format', '%6.3f', @ischar};

options = validateInput(defaults, varargin(1:nargin-1));

set(gca, 'yticklabel', num2str(get(gca,'ytick')', options.format));
%set(gca,'xticklabel',num2str(get(gca,'xtick')),options.format);
