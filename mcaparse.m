function [specfile, scan, extn] = mcaparse(mcafile)
% function [specfile, scan, extn] = mcaparse(mcafile)
% Where mcafile is a string of the form specfile_scannumber.mca, returns
% the parsed specfile string and scan number.  If no underscore is found
% returns NaN for scan and the empty string for specfile
%
% This would benefit from some error checking.  It could use the add_error
% function to inform the calling function what went wrong.

extn = mcafile(end-3:end);                 % Get the last three characeters
underscores = find(mcafile(1:end-4)=='_'); % find gives the indices of '_'s
if ~isempty(underscores)
    scan = str2double(mcafile(underscores(end)+1:end-4)); % get the number..
    specfile = mcafile(1:underscores(end)-1);             % get spec file
else
    scan=NaN;
    specfile='';
end