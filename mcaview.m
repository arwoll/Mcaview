function varargout = mcaview(varargin)
% MCAVIEW M-file for mcaview.fig
%      MCAVIEW, by itself, creates a new MCAVIEW or raises the existing
%      singleton*.
%
%      H = MCAVIEW returns the handle to a new MCAVIEW or the handle to
%      the existing singleton*.
%
%      MCAVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MCAVIEW.M with the given input arguments.
%
%      MCAVIEW('Property','Value',...) creates a new MCAVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mcaview_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mcaview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.
%
% There are a number of GUI-aware functions at the end of this file.
% Because they have knowledge of the GUI's objects (buttons, input windows,
% and figures), they are prefixed by the string "mcaview_". 
%
% Requires: all files in the parent directory, in addition to those in
% private/
%
% -Arthur Woll 12/7/04

% Edit the above text to modify the response to help mcaview

% Last Modified by GUIDE v2.5 26-Jul-2007 16:19:29

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           MATLAB SETTINGS AW        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% R14 SP3 -- When the following was set to 1 (default), slider callbacks
% are called twice when one of the arrow buttons is activated. This appears
% to be related to bug 201199, which is supposedly fixed in release 2006a,
% matlab version 7.2...

% The following appears to be a nono for the compiled version...
%if ~isdeployed
%if isunix
%    feature('javafigures',0);
%end
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mcaview_OpeningFcn, ...
                   'gui_OutputFcn',  @mcaview_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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

