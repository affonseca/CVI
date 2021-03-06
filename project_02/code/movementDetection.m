
function varargout = movementDetection(varargin)
% MOVEMENTDETECTION MATLAB code for movementDetection.fig
%      MOVEMENTDETECTION, by itself, creates a new MOVEMENTDETECTION or raises the existing
%      singleton*.
%
%      H = MOVEMENTDETECTION returns the handle to a new MOVEMENTDETECTION or the handle to
%      the existing singleton*.
%
%      MOVEMENTDETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVEMENTDETECTION.M with the given input arguments.
%
%      MOVEMENTDETECTION('Property','Value',...) creates a new MOVEMENTDETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before movementDetection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to movementDetection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help movementDetection

% Last Modified by GUIDE v2.5 26-May-2016 22:54:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @movementDetection_OpeningFcn, ...
                   'gui_OutputFcn',  @movementDetection_OutputFcn, ...
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


% --- Executes just before movementDetection is made visible.
function movementDetection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to movementDetection (see VARARGIN)

% Choose default command line output for movementDetection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes movementDetection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = movementDetection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(strcmp(handles.playButton.String,'Pause'))
    handles.pauseRun = 1;
    guidata(hObject,handles);
    return;
end

%check if options are correct
[options, typeIdentifiers, success] = lockAndGetOptions(handles);
if(success == 0)
    return;
end

%disable other buttons and changing my text
handles.playButton.String = 'Pause';
handles.stopButton.Enable = 'off';
handles.stepButton.Enable = 'off';
handles.loadButton.Enable = 'off';

while(handles.iteration < handles.nFrames-1)
    %getting the newest information on the handles
    handles = guidata(hObject);
    
    %there was a request to pause
    if(handles.pauseRun == 1)
        handles.playButton.String = 'Play';
        handles.pauseRun = 0;
        unlockOptions(handles);
        handles.stopButton.Enable = 'on';
        handles.stepButton.Enable = 'on';
        handles.loadButton.Enable = 'on';
        guidata(hObject,handles);
        return;
    end
    
    %do the step
    detectMovement(hObject, handles, options, typeIdentifiers);
end

unlockOptions(handles);
handles.playButton.String = 'Play';      
handles.playButton.Enable = 'off';
handles.stopButton.Enable = 'on';
handles.loadButton.Enable = 'on';


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

video = VideoReader(handles.videoFileName);

nFrames = video.Duration * video.FrameRate;
background = readFrame(video);

axes(handles.videoAxes);
imshow(background);

handles.playButton.Enable = 'on';
handles.stopButton.Enable = 'on';
handles.stepButton.Enable = 'on';
handles.originalButton.Value = 1;

%saving the starting information
handles.pauseRun = 0;
handles.background = background;
handles.nFrames = nFrames;
handles.video = video;
handles.iteration = 1;
handles.boxCounter = 0;
handles.lastFrameBoxes= zeros(0,5); %divided in index, x, y, width, height
handles.color_mix= zeros(0,3); % [Vehicle Other Person] used to count occurrences
handles.mergeSplitTable.Data = cell(0,3);
handles.onScreenTable.Data = cell(0,2);
handles.Binary = false;
guidata(hObject,handles);


% --- Executes on button press in stepButton.
function stepButton_Callback(hObject, eventdata, handles)
% hObject    handle to stepButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%check if options are correct
[options, typeIdentifiers, success] = lockAndGetOptions(handles);
if(success == 0)
    return;
end

%disable other buttons
handles.playButton.Enable = 'off';
handles.stopButton.Enable = 'off';
handles.stepButton.Enable = 'off';
handles.loadButton.Enable = 'off';

%do the step
detectMovement(hObject, handles, options, typeIdentifiers);

%enable buttons again
if(handles.iteration < handles.nFrames)
    handles.playButton.Enable = 'on';
    handles.stepButton.Enable = 'on';
end

unlockOptions(handles);
handles.stopButton.Enable = 'on';
handles.loadButton.Enable = 'on';





% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile(...    
    {'*.mp4', 'Supported Files (*.mp4)'},...    
    'MultiSelect', 'on');

%checking if something was chosen
if(size(pathname,2) == 1)
    return
end

handles.videoNameText.String = filename;

%getting video path
fullFileName = fullfile(pathname, filename);
handles.videoFileName = fullFileName;
guidata(hObject,handles);

%calling the stop callback to reload the video
 stopButton_Callback(hObject, eventdata, handles);


function alphaEdit_Callback(hObject, eventdata, handles)
% hObject    handle to alphaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alphaEdit as text
%        str2double(get(hObject,'String')) returns contents of alphaEdit as a double


% --- Executes during object creation, after setting all properties.
function alphaEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alphaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bwThreshEdit_Callback(hObject, eventdata, handles)
% hObject    handle to bwThreshEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bwThreshEdit as text
%        str2double(get(hObject,'String')) returns contents of bwThreshEdit as a double


% --- Executes during object creation, after setting all properties.
function bwThreshEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bwThreshEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function areaDeleteEdit_Callback(hObject, eventdata, handles)
% hObject    handle to areaDeleteEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of areaDeleteEdit as text
%        str2double(get(hObject,'String')) returns contents of areaDeleteEdit as a double


% --- Executes during object creation, after setting all properties.
function areaDeleteEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to areaDeleteEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mergeThreshEdit_Callback(hObject, eventdata, handles)
% hObject    handle to mergeThreshEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mergeThreshEdit as text
%        str2double(get(hObject,'String')) returns contents of mergeThreshEdit as a double


% --- Executes during object creation, after setting all properties.
function mergeThreshEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mergeThreshEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function deleteBoxesEdit_Callback(hObject, eventdata, handles)
% hObject    handle to deleteBoxesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of deleteBoxesEdit as text
%        str2double(get(hObject,'String')) returns contents of deleteBoxesEdit as a double


% --- Executes during object creation, after setting all properties.
function deleteBoxesEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deleteBoxesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mergeSplitEdit_Callback(hObject, eventdata, handles)
% hObject    handle to mergeSplitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mergeSplitEdit as text
%        str2double(get(hObject,'String')) returns contents of mergeSplitEdit as a double


% --- Executes during object creation, after setting all properties.
function mergeSplitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mergeSplitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vehicleWidthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to vehicleWidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vehicleWidthEdit as text
%        str2double(get(hObject,'String')) returns contents of vehicleWidthEdit as a double


% --- Executes during object creation, after setting all properties.
function vehicleWidthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vehicleWidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vehicleHeightEdit_Callback(hObject, eventdata, handles)
% hObject    handle to vehicleHeightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vehicleHeightEdit as text
%        str2double(get(hObject,'String')) returns contents of vehicleHeightEdit as a double


% --- Executes during object creation, after setting all properties.
function vehicleHeightEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vehicleHeightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vehicleErrorMarginEdit_Callback(hObject, eventdata, handles)
% hObject    handle to vehicleErrorMarginEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vehicleErrorMarginEdit as text
%        str2double(get(hObject,'String')) returns contents of vehicleErrorMarginEdit as a double


% --- Executes during object creation, after setting all properties.
function vehicleErrorMarginEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vehicleErrorMarginEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function personWidthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to personWidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of personWidthEdit as text
%        str2double(get(hObject,'String')) returns contents of personWidthEdit as a double


% --- Executes during object creation, after setting all properties.
function personWidthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to personWidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function personHeightEdit_Callback(hObject, eventdata, handles)
% hObject    handle to personHeightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of personHeightEdit as text
%        str2double(get(hObject,'String')) returns contents of personHeightEdit as a double


% --- Executes during object creation, after setting all properties.
function personHeightEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to personHeightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function personErrorMarginEdit_Callback(hObject, eventdata, handles)
% hObject    handle to personErrorMarginEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of personErrorMarginEdit as text
%        str2double(get(hObject,'String')) returns contents of personErrorMarginEdit as a double


