function [scanline, scan_mark, motor_mark] = find_scan(specfile, scan)
% [scanline, scan_mark, motor_mark] = find_scan(specfile, scan)
% Assumes specfile is alredy open. Makes no noise if the scan is not found, but
% returns scanline = -1.  
%
% scan_mark and motor_mark are the file position of the scan and (neareast preceding)
% motor position lines, respectively.
%
% In textscan, the format spec %[^\n] reads all characters other than newline (none
% of which are present since find_line strips them from scanline).
scanline = '';
scan_mark = -1;
motor_mark = -1;
while ischar(scanline)
    [scanline, index, mark] = find_line(specfile, {'#S', '#O0'});
    if index == 2
        motor_mark = mark;
        continue
    else
        scan_mark = mark;
        foo = textscan(scanline, '%d %[^\n]');
        if foo{1} == scan
            scanline = char(foo{2});
            break
        end
    end
end

