function export_to_spe(filename, scandata, spectrum)

% Check scandata -- does it have mcadata field?

% Follow file use standard of other outputs -- query for over-write here or
% elsewhere?

dim1 = size(scandata.mcadata,1);
dim2 = size(scandata.mcadata,2);

if spectrum > dim2
    fprintf('spectrum %d is too big, data has only %d spectra\n', spectrum, dim2);
    exit
end

f=fopen(filename, 'wt');
fprintf(f, '$SPEC_ID:\n');
fprintf(f, '%s scan %d\n', scandata.mcafile, spectrum);
fprintf(f, '$MEAS_TIM:\n');
fprintf(f, '%d \t %d\n', scandata.spec.cttime(1), scandata.spec.cttime(1));
fprintf(f, '$DATA:\n');
fprintf(f, '\t0 \t%d\n', dim1-1);
k = 1;
while k < dim1
    fprintf(f, '%d\t', scandata.mcadata(k,spectrum));
    if mod(k, 10) == 0
        fprintf(f, '\n');
    end
    k = k+1;
end

fclose(f);
fprintf('Wrote %d elements to file %s\n', ...
    dim1, filename);
