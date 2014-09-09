function mcaview_plot_profile(handles)
% function mcaview_plot_profile(handles) Plots all of the profiles in
% handles.profiles.  Doesn't pay attention to hold, but only scale and
% norm.  The disposition of the hold toggle button in the GUI affects how
% many profiles are allowed.  It also prints a legend, using the numerical
% values in handles.profile.e_com.

axes(handles.profile);
p = get(gca, 'Position');
cla reset;

if handles.roi_index == 0 || ~isfield(handles.scandata, 'roi') || isempty(handles.scandata.roi)
    set(gca, 'Position', p);
    return
end

type = handles.PROFILE_NAMES{handles.scandata.roi(handles.roi_index).state.profile_select}; 
if ~any(strcmp(type, {'xy','xz','yz','volume'})) &&  ...
        strcmp(get(handles.profile_sethold, 'String'),'All')
    nprofiles = find(strcmp(type,{handles.scandata.roi.type}));
else
    nprofiles = handles.roi_index;  
end

profiles = handles.scandata.roi(nprofiles);

norm = strcmp(get(handles.profile_setnorm, 'String'),'on');

logscale = strcmp(get(handles.profile_setlog, 'String'),'Log');
if logscale
    loglin = 'log';
else
    loglin = 'lin';
end

ncolors = size(handles.colors, 1);

