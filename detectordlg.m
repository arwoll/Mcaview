function varargout = detectordlg(varargin)
% DETECTORDLG M-file for detectordlg.fig
%      DETECTORDLG, by itself, creates a new DETECTORDLG or raises the existing
%      singleton*.
%
%      H = DETECTORDLG returns the handle to a new DETECTORDLG or the handle to
%      the existing singleton*.
%
%      DETECTORDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETECTORDLG.M with the given input arguments.
%
%      DETECTORDLG('Property','Value',...) creates a new DETECTORDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before detectordlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to detectordlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help detectordlg

% Last Modified by GUIDE v2.5 27-May-2005 22:59:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @detectordlg_OpeningFcn, ...
                   'gui_OutputFcn',  @detectordlg_OutputFcn, ...
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


% --- Executes just before detectordlg is made visible.
function detectordlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to detectordlg (see VARARGIN)
%set(hObject, 'WindowStyle', 'modal');

% detectordlg takes one or two arguments.  The first argument is a list of
% channel_low_text corresponding to peak positions.  The second, if given, is a
% starting channel_low calibration.

nvargin = length(varargin);
enable = (nvargin == 0) || (nvargin == 1);
switch nvargin
    case 0
        handles.dead.channels = 1:40;
        handles.dead.base = 1048;
    case 1
        handles.dead = varargin{1};
end

set(handles.channel_low, 'String', num2str(handles.dead.channels(1)));
set(handles.channel_high, 'String',num2str(handles.dead.channels(end)));
set(handles.pulses, 'String', num2str(handles.dead.base));

handles.output = handles.dead;

% 
% global LISTFORMAT  EFORMAT
% LISTFORMAT = '%g  :  (%g keV)';  EFORMAT = '%3.4f |';


if enable
    handles.default_dead = handles.dead;  % Return this if cancel button is chosen
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes detectordlg wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = detectordlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 
% % --------------------------------------------------------------------
% function Untitled_2_Callback(hObject, eventdata, handles)
% % hObject    handle to Untitled_2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
% % --------------------------------------------------------------------
% function Untitled_3_Callback(hObject, eventdata, handles)
% % hObject    handle to Untitled_3 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 


function channel_low_Callback(hObject, eventdata, handles)
% hObject    handle to channel_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_low as text
%        str2double(get(hObject,'String')) returns contents of channel_low as a double


handles.dead.channels = str2num(get(hObject, 'String')) : handles.dead.channels(end);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function channel_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = handles.default_dead;
guidata(hObject, handles);
uiresume;

% --- Executes on button press in accept.
function accept_Callback(hObject, eventdata, handles)
% hObject    handle to accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = handles.dead;
guidata(hObject, handles);
uiresume;

% --------------------------------------------------------------------
function savedet_Callback(hObject, eventdata, handles)
% hObject    handle to savedet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathstr] = uiputfile('*.det', 'Choose a filename for these settings');
dead = handles.dead;
save(fullfile(pathstr, filename),'dead','-mat');


% --------------------------------------------------------------------
function loaddet_Callback(hObject, eventdata, handles)
% hObject    handle to loaddet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathstr] = uigetfile('*.det', 'Choose a filename for these settings');
fullname = fullfile(pathstr, filename);
load(fullname, '-mat')
if ~isempty(dead)
    handles.dead = dead;
end

set(handles.channel_low, 'String', num2str(handles.dead.channels(1)));
set(handles.channel_high, 'String',num2str(handles.dead.channels(end)));
set(handles.pulses, 'String', num2str(handles.dead.base));

guidata(hObject, handles);

function pulses_Callback(hObject, eventdata, handles)
% hObject    handle to pulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pulses as text
%        str2double(get(hObject,'String')) returns contents of pulses as a double
handles.dead.base = str2double(get(hObject, 'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pulses_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function channel_high_Callback(hObject, eventdata, handles)
% hObject    handle to channel_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_high as text
%        str2double(get(hObject,'String')) returns contents of channel_high as a double

handles.dead.channels = handles.dead.channels(1) : str2num(get(hObject, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function channel_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


