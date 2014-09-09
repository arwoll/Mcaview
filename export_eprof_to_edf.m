function export_eprof_to_edf(filename, eprof)
% eprof is understood to be an energy-type ROI from scandata... (1D)

% Follow file use standard of other outputs -- query for over-write here or
% elsewhere?

channels = length(eprof.y);
databytes = 2*channels;

f=fopen(filename, 'wt');
fprintf(f, '{\n');
fprintf(f, 'HeaderID = EH:000001:000000:000000 ; \n');
fprintf(f, 'DataType = UnsignedShort ;\n');
fprintf(f, 'ByteOrder = HighByteFirst ;\n');
fprintf(f, 'Dim_1 = %d ;\n', channels);
fprintf(f, 'Dim_2 = %d ;\n', 1);
fprintf(f, 'Size = %d ;\n', databytes);
fprintf(f, 'Title = %s ;\n', 'Energy profile');
fprintf(f, '}\n');

datastart = ftell(f);

fclose(f);
f=fopen(filename,'ab');
fseek(f, 0,1); %Goto End of File
n = fwrite(f, eprof.y, 'uint16');
fclose(f);
fprintf('Wrote %d data bytes to file %s, beginning at byte %d\n', ...
    n, filename, datastart);
