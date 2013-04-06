function varargout = mpiv_gui(varargin)
% MPIV_GUI M-file for mpiv_gui.fig
%      MPIV_GUI, by itself, creates a new MPIV_GUI or raises the existing
%      singleton*.
%
%      H = MPIV_GUI returns the handle to a new MPIV_GUI or the handle to
%      the existing singleton*.
%
%      MPIV_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MPIV_GUI.M with the given input arguments.
%
%      MPIV_GUI('Property','Value',...) creates a new MPIV_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mpiv_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mpiv_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mpiv_gui

% Last Modified by GUIDE v2.5 22-Sep-2003 14:50:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mpiv_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @mpiv_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before mpiv_gui is made visible.
function mpiv_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mpiv_gui (see VARARGIN)

% Choose default command line output for mpiv_gui
handles.output = hObject;

% Update handles structure
handles.val_filename_1    = 'image1.bmp';
handles.val_filename_2    = 'image2.bmp';
handles.val_pivmethod     = 'COR';
handles.val_windowsize_x  = 64;
handles.val_windowsize_y  = 64;
handles.val_maxdisplace_x = 20;
handles.val_maxdisplace_y = 20;
handles.val_overlap       = 0.5;
handles.val_deltat        = 1;
handles.val_iteration     = 1;
guidata(hObject, handles);

% UIWAIT makes mpiv_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mpiv_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_startpiv.
function button_startpiv_Callback(hObject, eventdata, handles)
% hObject    handle to button_startpiv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in close_pushbutton.

% Prepare to close GUI application window
% PIV store data
var_mpiv.file_1        = handles.val_filename_1;
var_mpiv.file_2        = handles.val_filename_2;
var_mpiv.pivmethod     = handles.val_pivmethod;
var_mpiv.windowsize_x  = handles.val_windowsize_x;
var_mpiv.windowsize_y  = handles.val_windowsize_y;
var_mpiv.maxdisplace_x = handles.val_maxdisplace_x;
var_mpiv.maxdisplace_y = handles.val_maxdisplace_y;
var_mpiv.overlap       = handles.val_overlap;
var_mpiv.deltat        = handles.val_deltat;
var_mpiv.iteration     = handles.val_iteration;
%
%save('mpiv_paradata.mat','var_mpiv','-mat')

user_response = gui_confirm_mpivstart('Title','Confirm Close');
switch lower(user_response)
case 'no'
	% take no action
case 'yes'
    % Start MPIV
    im1 = imread(var_mpiv.file_1);
    im2 = imread(var_mpiv.file_2);
    close all
    %figure(1); imagesc(im1); title('image 1');
    %figure(2); imagesc(im2); title('image 2');
    [xi, yi, iu, iv] = mpiv(im1, im2, var_mpiv.windowsize_x, var_mpiv.windowsize_y, ...
                            var_mpiv.overlap, var_mpiv.overlap, ...
                            var_mpiv.maxdisplace_x, var_mpiv.maxdisplace_y, ...
                            var_mpiv.deltat, var_mpiv.pivmethod, var_mpiv.iteration, 1 );
    [iu_ft, iv_ft, iu_ip, iv_ip] = mpiv_filter(iu, iv, 2, 2.0, 3, 1 );
    save('mpiv_vecdata.mat','xi','yi','iu','iv','iu_ip','iv_ip');

    %delete(handles.figure1)
end


% --- Executes during object creation, after setting all properties.
function dlg_overlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dlg_overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% initial value
handles.val_overlap = str2double(get(hObject,'String'));
guidata(hObject, handles);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dlg_overlap_Callback(hObject, eventdata, handles)
% hObject    handle to dlg_overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dlg_overlap as text
%        str2double(get(hObject,'String')) returns contents of dlg_overlap as a double
%var_mpiv.overlap = str2double(get(hObject,'String'));
handles.val_overlap = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function dlg_window_size_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dlg_window_size_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dlg_window_size_x_Callback(hObject, eventdata, handles)
% hObject    handle to dlg_window_size_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dlg_window_size_x as text
%        str2double(get(hObject,'String')) returns contents of dlg_window_size_x as a double
handles.val_windowsize_x = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function dlg_window_size_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dlg_window_size_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dlg_window_size_y_Callback(hObject, eventdata, handles)
% hObject    handle to dlg_window_size_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dlg_window_size_y as text
%        str2double(get(hObject,'String')) returns contents of dlg_window_size_y as a double
handles.val_windowsize_y = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes on button press in pushbutton_filename1.
function pushbutton_filename1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_filename1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile('*','Select first image');
handles.val_filename_1 = filename;
guidata(hObject, handles);
set(handles.pushbutton_filename1,'String',filename)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton_filename1.
function pushbutton_filename1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_filename1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function filename_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function filename_1_Callback(hObject, eventdata, handles)
% hObject    handle to filename_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename_1 as text
%        str2double(get(hObject,'String')) returns contents of filename_1 as a double


% --- Executes on button press in pushbutton_filename2.
function pushbutton_filename2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_filename2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile('*','Select first image');
handles.val_filename_2 = filename;
guidata(hObject, handles);
set(handles.pushbutton_filename2,'String',filename)


% --- Executes during object creation, after setting all properties.
function iteration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iteration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in iteration.
function iteration_Callback(hObject, eventdata, handles)
% hObject    handle to iteration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns iteration contents as cell array
%        contents{get(hObject,'Value')} returns selected item from iteration
val = get(hObject,'Value');
switch val
    case 1
        handles.val_iteration = 1;
    case 2
        handles.val_iteration = 0;
    case 3
        handles.val_iteration = 1;
    case 4
        handles.val_iteration = 2;
    case 5
        handles.val_iteration = 3;
    case 6
        handles.val_iteration = 4;
    case 7
        handles.val_iteration = 5;
end
guidata(hObject, handles);
%handles.val_iteration


% --- Executes during object creation, after setting all properties.
function maxdisplace_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxdisplace_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function maxdisplace_x_Callback(hObject, eventdata, handles)
% hObject    handle to maxdisplace_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxdisplace_x as text
%        str2double(get(hObject,'String')) returns contents of maxdisplace_x as a double
handles.val_maxdisplace_x = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function maxdisplace_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxdisplace_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function maxdisplace_y_Callback(hObject, eventdata, handles)
% hObject    handle to maxdisplace_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxdisplace_y as text
%        str2double(get(hObject,'String')) returns contents of maxdisplace_y as a double
handles.val_maxdisplace_y = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function deltat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deltat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function deltat_Callback(hObject, eventdata, handles)
% hObject    handle to deltat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of deltat as text
%        str2double(get(hObject,'String')) returns contents of deltat as a double
handles.val_deltat = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pivmethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pivmethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in pivmethod.
function pivmethod_Callback(hObject, eventdata, handles)
% hObject    handle to pivmethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pivmethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pivmethod
val = get(hObject,'Value');
switch val
    case 1
        handles.val_pivmethod = 'COR';
    case 2
        handles.val_pivmethod = 'MQD';
end
guidata(hObject, handles);
%handles.val_pivmethod
