function handles = ecaldlg_updatelist(handles)
% Updates the list of channel/energy pairs in handles.calpairs. This is needed whenever the

global LISTFORMAT EFORMAT

list = '';
for k = 1:length(handles.channels);
    list{k} = sprintf(LISTFORMAT, handles.channels(k), handles.energies(k));
end
set(handles.calpairs, 'String', list);
set(handles.calpairs, 'Value', 1);

selection = get(handles.calpairs, 'Value');
if ~isempty(handles.channels)
    set(handles.channel, 'String', num2str(handles.channels(selection)));
    set(handles.energy, 'String', num2str(handles.energies(selection)));
end

set(handles.currentecal, 'String', ['|' num2str(handles.ecal, ...
    EFORMAT)]);

