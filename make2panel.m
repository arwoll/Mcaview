%% Scripts for making figures...
% Data and rois are inside a scandata structure.
% Initialize eroi, droi for display, other vars
eroi = find(scandata.energy>1, 1):find(scandata.energy>17, 1);
droi = 1:length(scandata.depth);
depth_rois = find(strcmp({scandata.roi.type}, 'depth'));
rois = scandata.roi(depth_rois);
% mcaview colors that look OK over blue and over white:
% green red cyan magenta yellow orange
% colors = [1 0 0; 0 1 0; 0 1 1; 1 0 1; 1 1 0; 1 .4 0];
% default colors
%colors = get(gca, 'ColorOrder');
% colors assuming gray contrast in image.
colors = [1 0 0; 0 0 1; 0 .7 0; 1 0 1; .76 .53 .17];
ncolors = size(colors, 1);
xpos = [.13 .775];
ypos = [.51 .11 .39];

%% Per plot individualization
rois = rois([1 3 4 5 6]);
roi_ind = 1:length(rois);

%% Make image figure
figure(5);
subplot(2,1,1);
cla;
% imagesc(scandata.energy(eroi), scandata.depth(droi), ...
%     log(scandata.mcadata(eroi, droi)+1)');
imagesc(scandata.depth(droi),scandata.energy(eroi),  ...
    log(scandata.mcadata(eroi, droi)+1));
set(gca, 'XAxisLocation', 'top');
set(gca, 'Position', [xpos(1) ypos(1) xpos(2) ypos(3)]);
colormap(gray);
for k=roi_ind;
    com = rois(k).e_com;
    es = [com com];
    ds = scandata.depth([droi(1) droi(end)]);
    lw = 0.5;
    lc = colors(mod(roi_ind(k)-1, ncolors)+1,:);
    %line(es, ds, 'color', lc, 'LineWidth', lw, 'LineStyle', '-');
    line(ds, es, 'color', lc, 'LineWidth', lw, 'LineStyle', '-');
end
xlabel 'Depth (mm)'
ylabel 'Energy (keV)'

subplot(2,1,2);
reset(gca); cla; 
hold on
binsize = [2 1 1 1 3];
for k = roi_ind
    x = rois(k).x; y = rois(k).y;
    x = x-x(1);
    if binsize(k) > 1
        x = bindata(x, binsize(k)); y = bindata(y,binsize(k));
    end
    plot(x, y/max(y), '.-','LineWidth', 1.5, ...
        'Color', colors(mod(roi_ind(k)-1, ncolors)+1,:));
end
axis([0 .3 0 1]);
set(gca, 'Position', [xpos(1) ypos(2) xpos(2) ypos(3)]);
xlabel 'Depth (mm)'
ylabel 'Intensity (normalized)'
legend ({'Ca K\alpha', 'Fe K\alpha', 'Cu K\alpha', 'Pb L\alpha', 'Sr K\alpha'});
grid on