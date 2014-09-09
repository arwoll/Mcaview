function export_to_edf(filename, scandata)

% Check scandata -- does it have mcadata field?

% Follow file use standard of other outputs -- query for over-write here or
% elsewhere?

plotim = scandata.mcadata;
for k = 1:length(scandata.depth)
    plotim(:,k) = plotim(:,k)*scandata.dtcorr(k);
end
plotim=uint16(round(plotim));


dim1 = size(plotim,1);
dim2 = size(plotim,2);
databytes = 2*dim1*dim2;

f=fopen(filename, 'wt');
fprintf(f, '{\n');
fprintf(f, 'HeaderID = EH:000001:000000:000000 ; \n');
fprintf(f, 'DataType = UnsignedShort ;\n');
fprintf(f, 'ByteOrder = HighByteFirst ;\n');
fprintf(f, 'Dim_1 = %d ;\n', dim1);
fprintf(f, 'Dim_2 = %d ;\n', dim2);
fprintf(f, 'Size = %d ;\n', databytes);
fprintf(f, 'Title = %s ;\n', scandata.mcafile);
fprintf(f, '}\n');

datastart = ftell(f);

fclose(f);
f=fopen(filename,'ab');
fseek(f, 0,1); %Goto End of File
n = fwrite(f, plotim, 'uint16');
fclose(f);
fprintf('Wrote %d data bytes to file %s, beginning at byte %d\n', ...
    n, filename, datastart);