% --- Executes during object creation, after setting all properties.
function personErrorMarginEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to personErrorMarginEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------%
%--------------------------- OPTIONS FUNCTIONS ---------------------------%
%-------------------------------------------------------------------------%
function [options, typeIdentifiers, success] = lockAndGetOptions(handles)
success = 0;
options = zeros(6,1);
typeIdentifiers = zeros(2, 3);

%New frame weight to background option
option = str2double(handles.alphaEdit.String);
if(isnan(option))
    handles.alphaEdit.String = 'Error';
    return;
end
options(1) = option;

%Binary image Threshold option
option = str2double(handles.bwThreshEdit.String);
if(isnan(option))
    handles.bwThreshEdit.String = 'Error';
    return;
end
options(2) = option;

%Eliminate regions smaller than option
option = str2double(handles.areaDeleteEdit.String);
if(isnan(option))
    handles.areaDeleteEdit.String = 'Error';
    return;
end
options(3) = option;

%Same frame merge threshold option
option = str2double(handles.mergeThreshEdit.String);
if(isnan(option))
    handles.mergeThreshEdit.String = 'Error';
    return;
end
options(4) = option;

%Eliminate boxes with an area smaller than option
option = str2double(handles.deleteBoxesEdit.String);
if(isnan(option))
    handles.deleteBoxesEdit.String = 'Error';
    return;
end
options(5) = option;

%Previous frame merge or split threshold option
option = str2double(handles.mergeSplitEdit.String);
if(isnan(option))
    handles.mergeSplitEdit.String = 'Error';
    return;
end
options(6) = option;

%vehicle width
value = str2double(handles.vehicleWidthEdit.String);
if(isnan(value))
    handles.vehicleWidthEdit.String = 'Error';
    return;
end
typeIdentifiers(1,1) = value;

%vehicle height
value = str2double(handles.vehicleHeightEdit.String);
if(isnan(value))
    handles.vehicleHeightEdit.String = 'Error';
    return;
end
typeIdentifiers(1,2) = value;

%vehicle error margin
value = str2double(handles.vehicleErrorMarginEdit.String);
if(isnan(value))
    handles.vehicleErrorMarginEdit.String = 'Error';
    return;
end
typeIdentifiers(1,3) = value;

%person width
value = str2double(handles.personWidthEdit.String);
if(isnan(value))
    handles.personWidthEdit.String = 'Error';
    return;
end
typeIdentifiers(2,1) = value;

%person height
value = str2double(handles.personHeightEdit.String);
if(isnan(value))
    handles.personHeightEdit.String = 'Error';
    return;
end
typeIdentifiers(2,2) = value;

%person error margin
value = str2double(handles.personErrorMarginEdit.String);
if(isnan(value))
    handles.personErrorMarginEdit.String = 'Error';
    return;
end
typeIdentifiers(2,3) = value;

%No error, now locking
success = 1;

handles.alphaEdit.Enable = 'off';
handles.bwThreshEdit.Enable = 'off';
handles.areaDeleteEdit.Enable = 'off';
handles.mergeThreshEdit.Enable = 'off';
handles.deleteBoxesEdit.Enable = 'off';
handles.mergeSplitEdit.Enable = 'off';

handles.vehicleWidthEdit.Enable = 'off';
handles.vehicleHeightEdit.Enable = 'off';
handles.vehicleErrorMarginEdit.Enable = 'off';
handles.personWidthEdit.Enable = 'off';
handles.personHeightEdit.Enable = 'off';
handles.personErrorMarginEdit.Enable = 'off';

function unlockOptions(handles)

handles.alphaEdit.Enable = 'on';
handles.bwThreshEdit.Enable = 'on';
handles.areaDeleteEdit.Enable = 'on';
handles.mergeThreshEdit.Enable = 'on';
handles.deleteBoxesEdit.Enable = 'on';
handles.mergeSplitEdit.Enable = 'on';

handles.vehicleWidthEdit.Enable = 'on';
handles.vehicleHeightEdit.Enable = 'on';
handles.vehicleErrorMarginEdit.Enable = 'on';
handles.personWidthEdit.Enable = 'on';
handles.personHeightEdit.Enable = 'on';
handles.personErrorMarginEdit.Enable = 'on';


