% Script draw_periodic
%
%
% Uses variables in periodic.mat: peri0, ele (issue load periodic.mat
% before running this script)
%

boxw = 8;
boxh = 3;

hper = figure(5);
set(hper, 'Units', 'characters');
pos = get(hper, 'Position');
set(hper, 'Position', [pos(1) pos(2) boxw*20 boxh*11]);


for k = 1:98
%    draw_sq(peri0(k,[2 1]), 5); 
%    [peri0(k,[2 1]) boxw boxh]

    uicontrol(hper, 'Style', 'togglebutton', 'Units', 'characters','Position', ...
        [(1+peri0(k,2))*boxw (1+peri0(k,1))*boxh boxw boxh],'String', ele(k).sym)
end