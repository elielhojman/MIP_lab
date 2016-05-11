function varargout = imageScroller(varargin)
% IMAGESCROLLER MATLAB code for imageScroller.fig
%      IMAGESCROLLER, by itself, creates a new IMAGESCROLLER or raises the existing
%      singleton*.
%
%      H = IMAGESCROLLER returns the handle to a new IMAGESCROLLER or the handle to
%      the existing singleton*.
%
%      IMAGESCROLLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGESCROLLER.M with the given input arguments.
%
%      IMAGESCROLLER('Property','Value',...) creates a new IMAGESCROLLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imageScroller_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imageScroller_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imageScroller

% Last Modified by GUIDE v2.5 11-May-2016 17:50:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imageScroller_OpeningFcn, ...
                   'gui_OutputFcn',  @imageScroller_OutputFcn, ...
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


% --- Executes just before imageScroller is made visible.
function imageScroller_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imageScroller (see VARARGIN)

% Choose default command line output for imageScroller
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imageScroller wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imageScroller_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliceNum = round(get(hObject,'Value')); 
handles.sliceNum = sliceNum;
imagesc(handles.vol(:,:,sliceNum)','Parent',handles.axes1);
set(handles.txtSliceNum,'String',['Slice: ', num2str(sliceNum)]);

roi = handles.seg(:,:,sliceNum);
roi(roi ~= 0) = 1; % Set values for ilium and sacrum to 1;
try
    square = getConvhullSquare(roi);        
catch
    display('Linear points in convhull. Try other Slice');   
    square = [0 300 0 300];
end
square = square + [-50 50 -50 50]; % increase the field of view
% Make it same ratio
diffX = square(2) - square(1);
diffY = square(4) - square(3);
M = max([diffX, diffY]);
square = [square(1), square(1)+M, square(3), square(3)+M];
colormap gray(256);    
axis(square);
set(gca, 'CLim', [0, 700]);    
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in btnNext.
function btnNext_Callback(hObject, eventdata, handles)
% hObject    handle to btnNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.idx = handles.idx + 1;
name = handles.diagList{handles.idx}.name;
handles.diagnosis = handles.diagList{handles.idx}.diagnosis;
ctTitle = [name, '  Diagnosis: ', num2str(handles.diagnosis)];
set(handles.txtAccNum,'String',ctTitle);
accNum = name(1:end-1);
handles.accNum = accNum;
side = name(end);
handles.side = side;
folderPath = ['sacro/dataset/',accNum];
volMatFile = [folderPath, '/', accNum, '.mat'];
borderMatFile = [folderPath,'/segBorder.mat'];
if ~exist(volMatFile,'file') || ~exist(borderMatFile,'file')
    display(['Skipping ', name]);    
end

load(volMatFile); % The volume is under the variable 'vol'
vol = dicom2niftiVol(vol,dicomInfo); % dicomInfo is also stored in the volMatFile

load(borderMatFile); % The border segmentation is under 'segBorder', the ilium = 2 and the sacrum = 1;
if side == 'R'
    seg = segBorder.R;
else
    seg = segBorder.L;
end

handles.vol = vol;
handles.seg = seg;

M = size(vol,3)-1;
set(handles.slider1,'Max',M);
set(handles.slider1,'Min',0);
set(handles.slider1,'SliderStep',[1/M 1/M]);
guidata(hObject,handles);
imagesc(handles.vol(:,:,1)','Parent',handles.axes1);
set(handles.txtSliceNum,'String','Slice: 1');


% --- Executes on button press in btnSavePoints.
function btnSavePoints_Callback(hObject, eventdata, handles)
% hObject    handle to btnSavePoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x,y] = getpts();
for k = 1:numel(x)
    s = struct('x',round(x),'y',round(y),'z',handles.sliceNum, ...
        'accNum',handles.accNum,'side',handles.side,'diagnosis',handles.diagnosis);
    handles.pointsOfInterest{end+1} = s;
end
guidata(hObject,handles);