%-------------------------------------------------------------------------%
%--------------------------- MAIN STEP FUNCTION --------------------------%
%-------------------------------------------------------------------------%
function detectMovement(hObject, handles, options, typeIdentifiers)

    %extract information from handles
    boxCounter = handles.boxCounter;
    lastFrameBoxes = handles.lastFrameBoxes;
    video = handles.video;
    iteration = handles.iteration;
    background = handles.background;
    color_mix = handles.color_mix;
    onScreen = num2cell(zeros(0,2));
     %each frame counts equally in the overall calculation but lets add a
     %weight to it
    alpha = 1/iteration * options(1);
    if(alpha > 1)
        alpha = 1;
    end
    Y = readFrame(video);
    
    background = alpha * double(Y) + (1-alpha) * double(background);
    bkgImage = uint8(background); 
    
    differenceImage = imabsdiff(Y,bkgImage);
    
    bwThreshold = options(2)/100;
    %bwThreshold = graythresh(bkgImage);
    differenceImgBW = ... 
                    (im2bw(differenceImage(:,:,1), bwThreshold) | ...
                    im2bw(differenceImage(:,:,2), bwThreshold) | ...
                    im2bw(differenceImage(:,:,3), bwThreshold));
    
    %differenceImgBW = medfilt2(differenceImgBW);
    se = strel('square', 5);
    transformedImage = bwareaopen(differenceImgBW, options(3));
    transformedImage = imclose(transformedImage, se);
    transformedImage = imfill(transformedImage, 'holes');
    
    regionProperties = regionprops('table',transformedImage,...
                                   'Area', 'Centroid', 'BoundingBox');

    mergedBoxes = mergeBoxes(regionProperties.BoundingBox, options(4)/100);
    
    %only keeping boxes with an area bigger than threshold
    if(size(mergedBoxes,1) ~= 0)
        mergedBoxes = mergedBoxes(mergedBoxes(:,3).*mergedBoxes(:,4) > options(5),:);
    end

    [newBoxesIds, mergeSplitData, boxCounter] = matchBoxes(...
                lastFrameBoxes, mergedBoxes, options(6)/100, boxCounter);

    axes(handles.videoAxes);
    if handles.binaryButton.Value
        imshow(transformedImage);
    else
        imshow(Y);
    end

    nRegions = size(mergedBoxes,1);
    %drawing the final regions
    for j=1:nRegions
        color = getRegionTypeColor(typeIdentifiers, mergedBoxes(j,:));
         if( size(color_mix, 1) >= newBoxesIds(j) )
            color_mix(newBoxesIds(j),:) = color_mix(newBoxesIds(j),:) + color;
             %if was seen as something other than other, eliminate other
             %matches
             if(color_mix(newBoxesIds(j),2) > 0 && (color_mix(newBoxesIds(j),3) > 0 || color_mix(newBoxesIds(j),1) > 0))
                color_mix(newBoxesIds(j),2) = 0;
             end
         else
           color_mix(newBoxesIds(j),:) = color;
        end

        c = color_mix(newBoxesIds(j),:)-max(color_mix(newBoxesIds(j),:)) == 0;
        if(sum(c) ~= 1)
           car = c(1);
           person = c(3);
           
           if(car - person == 0)
               c = color;
           else
               c = c - [0 1 0];
           end
        end
        
        types = ['Vehicle'
            'Other  '
            'Person '];
        
        onScreen{j,1} = newBoxesIds(j);
        onScreen{j,2} = types(find(c ==1),:);
        rectangle('Position',mergedBoxes(j,:), 'EdgeColor', c);
    end

    for j=1:nRegions
        box = mergedBoxes(j,:);
