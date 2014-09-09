%% Scripts for making figures...
% Data and rois are inside a scandata structure.
% Initialize eroi, droi for display, other vars
dmin = 0; dmax = 0.2;
eroi = find(scandata.energy>1, 1):find(scandata.energy>17, 1);
droi = find(scandata.depth > dmin, 1): (find(scandata.depth > dmax, 1) -1); % length(scandata.depth);
dra = scandata.depth(droi);
era = scandata.energy(eroi);
depth_rois = find(strcmp({scandata.roi.type}, 'depth'));
rois = scandata.roi(depth_rois);

ebmode = 1;

% mcaview colors that look OK over blue and over white:
% green red cyan magenta yellow orange
% colors = [1 0 0; 0 1 0; 0 1 1; 1 0 1; 1 1 0; 1 .4 0];
% default colors
%colors = get(gca, 'ColorOrder');
% colors assuming gray contrast in image.
colors = [1 0 0; 0 0 1; 0 .7 0; 1 0 1; .76 .53 .17];
ncolors = size(colors, 1);

horiz = 0;
if horiz
    figpos = [6 349 1032 408];
    xpos = [.11 .51 .39];
    ypos = [.13 .775];
else
    figpos = [6 72 518 685];
    xpos = [.13 .775];
    ypos = [.51 .11 .39];
end

%% Per plot individualization
% 4_14
% rois = rois([1 3 4 5 6]);
% 4_12
rois = rois([4 3 2]);
roi_ind = 1:length(rois);

%% Make image figure
figure(5);
set(gcf, 'Position', figpos);
if horiz
    subplot(1,2,1);
else
    subplot(2,1,1);
end
cla;
if horiz
    imagesc(era, dra, ...
        log(scandata.mcadata(eroi, droi)+1)');
else
    imagesc(dra, era,  ...
        log(scandata.mcadata(eroi, droi)+1));
end
if ~horiz
    set(gca, 'XAxisLocation', 'top');
end
if horiz
    set(gca, 'Position', [xpos(1) ypos(1) xpos(3) ypos(2)]);
else 
    set(gca, 'Position', [xpos(1) ypos(1) xpos(2) ypos(3)]);
end
colormap(gray);
for k=roi_ind;
    com = rois(k).e_com;
    es = [com com];
    ds = scandata.depth([droi(1) droi(end)]);
    lw = 0.5;
    lc = colors(mod(roi_ind(k)-1, ncolors)+1,:);
    if horiz
        line(es, ds, 'color', lc, 'LineWidth', lw, 'LineStyle', '-');
    else
        line(ds, es, 'color', lc, 'LineWidth', lw, 'LineStyle', '-');
    end
end
if horiz
    ylabel 'Depth (mm)'
    xlabel 'Energy (keV)'
else
    xlabel 'Depth (mm)'
    ylabel 'Energy (keV)'
end

if horiz
    subplot(1,2,2);
else
    subplot(2,1,2);
end
reset(gca); cla;
hold on
binsize = [2 1 1 1 3];
for k = roi_ind
    x = rois(k).x; y = rois(k).y;
    x = x-x(1);
    if binsize(k) > 1
        x = bindata(x, binsize(k)); y = bindata(y,binsize(k));
    end
    if ebmode
        errorbar(x, y/max(y), sqrt(y)/max(y), '.-','LineWidth', 1.5, ...
            'Color', colors(mod(roi_ind(k)-1, ncolors)+1,:));
    else
        plot(x, y/max(y), '.-','LineWidth', 1.5, ...
            'Color', colors(mod(roi_ind(k)-1, ncolors)+1,:));
    end
end
axis([dra(1) dra(end) 0 1]);
if horiz
    set(gca, 'Position', [xpos(2) ypos(1) xpos(3) ypos(2)]);
    set(gca, 'YAxisLocation', 'right');
else 
    set(gca, 'Position', [xpos(1) ypos(2) xpos(2) ypos(3)]);
end
xlabel 'Depth (mm)'
ylabel 'Intensity (normalized)'
legend ({'Ca K\alpha', 'Fe K\alpha', 'Pb L\alpha'});
grid on