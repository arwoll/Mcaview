function varargout = ecaldlg(varargin)
% ECALDLG M-file for ecaldlg.fig
%      ECALDLG, by itself, creates a new ECALDLG or raises the existing
%      singleton*.
%
%      H = ECALDLG returns the handle to a new ECALDLG or the handle to
%      the existing singleton*.
%
%      ECALDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ECALDLG.M with the given input arguments.
%
%      ECALDLG('Property','Value',...) creates a new ECALDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ecaldlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ecaldlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ecaldlg

% Last Modified by GUIDE v2.5 21-May-2005 18:40:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ecaldlg_OpeningFcn, ...
                   'gui_OutputFcn',  @ecaldlg_OutputFcn, ...
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


% --- Executes just before ecaldlg is made visible.
function ecaldlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ecaldlg (see VARARGIN)
%set(hObject, 'WindowStyle', 'modal');

% ecaldlg takes one or two arguments.  The first argument is a list of
% channels corresponding to peak positions.  The second, if given, is a
% starting energy calibration.

nvargin = length(varargin);
switch nvargin
    case 0
        handles.channels = [];
        handles.ecal = [0 1];
        handles.output = [];
    case 1
        handles.channels = varargin{1};
        handles.ecal = [0 1];
        handles.output = [];
    case 2
        handles.channels = varargin{1};
        handles.ecal = varargin{2};
        handles.output = handles.ecal;
    otherwise
        error('ecaldlg takes 0,1, or 2 arguments -- see ecaldlg.m');
end        

switch length(handles.ecal)
    case 2
        set(handles.linear, 'Value', get(handles.linear, 'Max'));
%         set(handles.ecaleqn, 'String', 'E = E0 + E1ch');
    case 3
        set(handles.linear, 'Value', get(handles.linear, 'Min'));
%         set(handles.ecaleqn, 'String', 'E = E0  +  E1ch + E2ch^2');
end

ecaldlg_update_order(handles)

% 
% guidata(hObject, handles);
% ecaldlg('linear_Callback', handles.linear, eventdata, handles);


global LISTFORMAT  EFORMAT
LISTFORMAT = '%g  :  (%g keV)';  EFORMAT = '%3.4f |';

handles.default_ecal = handles.ecal;  % Return this if cancel button is chosen
handles.energies = channel2energy(handles.channels, handles.ecal);
handles = ecaldlg_updatelist(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ecaldlg wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ecaldlg_OutputFcn(hObject, eventdata, handles) 
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

% --- Executes on selection change in calpairs.
function calpairs_Callback(hObject, eventdata, handles)
% hObject    handle to calpairs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns calpairs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from calpairs
selection = get(hObject, 'Value');

set(handles.channel, 'String', num2str(handles.channels(selection)));
set(handles.energy, 'String', num2str(handles.energies(selection)));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function calpairs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calpairs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', 'Empty');
guidata(hObject, handles);

function energy_Callback(hObject, eventdata, handles)
% hObject    handle to energy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of energy as text
%        str2double(get(hObject,'String')) returns contents of energy as a double

global LISTFORMAT EFORMAT 

list = get(handles.calpairs, 'String');
selection = get(handles.calpairs, 'Value');
handles.energies(selection) = str2double(get(hObject, 'String'));

list{selection} = sprintf(LISTFORMAT, handles.channels(selection), handles.energies(selection));
set(handles.calpairs, 'String', list);

fitorder = (get(handles.linear, 'Value') == get(handles.linear, 'Min')) + 1;

new_ecal = polyfit(handles.channels, handles.energies, fitorder);
new_ecal = new_ecal(end:-1:1);

handles.ecal = new_ecal;

set(handles.currentecal, 'String', ['|' num2str(handles.ecal, ...
    EFORMAT)]);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function energy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to energy (see GCBO)
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

handles.output = handles.default_ecal;
guidata(hObject, handles);
uiresume;

% --- Executes on button press in accept.
function accept_Callback(hObject, eventdata, handles)
% hObject    handle to accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = handles.ecal;
guidata(hObject, handles);
uiresume;

% --------------------------------------------------------------------
function savecal_Callback(hObject, eventdata, handles)
% hObject    handle to savecal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathstr] = uiputfile('*.cal', 'Choose a filename for this calibration');
if isequal(filename, 0)
    return
end
ecal = handles.ecal;
channels = handles.channels;
energies = handles.energies;
save(fullfile(pathstr, filename),'ecal','channels', 'energies','-mat');

% --------------------------------------------------------------------
function loadcal_Callback(hObject, eventdata, handles)
% hObject    handle to loadcal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathstr] = uigetfile('*.cal', 'Choose a filename for this calibration');
if isequal(filename, 0)
    return
end

fullname = fullfile(pathstr, filename);
load(fullname, '-mat')
% if ~isempty(ecal)
%     handles.ecal = ecal;
% end
if ~isempty(channels)
       appendlist = questdlg(sprintf('Append stored peaks to list?'), ...
        'Append?', 'Yes', 'No', 'Yes');
    if strcmp(appendlist, 'Yes')
        handles.channels = [handles.channels channels];
        handles.energies = [handles.energies energies];
        handles = ecaldlg_updatelist(handles);
    end
end
guidata(hObject, handles);

% Recalculate Energy calibration
ecaldlg('energy_Callback', handles.energy, eventdata, handles);

% --- Executes on button press in linear.
function linear_Callback(hObject, eventdata, handles)
% hObject    handle to linear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of linear

ecaldlg_update_order(handles);

% guidata(hObject, handles);

% Recalculate Energy calibration
ecaldlg('energy_Callback', handles.energy, eventdata, handles);
