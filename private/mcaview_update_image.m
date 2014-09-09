function handles = mcaview_update_image(handles)
% function mcaview_update(handles) updates all relevant fields in the
% gui to the new values in handles. This began as updating plots, but now
% includes updating 1) The energy calibration fields, 2) the snapshot axes,
% 3) the 'scanx' and  'scanz' labels, and 4) The image plot.
%profile on

showimages = strcmp(get(handles.menu_view_images, 'Checked'), 'on');
% Find the separate figure in which we will put the snapshots
imagefig = findobj('Tag', 'snapshot','Type', 'figure');
if showimages && isfield(handles.scandata, 'image') && ...
        length(handles.scandata.image) >= 1
    if length(handles.scandata.image) >= handles.page
        imgn = handles.page;
        datadir = handles.current_path;
        if isempty(imagefig)
            guipos = get(handles.mcaview, 'Position');
            
            imagefig = figure('Tag', 'snapshot');
            figpos = get(gcf, 'Position');
            set(gcf, 'Position', [guipos(1)+guipos(3) ...
                guipos(2)+guipos(4)-figpos(4) figpos(3) figpos(4)]);
            h = axes('position', [0 0 1 1]);
            axis_limits = 'normal';
        else
            figure(imagefig);
            figpos = get(gcf, 'Position');
            h = gca;
            axis_limits = axis(h);
        end
        imfile = fullfile(datadir, handles.scandata.image{imgn});
        if exist(imfile, 'file')
            im = imread(fullfile(datadir, handles.scandata.image{imgn}));
            imshow(im, 'InitialMagnification', 'fit');
            aspect = get(h,'PlotBoxAspectRatio');
            figpos(4) = aspect(2)/aspect(1)*figpos(3);
            set(imagefig, 'Position', figpos);
            axis(axis_limits);
            set(h, 'XTickLabel', '');
            set(h, 'YTickLabel', '');
        else
            warndlg(sprintf('Image %s not found, turning image view off',...
                handles.scandata.image{imgn}));
            set(handles.menu_view_images, 'Checked', 'off');
            close(imagefig);
        end
    end
elseif ~isempty(imagefig)
    close(imagefig);
end    

%figure(handles.mcaview);