%% --- Executes just before mcaview is made visible.
function mcaview_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mcaview (see VARARGIN)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stand-alone or within matlab prefs  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isdeployed
    set(handles.menu_export_roi, 'Enable', 'off');
    set(handles.menu_export_scandata, 'Enable', 'off');
    set(handles.menu_export_ecal, 'Enable', 'off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default Energy Calibration Settings %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(handles.ecal_b, 'String', '-0.5');
set(handles.ecal_m, 'String', '0.020166');
set(handles.ecal_sq, 'String', '0');

handles.ecal = [str2double(get(handles.ecal_b,'String')) ...
    str2double(get(handles.ecal_m,'String')) ...
    str2double(get(handles.ecal_sq,'String'))];

set(handles.ecalmode, 'Value', get(handles.ecalmode, 'Max'));

set(handles.motorlist1, 'Enable', 'off');
set(handles.motorpos1, 'Visible', 'off');
set(handles.motorlist2, 'Enable', 'off');
set(handles.motorpos2, 'Visible', 'off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Default MCA panel  Settings    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Default to Energy plot
set(handles.profile_select, 'Value', 1);
handles.current_profile_type = 'energy';

% Default to use relative position for the fast scanning axis
set(handles.depth_abs, 'String', 'rel');
set(handles.depth_abs_toggle, 'Enable', 'off');

% var2page indexes multiple scans, e.g. for mesh scans.
set(handles.var2page, 'Value', 1);
set(handles.var2pagepanel, 'Visible', 'off');

% var3page indexes multiple scans, e.g. for mesh scans.
set(handles.var3page, 'Value', 1);
set(handles.var3pagepanel, 'Visible', 'off');

% slice selector
%set(handles.slice_select, 'Visible', 'off');

set((get(handles.mca_scanplot, 'XLabel')), 'FontSize', 16);
set((get(handles.mca_scanplot, 'YLabel')), 'FontSize', 16);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Default Profile Plot Settings   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Default to linear scale
set(handles.profile_setlog, 'String','Lin');

% Default to background subtraction when making profiles
%set(handles.bksub, 'Value', 1);

% Default dead-time correction on 
set(handles.profile_dtcorr, 'String', 'off');

% Default hold off
set(handles.profile_sethold, 'String', 'Current');

% Default Interpolation setting for 2D profile plots
set(handles.profile_interp, 'String', 'off');
set(handles.profile_interp_tog, 'Enable', 'off');

% Default Normalize setting for profile plots.
set(handles.profile_setnorm, 'String', 'off');

% Profile plot selector is needed only for 2D plots. Otherwise, multiple
% profiles are plotted on the same axis
%set(handles.profile_show, 'Visible', 'off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Default Menu Settings      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(handles.menu_options_showfits, 'Checked', 'on');
set(handles.menu_options_autoupdate, 'Checked', 'on');
set(handles.profile_update, 'Enable', 'off');
set(handles.menu_file_openprior, 'Enable',   'off'); % Only enabled when handles.mcaformat is non-empty

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  User Data Initialization   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Virtual globals
handles.PROFILE_NAMES = {'energy','depth','xy','xz','yz','volume'};
% Save the state of those uicontrols that are used within makeprofile
% This implementation may outsmart myself some day...  In English: the
% FIELDNAMES of handles.roi_state are the uicontrol tags whose properties we
% need.  But for some of the uicontrols, we need the 'String' property, and
% for others we need the 'Value' property.  So the value of
% handles.roi_state.(tag_name) is string 'String' or 'Value' -- the
% property we need to access for that particular uicontrol...
state_tags = {'roi_shape','Value'; ...
    'profile_dtcorr', 'String';...
    'profile_select', 'Value';...
    'norm_to_ctr_toggle', 'Value';...
    'norm_ctr', 'Value';...
    'norm_ref','String';...
    'bksub', 'Value'; ...
    'left_bkgd', 'String';...
    'right_bkgd', 'String';...
    'var2page', 'Value';...
    'var3page','Value';...
    'roi_sym', 'String'};
for k = 1:size(state_tags,1)
    handles.roi_state.(state_tags{k,1}) = state_tags{k,2};
%    handles.roi_state.(state_tags{k,1}).value = get(handles.(state_tags{k,1}), state_tags{k,2});
end
% limited colors that look OK over blue and over white:
% green red cyan magenta yellow orange
handles.colors = [1 0 0; 0 1 0; 0 1 1; 1 0 1; 1 1 0; 1 .4 0];


% Dynamic user data...
handles.n_rois = 0;
handles.roi_index = 0;

handles.roi_vars = {'roi_rect', 'd_roi', 'e_roi'};
handles.roi_rect = [];
handles.d_roi = [];
handles.e_roi = [];
handles.scandata_saved = 1;
handles.loadpath = []; % strcat(pwd);
handles.loadscan = [];
handles.current_path = [];
handles.current_file = [];
handles.current_mcaformat = [];
handles.current_dead = [];
handles.page = 1;

handles.scandata =  [];
handles.mcaformat = '';  % spec, g2, chess1, chess3, chess1_2m: see openmca, openmca_settingsdlg
handles.dead.key = '';

load elamdb elamdb;
handles.elamdb = elamdb;
clear elamdb;

% Choose default command line output for mcaview
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%% --- Outputs from this function are returned to the command line.
function varargout = mcaview_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% --- Executes on button press in openscan.
function openscan_Callback(hObject, eventdata, handles)
% hObject    handle to openscan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = mcaview_importdata(handles);
guidata(hObject,handles);

function mcafile_select_Callback(hObject, eventdata, handles)
% hObject    handle to mcafile_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mcafile_select as text
%        str2double(get(hObject,'String')) returns contents of mcafile_select as a double

%handles.specfile=get(hObject, 'String');
%guidata(hObject,handles);

if ~handles.scandata_saved
    handles = mcaview_savecheck(handles);
end

handles = mcaview_importdata(handles);
guidata(hObject,handles);

%% --- Executes during object creation, after setting all properties.
function mcafile_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mcafile_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'String', 'specfile_scan.mca');

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%% --- Executes during object creation, after setting all properties.
function datadir_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datadir_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'String',strcat(pwd));

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% --------------------------------------------------------------------
function menu_file_openauto_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_openauto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mcaformat = '';
handles.dead = [];
handles.dead.key = '';
mcaview('menu_file_openprior_Callback',hObject, eventdata, handles)

%% --------------------------------------------------------------------
function menu_file_openprior_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_openprior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~handles.scandata_saved
    [handles, abort_flag] = mcaview_savecheck(handles);
    if abort_flag
        return
    end
    guidata(hObject,handles);
end

if isempty(handles.loadpath)
    handles.loadpath = pwd;
end

[file,newpath]=uigetfile({'*','All Files';'*.mca;*.mat','.mca and .mat files';'*.mat','Matlab files only';...
    '*.mca', 'Raw data files only'; '*.dat', 'Spec data files only'}, 'Pick a file', [handles.loadpath filesep]);
if ~isequal(file, 0)
%    set(handles.datadir_select,'String', pathstr);
    handles.loadpath = newpath;
    set(handles.mcafile_select, 'String', file);
    handles = mcaview_importdata(handles);
    guidata(hObject,handles);
else
    set(handles.mcafile_select, 'String', handles.current_file);
end 



%% --------------------------------------------------------------------
function menu_file_loadcal_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_loadcal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datadir = handles.current_path;
%all_in_dir = fullfile(datadir, '*');

[filename, pathstr] = uigetfile('*.cal', ...
    'Choose a filename for this calibration', [handles.current_path filesep]);
if isequal(filename, 0)
    return
end

fullname = fullfile(pathstr, filename);
ecal_present = whos('-file',fullname,'ecal');
if ~isempty(ecal_present)
    load(fullname, '-mat', 'ecal')
    handles.ecal = ecal;
else
    return
end

% if isfield(handles.scandata, 'channels')
%     handles.scandata.ecal = handles.ecal;
%     handles.scandata.energy = channel2energy(handles.scandata.channels, handles.ecal);
% end

handles = mcaview_update_gui(handles); % To update string fields -- also calls update_energy
mcaview_update_mcaplot(handles);
guidata(hObject, handles);


%% --------------------------------------------------------------------
function menu_file_dtsettings_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_dtsettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[mcaformat, dead] = openmca_settingsdlg(handles.mcaformat, handles.dead);

if ~isempty(dead)
    handles.scandata.dead = dead;
    handles.dead = dead;
    [handles.scandata.dtcorr,  handles.scandata.dtdel] = dt_calc(handles.scandata);
end

if strcmp(get(handles.menu_options_autoupdate, 'Checked'), 'on')
    mcaview('profile_update_Callback', hObject, eventdata,handles);
else
    guidata(hObject, handles);
end

function ecal_b_Callback(hObject, eventdata, handles)
% hObject    handle to ecal_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ecal_b as text
%        str2double(get(hObject,'String')) returns contents of ecal_b as a double
handles.ecal(1) = str2double(get(handles.ecal_b, 'String'));

if isfield(handles.scandata, 'channels')
    handles = mcaview_update_energy(handles);
    mcaview_update_mcaplot(handles);
    mcaview_plot_profile(handles);
end

guidata(hObject, handles);

%% --- Executes during object creation, after setting all properties.
function ecal_b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ecal_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% 
% set(hObject,'String', '-0.5');

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function ecal_m_Callback(hObject, eventdata, handles)
% hObject    handle to ecal_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ecal_m as text
%        str2double(get(hObject,'String')) returns contents of ecal_m as a double
handles.ecal(2) = str2double(get(handles.ecal_m, 'String'));
if isfield(handles.scandata, 'channels')
    handles = mcaview_update_energy(handles);
    mcaview_update_mcaplot(handles);
    mcaview_plot_profile(handles);
end
guidata(hObject, handles);

%% --- Executes during object creation, after setting all properties.
function ecal_m_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ecal_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%% Default Energy calibration
% 
% set(hObject,'String', '0.020166');

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%% --- Executes on button press in nextscan.
function nextscan_Callback(hObject, eventdata, handles)
% hObject    handle to nextscan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.scandata)
    return
end

if ~handles.scandata_saved
    handles=mcaview_savecheck(handles);
end

mcafile = get(handles.mcafile_select,'String');
[path, base, extn] = fileparts(mcafile);

