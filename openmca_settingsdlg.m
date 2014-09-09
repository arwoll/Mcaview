function varargout = openmca_settingsdlg(varargin)
% OPENMCA_SETTINGSDLG M-file for openmca_settingsdlg.fig
%      OPENMCA_SETTINGSDLG, by itself, creates a new OPENMCA_SETTINGSDLG or raises the existing
%      singleton*.
%
%      H = OPENMCA_SETTINGSDLG returns the handle to a new OPENMCA_SETTINGSDLG or the handle to
%      the existing singleton*.
%
%      OPENMCA_SETTINGSDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPENMCA_SETTINGSDLG.M with the given input arguments.
%
%      OPENMCA_SETTINGSDLG('Property','Value',...) creates a new OPENMCA_SETTINGSDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before openmca_settingsdlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to openmca_settingsdlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help openmca_settingsdlg

% Last Modified by GUIDE v2.5 27-Mar-2006 16:39:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @openmca_settingsdlg_OpeningFcn, ...
                   'gui_OutputFcn',  @openmca_settingsdlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before openmca_settingsdlg is made visible.
function openmca_settingsdlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to openmca_settingsdlg (see VARARGIN)



mcaformat_descriptions = {'MCA data contained in spec file';...
                    'Each MCA spectrum in its own spec-like file';...
                    'mcafile = <specfile>_#.mca';...
                    'mcafile = <specfile>_###.mca';...
                    'mcafile = <specfile>_#.#.mca'};
mcaformat_fields = {'spec', 'g2', 'chess1', 'chess3', 'chess_sp'};

if isempty(varargin)
    mcaformat = mcaformat_fields{3};
    dead.key = 'no_dtcorr';
else
    mcaformat = varargin{1};
    dead = varargin{2};
end

matches = [];
if iscell(mcaformat)
    for k = 1:length(mcaformat)
        matches = [matches find(strcmp(mcaformat{k},mcaformat_fields))];
    end
else
    matches = find(strcmp(mcaformat, mcaformat_fields));
end

handles.mcaformat_choices = matches;
handles.mcaformat_fields = mcaformat_fields;

set(handles.mcaformat_select, 'String', mcaformat_descriptions(matches));
set(handles.mcaformat_select, 'Value', 1);
if ~iscell(mcaformat)
    set(handles.mcaformat_select, 'Enable', 'off');
end

if isempty(dead.key)
    dead.key = 'no_dtcorr';
end
det_selection = find(strcmp(dead.key, get(handles.detector_select, 'String')));
if isempty(det_selection)
    errordlg(sprintf('Oops, unrecognized detector type: %s', dead.key));
    return
end

set(handles.detector_select, 'Value', det_selection);
if strcmp(dead.key, 'xflash')
    set(handles.pulse_chan, 'String', '1:40');
    if isfield(dead, 'pulse_freq')
        set(handles.pulse_freq, 'String', num2str(dead.pulse_freq));
    else
        set(handles.pulse_freq, 'String', '1048');
    end
end

if strcmp(dead.key, 'generic')
    if isfield(handles.dead, 'chan')
        set(handles.pulse_chan, 'String', ...
            sprintf('%d:%d',dead.pulse_chan(1), dead.pulse_chan(end)));
    else
        set(handles.pulse_chan, 'String', 0);
    end
    if isfield(dead, 'pulse_freq')
        set(handles.pulse_freq, 'String', num2str(dead.pulse_freq));
    else
        set(handles.pulse_freq, 'String', '1');
    end
end

if strcmp(dead.key, 'vortex')
    if isfield(dead, 'chan') && ~isempty(dead.chan)
        set(handles.dsp_dead_location, 'Value',dead.chan);
    end
    if isfield(dead, 'tau') && ~isempty(dead.tau)
        set(handles.dsp_use_tau, 'Value', 1);
        set(handles.dsp_tau, 'String', num2str(dead.tau));
    else
        set(handles.dsp_use_tau, 'Value', 0);
        set(handles.dsp_tau, 'String', '1');
    end
end

handles.output = struct('mcaformat', '', 'dead', '');
guidata(hObject, handles);

openmca_settingsdlg('detector_select_Callback', hObject, eventdata,handles)

% Choose default command line output for openmca_settingsdlg
%handles.output = hObject;

