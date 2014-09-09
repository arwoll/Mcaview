function varargout = showplots_export(varargin)
% SHOWPLOTS_EXPORT M-file for showplots_export.fig
%      SHOWPLOTS_EXPORT, by itself, creates a new SHOWPLOTS_EXPORT or raises the existing
%      singleton*.
%
%      H = SHOWPLOTS_EXPORT returns the handle to a new SHOWPLOTS_EXPORT or the handle to
%      the existing singleton*.
%
%      SHOWPLOTS_EXPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHOWPLOTS_EXPORT.M with the given input arguments.
%
%      SHOWPLOTS_EXPORT('Property','Value',...) creates a new SHOWPLOTS_EXPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before showplots_export_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to showplots_export_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help showplots_export

% Last Modified by GUIDE v2.5 15-Mar-2006 09:34:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @showplots_export_OpeningFcn, ...
                   'gui_OutputFcn',  @showplots_export_OutputFcn, ...
                   'gui_LayoutFcn',  @showplots_export_LayoutFcn, ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

%gui_State

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before showplots_export is made visible.
function showplots_export_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to showplots_export (see VARARGIN)

% Choose default command line output for showplots_export
handles.output = hObject;

nvargin = length(varargin);
if nvargin < 3
    errordlg('Oops, showplots must be called with at least three arguments', 'showplots');
end

handles.x = varargin{1};
handles.y = varargin{2};
handles.comp = varargin{3};

if nvargin == 4
    handles.chi = varargin{4};
end        

nplots = size(handles.y, 2);
set(handles.plotselect,'Max', nplots);
set(handles.plotselect,'Min', 1);
minstep = 1/(nplots-1);
set(handles.plotselect,'SliderStep', [minstep minstep*floor(nplots/2)]);
set(handles.plotselect, 'Value', 1);

% Update handles structure
guidata(hObject, handles);

set(handles.showfit, 'FontSize', 18);
%set((get(gca, 'Title')), 'FontSize', 18);
%set((get(gca, 'XLabel')), 'FontSize', 18);
%set((get(gca, 'YLabel')), 'FontSize', 18);


showplots('plotselect_Callback', hObject, eventdata, handles);

% UIWAIT makes showplots_export wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = showplots_export_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function plotselect_Callback(hObject, eventdata, handles)
% hObject    handle to plotselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

axes(handles.showfit)
current = get(handles.plotselect, 'Value');
plot(handles.x, handles.y(:,current), 'bo', handles.x, handles.comp(:, current), 'r-');
a  = axis;
xpos = a(1)+.8*(a(2)-a(1));
ypos = a(3)+.9*(a(4)-a(3));
if isfield(handles, 'chi')
    %title(sprintf('Panel %d, {\\chi}^2 = %g', current, handles.chi(current)));
    text(xpos, ypos, sprintf('Panel %d\n{\\chi}^2 = %6.2g', ...
        current, handles.chi(current)));
end


% --- Executes during object creation, after setting all properties.
function plotselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Creates and returns a handle to the GUI figure. 
function h1 = showplots_export_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end

appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', [], ...
    'taginfo', struct(...
    'figure', 2, ...
    'axes', 2, ...
    'slider', 2), ...
    'override', 0, ...
    'release', 13, ...
    'resize', 'none', ...
    'accessibility', 'callback', ...
    'mfile', [], ...
    'callbacks', [], ...
    'singleton', [], ...
    'syscolorfig', [], ...
    'blocking', 0, ...
    'lastSavedFile', '/Users/woll/Matlab/woll_xrf/mcaview-0.93/showplots_export.m');
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];

