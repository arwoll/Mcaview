function [textline, varargout] = find_line(specfile, headstr)
% [textline, [index, file_position]] = find_line(specfile, headstr)
% Searches a textfile <specfile> for a line whos first token
% matches any string in the string or cell array headstr, returning
% the remainder of that line.  If the optional 2nd and third arguments
% are given, also returns the index of the element in headstr which matched and 
% the file position of the line which matched.
%
% The main use of the fancy additions is in find_scan, internal to
% openspec, where we want to find the desired scan, but also flag
% changes in the motor configuration. 
%
% Assumes: specfile is alredy open

if nargout == 3
    varargout{1} = [];
    varargout{2} = [];
end
while 1
    mark = ftell(specfile);
    textline=fgetl(specfile);
    if ~ischar(textline), break, end
    [H, textline] = strtok(textline);
    match = strcmp(H, headstr);
    if any(match)
        if nargout == 3
            varargout{1} = find(match);
            varargout{2} = mark;
        end
        break
    end
end