handles.loadscan = handles.scandata.spec.scann + 1;

switch handles.scandata.mcaformat
    case 'spec'
        nfile = mcafile;
        % Filename need not change...
    case 'g2'
        warndlg('Sorry, feature not added for this filetype');
        return
    case 'chess1'
        nfile = [handles.scandata.specfile '_' num2str(handles.loadscan) extn];
    case 'chess3'
        nfile = [handles.scandata.specfile '_' sprintf('%03d',handles.loadscan) extn];
    case 'chess_sp'
        [path, base, mca_ind] = fileparts(base);
        nfile = [handles.scandata.specfile '_' num2str(handles.loadscan) '.' mca_ind '.' extn];
end

handles.loadpath = handles.current_path;

set(handles.mcafile_select,'String',nfile);

handles = mcaview_importdata(handles);
handles.loadscan = [];
guidata(hObject,handles);

%% --- Executes on button press in previousscan.
function previousscan_Callback(hObject, eventdata, handles)
% hObject    handle to previousscan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isempty(handles.scandata)
    return
end

if ~handles.scandata_saved
    handles=mcaview_savecheck(handles);
end

mcafile = get(handles.mcafile_select,'String');
[path, base, extn] = fileparts(mcafile);


handles.loadscan = handles.scandata.spec.scann - 1;

switch handles.scandata.mcaformat
    case 'spec'
        nfile = mcafile;
        % Filename need not change...
    case 'g2'
        warndlg('Sorry, feature not added for this filetype');
        return
    case 'chess1'
        nfile = [handles.scandata.specfile '_' num2str(handles.loadscan) extn];
    case 'chess3'
        nfile = [handles.scandata.specfile '_' sprintf('%03d',handles.loadscan) extn];
    case 'chess_sp'
        [path, base, mca_ind] = fileparts(base);
        nfile = [handles.scandata.specfile '_' num2str(handles.loadscan) '.' mca_ind '.' extn];
end

handles.loadpath = handles.current_path;

set(handles.mcafile_select,'String',nfile);

handles = mcaview_importdata(handles);
handles.loadscan = [];
guidata(hObject,handles);

%% --------------------------------------------------------------------
function profile_setlog_tog_Callback(hObject, eventdata, handles)
% hObject    handle to uipanel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.profile_setlog, 'String'), 'Log')
    set(handles.profile_setlog, 'String', 'Lin');
else
    set(handles.profile_setlog,  'String', 'Log');
end
mcaview_plot_profile(handles);

function profile_setnorm_tog_Callback(hObject, eventdata, handles)
% hObject    handle to uipanel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.profile_setnorm, 'String'), 'on')
    set(handles.profile_setnorm, 'String', 'off');
else
    set(handles.profile_setnorm,  'String', 'on');
end
mcaview_plot_profile(handles);

%% --------------------------------------------------------------------
function menu_file_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

confirm_quit = questdlg('Really quit mcaview?', ...
    'Quit?', 'Yes', 'No', 'Yes');
if strcmp(confirm_quit, 'Yes')
    close(handles.mcaview);
end

%% --- Executes on button press in ecalmode.
function ecalmode_Callback(hObject, eventdata, handles)
% hObject    handle to ecalmode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mcaview_update_mcaplot(handles);
mcaview_plot_profile(handles);
    
%% --- Executes on button press in ecalcalc.
function ecalcalc_Callback(hObject, eventdata, handles)
% hObject    handle to ecalcalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

new_ecal = ecaldlg([handles.scandata.roi.ch_com], handles.ecal);

if ~isequal(new_ecal, handles.ecal) % && isfield(handles.scandata, 'channels')
    handles.ecal = new_ecal;
    handles = mcaview_update_energy(handles);
    mcaview_update_mcaplot(handles);
    mcaview_plot_profile(handles);
    guidata(hObject, handles);
end

%% --------------------------------------------------------------------
function menu_file_savetomat_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_savetomat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = mcaview_save_to_mat(handles);
guidata(hObject, handles);

function ecal_sq_Callback(hObject, eventdata, handles)
% hObject    handle to ecal_sq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ecal_sq as text
%        str2double(get(hObject,'String')) returns contents of ecal_sq as a double
handles.ecal(3) = str2double(get(handles.ecal_sq, 'String'));
if isfield(handles.scandata, 'channels')
    handles = mcaview_update_energy(handles);
    mcaview_update_mcaplot(handles);
    mcaview_plot_profile(handles);
end
guidata(hObject, handles);

%% --- Executes during object creation, after setting all properties.
function ecal_sq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ecal_sq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --------------------------------------------------------------------
function menu_export_Callback(hObject, eventdata, handles)
% hObject    handle to menu_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --------------------------------------------------------------------
function menu_export_roi_Callback(hObject, eventdata, handles)
% hObject    handle to menu_menu_export_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.scandata.roi(handles.roi_index))
    assignin('base', 'roi', handles.scandata.roi(handles.roi_index));
end


%% --------------------------------------------------------------------
function menu_export_scandata_Callback(hObject, eventdata, handles)
% hObject    handle to menu_menu_export_scandata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.scandata)
    assignin('base', 'scandata', handles.scandata);
end

%% --------------------------------------------------------------------
function menu_export_ecal_Callback(hObject, eventdata, handles)
% hObject    handle to menu_menu_export_ecal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

assignin('base', 'ecal', handles.ecal);

%% --- Executes on selection change in roi_shape.
function roi_shape_Callback(hObject, eventdata, handles)
% hObject    handle to roi_shape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns roi_shape contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roi_shape
%val = get(hObject, 'Value');

% Note: the following does not produce an error if
% handles.scandata.profiles.(handles.current_profile_type) is empty
if strcmp(get(handles.menu_options_autoupdate, 'Checked'), 'on')
    mcaview('profile_update_Callback', hObject, eventdata,handles);
end


