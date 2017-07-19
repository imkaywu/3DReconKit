function waited = wait_for_existence(name,type,pause_time,max_time)
% 
% Wait until NAME exists (up to MAX_TIME seconds)
% 
% 
%USAGE
%-----
% waited = wait_for_existence(name,type,pause_time,max_time)
% 
% 
%INPUT
%-----
% - NAME      : name of the function, class, directory, file or variable
%   (must be a string)
% - TYPE      : 'builtin', 'class', 'dir', 'file' or 'var'
% - PAUSE_TIME: amount of time to wait in the pauses (in seconds)
% - MAX_TIME  : maximum amount of time to wait (in seconds)
% 
% 
%OUTPUT
%------
% - WAITED: 0 (if NAME exists) or 1 (if NAME does not exist and MAX_TIME
%   has been elapsed)
% 
% 
%EXAMPLE
%-------
% waited = wait_for_existence('new_dir','dir',0.2,2)
% 
% 
% See also EXIST

% Guilherme Coco Beltramini (guicoco@gmail.com)
% 2013-Jan-07, 03:17 pm

if ~ischar(name)
    error('NAME must be a string')
end

switch type
    case 'builtin'
        status = 5;
    case 'class'
        status = 8;
    case 'dir'
        status = 7;
    case 'file'
        status = [2 3 4 6];
    case 'var'
        status = 1;
    otherwise
        error('Unknown TYPE')
end

tmp = 0;
if strcmp(type,'var') % the variable is in the caller workspace
    while evalin('caller',sprintf('exist(''%s'',''var'')~=%d',name,status)) && ...
            tmp<max_time/pause_time
        tmp = tmp + 1;
        pause(pause_time)
    end
else % the workspace doesn't matter
    while all(exist(name,type)~=status) && tmp<max_time/pause_time
        tmp = tmp + 1;
        pause(pause_time)
    end
end

if tmp<max_time/pause_time
    waited = 0;
else
    waited = 1;
end