%         text_ = strcat(int2str(newBoxesIds(j)),': ');
%         text_ = strcat(text_,int2str(box(3)*box(4)));
        t = text(box(1) + box(3)/2, box(2) + box(4)/2, int2str(newBoxesIds(j)));
        t.FontSize = 10;
        t.Color = 'black';
        t.FontWeight = 'bold';
        t.HorizontalAlignment = 'center';
    end
    
    data = handles.mergeSplitTable.Data;
    
    nSplits = size(mergeSplitData.splits,1);
    splitData = cell(nSplits, 3);
    for i=1:nSplits
        split = mergeSplitData.splits(i);
        splitData{i,1} = 'Split';
        splitData{i,2} =  mat2str(split.splittedFrom);
        splitData{i,3} =  mat2str(split.splittedTo);
        
        box = lastFrameBoxes(lastFrameBoxes(:,1) == split.splittedFrom, 2:5);
        t = text(box(1) + box(3)/2, box(2) + box(4)/2, 'SPLIT');
        t.FontSize = 20;
        t.Color = 'white';
        t.FontWeight = 'bold';
        t.HorizontalAlignment = 'center';
    end
    
    %updating last frame boxes and iteration
    %we do this between splits and merge logs so we can draw them on the
    %screen
    if(nRegions == 0)
        lastFrameBoxes = zeros(0,5);
    else
        lastFrameBoxes = [newBoxesIds mergedBoxes];
    end
    iteration = iteration+1;
    
    nMerges = size(mergeSplitData.merges,1);
    mergeData = cell(nMerges, 3);
    for i=1:nMerges
        merge = mergeSplitData.merges(i);
        mergeData{i,1} = 'Merge';
        mergeData{i,2} = mat2str(merge.mergedFrom);
        mergeData{i,3} = mat2str(merge.mergedTo);
        
        box = lastFrameBoxes(lastFrameBoxes(:,1) == merge.mergedTo, 2:5);
        t = text(box(1) + box(3)/2, box(2) + box(4)/2, 'MERGE');
        t.FontSize = 20;
        t.Color = 'white';
        t.FontWeight = 'bold';
        t.HorizontalAlignment = 'center';
    end
    
    data = [data; mergeData; splitData];
    
    %updating all this information in the handles
    handles.background = background;
    handles.iteration = iteration;
    handles.boxCounter = boxCounter;
    handles.lastFrameBoxes = lastFrameBoxes;
    handles.mergeSplitTable.Data = data;
    handles.onScreenTable.Data = onScreen;
    handles.color_mix = color_mix;
    guidata(hObject,handles);
    drawnow;

    
function mergedBoxes = mergeBoxes(originalBoxes, threshold)

    if size(originalBoxes,1) == 0
        mergedBoxes = originalBoxes;
        return;
    end

    %change coordenate system from x1, y1, w, h to x1, y1, x2, y2
    %this makes operations easier
    inputBoxes = originalBoxes;
    inputBoxes = toCoorSystem(inputBoxes);

    mergeCounter = 1; %must start non-zero
    while(mergeCounter ~= 0)
        mergeCounter = 0;
        nBoxes = size(inputBoxes,1);
        outputBoxes = zeros(size(inputBoxes));
        boxMerged = zeros(nBoxes,1);

        for i=1:nBoxes
            if boxMerged(i)
                continue;
            end

            for j=i+1:nBoxes
                if boxMerged(j)
                    continue;
                end

                box1 = inputBoxes(i,:);
                box2 = inputBoxes(j,:);
                
                intersectionBoxArea = getIntersectionArea(box1, box2);
                
                if(intersectionBoxArea == 0)
                    continue;
                end

                box1Area = getArea(box1);
                box2Area = getArea(box2);

                if( intersectionBoxArea/box1Area>threshold && ...
                    intersectionBoxArea/box2Area>threshold)

                    boxMerged(i) = 1; boxMerged(j) = 1; 
                    mergeCounter = mergeCounter+1;
                    outputBoxes(mergeCounter,:) =   [min(box1(1:2),box2(1:2))... 
                                                    max(box1(3:4),box2(3:4))];
                end

            end
        end

        unmergedBoxes = inputBoxes(boxMerged==0,:);
        %now our output is our new input
        inputBoxes = [outputBoxes(1:mergeCounter,:) ; unmergedBoxes];
    end

    %Returning again in the original system 
    mergedBoxes = fromCoorSystem(inputBoxes);
    
    
