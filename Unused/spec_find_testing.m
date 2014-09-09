% load test
f=fopen('teniers6', 'r');

% fseek(f, scan_mark,-1);
% nextline = find_line(f, '#P0');
[scanline, scan_mark, motor_mark] = find_scan_test(f, 7);
scanline
scan_mark
motor_mark
 
%fseek(f, scan_mark, -1);

%fclose(f);