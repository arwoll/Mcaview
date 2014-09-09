function handles = mcaview_update(handles)
% function mcaview_update(handles) updates all relevant fields in the
% gui to the new values in handles. This began as updating plots, but now
% includes updating 1) The energy calibration fields, 2) the snapshot axes,
% 3) the 'scanx' and  'scanz' labels, and 4) The image plot.
%profile on

set(handles.ecal_b, 'String', num2str(handles.ecal(1), 2));
set(handles.ecal_m, 'String', num2str(handles.ecal(2), 4));
if length(handles.ecal) == 3
    set(handles.ecal_sq, 'String', num2str(handles.ecal(3), 4));
else
    set(handles.ecal_sq, 'String', '0');
end

foo = sscanf(get(handles.current_roi_show, 'String'),'%d/%d', 2);
handles.roi_index = foo(1);
handles.n_rois =  foo(2);
ecalmode = get(handles.ecalmode, 'Value') == get(handles.ecalmode, 'Max');
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
    if ecalmode
        set(handles.roi_centroid_label, 'String', 'Energy:');
        set(handles.roi_centroid, 'String', sprintf('%6.2f', ...
            handles.scandata.roi(handles.roi_index).e_com))
    else
        set(handles.roi_centroid_label, 'String', 'Channel:');
        set(handles.roi_centroid, 'String', sprintf('%6.2f', ...
            handles.scandata.roi(handles.roi_index).ch_com));
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
    page = (get(handles.var3page, 'Value')-1) * handles.scandata.spec.size(2) + ...
        get(handles.var2page, 'Value');
else
    page = 1;
end

if strcmp(get(handles.var2pagepanel,'Visible'), 'on')
    set(handles.var2disp,'String', ...
        sprintf('%0.6g', handles.scandata.spec.var2(1,page)));
end

if strcmp(get(handles.var3pagepanel,'Visible'), 'on')
    set(handles.var3disp,'String', ...
        sprintf('%0.6g', handles.scandata.spec.var3(1,page)));
end


depth_abs = strcmp(get(handles.depth_abs, 'String'), 'abs');
if strcmp(get(handles.depth_abs, 'Enable'), 'on')
    if depth_abs
        handles.scandata.depth = handles.scandata.spec.var1(:,page);
    else
        handles.scandata.depth = handles.scandata.spec.var1(:,page)-handles.scandata.spec.var1(1,page);
    end
end

ncolors = size(handles.colors, 1);

if isfield(handles.scandata, 'mcadata')
    low = str2double(get(handles.mca_scanplot_low, 'String'));
    high = str2double(get(handles.mca_scanplot_high, 'String'));
    ra = log([low high]);
    dtcorr_image = strcmp(get(handles.menu_options_dtcorrect_mcaplot, 'Checked'), 'on');
    axes(handles.mca_scanplot);
    if ecalmode 
        eaxis = handles.scandata.energy;
    else
        eaxis = handles.scandata.channels;
    end
    plotim = handles.scandata.mcadata(:, :,page);
    if dtcorr_image 
        for k = 1:length(handles.scandata.depth)
            plotim(:,k) = plotim(:,k)*handles.scandata.dtcorr(k);
        end
    end
    imagesc(eaxis(2:end), handles.scandata.depth, log(plotim(2:end,:)+1)', ra);
    
    profile_strings = get(handles.profile_select, 'String');
    if ecalmode
        xlabel 'Energy (keV)';
        profile_strings{1} = 'I vs. Energy';
    else
        xlabel 'Channel';
        profile_strings{1} =  'I vs. Channel';
    end
    set(handles.profile_select, 'String', profile_strings);
    ylabel(handles.scandata.spec.mot1); %'Depth (mm)';
    
    if handles.n_rois>0
        for k=1:handles.n_rois
            rect = handles.scandata.roi(k).roi_rect;
            if ecalmode
                es = handles.scandata.energy([rect(1) rect(1) rect(2) rect(2) rect(1)]);
            else
                es = [rect(1) rect(1) rect(2) rect(2) rect(1)];
            end
            ds = handles.scandata.depth([rect(3) rect(4) rect(4) rect(3) rect(3)]);
            if k == handles.roi_index
                lw = 3; 
            else
                lw = 0.5;
            end
            lc = handles.colors(mod(k-1, ncolors)+1,:);
            line(es, ds, 'color', lc, 'LineWidth', lw, 'LineStyle', '-');
        end
    end 
end

showimages = strcmp(get(handles.menu_view_images, 'Checked'), 'on');
% Find the separate figure in which we will put the snapshots
imagefig = findobj('Tag', 'snapshot','Type', 'figure');
if showimages && isfield(handles.scandata, 'image') && ...
        length(handles.scandata.image) >= 1
    if length(handles.scandata.image) >= page
        imgn = page;
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

figure(handles.mcaview);