h1 = figure(...
'Units','characters',...
'Color',[0.701960784313725 0.701960784313725 0.701960784313725],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'MenuBar','none',...
'Name','showplots',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'Position',[103.8 26.1538461538462 111.6 35.3076923076923],...
'Resize','off',...
'HandleVisibility','callback',...
'Tag','figure1',...
'UserData',[],...
'Behavior',get(0,'defaultfigureBehavior'),...
'Visible','on',...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'showfit';

h2 = axes(...
'Parent',h1,...
'Units','characters',...
'Position',[12.4 7.92307692307692 85.4 23.4615384615385],...
'CameraPosition',[0.5 0.5 9.16025403784439],...
'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
'Color',get(0,'defaultaxesColor'),...
'ColorOrder',get(0,'defaultaxesColorOrder'),...
'FontSize',get(0,'defaultaxesFontSize'),...
'LooseInset',[14.56 3.55384615384615 10.64 2.42307692307692],...
'XColor',get(0,'defaultaxesXColor'),...
'YColor',get(0,'defaultaxesYColor'),...
'ZColor',get(0,'defaultaxesZColor'),...
'Tag','showfit',...
'Behavior',get(0,'defaultaxesBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

h3 = get(h2,'title');

set(h3,...
'Parent',h2,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',14,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[0.5 1.02459016393443 1.00005459937205],...
'Rotation',0,...
'String','',...
'Interpreter','tex',...
'VerticalAlignment','bottom',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey','',...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag','',...
'UserData',[],...
'Behavior',struct(),...
'Visible','on',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'Clipping','off');

h4 = get(h2,'xlabel');

set(h4,...
'Parent',h2,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',14,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[0.497658079625293 -0.0803278688524589 1.00005459937205],...
'Rotation',0,...
'String','',...
'Interpreter','tex',...
'VerticalAlignment','cap',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey','',...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag','',...
'UserData',[],...
'Behavior',struct(),...
'Visible','on',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'Clipping','off');

h5 = get(h2,'ylabel');

set(h5,...
'Parent',h2,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',14,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[-0.0667447306791569 0.49672131147541 1.00005459937205],...
'Rotation',90,...
'String','',...
'Interpreter','tex',...
'VerticalAlignment','bottom',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey','',...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag','',...
'UserData',[],...
'Behavior',struct(),...
'Visible','on',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'Clipping','off');

h6 = get(h2,'zlabel');

set(h6,...
'Parent',h2,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',14,...
'FontWeight','normal',...
'HorizontalAlignment','right',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[-0.146370023419204 1.16229508196721 1.00005459937205],...
'Rotation',0,...
'String','',...
'Interpreter','tex',...
'VerticalAlignment','middle',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey','',...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag','',...
'UserData',[],...
'Behavior',struct(),...
'Visible','off',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'Clipping','off');

appdata = [];
appdata.lastValidTag = 'plotselect';

h7 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.9 0.9 0.9],...
'Callback','showplots_export(''plotselect_Callback'',gcbo,[],guidata(gcbo))',...
'FontSize',10,...
'Position',[22 3.30769230769231 66.2 1.69230769230769],...
'String',{  'Slider' },...
'Style','slider',...
'CreateFcn', {@local_CreateFcn, 'showplots_export(''plotselect_CreateFcn'',gcbo,[],guidata(gcbo))', appdata} ,...
'Tag','plotselect',...
'Behavior',get(0,'defaultuicontrolBehavior'));


hsingleton = h1;


% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   eval(createfcn);
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
                    'gui_Singleton'
                    'gui_OpeningFcn'
                    'gui_OutputFcn'
                    'gui_LayoutFcn'
                    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error('Could not find field %s in the gui_State struct in GUI M-file %s', gui_StateFields{i}, gui_Mfile);        
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % SHOWPLOTS_EXPORT
    % create the GUI
    gui_Create = 1;
elseif isequal(ishandle(varargin{1}), 1) && ispc && iscom(varargin{1}) && isequal(varargin{1},gcbo)
    % SHOWPLOTS_EXPORT(ACTIVEX,...)    
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif ischar(varargin{1}) && numargin>1 && isequal(ishandle(varargin{2}), 1)
    % SHOWPLOTS_EXPORT('CALLBACK',hObject,eventData,handles,...)
    gui_Create = 0;
else
    % SHOWPLOTS_EXPORT(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = 1;
end

if gui_Create == 0
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.
    
    % Do feval on layout code in m-file if it exists
    if ~isempty(gui_State.gui_LayoutFcn)
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);
        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen')
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt);            
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt);            
        end
    end
    
    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    
    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig 
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end
    
    % If user specified 'Visible','off' in p/v pairs, don't make the figure
    % visible.
    gui_MakeVisible = 1;
    for ind=1:2:length(varargin)
        if length(varargin) == ind
            break;
        end
        len1 = min(length('visible'),length(varargin{ind}));
        len2 = min(length('off'),length(varargin{ind+1}));
        if ischar(varargin{ind}) && ischar(varargin{ind+1}) && ...
                strncmpi(varargin{ind},'visible',len1) && len2 > 1
            if strncmpi(varargin{ind+1},'off',len2)
                gui_MakeVisible = 0;
            elseif strncmpi(varargin{ind+1},'on',len2)
                gui_MakeVisible = 1;
            end
        end
    end
    
    % Check for figure param value pairs
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end
        try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end
    
    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});
    
    if ishandle(gui_hFigure)
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
        
        % Make figure visible
        if gui_MakeVisible
            set(gui_hFigure, 'Visible', 'on')
            if gui_Options.singleton 
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        rmappdata(gui_hFigure,'InGUIInitialization');
    end
    
    % If handle visibility is set to 'callback', turn it on until finished with
    % OutputFcn
    if ishandle(gui_hFigure)
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end
    
    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end
    
    if ishandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end    

function gui_hFigure = local_openfig(name, singleton)

% this application data is used to indicate the running mode of a GUIDE
% GUI to distinguish it from the design mode of the GUI in GUIDE.
setappdata(0,'OpenGuiWhenRunning',1);

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
try 
    gui_hFigure = openfig(name, singleton, 'auto');
catch
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
end
rmappdata(0,'OpenGuiWhenRunning');
