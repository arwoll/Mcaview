function [e_roi, d_roi, plot_roi] = mcaview_getroi(handles)
% function [e_roi, d_roi, plot_roi] = mcaview_getroi(handles)
%
% Returns the indices of depth and energy variables corresponding to a
% drawn rectangle in mca_scanplot.  Also returns (version 0.94) returns the
% extent of the rectangle in the units of the image for the purpose of
% redrawing the ROI region...
%
% In this version I swapped the order of e and d to correspond to the
% convention of x preceding y, since energy is plotted on the x-axis.

rect = aw_getrect(handles.mca_scanplot);

d_roi = 1; e_roi = 1; plot_roi = [];

if rect(3) == 0 || rect(4) == 0
    return
end

d=handles.scandata.depth;
if get(handles.ecalmode, 'Value') == 1
    e=handles.scandata.energy;
else
    e=handles.scandata.channels;
end
% Rect is returning with plot units (energy, distance) which we must
% convert to pixels

e_roi = find( (e>=rect(1)) .* (e<=(rect(1)+rect(3))) );
d_roi = find( (d>=rect(2)) .* (d<=(rect(2)+rect(4))) );

plot_roi = [e_roi(1) e_roi(end) d_roi(1) d_roi(end)];
