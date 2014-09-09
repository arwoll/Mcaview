function handles = mcaview_update_energy(handles)
% function mcaview_update_energy(handles) updates all relevant fields in the
% gui to the new values in handles, e.g. handles.ecal, handles.roi_index
% (when changing rois), and
% handles.scandata.roi(handles.current_roi).state. It also handles
% visibility changes of uicontrols.  It has an output argument since, if
% the user is opening a new file, then handles.page must be updated to
% reflect the values now in var2page, var3page. handles.page, in turn, is
% an important userdata variable that must be correct for plotting to
% work...


set(handles.ecal_b, 'String', num2str(handles.ecal(1), 2));
set(handles.ecal_m, 'String', num2str(handles.ecal(2), 4));
if length(handles.ecal) == 3
    set(handles.ecal_sq, 'String', num2str(handles.ecal(3), 4));
else
    set(handles.ecal_sq, 'String', '0');
end

if ~isfield(handles.scandata, 'channels')
    return
end
    
handles.scandata.ecal = handles.ecal;
handles.scandata.energy = channel2energy(handles.scandata.channels, handles.ecal);

for k = 1:handles.n_rois
    ch_com = handles.scandata.roi(k).ch_com;
    ch_fwhm = handles.scandata.roi(k).ch_fwhm;
    handles.scandata.roi(k).e_com = channel2energy(ch_com, handles.ecal);
    handles.scandata.roi(k).e_fwhm = channel2energy(ch_com + ch_fwhm/2.0, handles.scandata.ecal)-...
        channel2energy(ch_com - ch_fwhm/2.0, handles.scandata.ecal);
    if strcmp(handles.scandata.roi(k).type, 'energy')
        if length(handles.scandata.roi(k).x) ~= length(handles.scandata.roi(k).e_roi)
            handles.scandata.roi(k).x = channel2energy(handles.scandata.channels, handles.ecal);
        else
            handles.scandata.roi(k).x = channel2energy(handles.scandata.roi(k).e_roi, handles.ecal);
        end
    end
end
