    for k = 1:nprofiles  
        if k > 1 
            hold on
        end
        z = handles.profiles(k).z;
        if strcmp(loglin, 'log')
            z = log(z+1);
        end
        if norm
            % If norm is checked, normalize by scan
            for n = 1:size(z,2)
                z(:,n) = z(:,n)/max(z(:,n));
            end
        end
        contour(handles.profiles(k).y, handles.profiles(k).x(end:-1:1), z, 5,...
        'Color',colors(mod(k-1, ncolors)+1,:));
    end
    hold off