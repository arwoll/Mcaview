function [d_roi, e_roi] = mcaview_getroi(handles)
% Apparently there are instances where the interactive features of the
% figure are not properly restored. This might have something to do with
% ButtonDownFcn... Alternatively getrect may be called recursively by
% mistake..

rect = getrect(handles.mca_scanplot);

d_roi = 1; e_roi = 1;

if rect(3) == 0 || rect(4) == 0
    return
end

d=handles.scandata.depth;
e=handles.scandata.energy;

% Rect is returning with plot units (energy, distance) which we must
% convert to pixels

% Would be nice to make the following work -- to show all working rois...
% es = [rect(1) rect(1) rect(1)+rect(3) rect(1)+ rect(3) rect(1)];
% ds = [rect(2) rect(2)+rect(4) rect(2)+rect(4) rect(2) rect(2)];
% 
% axes(handles.mca_scanplot);
% line(es, ds, 'color', 'w', 'LineWidth', 1, 'LineStyle', '-');

e_roi = find( (e>rect(1)) .* (e<(rect(1)+rect(3))) );
d_roi = find( (d>rect(2)) .* (d<(rect(2)+rect(4))) );