%% --- Executes during object creation, after setting all properties.
function roi_shape_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_shape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%set(hObject,'String', {'Rect', 'Wide', 'Tall'});
%set(hObject,'Value', 1);

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on slider movement.
function var2page_Callback(hObject, eventdata, handles)
% hObject    handle to var2page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
var2 = round(get(hObject, 'Value'));
set(hObject, 'Value', var2);

handles.page = (get(handles.var3page, 'Value')-1) * handles.scandata.spec.size(2) + ...
    get(handles.var2page, 'Value');

if strcmp(get(handles.var2pagepanel,'Visible'), 'on')
    set(handles.var2disp,'String', ...
        sprintf('%0.6g', handles.scandata.spec.var2(1,handles.page)));
end
guidata(hObject, handles);

if handles.n_rois > 0
    type = handles.scandata.roi(handles.roi_index).type;
    switch type
        case handles.PROFILE_NAMES(6)
            mcaview_plot_profile(handles);
        case handles.PROFILE_NAMES(4)
            mcaview('profile_update_Callback', hObject, eventdata,handles);
            handles = guidata(hObject);
        case handles.PROFILE_NAMES([1 2])
            if strcmp(get(handles.profile_sethold, 'String'),'All') && ...
                strcmp(get(handles.menu_options_follow, 'Checked'), 'on')
                nprofiles = find(strcmp(type,{handles.scandata.roi.type}));
                current = handles.roi_index;
                for p = nprofiles
                    handles.roi_index = p;
                    for k = 1:length(handles.roi_vars)
                        handles.(handles.roi_vars{k}) = handles.scandata.roi(p).(handles.roi_vars{k});
                    end
                    handles = mcaview_makeprofile(handles);
                end
                handles.roi_index = current;
            else
                mcaview('profile_update_Callback', hObject, eventdata,handles);
                handles = guidata(hObject);
            end
            mcaview_plot_profile(handles);
        % case handles.PROFILE_NAMES([3 5]) -- do nothing
    end
end

handles = mcaview_update_mcaplot(handles);
guidata(hObject, handles);
mcaview_update_image(handles);

%% --- Executes during object creation, after setting all properties.
function var2page_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var2page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%% --- Executes on button press in _tog.
function profile_sethold_tog_Callback(hObject, eventdata, handles)
% hObject    handle to  (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of 

if strcmp(get(handles.profile_sethold, 'String'), 'All')
    set(handles.profile_sethold, 'String', 'Current');
else
    set(handles.profile_sethold,  'String', 'All');
end
mcaview_plot_profile(handles);

%% --- Executes on selection change in motorlist2.
function motorlist2_Callback(hObject, eventdata, handles)
% hObject    handle to motorlist2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns motorlist2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from motorlist2

mot_sel = get(hObject, 'Value');
set(handles.motorpos2, 'String', ...
    num2str(handles.scandata.spec.motor_positions(mot_sel)));


%% --- Executes during object creation, after setting all properties.
function motorlist2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motorlist2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on selection change in motorlist1.
function motorlist1_Callback(hObject, eventdata, handles)
% hObject    handle to motorlist1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns motorlist1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from motorlist1

mot_sel = get(hObject, 'Value');
set(handles.motorpos1, 'String', ...
    num2str(handles.scandata.spec.motor_positions(mot_sel)));


%% --- Executes during object creation, after setting all properties.
function motorlist1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motorlist1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on button press in profile_interp_tog.
function profile_interp_tog_Callback(hObject, eventdata, handles)
% hObject    handle to profile_interp_tog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of profile_interp_tog

if strcmp(get(handles.profile_interp, 'String'), 'on')
    set(handles.profile_interp, 'String', 'off');
else
    set(handles.profile_interp,  'String', 'on');
end
mcaview_plot_profile(handles);


%% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function mcaview_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to mcaview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

type = get(hObject, 'SelectionType');

position = get(handles.mca_scanplot, 'CurrentPoint');
x = position(1,1);
y = position(1,2);
xlim = get(handles.mca_scanplot, 'Xlim');
ylim = get(handles.mca_scanplot, 'Ylim');

if xlim(1) < x && x < xlim(2) && ylim(1) < y && y < ylim(2) && ...
        strcmp(type,'normal')
    [ei, di, plotrect] = mcaview_getroi(handles);
    if length(di) > 1 || length(ei) > 1
        handles.d_roi = di; handles.e_roi = ei;
        handles.roi_rect = plotrect;
        set(handles.left_bkgd, 'String', sprintf('%d:%d', ei(1),ei(2)));
        set(handles.right_bkgd, 'String', sprintf('%d:%d', ei(end-1),ei(end)));
        handles = mcaview_makeprofile(handles);
        handles = mcaview_update_gui(handles);
        mcaview_update_mcaplot(handles);
        mcaview_plot_profile(handles);
        guidata(hObject, handles);
    end
end


%% --------------------------------------------------------------------
function menu_file_exportedf_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_exportedf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if ~isfield(handles.scandata, 'mcafile')
    return
end
datadir = handles.current_path;

edffile = strrep(handles.scandata.mcafile, '.mca', '.edf');
[edffile, path] = uiputfile('*.edf', 'Select Filename', fullfile(datadir,edffile));
if isequal(edffile, 0)
    return
end
scandata = handles.scandata;
export_to_edf(fullfile(path, edffile),scandata);


%% --- Executes on slider movement.
function var3page_Callback(hObject, eventdata, handles)
% hObject    handle to var3page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
var3 = round(get(hObject, 'Value'));
var2 = get(handles.var2page, 'Value');
n_fast = size(handles.scandata.mcadata, 3);

if var3 == get(handles.var3page, 'Max')    
    n2 = n_fast - (var3-1)*handles.scandata.spec.size(2);
    if n2 == 1
        set(handles.var2page, 'Value', 1);
        set(handles.var2page, 'Enable', 'off');
    else
        if var2 > n2
            set(handles.var2page, 'Value', n2);
        end
        set(handles.var2page,'Max', n2);
    end
else
    n2 = handles.scandata.spec.size(2);
    set(handles.var2page,'Max', n2);
    set(handles.var2page, 'Enable', 'on');
end

set(hObject, 'Value', var3);

handles.page = (get(handles.var3page, 'Value')-1) * handles.scandata.spec.size(2) + ...
    get(handles.var2page, 'Value');

if strcmp(get(handles.var3pagepanel,'Visible'), 'on')
    set(handles.var3disp,'String', ...
        sprintf('%0.6g', handles.scandata.spec.var3(1,handles.page)));
end

guidata(hObject, handles);

if handles.n_rois > 0
    type = handles.scandata.roi(handles.roi_index).type;
    switch type
        case handles.PROFILE_NAMES(6)
            mcaview_plot_profile(handles);
        case handles.PROFILE_NAMES(3)
            mcaview('profile_update_Callback', hObject, eventdata,handles);
            handles = guidata(hObject);
        case handles.PROFILE_NAMES([1 2])
            if strcmp(get(handles.profile_sethold, 'String'),'All') && ...
                strcmp(get(handles.menu_options_follow, 'Checked'), 'on')
                nprofiles = find(strcmp(type,{handles.scandata.roi.type}));
                current = handles.roi_index;
                for p = nprofiles
                    handles.roi_index = p;
                    for k = 1:length(handles.roi_vars)
                        handles.(handles.roi_vars{k}) = handles.scandata.roi(p).(handles.roi_vars{k});
                    end
                    handles = mcaview_makeprofile(handles);
                end
                handles.roi_index = current;
            else
                mcaview('profile_update_Callback', hObject, eventdata,handles);
                handles = guidata(hObject);
            end
            mcaview_plot_profile(handles);
        % case handles.PROFILE_NAMES([4 5]) -- do nothing
    end
end

handles = mcaview_update_mcaplot(handles);
guidata(hObject, handles);
mcaview_update_image(handles);

%% --- Executes during object creation, after setting all properties.
function var3page_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var3page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stat = web(['http://staff.chess.cornell.edu/~woll/Dist/Software/Mcaview/' ...
    'Mcaview_src/mcaview-0.97/Docs/Help/index.html'], '-browser');
if stat 
    errordlg({'Sorry, Could not auto-load page',...
        'please visit http://staff.chess.cornell.edu:~woll/Dist/Docs/mcaview_help.html'});
end

%% --------------------------------------------------------------------
function menu_options_showfits_Callback(hObject, eventdata, handles)
% hObject    handle to menu_options_showfits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'off')
    set(hObject, 'Checked', 'on');
