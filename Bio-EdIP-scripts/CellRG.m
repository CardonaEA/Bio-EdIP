function varargout = CellRG(varargin)
% CELLRG MATLAB code for CellRG.fig
%      CELLRG, by itself, creates a new CELLRG or raises the existing
%      singleton*.
%
%      H = CELLRG returns the handle to a new CELLRG or the handle to
%      the existing singleton*.
%
%      CELLRG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CELLRG.M with the given input arguments.
%
%      CELLRG('Property','Value',...) creates a new CELLRG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CellRG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CellRG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CellRG

% Last Modified by GUIDE v2.5 10-Jul-2015 20:59:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CellRG_OpeningFcn, ...
                   'gui_OutputFcn',  @CellRG_OutputFcn, ...
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


% --- Executes just before CellRG is made visible.
function CellRG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CellRG (see VARARGIN)

set(handles.figure1,'Name','Bio-EdIP version 1.1')
set(handles.b_RunAnalysis,'Enable','off')
set(handles.b_ExportData,'Enable','off')
set(handles.b_PreviousIm,'Enable','off')
set(handles.b_NextIm,'Enable','off')
set(handles.b_Polygon,'Enable','off')
set(handles.b_ZoomOff,'Enable','off')
set(handles.b_Done,'Enable','off')
set(handles.cbox_Manual,'Enable','off')
set(handles.slider_Blocks,'Enable','off')
set(handles.slider_Threshold,'Enable','off')
set(handles.b_ResetManual,'Enable','off')
set(handles.i_Current,'xtick',[],'ytick',[])
set(handles.i_ImSeg,'xtick',[],'ytick',[])

% Choose default command line output for CellRG
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CellRG wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CellRG_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in b_OpenFile.
function b_OpenFile_Callback(hObject, eventdata, handles)
% hObject    handle to b_OpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.b_Polygon,'Enable','off')
set(handles.b_RunAnalysis,'Enable','off')
drawnow

% Load Imge 
[filename,pathname] = uigetfile({'*.tif';'*.jpg';'*.png';'*.jp2';'*.gif';'*.bmp'},'Select the image file');

% If selected any image... continue  
if filename ~= 0 
    ruta = [pathname filename];
    set(handles.figure1,'Name',['Bio-EdIP  -  ' ruta]);
    f=imread(ruta);
    [i1,i2,map] = size(f);
    if map ==3
        fg = rgb2gray(f);
    else 
        fg = f;
    end
    % Converted Fr a Cell variable
    fr = cell(1,1);
    % Corrected Image whit a median filter [20 x 20]
    m = medfilt2(fg,[20 20],'symmetric');
    fr{1} = iluminationMat(fg,m);
    % Show a corrected image at axes i_Current    
    axes(handles.i_Current)
    imshow(fr{1}), axis off 
    % Set enable Run Analysus and Polygon bottoms  
    set(handles.b_RunAnalysis,'Enable','on')
    set(handles.b_Polygon,'Enable','on')
    % Shared a number of image file
    handles.numfiles = 1;
    % Shared in GUI next variables
    handles.fr = fr;
    handles.filename = filename;
    handles.pathname = pathname;
    handles.ruta = [ruta '  -  Single Analysis'];
    %Create a listfiles of 1 file
    listfiles = cell(1,1);
    listfiles{1} = filename;
    handles.listfiles = listfiles; 
    % count
    handles.n = 1;
else
    msgbox('Image no load','Error while opening file','error')
end
guidata(hObject, handles);



% --- Executes on button press in b_OpenFolder.
function b_OpenFolder_Callback(hObject, eventdata, handles)
% hObject    handle to b_OpenFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.b_Polygon,'Enable','off')
set(handles.b_RunAnalysis,'Enable','off')
drawnow