function [newBoxesIds, mergeSplitLog, counter] = ...
            matchBoxes(oldBoxes, newBoxes, threshold, counter)
    %separating ID from box location info
    oldBoxesIds = oldBoxes(:,1);
    oldBoxes = oldBoxes(:,2:5);
    
    if size(oldBoxes,1) ~= 0 
        oldBoxes = toCoorSystem(oldBoxes);
    end
    if size(newBoxes,1) ~= 0 
        newBoxes = toCoorSystem(newBoxes);
    end
    
    oldBoxesLength = size(oldBoxes,1);
    newBoxesLength = size(newBoxes,1);
    %set all to -1 which means no match
    newBoxesIds = zeros(newBoxesLength,1) - 1;
    
    matchMatrix = zeros(oldBoxesLength,newBoxesLength);
    for i=1:oldBoxesLength
        for j=1:newBoxesLength
            oldBox = oldBoxes(i,:);
            newBox = newBoxes(j,:);
            
             intersectionBoxArea = getIntersectionArea(oldBox, newBox);
                
            if(intersectionBoxArea == 0)
                continue;
            end

            oldBoxArea = getArea(oldBox);
            newBoxArea = getArea(newBox);
            
            if intersectionBoxArea/oldBoxArea>threshold
                
                %%case 1 -> perfect match
                if intersectionBoxArea/newBoxArea>threshold
                    matchMatrix(i,j) = 1;
                %case 2 -> only old box matches (we have a merge)
                else
                    matchMatrix(i,j) = 2;
                end
            %case 3 -> only new box matches (we have a split)
            elseif intersectionBoxArea/newBoxArea>threshold
                matchMatrix(i,j) = 3;
            end   
        end
    end
    
    %now get a new ID for every region.
    for i=1:newBoxesLength
        %looking for perfect matches
        match = oldBoxesIds(matchMatrix(:,i) == 1);
        
        %only case where it gets an ID
        if(length(match) == 1)
            newBoxesIds(i) = match;
        else
            counter = counter+1;
            newBoxesIds(i) = counter;
        end
    end
    
    %Create split log entries
    splitLog = [];
    for i=1:oldBoxesLength
        splittedBoxesIDs = newBoxesIds(matchMatrix(i,:) == 3);
        
        if(size(splittedBoxesIDs) <= 1)
            %found nothing
            continue;
        end
        
        %Each log info has the inform
        splitLogEntry = struct( 'splittedFrom', {oldBoxesIds(i)},... 
                                'splittedTo', {splittedBoxesIDs});
        splitLog = [splitLog splitLogEntry];
    end
    
    %Create merge log entries
    mergeLog = [];
    for i=1:newBoxesLength
        mergedBoxesIDs = oldBoxesIds(matchMatrix(:,i) == 2);
        
        
        if(size(mergedBoxesIDs) <= 1)
            %found nothing
            continue;
        end
        
        %Each log info has the inform
        mergeLogEntry = struct( 'mergedFrom', {mergedBoxesIDs},... 
                                'mergedTo', {newBoxesIds(i)});
        mergeLog = [mergeLog mergeLogEntry];
    end
    
    mergeSplitLog = struct('splits', {splitLog}, 'merges', {mergeLog});
    
function color = getRegionTypeColor(typeIdentifiers, box)

color = [0, 1, 0]; %green

%calculate if is vehicle
vehicleErrorMargin = typeIdentifiers(1,3)/100;
vehicleMinWidth = typeIdentifiers(1,1) - vehicleErrorMargin * typeIdentifiers(1,1);
vehicleMaxWidth = typeIdentifiers(1,1) + vehicleErrorMargin * typeIdentifiers(1,1);
vehicleMinHeight = typeIdentifiers(1,2) - vehicleErrorMargin * typeIdentifiers(1,2);
vehicleMaxHeight = typeIdentifiers(1,2) + vehicleErrorMargin * typeIdentifiers(1,2);
vehicleMinRatio = typeIdentifiers(1,1)/typeIdentifiers(1,2) - vehicleErrorMargin * ...
                  typeIdentifiers(1,1)/typeIdentifiers(1,2);
