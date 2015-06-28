function username = whoami()
% Purpose:	Returns the username of the current user.
%			This function is a hack, which requires microsoft Excel to be
%			an application on the computer. The function connects to Excel
%			using the com function actxserver. If Excel is not available
%			you should get an error like: Server creation failed. Invalid
%			ProgID 'excell.application'
try
	h           = actxserver('excel.application');
	username    = h.get('UserName');
catch whoamiError
	username = ''
	warning('Excel unavailable or other error in whoami function.');
end