% UIWAIT makes openmca_settingsdlg wait for user response (see UIRESUME)
uiwait(handles.openmca_settingsdlg);


% --- Outputs from this function are returned to the command line.
function varargout = openmca_settingsdlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = '';
    varargout{2} = '';
    return
end
varargout{1} = handles.output.mcaformat;
varargout{2} = handles.output.dead;
delete(handles.openmca_settingsdlg);



function pulse_chan_Callback(hObject, eventdata, handles)
% hObject    handle to pulse_chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pulse_chan as text
%        str2double(get(hObject,'String')) returns contents of pulse_chan as a double


% --- Executes during object creation, after setting all properties.
function pulse_chan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pulse_chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pulse_freq_Callback(hObject, eventdata, handles)
% hObject    handle to pulse_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pulse_freq as text
%        str2double(get(hObject,'String')) returns contents of pulse_freq as a double


% --- Executes during object creation, after setting all properties.
function pulse_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pulse_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dsp_tau_Callback(hObject, eventdata, handles)
% hObject    handle to dsp_tau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dsp_tau as text
%        str2double(get(hObject,'String')) returns contents of dsp_tau as a double


% --- Executes during object creation, after setting all properties.
function dsp_tau_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dsp_tau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in accept.
function accept_Callback(hObject, eventdata, handles)
% hObject    handle to accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Mcaformat:
selection = get(handles.mcaformat_select, 'Value');
handles.output.mcaformat = handles.mcaformat_fields{handles.mcaformat_choices(selection)};

det_types = get(handles.detector_select, 'String');
dead.key = det_types{get(handles.detector_select, 'Value')};

if strcmp(dead.key, 'xflash')
    dead.chan = 1:40;
    dead.pulse_freq = sscanf(get(handles.pulse_freq, 'String'),'%f', 1);
elseif strcmp(dead.key, 'generic')
    % The following will usually be a range of channel numbers...
    dead.chan = eval(get(handles.pulse_chan, 'String'));
    dead.pulse_freq = sscanf(get(handles.pulse_freq, 'String'),'%f', 1);
elseif strcmp(dead.key, 'vortex')
    dead.chan = get(handles.dsp_dead_location, 'Value');
    if get(handles.dsp_use_tau, 'Value') == 1
        dead.tau = sscanf(get(handles.dsp_tau, 'String'),'%f', 1);
    end
end

handles.output.dead = dead;

guidata(hObject, handles);
uiresume;


% --- Executes on button press in abort.
function abort_Callback(hObject, eventdata, handles)
% hObject    handle to abort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
uiresume;

% --- Executes on selection change in mcaformat_select.
function mcaformat_select_Callback(hObject, eventdata, handles)
% hObject    handle to mcaformat_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns mcaformat_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mcaformat_select


% --- Executes during object creation, after setting all properties.
function mcaformat_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mcaformat_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in detector_select.
function detector_select_Callback(hObject, eventdata, handles)
% hObject    handle to detector_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns detector_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from detector_select

detectors = get(handles.detector_select, 'String');
selection = detectors{get(handles.detector_select, 'Value')};
if any(strcmp(selection, {'xflash', 'generic'}))
    if strcmp(selection, 'xflash')
        set(handles.pulse_chan, 'Enable', 'off');
    else
        set(handles.pulse_chan, 'Enable', 'on');
    end
    set(handles.detector_type, 'String', selection);
    set(handles.pulser_settings_panel, 'Visible', 'on');
    set(handles.dsp_settings_panel, 'Visible', 'off');
elseif strcmp(selection, 'vortex')
    set(handles.pulser_settings_panel, 'Visible', 'off');
    set(handles.dsp_settings_panel, 'Visible', 'on');
else
    set(handles.pulser_settings_panel, 'Visible', 'off');
    set(handles.dsp_settings_panel, 'Visible', 'off');
end


% --- Executes during object creation, after setting all properties.
function detector_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detector_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dsp_use_tau.
function dsp_use_tau_Callback(hObject, eventdata, handles)
% hObject    handle to dsp_use_tau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dsp_use_tau

% --- Executes on selection change in dsp_dead_location.
function dsp_dead_location_Callback(hObject, eventdata, handles)
% hObject    handle to dsp_dead_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns dsp_dead_location contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dsp_dead_location


% --- Executes during object creation, after setting all properties.
function dsp_dead_location_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dsp_dead_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


