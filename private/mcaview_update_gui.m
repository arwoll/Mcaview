function handles = mcaview_update_gui(handles)
% function mcaview_update_gui(handles) updates all relevant fields in the
% gui to the new values in handles, e.g. handles.ecal, handles.roi_index
% (when changing rois), and
% handles.scandata.roi(handles.current_roi).state. It also handles
% visibility changes of uicontrols.  It has an output argument since, if
% the user is opening a new file, then handles.page must be updated to
% reflect the values now in var2page, var3page. handles.page, in turn, is
% an important userdata variable that must be correct for plotting to
% work...

handles = mcaview_update_energy(handles);

set(handles.current_roi_show, 'String', sprintf('%d/%d', handles.roi_index, handles.n_rois));

if handles.roi_index ~= 0 
    for k = 1:length(handles.roi_vars)
        handles.(handles.roi_vars{k}) = handles.scandata.roi(handles.roi_index).(handles.roi_vars{k});
    end
    state_tags = fieldnames(handles.roi_state);
    for k = 1:length(state_tags)
        if ~isempty(handles.scandata.roi(handles.roi_index).state.(state_tags{k}))
            set(handles.(state_tags{k}), handles.roi_state.(state_tags{k}), ...
                handles.scandata.roi(handles.roi_index).state.(state_tags{k}));
        end
    end
else
    handles.d_roi = [];
    handles.e_roi = [];
    handles.roi_rect = [];
end

profile_selection = get(handles.profile_select, 'Value');
switch profile_selection
    case {1,2}
        set(handles.profile_interp_tog, 'Enable', 'off');
    case {3,4,5}
        set(handles.profile_interp_tog, 'Enable', 'on');
end

if handles.scandata.spec.dims > 1
    handles.page = (get(handles.var3page, 'Value')-1) * handles.scandata.spec.size(2) + ...
        get(handles.var2page, 'Value');
else
    handles.page = 1;
end

if strcmp(get(handles.var2pagepanel,'Visible'), 'on')
    set(handles.var2disp,'String', ...
        sprintf('%0.6g', handles.scandata.spec.var2(1,handles.page)));
end

if strcmp(get(handles.var3pagepanel,'Visible'), 'on')
    set(handles.var3disp,'String', ...
        sprintf('%0.6g', handles.scandata.spec.var3(1,handles.page)));
end