else
    set(hObject, 'Checked', 'off');
end


%% --------------------------------------------------------------------
function menu_view_images_Callback(hObject, eventdata, handles)
% hObject    handle to image_menu_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off');
else
    set(hObject, 'Checked', 'on');
end


%% --------------------------------------------------------------------
function menu_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --------------------------------------------------------------------
function menu_file_openrecent_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_openrecent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --------------------------------------------------------------------
function open_recent_contextmenu_Callback(hObject, eventdata, handles)
% hObject    handle to open_recent_contextmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%% --- Executes on button press in previous_roi.
function previous_roi_Callback(hObject, eventdata, handles)
% hObject    handle to previous_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.n_rois == 0
    return
elseif handles.roi_index > 1
    handles.roi_index = handles.roi_index - 1;
elseif handles.n_rois > 1
    handles.roi_index = handles.n_rois;
end
%set(handles.current_roi_show, 'String', sprintf('%d/%d',new_roi, handles.n_rois));
handles = mcaview_update_gui(handles);
guidata(hObject, handles);

mcaview_update_mcaplot(handles);
mcaview_plot_profile(handles);

%% --- Executes on button press in next_roi.
function next_roi_Callback(hObject, eventdata, handles)
% hObject    handle to next_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.n_rois == 0
    return
elseif handles.roi_index < handles.n_rois
    handles.roi_index = handles.roi_index + 1;
elseif handles.n_rois > 1
    handles.roi_index = 1;
end
%set(handles.current_roi_show, 'String', sprintf('%d/%d',new_roi, handles.n_rois));
handles = mcaview_update_gui(handles);
guidata(hObject, handles);
mcaview_update_mcaplot(handles);
mcaview_plot_profile(handles);

%% --- Executes on selection change in bksub.
function bksub_Callback(hObject, eventdata, handles)
% hObject    handle to bksub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns bksub contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bksub

if any(get(hObject, 'Value') == [3 4])
    set(handles.left_bk_select, 'Enable', 'On');
    set(handles.right_bk_select, 'Enable', 'On');
    set(handles.left_bkgd, 'Enable', 'On');
    set(handles.right_bkgd, 'Enable', 'On');
else
    set(handles.left_bk_select, 'Enable', 'Off');
    set(handles.right_bk_select, 'Enable', 'Off');
    set(handles.left_bkgd, 'Enable', 'Off');
    set(handles.right_bkgd, 'Enable', 'Off');
end
    
if strcmp(get(handles.menu_options_autoupdate, 'Checked'), 'on')
    mcaview('profile_update_Callback', hObject, eventdata,handles);
end
% handles = mcaview_makeprofile(handles);
% guidata(hObject, handles);
% 
% mcaview_plot_profile(handles);

%% --- Executes during object creation, after setting all properties.
function bksub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bksub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on button press in mode_select.
function mode_select_Callback(hObject, eventdata, handles)
% hObject    handle to mode_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.mode, 'String'), 'new')
    set(handles.mode, 'String', 'edit');
else
    set(handles.mode, 'String', 'new');
end

%% --- Executes on button press in norm_to_ctr_toggle.
function norm_to_ctr_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to norm_to_ctr_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of norm_to_ctr_toggle
if strcmp(get(handles.menu_options_autoupdate, 'Checked'), 'on')
    mcaview('profile_update_Callback', hObject, eventdata,handles);