% Load folder
folder = uigetdir;
if folder ~= 0
    % Set foder as GUI work folder
    cd (folder);
    % Specify a Image extension 
    exts = {'*.tif';'*.jpg';'*.png';'*.jp2';'*.gif';'*.bmp'};
    % Define a numfiles: a count variable that indicate the number of image files 
    numfiles = 0;
    % Create a empy Cell 
    listfiles = {};
    set(handles.figure1,'Name','Bio-EdIP  -  Loading Folder');
    drawnow
    % Search a image files {exts} 
    for i = 1:numel(exts)
        files = dir(exts{i});
        numfiles = numfiles + numel(files);
        listfiles = [listfiles{:} {files.name}]';
    end
    if numfiles ~= 0
        % Define a Cell with a array of numfiles elements 
        Im = cell(1,numfiles);
        % Read imges of selected folder, corrected and save with Cell
        % Waitbar: Open folder
        op = waitbar(0,'Loading and filtering files...');
        set (op, 'WindowStyle','modal', 'CloseRequestFcn','')
        for j = 1 : numfiles;
            Im{j} = imread(listfiles{j});
            [M,N,map] = size (Im{j});
            if map == 3
                Im{j} = rgb2gray(Im{j});
            end
            m = medfilt2(Im{j},[20 20],'symmetric');
            fr = iluminationMat(Im{j},m);
            Im{j} = fr;
            waitbar(j / numfiles)
            drawnow
        end
        % Show a corrected image element 1 at axes i_Current
        axes(handles.i_Current)
        imshow(Im{1}), axis off 
        set(handles.figure1,'Name',['Bio-EdIP  -  ' folder]);
        % Save cell Im on fr 
        fr = Im;
        % Set enable run analysis bottom
        set(handles.b_RunAnalysis,'Enable','on')
        handles.fr = fr;
        % Shared a number and name of image files in selected folder
        handles.numfiles = numfiles;
        handles.listfiles = listfiles; 
        handles.ruta = [folder '  -  Multiple Analysis'];
        % count
        handles.n = 1;
        %delete waitbar
        delete (op)
    else
        msgbox('Folder: No Image files','Error while opening folder','error')
    end
        
else
    msgbox('Folder no load','Error while opening folder','error')
end
guidata(hObject, handles);


% --- Executes on button press in b_RunAnalysis.
function b_RunAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to b_RunAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set Disable image bottoms
set(handles.b_OpenFile,'Enable','off')
set(handles.b_OpenFolder,'Enable','off')
% When open a file
% Show Processing Folder
set(handles.figure1,'Name',['Bio-EdIP  -  ' handles.ruta '   -   Processing:   ' num2str(handles.numfiles) '  Images...']);
drawnow
    
% Set disable Run Analysus and Polygon bottoms
set(handles.b_Polygon,'Enable','off')
set(handles.b_RunAnalysis,'Enable','off')
drawnow

% Define a Cell with a array of numfiles elements
B = cell(1,handles.numfiles);
Breset = cell(1,handles.numfiles);
F = cell(1,handles.numfiles);
F1 = cell(1,handles.numfiles);
TSI = cell(1,handles.numfiles);

S = cell(1,handles.numfiles);
y = cell(1,handles.numfiles);

OpA = cell(1,handles.numfiles);
OpAreset = cell(1,handles.numfiles);
ClA = cell(1,handles.numfiles); 
ClAreset = cell(1,handles.numfiles);
OpP = cell(1,handles.numfiles);
OpPreset = cell(1,handles.numfiles);
ClP = cell(1,handles.numfiles);
ClPreset = cell(1,handles.numfiles);

% Cell cbox_manual, T, sliders
Blocks = cell(1,handles.numfiles);
T = cell(1,handles.numfiles);
cbox = cell(1,handles.numfiles);

% Waitbar: Processing step
pro = waitbar(0,'Segmenting images... Status is shown in the title bar');
set (pro, 'WindowStyle','modal', 'CloseRequestFcn','');

% Processing  since 1 to numberfiles
for a = 1 : handles.numfiles
    y{a} = edge_sobel(handles.fr{a});
    [h,n] = imhist(handles.fr{a});
    [maxi,id] = max(h);
    v = id - 1;
    vi = v-1:v+1; 
    % Looking for intensity levels with non true pixels 
    if numel(find (handles.fr{a} == vi(1))) == 0
        vi(1) = v-2;
    end
    if numel(find (handles.fr{a} == vi(3))) == 0
        vi(3) = v+2;    
    end
    S{a} = ismember(handles.fr{a},vi);
    % Create a cell variable with default values
    Blocks{a} = 0.5;
    T{a} = 3;
    cbox{a} = 0;
    % Block processing
    [S2,TSD,SD] = SeedBlock(S{a},0.5);
    g = Regiongrow_Mat(y{a},S2,3);
    % Save in a cell every image processed 
    z = imclose(g,strel('disk',6,0));
    % Save in a cell every binary image for export
    B{a} = double(z);
    % Save in a cell every binary image for reset 
    Breset{a} = B{a};
    % Save in a cell every showed image 
    F{a} = im2overlay(handles.fr{a},z,'p');
    % Save in a cell every overlayed image
    F1{a} = im2overlay(handles.fr{a},z,'f');

    % calculate cell free and cell area
    Bi = sum(z(:));
    TSI{a} = size(handles.fr{a},1)*size(handles.fr{a},2);
    OpA{a} = (Bi/TSI{a})*100; OpAreset{a} = OpA{a};
    ClA{a} = 100 - OpA{a};  ClAreset{a} = ClA{a};
    OpP{a} = Bi;  OpPreset{a} = OpP{a};
    ClP{a} = TSI{a} - Bi;  ClPreset{a} = ClP{a};
    % Showing process
    set(handles.figure1,'Name',['Bio-EdIP  -  ' handles.ruta '   -   Processed:   ' num2str(a) '/' num2str(handles.numfiles) '  Images...']);
    drawnow
    %Waitbar
    waitbar(a / handles.numfiles)
    drawnow
