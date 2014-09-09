function h = draw_lines(axes_handle, E0, elamdb)
% function h = draw_lines(axes_handle, E0, elamdb)
%
% axes_handle: handle to an axes
%
% E0: Incident Energy (in keV)
%
% elamdb: the database of atomic properties. elamdb.ele is the main
% database, and elamdb.n is a simple structure of atomic numbers, e.g.
% elamdb.n.He = 2, etc.
%
% refresh_plot = ['cxfitfig(''cxfitfig_editboxes_Callback'',gcbo,[],guidata(gcbo))'];
% 
% Step 1: Create our main GUI figure, showing the periodic table of the
% elements
boxw = 8;
boxh = 3;

h = figure('Menubar', 'none','Units', 'characters', 'Name','Periodic Table');
pos = get(h, 'Position');
set(h, 'Position', [pos(1) pos(2) boxw*20 boxh*11]);

peri0 = elamdb.periodic_layout;
ele = elamdb.ele;

% What's missing below are the tags associated with each button...
for k = 1:98
    uicontrol(h, 'Style', 'togglebutton', 'Units', 'characters','Position', ...
        [(1+peri0(k,2))*boxw (1+peri0(k,1))*boxh boxw boxh],'String', ele(k).sym)
end

% The command below creates a structure, 'handles' whos fields correspond
% to the tags of all of the uicontrol buttons we just added.
handles = guihandles(h);

% The command below saves the structure above within the 'userdata' of the
% figure, to be accessed later, especially by the callback of each
% button...
guidata(h, handles);