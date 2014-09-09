function showplots_update_plot(handles)
axes(handles.showfit)
current = get(handles.plotselect, 'Value');
plot(handles.x, handles.y(:,current), 'bo', handles.x, handles.comp(:, current), 'r-');
a  = axis;
if isfield(handles, 'chi')
    title(sprintf('Panel %d, chi _sq = %g', current, handles.chi(current)));
end