vehicleMaxRatio = typeIdentifiers(1,1)/typeIdentifiers(1,2) + vehicleErrorMargin * ...
                  typeIdentifiers(1,1)/typeIdentifiers(1,2);

isVehicle = (box(3) >= vehicleMinWidth && box(3) <= vehicleMaxWidth && ...
            box(4) >= vehicleMinHeight && box(4) <= vehicleMaxHeight && ...
            box(3)/box(4) >= vehicleMinRatio && box(3)/box(4) <= vehicleMaxRatio && box(3)>box(4));

%calculate if is person
personErrorMargin = typeIdentifiers(2,3)/100;
personMinWidth = typeIdentifiers(2,1) - personErrorMargin * typeIdentifiers(2,1);
personMaxWidth = typeIdentifiers(2,1) + personErrorMargin * typeIdentifiers(2,1);
personMinHeight = typeIdentifiers(2,2) - personErrorMargin * typeIdentifiers(2,2);
personMaxHeight = typeIdentifiers(2,2) + personErrorMargin * typeIdentifiers(2,2);
personMinRatio = typeIdentifiers(2,1)/typeIdentifiers(2,2) - vehicleErrorMargin * ...
                  typeIdentifiers(2,1)/typeIdentifiers(2,2);
personMaxRatio = typeIdentifiers(2,1)/typeIdentifiers(2,2) + vehicleErrorMargin * ...
                  typeIdentifiers(2,1)/typeIdentifiers(2,2);

isPerson = (box(3) >= personMinWidth && box(3) <= personMaxWidth && ...
            box(4) >= personMinHeight && box(4) <= personMaxHeight && ...
            box(3)/box(4) >= personMinRatio && box(3)/box(4) <= personMaxRatio && box(3)<box(4));
        
if(isVehicle && ~isPerson)
    color = [1 0 0];
end

if(isPerson && ~isVehicle)
    color = [0 0 1];
end
    
%--------------------------------------------------------------------------    
%-- Utility functions related with boxes using the X1, Y1, X2, Y2 system --
%--------------------------------------------------------------------------
function newBoxes = toCoorSystem(boxes)
    newBoxes = boxes;
    newBoxes(:,3) = newBoxes(:,1) + newBoxes(:,3);
    newBoxes(:,4) = newBoxes(:,2) + newBoxes(:,4);

function newBoxes = fromCoorSystem(boxes)
    newBoxes = boxes;
    newBoxes(:,3) = newBoxes(:,3) - newBoxes(:,1);
    newBoxes(:,4) = newBoxes(:,4) - newBoxes(:,2);

function area = getArea(boxes)
    area = (boxes(:,3)-boxes(:,1)) * (boxes(:,4)-boxes(:,2));
    
function area = getIntersectionArea(box1, box2)
    area = 0;
    if( box1(3)<box2(1)||... X1+W1>X2 
        box2(3)<box1(1)||... X2+W2>X1 
        box1(4)<box2(2)||... Y1+H1>Y2 
        box2(4)<box1(2)) %   Y2+H2>Y1
        %no intersection
        return;
    end
    
    intersectionBox = [max(box1(1:2),box2(1:2)) min(box1(3:4),box2(3:4))];
    area = getArea(intersectionBox);


% --- Executes during object creation, after setting all properties.
function onScreenTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to onScreenTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in originalButton.
function originalButton_Callback(hObject, eventdata, handles)
% hObject    handle to originalButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.binaryButton.Value = 0;
% Hint: get(hObject,'Value') returns toggle state of originalButton


% --- Executes on button press in binaryButton.
function binaryButton_Callback(hObject, eventdata, handles)
% hObject    handle to binaryButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.originalButton.Value = 0;
% Hint: get(hObject,'Value') returns toggle state of binaryButton
