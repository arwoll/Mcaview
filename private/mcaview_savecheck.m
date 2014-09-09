function [handles, abort_flag] = mcaview_savecheck(handles)

abort_flag = 0;
if ~isempty(handles.scandata)
    save_first = questdlg('Save current data & profiles before opening new scan?', ...
        'Save Work?', 'yes', 'no','cancel','yes');
    switch save_first
        case 'yes'
            handles = mcaview_save_to_mat(handles);
        case 'cancel'
            abort_flag = 1;
            return
    end
end