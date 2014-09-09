function ecaldlg_update_order(handles)

linear = get(handles.linear, 'Value') == get(handles.linear, 'Max');
if linear
%     set(handles.linear, 'Value', get(handles.linear, 'Max'));
%     set(handles.linear, 'String', 'Linear');
    set(handles.ecaleqn, 'String', 'E = E0 + E1ch');
else
%     set(handles.linear, 'Value', get(handles.linear, 'Min'));
%     set(handles.linear, 'String', 'Quadratic');
    set(handles.ecaleqn, 'String', 'E = E0  +  E1ch + E2ch^2');
end
