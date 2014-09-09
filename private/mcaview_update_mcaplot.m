function handles = mcaview_update_mcaplot(handles)
% function mcaview_update_mcaplot(handles) updates the mcaplot, and also
% various labels in the GUI.  Alternatively, I might re-consture the
% different update functions as different update 'levels'.  The highest
% leverl (update_gui) is almost always followed by the rest, whereas lower
% levels are often used without having to do update_gui....

ecalmode = get(handles.ecalmode, 'Value') == get(handles.ecalmode, 'Max');

if handles.roi_index ~= 0 
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

%page = handles.page;

depth_abs = strcmp(get(handles.depth_abs, 'String'), 'abs');
if strcmp(get(handles.depth_abs, 'Enable'), 'on')
    if depth_abs
        handles.scandata.depth = handles.scandata.spec.var1(:,handles.page);
    else
        handles.scandata.depth = handles.scandata.spec.var1(:,handles.page)- ...
            handles.scandata.spec.var1(1,handles.page);
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
    plotim = single(handles.scandata.mcadata(:, :,handles.page));
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