end

%% --- Executes on selection change in norm_ctr.
function norm_ctr_Callback(hObject, eventdata, handles)
% hObject    handle to norm_ctr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns norm_ctr contents as cell array
%        contents{get(hObject,'Value')} returns selected item from norm_ctr
if strcmp(get(handles.menu_options_autoupdate, 'Checked'), 'on')
    mcaview('profile_update_Callback', hObject, eventdata,handles);
end

%% --- Executes during object creation, after setting all properties.
function norm_ctr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to norm_ctr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on button press in dtcorr_toggle.
function dtcorr_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to dtcorr_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.profile_dtcorr, 'String'), 'on')
    set(handles.profile_dtcorr, 'String', 'off');
else
    set(handles.profile_dtcorr, 'String', 'on');
end
if strcmp(get(handles.menu_options_autoupdate, 'Checked'), 'on')
    mcaview('profile_update_Callback', hObject, eventdata,handles);
end

%% --- Executes on button press in clear_roi.
function clear_roi_Callback(hObject, eventdata, handles)
% hObject    handle to clear_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Remove current roi -- 
if handles.n_rois == 0
    return
end

handles.scandata.roi(handles.roi_index) = [];
handles.n_rois = handles.n_rois - 1;
if handles.roi_index > handles.n_rois
    handles.roi_index = handles.n_rois;
end

% The following should end up resembling the commands for next/previous roi
%set(handles.current_roi_show, 'String', sprintf('%d/%d',new_roi, handles.n_rois));
handles = mcaview_update_gui(handles);
guidata(hObject, handles)
mcaview_update_mcaplot(handles);
mcaview_plot_profile(handles);

%% --- Executes on button press in depth_abs_toggle.
function depth_abs_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to depth_abs_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.depth_abs, 'String'), 'abs')
    set(handles.depth_abs, 'String', 'rel');
else
    set(handles.depth_abs, 'String', 'abs');
end
handles = mcaview_update_mcaplot(handles);
guidata(hObject, handles);
mcaview_plot_profile(handles);


%% --- Executes on button press in left_bk_select.
function left_bk_select_Callback(hObject, eventdata, handles)
% hObject    handle to left_bk_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Before the following -- we need the code for selecting bkgd points,
% such as allowing mouse-selection of the bkgd points using, e.g., a
% separate figure... Ditto right_bk_select_Callback

if get(handles.profile_select, 'Value') ~= 1
    return
else
    left_bk = mcaview_getback(handles);
    left_bk(find(left_bk<handles.e_roi(1))) = handles.e_roi(1);
    set(handles.left_bkgd, 'String', sprintf('%d:%d',left_bk(1), left_bk(2)));
end

if strcmp(get(handles.menu_options_autoupdate, 'Checked'), 'on')
    mcaview('profile_update_Callback', hObject, eventdata,handles);
end
%% --- Executes on button press in right_bk_select.
function right_bk_select_Callback(hObject, eventdata, handles)
% hObject    handle to right_bk_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.profile_select, 'Value') ~= 1
    return
else
    right_bk = mcaview_getback(handles);
    right_bk(find(right_bk>handles.e_roi(end))) = handles.e_roi(end);
    set(handles.right_bkgd, 'String', sprintf('%d:%d',right_bk(1), right_bk(end)));
end

if strcmp(get(handles.menu_options_autoupdate, 'Checked'), 'on')
    mcaview('profile_update_Callback', hObject, eventdata,handles);
end


function left_bkgd_Callback(hObject, eventdata, handles)
% hObject    handle to left_bkgd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of left_bkgd as text
%        str2double(get(hObject,'String')) returns contents of left_bkgd as a double
if strcmp(get(handles.menu_options_autoupdate, 'Checked'), 'on')
    mcaview('profile_update_Callback', hObject, eventdata,handles);
end

%% --- Executes during object creation, after setting all properties.
function left_bkgd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to left_bkgd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function right_bkgd_Callback(hObject, eventdata, handles)
% hObject    handle to right_bkgd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of right_bkgd as text
%        str2double(get(hObject,'String')) returns contents of right_bkgd as a double
if strcmp(get(handles.menu_options_autoupdate, 'Checked'), 'on')
    mcaview('profile_update_Callback', hObject, eventdata,handles);
end

%% --- Executes during object creation, after setting all properties.
function right_bkgd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to right_bkgd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --------------------------------------------------------------------
function menu_options_autoupdate_Callback(hObject, eventdata, handles)
% hObject    handle to menu_options_autoupdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off');
    set(handles.profile_update, 'Enable', 'on');
else
    set(hObject, 'Checked', 'on');
    set(handles.profile_update, 'Enable', 'off');
end

%% --------------------------------------------------------------------
function menu_options_Callback(hObject, eventdata, handles)
% hObject    handle to menu_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --- Executes on selection change in profile_select.
function profile_select_Callback(hObject, eventdata, handles)
% hObject    handle to profile_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns profile_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from profile_select

if strcmp(get(handles.menu_options_autoupdate, 'Checked'), 'on')
    mcaview('profile_update_Callback', hObject, eventdata,handles);
end

%% --- Executes during object creation, after setting all properties.
function profile_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to profile_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on button press in copy_roi.
function copy_roi_Callback(hObject, eventdata, handles)
% hObject    handle to copy_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.n_rois == 0
    return
end

handles.n_rois = handles.n_rois+1;
set(handles.current_roi_show, 'String', sprintf('%d/%d',handles.n_rois, handles.n_rois))
handles.scandata.roi(handles.n_rois) = handles.scandata.roi(handles.roi_index);
handles.roi_index = handles.n_rois;
guidata(hObject, handles);


%% --- Executes on button press in profile_update.
function profile_update_Callback(hObject, eventdata, handles)
% hObject    handle to profile_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.roi_index == 0 
    return
