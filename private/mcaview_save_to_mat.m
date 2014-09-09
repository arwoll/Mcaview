function handles = mcaview_save_to_mat(handles)

if ~isfield(handles.scandata, 'mcafile')
    return
end
datadir = handles.current_path;

if strcmp(handles.mcaformat,  'spec')
    matfile = sprintf('%s_%03d.mat',handles.scandata.specfile, ...
        handles.scandata.spec.scann);
else
    matfile = strrep(handles.scandata.mcafile, '.mca', '.mat');
end
[matfile, path] = uiputfile('*.mat', 'Select Filename', fullfile(datadir,matfile));
if isequal(matfile, 0)
    return
end
%scandata = handles.scandata;
save(fullfile(path, matfile),'-struct','handles','scandata');
handles.scandata_saved = 1;
