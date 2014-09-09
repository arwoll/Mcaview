function [scanline, varargout] = find_scan(specfile, scan)
% [scanline, varargout] = find_scan(specfile, scan)
% Assumes specfile is alredy open. Makes no noise if the scan is not found.
%
% if present, varargout should have two elements. They are the file
% position of the scan and motor position lines, respectively.
if nargout > 1
    varargout = {-1, -1};
end
while 1
    [scanline, index, mark] = find_line(specfile, {'#S', '#O0'});
    if ~ischar(scanline)
        break
    end
    if nargout > 1 
        varargout{index} = mark;
        if index == 2
            continue
        end
    end

    [S, scanline] = strtok(scanline);
    if strcmp(S, sprintf('%d', scan))
        %scan_found = 1;
        scanline = scanline(find(scanline~=' ',1):end);
        break
    end
end