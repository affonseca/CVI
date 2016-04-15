function varargout = moneyCounter(varargin)
% MONEYCOUNTER MATLAB code for moneyCounter.fig
%      MONEYCOUNTER, by itself, creates a new MONEYCOUNTER or raises the existing
%      singleton*.
%
%      H = MONEYCOUNTER returns the handle to a new MONEYCOUNTER or the handle to
%      the existing singleton*.
%
%      MONEYCOUNTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MONEYCOUNTER.M with the given input arguments.
%
%      MONEYCOUNTER('Property','Value',...) creates a new MONEYCOUNTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before moneyCounter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to moneyCounter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help moneyCounter

% Last Modified by GUIDE v2.5 15-Apr-2016 22:54:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @moneyCounter_OpeningFcn, ...
                   'gui_OutputFcn',  @moneyCounter_OutputFcn, ...
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


% --- Executes just before moneyCounter is made visible.
function moneyCounter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to moneyCounter (see VARARGIN)

% Choose default command line output for moneyCounter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes moneyCounter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = moneyCounter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in imageLoader.
function imageLoader_Callback(hObject, eventdata, handles)
% hObject    handle to imageLoader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile(...    
    {'*.jpg; *.JPG; *.jpeg; *.JPEG; *.img; *.IMG; *.tif; *.TIF; *.tiff, *.TIFF','Supported Files (*.jpg,*.img,*.tiff,)'; ...
    '*.jpg','jpg Files (*.jpg)';...
    '*.JPG','JPG Files (*.JPG)';...
    '*.jpeg','jpeg Files (*.jpeg)';...
    '*.JPEG','JPEG Files (*.JPEG)';...
    '*.img','img Files (*.img)';...
    '*.IMG','IMG Files (*.IMG)';...
    '*.tif','tif Files (*.tif)';...
    '*.TIF','TIF Files (*.TIF)';...
    '*.tiff','tiff Files (*.tiff)';...
    '*.TIFF','TIFF Files (*.TIFF)'},...    
    'MultiSelect', 'on');

%getting image path
fullFileName = fullfile(pathname, filename);
newImage = imread(fullFileName);

%showing image and image name
axes(handles.image)
imshow(newImage);
set(handles.imageText,'String',filename);

%creating BW image using H from HSV image (better results)
imgHSV = uint8(rgb2hsv(newImage)*255); 
imgBW = imgHSV(:,:,1)<128;

%calculating region properties
regionProperties = regionprops('table',imgBW, 'Area', 'Centroid',...
    'MajorAxisLength','MinorAxisLength');

%Getting image labeling
[labeledImage, numberOfLabels] = bwlabel(imgBW);

%saving all calculated information as handles
handles.colorImage = newImage;
handles.bwImage = imgBW;
handles.labeledImage = labeledImage;
handles.regionProperties = regionProperties;
handles.numberOfRegions = numberOfLabels;
guidata(hObject,handles);

%updating both region Table and display mode (called in table)
displayModeButtonGroup_SelectionChangedFcn(hObject, eventdata, handles);




% --- Executes on button press in propertiesSaver.
function propertiesSaver_Callback(hObject, eventdata, handles)
% hObject    handle to propertiesSaver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in propertiesLoader.
function propertiesLoader_Callback(hObject, eventdata, handles)
% hObject    handle to propertiesLoader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in regionMenu.
function regionMenu_Callback(hObject, eventdata, handles)
% hObject    handle to regionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns regionMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from regionMenu


% --- Executes during object creation, after setting all properties.
function regionMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in coinMenu.
function coinMenu_Callback(hObject, eventdata, handles)
% hObject    handle to coinMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns coinMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from coinMenu


% --- Executes during object creation, after setting all properties.
function coinMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coinMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in coinPropertyMenu.
function coinPropertyMenu_Callback(hObject, eventdata, handles)
% hObject    handle to coinPropertyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns coinPropertyMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from coinPropertyMenu


% --- Executes during object creation, after setting all properties.
function coinPropertyMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coinPropertyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in thresholdMenu.
function thresholdMenu_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns thresholdMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from thresholdMenu


% --- Executes during object creation, after setting all properties.
function thresholdMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function errorMarginText_Callback(hObject, eventdata, handles)
% hObject    handle to errorMarginText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of errorMarginText as text
%        str2double(get(hObject,'String')) returns contents of errorMarginText as a double


% --- Executes during object creation, after setting all properties.
function errorMarginText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to errorMarginText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in regionToCoinButton.
function regionToCoinButton_Callback(hObject, eventdata, handles)
% hObject    handle to regionToCoinButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in displayModeButtonGroup.
function displayModeButtonGroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in displayModeButtonGroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Check if an image was loaded
if(isfield(handles,'bwImage') == 0)
    return;
end

axes(handles.image);
cla reset

selectedButton = get(get(handles.displayModeButtonGroup,'SelectedObject'), 'String');
switch selectedButton
    case 'Original'
        
        imshow(handles.colorImage);
        
    case 'Binary'
        imshow(handles.bwImage);
        
    case 'Region Properties'
        areasImage = handles.colorImage;
        pixelsInImage = size(handles.colorImage, 1) * size(handles.colorImage, 2);

        stats = handles.regionProperties;
        centers = stats.Centroid;
        diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
        radii = diameters/2;
        
        for i=1:handles.numberOfRegions
            %drawing region areas
            [areaRows, areaCols] = find(handles.labeledImage==i);
            indexes = sub2ind([ size(handles.colorImage, 1),...
                                size(handles.colorImage, 2)],...
                                areaRows, areaCols);
            color1 = uint8(hsv2rgb(i/handles.numberOfRegions, 0.5, 1) * 255);

            areasImage(indexes + 0*pixelsInImage) = color1(1); %red channel
            areasImage(indexes + 1*pixelsInImage) = color1(2);  %green channel
            areasImage(indexes + 2*pixelsInImage) = color1(3); %blue channel  
        end
        
        imshow(areasImage);

        for i=1:handles.numberOfRegions
            %drawing region perimeters
            color2 = uint8(hsv2rgb(i/handles.numberOfRegions, 1, 0.5) * 255);
            viscircles(centers(i,:), radii(i),'EdgeColor', color2);


            %drawing the region labels
            t = text(round(centers(i,1)), round(centers(i,2)), int2str(i));
            t.FontSize = 30;
            t.HorizontalAlignment = 'center';
        end

    
    case 'Coin Type'
        imshow(handles.colorImage);
        
        coinsType = handles.regionPropertiesTable.Data(:,6);
        centers = handles.regionProperties.Centroid;
        
        for i=1:handles.numberOfRegions
            %drawing the coin type
            t = text(round(centers(i,1)), round(centers(i,2)), coinsType(i));
            t.FontSize = 30;
            t.HorizontalAlignment = 'center';
        end
    otherwise
        fprintf('Wuuuuuut???')
end
    


% --- Executes when entered data in editable cell(s) in regionPropertiesTable.
function regionPropertiesTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to regionPropertiesTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

if(isfield(handles,'regionProperties') == 0)
    return;
end

properties = handles.regionProperties;
%defining the data to be in the table
propertiesCells = num2cell([    properties.Area... 
                                properties.Centroid...
                                properties.MajorAxisLength... 
                                properties.MinorAxisLength]);
dummyValue = cell(handles.numberOfRegions, 1);
dummyValue(:) = {'?'};

%concatening and setting it as the new data
data = [propertiesCells dummyValue];
handles.regionPropertiesTable.Data = data;

%TODO Get coin type property

displayModeButtonGroup_SelectionChangedFcn(hObject, eventdata, handles);