end
handles = mcaview_makeprofile(handles);
guidata(hObject, handles);
mcaview_plot_profile(handles);
%figure(handles.mcaview);


%% --- Executes on button press in profile_make_copy.
function profile_make_copy_Callback(hObject, eventdata, handles)
% hObject    handle to profile_make_copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

new_fig = figure;
figpos  = get(gcf, 'Position');
new_axes = copyobj(handles.profile, new_fig);
set(new_axes, 'Units', 'Normalized', 'Position', [.1 .1 .8 .8]);
xl = get(new_axes, 'XLim'); x_extent = abs(xl(2)-xl(1));
yl = get(new_axes, 'YLim'); y_extent = abs(yl(2)-yl(1));
plotratio = y_extent/x_extent;
if plotratio > .1 && plotratio <= 1
    figpos(4) = figpos(3)*plotratio;
    set(new_fig, 'Position', figpos);
elseif plotratio > 1 && plotratio < 10 
    figpos(3) = figpos(4)/plotratio;
    set(new_fig, 'Position', figpos); 
end
title(new_axes, ['Energy = ' get(handles.roi_centroid, 'String')]);


%% --- Executes on button press in mca_make_copy.
function mca_make_copy_Callback(hObject, eventdata, handles)
% hObject    handle to mca_make_copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


new_fig = figure;
new_axes = copyobj(handles.mca_scanplot, new_fig);
set(new_axes, 'Units', 'Normalized', 'Position', [.1 .1 .8 .8]);


%% --------------------------------------------------------------------
function menu_export_image2txt_Callback(hObject, eventdata, handles)
% hObject    handle to menu_export_image2txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles.scandata, 'roi')
    return
end

if ~strcmp(handles.scandata.roi.type, {'xy', 'xz', 'yz'})
    return
else
    roi = handles.scandata.roi(handles.roi_index).z;
end

datadir = handles.current_path;

[filename, path] = uiputfile('*.txt', 'Select Filename', [datadir filesep]);
if isequal(filename, 0)
    return
end
%scandata = handles.scandata;
save(fullfile(path, filename),'roi','-ascii');


%% --- Executes during object creation, after setting all properties.
function t1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function scan_number_Callback(hObject, eventdata, handles)
% hObject    handle to scan_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scan_number as text
%        str2double(get(hObject,'String')) returns contents of scan_number as a double

if isempty(handles.scandata)
    return
end

if ~handles.scandata_saved
    handles=mcaview_savecheck(handles);
end

mcafile = get(handles.mcafile_select,'String');
[path, base, extn] = fileparts(mcafile);

handles.loadscan = sscanf(get(hObject, 'String'), '%d', 1);
% if handles.loadscan == handles.scandata.spec.scann
%     return
% end

switch handles.scandata.mcaformat
    case 'spec'
        nfile = mcafile;
        % Filename need not change...
    case 'g2'
        warndlg('Sorry, feature not added for this filetype');
        return
    case 'chess1'
        nfile = [handles.scandata.specfile '_' num2str(handles.loadscan) extn];
    case 'chess3'
        nfile = [handles.scandata.specfile '_' sprintf('%03d',handles.loadscan) extn];
    case 'chess_sp'
        [base, mca_ind] = fileparts(base);
        nfile = [handles.scandata.specfile '_' num2str(handles.loadscan) '.' mca_ind '.' extn];
end

handles.loadpath = handles.current_path;

set(handles.mcafile_select,'String',nfile);

handles = mcaview_importdata(handles);
handles.loadscan = [];
guidata(hObject,handles);



function norm_ref_Callback(hObject, eventdata, handles)
% hObject    handle to norm_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of norm_ref as text
%        str2double(get(hObject,'String')) returns contents of norm_ref as a double

if strcmp(get(handles.menu_options_autoupdate, 'Checked'), 'on')
    mcaview('profile_update_Callback', hObject, eventdata,handles);
end


%% --------------------------------------------------------------------
function menu_file_batch_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Loop 1: For each file
%   Call mcaview_importdata.  
%   Loop 2: For each ROI
%     Set handles properties to those of current ROI
%     Collate some properties of that profile... If a depth profile -- do
%     further processing -- e.g. peak finding, etc?
%     Add to a results table
% Remove current roi --

if handles.n_rois == 0
    errordlg('Must define at least one ROI for batch processing');
    return
end

% uigetfile dlg -- only matlab files allowed, multiple files OK
[files,newpath]=uigetfile({'*.mat','Matlab files only'},...
     'Pick a file', [handles.loadpath filesep], 'MultiSelect', 'on');
if isequal(files, 0)
    set(handles.mcafile_select, 'String', handles.current_file);
    return
end

% Steps:   Save/set some defaults: 
imgview = get(handles.menu_view_images, 'Checked');
if strcmp(imgview, 'on')
    set(handles.menu_view_images,'Checked', 'off');