end

% Imges to manual reset
Freset = F;
F1reset = F1;
% Show image at ImSeg axes
axes(handles.i_ImSeg)
imshow(F{1}), axis off
% Show analysis values at interface 
set(handles.eT_OpArea,'String',num2str(OpA{1}));
set(handles.eT_OpPixels,'String',num2str(OpP{1}));
set(handles.eT_ClArea,'String',num2str(ClA{1}));
set(handles.eT_ClPixels,'String',num2str(ClP{1}));

% Set enable next bottoms
set(handles.b_ExportData,'Enable','on')
set(handles.cbox_Manual,'Enable','on')
set(handles.b_Done,'Enable','on')
set(handles.b_ZoomOff,'Enable','on')

% When open a file
if handles.numfiles == 1
    % Show Processing Image 
    set(handles.figure1,'Name',['Bio-EdIP  -  ' handles.ruta '   -   Processed:   ' num2str(a) '/' num2str(handles.numfiles) '  Images']);
end
% When open a folder
if handles.numfiles > 1
    % Show Processing Folder
    set(handles.figure1,'Name',['Bio-EdIP  -  ' handles.ruta '   -   Processed:   ' num2str(a) '/' num2str(handles.numfiles) '  Images']);
    set(handles.b_NextIm,'Enable','on')
end

% Show Image 1/numfiles
set(handles.eT_NumIm,'String',['Image:  1/' num2str(handles.numfiles)]);
set(handles.eT_NumImC,'String',['Image:  1/' num2str(handles.numfiles)]);

% Numerical Varibles to manual reset 
handles.OpAreset = OpAreset;
handles.ClAreset = ClAreset;
handles.OpPreset = OpPreset;
handles.ClPreset = ClPreset;
% Numericla Variables to export
handles.col1 = OpA; 
handles.col2 = OpP;
handles.col3 = ClA;
handles.col4 = ClP;
% Size of images to manual adjustment callback
handles.TSI = TSI;
% Images to export is user do not reaize a manual adjustment
handles.F = F;
handles.F1 = F1;
handles.B = B;
% Sobel gradient and seeds image
handles.S = S;
handles.y = y;
% Shared Imges to manual reset
handles.Freset = Freset;
handles.F1reset = F1reset;
handles.Breset = Breset;
% Shared a cell variables with default values
handles.Blocks = Blocks;
handles.T = T;
handles.cbox = cbox;
% delete Waitbar
delete (pro)

guidata(hObject, handles);