switch type
    case handles.PROFILE_NAMES(1:2) %energy/scan profile
        labels = cellstr(num2str([profiles.e_com]', 4)); % 4 digit precision
        fwhm = cellstr(num2str([profiles.fwhm]', 4));
        %labels = strcat('E=',labels, ' : \Delta=', fwhm);
        % for k = 1:length(labels)
        %     labels{k} = [labels{k} '/' num2str(profiles(k).fwhm)];
        % end

        %load elamdb
        elamdb=handles.elamdb;
        %%%%%%%%%%%%%%%%%%%%%%%%% Make the plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        plot_chan = 0;
        rel = 0;
        if strcmp(type, handles.PROFILE_NAMES{1})
            if get(handles.ecalmode, 'Value') == get(handles.ecalmode, 'Max')
                xlabel 'Energy (keV)';
            else
                xlabel 'Channel';
                plot_chan = 1;
            end
            fenergy = cell(length(profiles));
            fintensity = cell(length(profiles));
        else
            rel = strcmp(get(handles.depth_abs, 'String'), 'rel');
            xlabel([handles.scandata.spec.mot1 ' (mm)']);
        end

        hold on
        for k=1:length(profiles)
            % Plot each profile in profiles, cycling through the colors
            if norm
                y = profiles(k).y/max(profiles(k).y);
            else
                y = profiles(k).y;
            end
            if plot_chan
                x = profiles(k).e_roi;
            else
                x = profiles(k).x - rel*profiles(1).x(1);
            end
            if handles.roi_index == nprofiles(k)
                lw = 3;
            else
                lw = 0.5;
            end

            %get fluorescence
            if strcmp(type, handles.PROFILE_NAMES{1})
                if (~isempty(profiles(k).sym))
                    [fe, fi] = get_fluorescence(elamdb.n.(profiles(k).sym), ...
                        handles.scandata.energy(end), elamdb.ele);
                    %fenergy{k} = num2cell(fe);
                    %fintensity{k} = num2cell(fi);
                else
                    % fenergy{k} = num2cell([profiles(k).e_com profiles(k).e_com
                    % profiles(k).e_com profiles(k).e_com profiles(k).e_com]);
                    % fintensity{k} = num2cell([0 0 0 0 0]);
                end
            end
            plot(x, y, 'LineWidth', lw, ...
                'Color', handles.colors(mod(nprofiles(k)-1, ncolors)+1,:));
            % plot fluorescence lines - a = maxy, b = maxy/8 height
            if(~isempty(profiles(k).sym) && strcmp(type, handles.PROFILE_NAMES{1}))
                te = fe;
                ti = fi;

                %te = fenergy{k};
                %ti = fintensity{k};
                if (elamdb.n.(profiles(k).sym) > elamdb.n.Nb) % L lines
                    % alpha = (te{10} + te{11})/2;
                    % beta = (te{2} + te{6})/2;
                    alpha = sum(te(10:11).*ti(10:11))/sum(ti(10:11)); %te{10} + te{11})/2;
                    beta = sum(te([2 6]).*ti([2 6]))/sum(ti([2 6])); % (te{2} + te{6})/2;
                    plot([alpha alpha],[min(y) max(y)],'Color', ...
                        handles.colors(mod(nprofiles(k)-1, ncolors)+1,:))
                    plot([beta beta],[min(y) max(y)/8],'Color', ...
                        handles.colors(mod(nprofiles(k)-1, ncolors)+1,:));
                else % K lines
                    alpha = sum(te([2 3]).*ti([2 3]))/sum(ti([2 3])); %(te{2} + te{3})/2;
                    beta = sum(te([4 5]).*ti([4 5]))/sum(ti([4 5]));
                    plot([alpha alpha],[min(y) max(y)],'Color', ...
                        handles.colors(mod(nprofiles(k)-1, ncolors)+1,:))
                    plot([beta beta],[min(y) max(y)/8],'Color', ...
                        handles.colors(mod(nprofiles(k)-1, ncolors)+1,:));
                end
            end
        end % for loop through profiles
        hold off
        grid on
        set(handles.profile, 'YScale', loglin, 'Color', [0 0 .5625]);

        %%%%%%%%%%%%%%%%%%%%%%%%% Label Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %        legend(labels, 'Location', 'EastOutside', 'FontSize', 10);

        set((get(gca, 'XLabel')), 'FontSize', 16);
        if norm
            ylabel 'Intensity (normalized)';
        else
            ylabel 'Intensity (counts)';
        end
        set((get(gca, 'YLabel')), 'FontSize', 16);
    case handles.PROFILE_NAMES(3:5)%2D
        hold off
        %cla reset
        interp_on = strcmp(get(handles.profile_interp, 'String'),'on');

        z = double(profiles.z);
        mxz = max(z(:));
        if logscale
            z = log(z+1);
        end
        if norm
            % If norm is checked, normalize by scan
            for n = 1:size(z,2)
                z(:,n) = z(:,n)/max(z(:,n));
            end
            mnz = 1/mxz; mxz = 1;
        else
            mnz = 1;
        end
        if strcmp(get(handles.depth_abs, 'String'), 'rel')
            for j = 1:size(profiles.x,2);
                profiles.x(:,j) =  profiles.x(:,j) - profiles.x(1, j);
            end
        end
        surf(profiles.y, profiles.x, z, 'LineStyle','none');
        axis tight; view(0, -90);
        if interp_on shading interp; end
        % end
        h = colorbar;
        if logscale
            mxz = log10(mxz);
            mnz = log10(mnz);
            upper = mxz-mod(mxz, 1);
            lower = mnz-mod(mnz, 1) + 1;
            ytick = lower:upper;
            for k = 1:length(ytick)
                yticklabel{k} = sprintf('%g', 10^ytick(k));
            end
            set(h, 'ytick', log(10.^ytick));
            set(h, 'yticklabel', yticklabel);
        end
        switch type % 2Ds
            case handles.PROFILE_NAMES{3}
                ylabel([handles.scandata.spec.mot1 ' (mm)']);
                xlabel([handles.scandata.spec.mot2 ' (mm)']);
            case handles.PROFILE_NAMES{4}
                ylabel([handles.scandata.spec.mot1 ' (mm)']);
                xlabel([handles.scandata.spec.mot3 ' (mm)']);
            case handles.PROFILE_NAMES{5}
                ylabel([handles.scandata.spec.mot2 ' (mm)']);
                xlabel([handles.scandata.spec.mot3 ' (mm)']);
        end
    case handles.PROFILE_NAMES(6) %volume
        hold off
        z = permute(profiles.x,[2 3 1]);
        y = permute(profiles.y,[2 3 1]);
        x = permute(profiles.z, [2 3 1]);
        v = double(permute(profiles.v, [2 3 1]));
        if logscale
            v = log(v+1);
        end
        mxv = max(v(:));
        %        isosurface(x,y, z, v, mxv/2); 
        var2page = str2double(get(handles.var2disp,'String'));
        var3page = str2double(get(handles.var3disp,'String'));
        slice(x,y, z,v, var3page, var2page,max(z(1,1,:)));
        axis tight;view([1,1,-1]);
        set(gca, 'CameraUpVector', [1,1,-1]); 
end
set(gca, 'Position', p);