end
showfits = get(handles.menu_options_showfits' ,'Checked');
if strcmp(showfits, 'on')
     set(handles.menu_options_showfits' ,'Checked', 'off');
end

% Current ROIs should go into a handles structure saving all of these
% variables.
all_rois = handles.scandata.roi;

% Is the following right/necessary?
ecal = handles.scandata.ecal;

% If there was only one file selected, then files is a string rather than a
% cell array, so here we turn it into a cell array with one element.
if ~iscell(files)
    files = {files};
end

update_matfiles = strcmp(get(handles.menu_options_batch_update, 'Checked'), ...
    'on');


% Loop 1: For each file
% %   Call mcaview_importdata.  
% results.e_com = ones([length(files) length(all_rois)]);
% results.area = ones([length(files) length(all_rois)]);
for k = 1:length(files)
    try
        handles.loadpath = newpath;
        set(handles.mcafile_select, 'String', files{k});
        handles = mcaview_importdata(handles);
        %load(fullfile(newpath,files{k}),'scandata');
    catch
        warndlg(sprintf('Oops, Error loading scandata variable from %s',files{k}));
        continue
    end
    %    scandata.ecal = ecal;
    %    handles.scandata = scandata;
    handles.ecal = ecal;
    handles.scandata.ecal = ecal;
    %mcaview_update_mcaplot(handles);
    % Clear saved ROIs. 
    if handles.n_rois ~= 0
        handles.n_rois = 0;
        handles.roi_index = 0;
        handles.scandata.roi = [];        
        %set(handles.current_roi_show, 'String', '0/0');
    end
    results(k).file = files{k};
    for m = 1:length(all_rois)
        %     call mcaview_makeprofile
        % Set GUI settings to those of all_rois(m)
        for n = 1:length(handles.roi_vars)
            handles.(handles.roi_vars{n}) = all_rois(m).(handles.roi_vars{n});
        end
        state_tags = fieldnames(handles.roi_state);
        for n = 1:length(state_tags)
            set(handles.(state_tags{n}), handles.roi_state.(state_tags{n}), ...
                all_rois(m).state.(state_tags{n}));
        end
        if m>1 && isequal(handles.roi_rect, all_rois(m-1).roi_rect)
            copy_roi_Callback(handles.copy_roi, [], handles);
            handles = guidata(hObject);
        end
        handles = mcaview_makeprofile(handles);        
        handles = mcaview_update_gui(handles);
        mcaview_update_mcaplot(handles);
        mcaview_plot_profile(handles);
        % send roi to a post-process function that selects the parameters
        % to save, e.g. area, e_com, etc.
    end     %   End of Loop 2
%    results(k) = mcaview_batch_process(handles.scandata.roi);
%    results(k).file = files{k};
    if update_matfiles
        save(fullfile(newpath, files{k}),'-struct','handles','scandata');
        handles.scandata_saved = 1;
    end
    % Store results from these ROIs.
end    % End of Loop 1
%assignin('base', 'results', results);

% Reset GUI defaults
set(handles.menu_view_images, 'Checked', imgview);
set(handles.menu_options_showfits' ,'Checked', 'off');
guidata(hObject, handles);


%% --------------------------------------------------------------------
function menu_options_batch_update_Callback(hObject, eventdata, handles)
% hObject    handle to menu_options_batch_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'off')
    set(hObject, 'Checked', 'on');
else
    set(hObject, 'Checked', 'off');
end


%% --------------------------------------------------------------------
function menu_options_dtcorrect_mcaplot_Callback(hObject, eventdata, handles)
% hObject    handle to menu_options_dtcorrect_mcaplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'off')
    set(hObject, 'Checked', 'on');
else
    set(hObject, 'Checked', 'off');
end
mcaview_update_mcaplot(handles);


%% --------------------------------------------------------------------
function menu_export_dtmca_Callback(hObject, eventdata, handles)
% hObject    handle to menu_export_dtmca (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.scandata)
    if handles.scandata.spec.dims > 1
        page = (get(handles.var3page, 'Value')-1) * handles.scandata.spec.size(2) + ...
            get(handles.var2page, 'Value');
    else
        page = 1;
    end
    mcadata=handles.scandata.mcadata(:,:,page);
    % THE FOLLOWING WAS CHANGED SINCE ver 0.98
    for k = 1:length(handles.scandata.depth)
        mcadata(:,k) = mcadata(:,k)*handles.scandata.dtcorr(k, page);
    end
    assignin('base', 'mcadata', mcadata);
    assignin('base', 'depth', handles.scandata.depth);
    assignin('base', 'energy',handles.scandata.energy);
end



function mca_scanplot_low_Callback(hObject, eventdata, handles)
% hObject    handle to mca_scanplot_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mca_scanplot_low as text
%        str2double(get(hObject,'String')) returns contents of mca_scanplot_low as a double
mcaview_update_mcaplot(handles);

%% --- Executes during object creation, after setting all properties.
function mca_scanplot_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mca_scanplot_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mca_scanplot_high_Callback(hObject, eventdata, handles)
% hObject    handle to mca_scanplot_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mca_scanplot_high as text
%        str2double(get(hObject,'String')) returns contents of mca_scanplot_high as a double
mcaview_update_mcaplot(handles);

%% --- Executes during object creation, after setting all properties.
function mca_scanplot_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mca_scanplot_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on button press in mca_scanplot_frz.
function mca_scanplot_frz_Callback(hObject, eventdata, handles)
% hObject    handle to mca_scanplot_frz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mca_scanplot_frz


%% --------------------------------------------------------------------
function menu_file_eprof_exportedf_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_eprof_exportedf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles.scandata, 'mcafile')
    return
end

eprof = handles.scandata.roi(handles.roi_index);
if ~strcmp(eprof.type, 'energy')
    return
end
    
datadir = handles.current_path;

if handles.scandata.mcafile(end-3) == '.'
    edffile = handles.scandata.mcafile;
    edffile(end-3:end) = '.edf';
end
[edffile, path] = uiputfile('*.edf', 'Select Filename', fullfile(datadir,edffile));
if isequal(edffile, 0)
    return
end

export_eprof_to_edf(fullfile(path, edffile),eprof);



function roi_sym_Callback(hObject, eventdata, handles)
% hObject    handle to roi_sym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_sym as text
%        str2double(get(hObject,'String')) returns contents of roi_sym as a double
str = get(hObject, 'String');
if ~any(strcmp(str, fieldnames(handles.elamdb.n)))
    warndlg([str ' is not an element symbol (Na from 1 to 98)']); 
    set(hObject, 'String', '');
elseif handles.roi_index > 0 
    handles.scandata.roi(handles.roi_index).state.roi_sym = str;
    handles.scandata.roi(handles.roi_index).sym = str;
    mcaview_plot_profile(handles);
    guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function roi_sym_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_sym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_options_follow_Callback(hObject, eventdata, handles)
% hObject    handle to menu_options_follow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off');
else
    set(hObject, 'Checked', 'on');
end