% --- Executes on button press in b_ExportData.
function b_ExportData_Callback(hObject, eventdata, handles)
% hObject    handle to b_ExportData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Savin data
set(handles.figure1,'Name',['Bio-EdIP  -  '  '   Saving...']);
drawnow
% Images to export
ImSave = handles.F;
ImSave1 = handles.F1;
ImSaveB = handles.B;
filename = handles.listfiles;
% Save cell varibles with numericla values
col1 = handles.col1; 
col2 = handles.col2;
col3 = handles.col3;
col4 = handles.col4;
% Save cell varibles with Adjust parameters
col5 = handles.Blocks;
col6 = handles.T;
% Cat independiente measures
Elistfiles = {'Image',handles.listfiles{:}};
Ecol1 = {'Cell Free Region [%]',col1{:}};
Ecol2 = {'Cell Free Region [Px]',col2{:}};
Ecol3 = {'Cell Covered Region [%]',col3{:}};
Ecol4 = {'Cell Covered Region [Px]',col4{:}};
Ecol5 = {'Blocks',col5{:}};
Ecol6 = {'Threshold',col6{:}};
% Cat all data
d = {Elistfiles{:}; Ecol1{:}; Ecol2{:}; Ecol3{:}; Ecol4{:}; Ecol5{:}; Ecol6{:}};
% get dir to save    
folder = uigetdir('','Select folder to save');
if folder ~= 0
    % Waitbar: Saving step
    sf = waitbar(0,'Saving data... Please wait');
    set (sf, 'WindowStyle','modal', 'CloseRequestFcn','');
    % Save images
    for s = 1:handles.numfiles
        imwrite(ImSave{s},[folder '\' filename{s}(1:end-4) '_Outline' '.tif'],'compression','none')
        imwrite(ImSave1{s},[folder '\' filename{s}(1:end-4) '_Overlay' '.tif'],'compression','none')
        imwrite(ImSaveB{s},[folder '\' filename{s}(1:end-4) '_Binary' '.tif'],'compression','none')
        %Waitbar
        waitbar(s / handles.numfiles)
        drawnow
    end
    % Save data 
    xlswrite([folder '\' 'Analysis.xls'], d)
    tocite = {'How to cite';'Cardona A, Ariza-Jiménez L, Uribe D, Arroyave JC, Galeano J, Cortés-Mancera FM. Bio-EdIP: An Automatic Approach for In vitro Cell Confluence Images Quantification. Comput Methods Programs Biomed 2017;145:23–33. doi:10.1016/j.cmpb.2017.03.026'}; 
    xlswrite([folder '\' 'Analysis.xls'], tocite,1,'A9')
    %xlswrite([folder '\' 'Analysis.xlsx'], d)
    % Saved finished
    set(handles.figure1,'Name',['Bio-EdIP  -  '  '   Saved']);
    % delete  waitbar
    delete (sf)
else
    set(handles.figure1,'Name',['Bio-EdIP  -  '  '   No Saved']);
end



% --- Executes on button press in b_PreviousIm.
function b_PreviousIm_Callback(hObject, eventdata, handles)
% hObject    handle to b_PreviousIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% count
n = handles.n;
n = n-1;
%Show image
axes(handles.i_ImSeg)
imshow(handles.F{n}), axis off
axes(handles.i_Current)
imshow(handles.fr{n}), axis off

% Show values of selected image, I use a reset cells variables
set(handles.eT_OpArea,'String',num2str(handles.col1{n}));
set(handles.eT_OpPixels,'String',num2str(handles.col2{n}));
set(handles.eT_ClArea,'String',num2str(handles.col3{n}));
set(handles.eT_ClPixels,'String',num2str(handles.col4{n}));
% Show Image n/numfiles
set(handles.eT_NumIm,'String',['Image:  ' num2str(n) '/' num2str(handles.numfiles)]);
set(handles.eT_NumImC,'String',['Image:  ' num2str(n) '/' num2str(handles.numfiles)]);
% disble Previous Im when n == 1
if n == 1
    set(handles.b_PreviousIm,'Enable','off')
    set(handles.b_NextIm,'Enable','on')
    drawnow
end
% Set cbox
set(handles.cbox_Manual,'Value',handles.cbox{n});
% Set disable when cbox == 0
if handles.cbox{n} == 0
    set(handles.slider_Blocks,'Enable','off')
    set(handles.slider_Threshold,'Enable','off')
    set(handles.eT_ValueA,'String','Value A');
    set(handles.eT_ValueT,'String','Value T');
    set(handles.b_ResetManual,'Enable','off')
%     drawnow
end
if handles.cbox{n} == 1
    set(handles.slider_Blocks,'Enable','on')
    set(handles.slider_Threshold,'Enable','on')
    set(handles.eT_ValueA,'String',num2str(handles.Blocks{n}));
    set(handles.eT_ValueT,'String',num2str(handles.T{n})); 
    set(handles.slider_Blocks,'Value',handles.Blocks{n});
    set(handles.slider_Threshold,'Value',handles.T{n});
    set(handles.b_ResetManual,'Enable','off')
    if get(handles.slider_Blocks,'Value') ~= 0.5 || get(handles.slider_Threshold,'Value') ~= 3
        set(handles.b_ResetManual,'Enable','on')
    end
%     drawnow
end
% enable
set(handles.b_NextIm,'Enable','on')
% Shared new value of count
handles.n = n;
guidata(hObject, handles);


% --- Executes on button press in b_NextIm.
function b_NextIm_Callback(hObject, eventdata, handles)
% hObject    handle to b_NextIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% count
n = handles.n;
n = n+1;
%Show image
axes(handles.i_ImSeg)
imshow(handles.F{n}), axis off
axes(handles.i_Current)
imshow(handles.fr{n}), axis off

% Show values of selected image, I use a reset cells variables
set(handles.eT_OpArea,'String',num2str(handles.col1{n}));
set(handles.eT_OpPixels,'String',num2str(handles.col2{n}));
set(handles.eT_ClArea,'String',num2str(handles.col3{n}));
set(handles.eT_ClPixels,'String',num2str(handles.col4{n}));
% Show Image n/numfiles
set(handles.eT_NumIm,'String',['Image:  ' num2str(n) '/' num2str(handles.numfiles)]);
set(handles.eT_NumImC,'String',['Image:  ' num2str(n) '/' num2str(handles.numfiles)]);
% disble Next Im when n == numfiles
if n == handles.numfiles
    set(handles.b_NextIm,'Enable','off')
    drawnow
end
% Set cbox
set(handles.cbox_Manual,'Value',handles.cbox{n});
% Set disable when cbox == 0
if handles.cbox{n} == 0
    set(handles.slider_Blocks,'Enable','off')
    set(handles.slider_Threshold,'Enable','off')
    set(handles.eT_ValueA,'String','Value A');
    set(handles.eT_ValueT,'String','Value T');
    set(handles.b_ResetManual,'Enable','off')
%     drawnow
end
if handles.cbox{n} == 1
    set(handles.slider_Blocks,'Enable','on')
    set(handles.slider_Threshold,'Enable','on')
    set(handles.eT_ValueA,'String',num2str(handles.Blocks{n}));
    set(handles.eT_ValueT,'String',num2str(handles.T{n})); 
    set(handles.slider_Blocks,'Value',handles.Blocks{n});
    set(handles.slider_Threshold,'Value',handles.T{n});
    set(handles.b_ResetManual,'Enable','off')
    if get(handles.slider_Blocks,'Value') ~= 0.5 || get(handles.slider_Threshold,'Value') ~= 3
        set(handles.b_ResetManual,'Enable','on')
    end
%     drawnow
end
% set enable previous im
set(handles.b_PreviousIm,'Enable','on')
% Shared new value of count 
handles.n = n;
guidata(hObject, handles);


function eT_OpArea_Callback(hObject, eventdata, handles)
% hObject    handle to eT_OpArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eT_OpArea as text
%        str2double(get(hObject,'String')) returns contents of eT_OpArea as a double


% --- Executes during object creation, after setting all properties.
function eT_OpArea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eT_OpArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eT_ClArea_Callback(hObject, eventdata, handles)
% hObject    handle to eT_ClArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eT_ClArea as text
%        str2double(get(hObject,'String')) returns contents of eT_ClArea as a double


% --- Executes during object creation, after setting all properties.
function eT_ClArea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eT_ClArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eT_OpPixels_Callback(hObject, eventdata, handles)
% hObject    handle to eT_OpPixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eT_OpPixels as text
%        str2double(get(hObject,'String')) returns contents of eT_OpPixels as a double


% --- Executes during object creation, after setting all properties.
function eT_OpPixels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eT_OpPixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eT_ClPixels_Callback(hObject, eventdata, handles)
% hObject    handle to eT_ClPixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eT_ClPixels as text
%        str2double(get(hObject,'String')) returns contents of eT_ClPixels as a double


% --- Executes during object creation, after setting all properties.
function eT_ClPixels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eT_ClPixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in cbox_Manual.
function cbox_Manual_Callback(hObject, eventdata, handles)
% hObject    handle to cbox_Manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbox_Manual

% Save cbox manual value
handles.cbox{handles.n} = get(hObject,'Value');
% Set values of cbox
if handles.cbox{handles.n} == 1 
    set(handles.slider_Blocks,'Enable','on')
    set(handles.slider_Threshold,'Enable','on')
    set(handles.eT_ValueA,'String',num2str(handles.Blocks{handles.n}));
    set(handles.eT_ValueT,'String',num2str(handles.T{handles.n}));
    set(handles.slider_Blocks,'Value',handles.Blocks{handles.n});
    set(handles.slider_Threshold,'Value',handles.T{handles.n});    
    drawnow    
    if get(handles.slider_Blocks,'Value') ~= 0.5 || get(handles.slider_Threshold,'Value') ~= 3
        set(handles.b_ResetManual,'Enable','on')
    end
end
if handles.cbox{handles.n} == 0
    set(handles.slider_Blocks,'Enable','off')
    set(handles.slider_Threshold,'Enable','off')
    set(handles.b_ResetManual,'Enable','off')
    set(handles.eT_ValueA,'String','Value A');
    set(handles.eT_ValueT,'String','Value T');
end
guidata(hObject, handles);


% --- Executes on slider movement.
function slider_Blocks_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Blocks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% count
n = handles.n;
% Manual adjustment initialized
% When open a file or folder
set(handles.figure1,'Name',['Bio-EdIP  -  ' handles.ruta  '   -   Manual Adjustment in Process ...']);
drawnow

% Disable sliders while manual adjustmen run
set(handles.slider_Blocks,'Enable','off')
set(handles.slider_Threshold,'Enable','off')
% Set disable bottoms while manual adjustmen finished
set(handles.cbox_Manual,'Enable','off')
set(handles.b_ResetManual,'Enable','off')
set(handles.b_ExportData,'Enable','off')
set(handles.b_Done,'Enable','off')
set(handles.b_ZoomOff,'Enable','off')
set(handles.b_NextIm,'Enable','off')
set(handles.b_PreviousIm,'Enable','off')
drawnow

% get values of sliders
Blocks = get(handles.slider_Blocks,'Value');
T = get(handles.slider_Threshold,'Value');
%Show values of sliders
set(handles.eT_ValueA,'String',num2str(Blocks));
set(handles.eT_ValueT,'String',num2str(T));
drawnow

% re- processing image {n}
[S2,TSD,SD] = SeedBlock(handles.S{n},Blocks);
g = Regiongrow_Mat(handles.y{n},S2,T);
z = imclose(g,strel('disk',6,0));
% Calculated the variables manual modifyed
Bi = sum(z(:));
OpA = (Bi/handles.TSI{n})*100; 
ClA = 100 - OpA; 
OpP = Bi; 
ClP = handles.TSI{n} - Bi; 
%Save at n position of cell, the image manual modifyed
handles.F{n} = im2overlay(handles.fr{n},z,'p');
handles.F1{n} = im2overlay(handles.fr{n},z,'f');
handles.B{n} = double(z);
%Save at n position of cell, the values of manual adjustment
handles.col1{n} = OpA; 
handles.col2{n} = OpP;
handles.col3{n} = ClA;
handles.col4{n} = ClP;
%Save at n position of cell, the values of manual adjustment variables
handles.Blocks{n} = Blocks;
handles.T{n} = T;
%Showa image manual modifyed
axes(handles.i_ImSeg)
imshow(handles.F{n}), axis off

% Show values of manual adjustment
set(handles.eT_OpArea,'String',num2str(OpA));
set(handles.eT_OpPixels,'String',num2str(OpP));
set(handles.eT_ClArea,'String',num2str(ClA));
set(handles.eT_ClPixels,'String',num2str(ClP));
%Set Bottoms
set(handles.cbox_Manual,'Enable','on')
set(handles.b_ResetManual,'Enable','on')
set(handles.b_ExportData,'Enable','on')
set(handles.b_Done,'Enable','on')
set(handles.b_ZoomOff,'Enable','on')
%Set botoms
if handles.n == handles.numfiles
    set(handles.b_NextIm,'Enable','off')
    drawnow
else
    set(handles.b_NextIm,'Enable','on')
end
if handles.n == 1
    set(handles.b_PreviousIm,'Enable','off')
    drawnow
else
    set(handles.b_PreviousIm,'Enable','on')
end
% Enable sliders when manual adjustmen finished
set(handles.slider_Blocks,'Enable','on')
set(handles.slider_Threshold,'Enable','on')

% Manual adjustment finished
% When open a file or folder
set(handles.figure1,'Name',['Bio-EdIP  -  ' handles.ruta  '   -   Manual Adjustment Finished ']);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_Blocks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Blocks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_Threshold_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
slider_Blocks_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function slider_Threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in b_ResetManual.
function b_ResetManual_Callback(hObject, eventdata, handles)
% hObject    handle to b_ResetManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% count
n = handles.n;
% show in ImSeg the reset image 
axes(handles.i_ImSeg)
imshow(handles.Freset{n}), axis off

% default values
handles.Blocks{n} = 0.5;
handles.T{n} = 3;
%Show values of sliders
set(handles.eT_ValueA,'String',num2str(handles.Blocks{n}));
set(handles.eT_ValueT,'String',num2str(handles.T{n}));
drawnow
% show defoult values at sliders
set(handles.slider_Blocks,'Value',0.5);
set(handles.slider_Threshold,'Value',3);

% show reset values of cell free and cell area
set(handles.eT_OpArea,'String',num2str(handles.OpAreset{n}));
set(handles.eT_OpPixels,'String',num2str(handles.OpPreset{n}));
set(handles.eT_ClArea,'String',num2str(handles.ClAreset{n}));
set(handles.eT_ClPixels,'String',num2str(handles.ClPreset{n}));
% Save teh reseted values at n position of cols cell
handles.col1{n} = handles.OpAreset{n}; 
handles.col2{n} = handles.OpPreset{n};
handles.col3{n} = handles.ClAreset{n};
handles.col4{n} = handles.ClPreset{n};
% Set disable reset
set(handles.b_ResetManual,'Enable','off')
%Set bottoms
if handles.n == handles.numfiles
    set(handles.b_NextIm,'Enable','off')
    drawnow
else
    set(handles.b_NextIm,'Enable','on')
end
if handles.n == 1
    set(handles.b_PreviousIm,'Enable','off')
    drawnow
else
    set(handles.b_PreviousIm,'Enable','on')
end
% Save at position n the image reseted
handles.F{n} = handles.Freset{n};
handles.F1{n} = handles.F1reset{n};
handles.B{n} = handles.Breset{n}; 
guidata(hObject, handles);



% --- Executes on button press in b_Polygon.
function b_Polygon_Callback(hObject, eventdata, handles)
% hObject    handle to b_Polygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Delimitation with polygon
set(handles.b_Polygon,'Enable','off')
set(handles.figure1,'Name',['Bio-EdIP  -  ' handles.ruta  '   -   Polygon Delimitation Selected']);
drawnow
set(handles.b_RunAnalysis,'Enable','off')
drawnow
set(handles.b_ExportData,'Enable','off')
set(handles.b_Done,'Enable','off')
set(handles.b_OpenFile,'Enable','off')
set(handles.b_OpenFolder,'Enable','off')
set(handles.b_ZoomOff,'Enable','on')
drawnow
% Set None to idicate that there isn't polygon draw
set(handles.eT_OpArea,'String','None');
set(handles.eT_OpPixels,'String','None');
set(handles.eT_ClArea,'String','None');
set(handles.eT_ClPixels,'String','None');
% Chose axes
axes(handles.i_ImSeg)
imshow(handles.fr{1}), axis off
% beggin draw polygon
BW = roipoly(handles.fr{1});
% Size of BW
[a,b,d] = size (BW);
% msgbox to polygon instructions
%msgbox('Please see the user guide to complet the manual delimitation... To cancel polygon delimitation press Esc','Help','help')
%drawnow
% No polygon delimitation 
if a == 0 && b== 0
    set(handles.figure1,'Name',['Bio-EdIP  -  ' handles.ruta  '   -   Polygon Delimitation Canceled']);
    drawnow
    set(handles.b_Polygon,'Enable','on')
    set(handles.b_Done,'Enable','on')
end
% Polygon delimitation done
if a ~= 0 && b~= 0
    %Create images to export
    P = im2overlay(handles.fr{1},BW,'p');
    F1 = im2overlay(handles.fr{1},BW,'f');
    %calculate values to show at interface
    Bi = sum(BW(:));
    TSI = size(handles.fr{1},1)*size(handles.fr{1},2);
    OpA = (Bi/TSI)*100; 
    ClA = 100 - OpA; 
    OpP = Bi; 
    ClP = TSI - Bi; 
    % Show Values
    set(handles.eT_OpArea,'String',num2str(OpA));
    set(handles.eT_OpPixels,'String',num2str(OpP));
    set(handles.eT_ClArea,'String',num2str(ClA));
    set(handles.eT_ClPixels,'String',num2str(ClP));
    % Chose axes to show poligon delimitated image
    axes(handles.i_ImSeg)
    imshow(P), axis off;
    % Poligon delimitation finishes
    set(handles.figure1,'Name',['Bio-EdIP  -  ' handles.ruta  '   -   Polygon Delimitation Finished']);
    set(handles.b_ExportData,'Enable','on')
    set(handles.b_Done,'Enable','on')
    % save variables to export
    % frist create a cell varibles (equal to other parts of code) and asigned a
    % value
    col1 = cell(1,1); col1{1} = OpA;
    col2 = cell(1,1); col2{1} = OpP;
    col3 = cell(1,1); col3{1} = ClA;
    col4 = cell(1,1); col4{1} = ClP;
    Fc = cell(1,1); Fc{1} = P;
    F1c = cell(1,1); F1c{1} = F1;
    Bc = cell(1,1); Bc{1} = double(BW);
    Blocks = cell(1,1); Blocks{1} = 'NA';
    T = cell(1,1); T{1} = 'NA';
    % Second: shared cell varibles 
    handles.col1 = col1; 
    handles.col2 = col2;
    handles.col3 = col3;
    handles.col4 = col4;
    handles.F = Fc;
    handles.F1 = F1c;
    handles.B = Bc;
    handles.Blocks = Blocks;
    handles.T = T;
    guidata(hObject, handles);
end

% --- Executes on button press in b_ZoomOff.
function b_ZoomOff_Callback(hObject, eventdata, handles)
% hObject    handle to b_ZoomOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

zoom(handles.i_ImSeg,'out')
zoom(handles.i_Current,'out')
drawnow
zoom off


% --- Executes on button press in b_Done.
function b_Done_Callback(hObject, eventdata, handles)
% hObject    handle to b_Done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.figure1,'Name','Bio-EdIP version 1.1')
set(handles.b_OpenFile,'Enable','on')
set(handles.b_OpenFolder,'Enable','on')
set(handles.b_RunAnalysis,'Enable','off')
set(handles.b_ExportData,'Enable','off')
set(handles.b_PreviousIm,'Enable','off')
set(handles.b_NextIm,'Enable','off')
set(handles.b_Polygon,'Enable','off')
set(handles.b_ZoomOff,'Enable','off')
set(handles.b_Done,'Enable','off')
set(handles.cbox_Manual,'Enable','off')
set(handles.slider_Blocks,'Enable','off')
set(handles.slider_Threshold,'Enable','off')
set(handles.b_ResetManual,'Enable','off')

set(handles.slider_Blocks,'Value',0.5);
set(handles.slider_Threshold,'Value',3);
set(handles.cbox_Manual,'Value',0);

set(handles.eT_OpArea,'String','Region [%]');
set(handles.eT_OpPixels,'String','Region [Px]');
set(handles.eT_ClArea,'String','Region [%]');
set(handles.eT_ClPixels,'String','Region [Px]');

set(handles.eT_ValueA,'String','Value A');
set(handles.eT_ValueT,'String','Value T');

set(handles.eT_NumIm,'String','Image');
set(handles.eT_NumImC,'String','Filtered Image');

cla(handles.i_Current,'reset')
cla(handles.i_ImSeg,'reset')

set(handles.i_Current,'xtick',[],'ytick',[])
set(handles.i_ImSeg,'xtick',[],'ytick',[])




function eT_ValueA_Callback(hObject, eventdata, handles)
% hObject    handle to eT_ValueA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eT_ValueA as text
%        str2double(get(hObject,'String')) returns contents of eT_ValueA as a double




% --- Executes during object creation, after setting all properties.
function eT_ValueA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eT_ValueA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eT_ValueT_Callback(hObject, eventdata, handles)
% hObject    handle to eT_ValueT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eT_ValueT as text
%        str2double(get(hObject,'String')) returns contents of eT_ValueT as a double


% --- Executes during object creation, after setting all properties.
function eT_ValueT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eT_ValueT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eT_NumIm_Callback(hObject, eventdata, handles)
% hObject    handle to eT_NumIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eT_NumIm as text
%        str2double(get(hObject,'String')) returns contents of eT_NumIm as a double


% --- Executes during object creation, after setting all properties.
function eT_NumIm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eT_NumIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eT_NumImC_Callback(hObject, eventdata, handles)
% hObject    handle to eT_NumImC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eT_NumImC as text
%        str2double(get(hObject,'String')) returns contents of eT_NumImC as a double


% --- Executes during object creation, after setting all properties.
function eT_NumImC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eT_NumImC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
