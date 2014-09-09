function bk_chan = mcaview_getback(handles)
% function [e_roi, d_roi, plot_roi] = mcaview_getroi(handles)
%
% Returns the indices of depth and energy variables corresponding to a
% drawn rectangle in mca_scanplot.  Also returns (version 0.94) returns the
% extent of the rectangle in the units of the image for the purpose of
% redrawing the ROI region...
%
% In this version I swapped the order of e and d to correspond to the
% convention of x preceding y, since energy is plotted on the x-axis.

rect = getrect(handles.profile);

bk_chan = 0;

if rect(3) == 0 || rect(4) == 0
    return
end

if get(handles.ecalmode, 'Value') == 0
    bk_chan = round(rect(1)):round(rect(1)+rect(3));
else
    e=handles.scandata.energy;
    bk_chan = find( (e>=rect(1)) .* (e<=(rect(1)+rect(3))));
    bk_chan = bk_chan([1 end]);
end
