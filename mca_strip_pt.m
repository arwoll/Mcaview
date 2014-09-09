function [base, num] = mca_strip_pt(mcafile)
% function base = mca_strip_pt(namestr)
% Where mcafile is a filename string WITH EXTENSION ALREADY REMOVED, and
% has the form 'name_pt', returns only 'name_'. An empty string is returned
% if no underscores are found or if the 'pt' is not numeric.
%

underscores = find(mcafile == '_'); % find gives the indices of '_'s
if ~isempty(underscores)
    num = str2double(mcafile(underscores(end)+1:end)); % get the number..
    if ~isnan(num)
        base = mcafile(1:underscores(end)-1);
        return
    end
end

% Makes it hear if no underscores or if pt is non-numeric
base='';