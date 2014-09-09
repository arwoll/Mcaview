function peaks = find_peak_locations(x, y, mode)

peaks = [];
rising = 0;
curr = y(1);

if nargin == 2
    mode = 'der';
end

switch mode
    case 'direct'
        for k = 2:length(newy)
            if y(k)>= curr
                rising = 1;
            elseif rising
                peaks(end+1).x = x(k-1);
                peaks(end).y = y(k-1);
                peaks(end).index = k-1;
                rising = 0;
            end
            curr = y(k);
        end
    case 'der'
        dy = zeros([1 length(y)-1]);
        for k=1:length(dy)
            dy(k) = y(k+1)-y(k); 
        end
        dy = abs(dy);
        falling = 0;
        curr = dy(1);
        for k = 2:length(dy)
            if dy(k) <= curr
                falling = 1;
            elseif falling
                peaks(end+1).x = x(k);
                peaks(end).y = y(k);
                peaks(end).index = k;
                falling = 0;
            end
            curr = dy(k);
        end
end

%Find two largest peaks and arrange acccording to left/right.
[p, ind] = sort([peaks.y], 'descend');
peaks = peaks(ind);