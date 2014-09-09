% mcaview colors that look OK over blue and over white:
% green red cyan magenta yellow orange
% colors = [1 0 0; 0 1 0; 0 1 1; 1 0 1; 1 1 0; 1 .4 0];
% default colors
%colors = get(gca, 'ColorOrder');
% colors assuming gray contrast in image.
colors = [0 0 0; 1 0 0; 0 0 1; 0 .7 0; 1 0 1; .76 .53 .17];
ncolors = size(colors, 1);

figpos = [6 349 1032 408];
xpos = [.12  .8];
ypos = [.12 .8];
% 
%     figpos = [6 72 518 685];
%     xpos = [.13 .775];
%     ypos = [.51 .11 .39];


%% Per plot individualization

% pars.dmin = 0; 
% pars.dmax = 0.2;
% pars.emin = 1;
% pars.emax = 17;
% pars.roi_select = [1 2 3 4];
% pars.text = 'teniers5\_34';
% if exist('scandata', 'var') == 1
%     rois = scandata.roi([pars.roi_select]);
%     pars.rois = rois;
% end
%rois = scandata.roi([pars.roi_select]);
%pars.binsize = [1 1 1 1];
%load teniers5_22_plotpars.mat
rois = pars.rois;
%rois = scandata.roi([pars.roi_select]);


% Data and rois are inside a scandata structure.
% Initialize eroi, droi for display, other vars
eroi = find(scandata.energy>pars.emin, 1):find(scandata.energy>pars.emax, 1);
droi = find(scandata.depth > pars.dmin, 1): (find(scandata.depth > pars.dmax, 1) -1); % length(scandata.depth);
dra = scandata.depth(droi);
era = scandata.energy(eroi);
%depth_rois = find(strcmp({scandata.roi.type}, 'depth'));
%rois = scandata.roi(depth_rois);

ebmode = 0;
logmode = 0;
% 4_14
% rois = rois([1 3 4 5 6]);
% 4_12
%rois = scandata.roi([pars.roi_select]);
roi_ind = pars.roi_select;


%% Make image figure
figure(6);
msize = 4;
lw = 2;
% set(gcf, 'Position', figpos);

reset(gca); cla;
hold on
binsize = pars.binsize;
for k = 1:length(roi_ind)
    r = roi_ind(k);
    x = rois(r).x; y = rois(r).y;
    x = x-x(1);
    if binsize(r) > 1
        x = bindata(x, binsize(r)); y = bindata(y,binsize(r));
    end
    mxy = max(y);
    lc = colors(mod(k-1, ncolors)+1,:);
    if ebmode
        errorbar(x*1000, y/mxy, sqrt(y)/mxy, 'o-','LineWidth', lw, ...
            'MarkerSize', msize, 'Color', lc, ...
            'MarkerFaceColor', lc);
    else
        plot(x*1000, y/mxy, 'o-','LineWidth', lw, ...
            'Color', lc, ...
            'MarkerSize', msize,'MarkerFaceColor', lc);
    end
end
axis([dra(1)*1000 dra(end)*1000 0 1.1]);
%text(0.91, -0.09, 0, pars.text, 'Units', 'Normalized');

set(gca, 'Position', [xpos(1) ypos(1) xpos(2) ypos(2)]);
set(gca, 'XTick', [0:25:ceil(dra(end)*1000)]);
if logmode
    set(gca, 'Yscale', 'log');
else
    set(gca, 'Yscale', 'lin');
end

xlabel 'Depth (\mum)'
ylabel 'Intensity (normalized)'
leg_text = {};
for k = 1:length(roi_ind)
    r = roi_ind(k);
    mxy = max(rois(r).y);
    if any(strcmp(rois(r).sym, {'Pb', 'Hg'}))
        label = 'L\alpha';
%        leg_text{k} = [rois(k).sym ' L\alpha \div ' num2str(round(mxy)) ''];
    else
        label = 'K\alpha';
%        leg_text{k} = [rois(k).sym ' K\alpha \div ' num2str(round(mxy)) ''];
    end
    %leg_text{k} = [rois(r).sym ' ' label ' \div ' num2str(round(mxy)) ''];
    leg_text{k} = [rois(r).sym ' ' label];
end
legend(leg_text);
%grid on