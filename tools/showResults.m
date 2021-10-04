function varargout = showResults(varargin)
% SHOWRESULTS MATLAB code for showResults.fig
%      SHOWRESULTS, by itself, creates a new SHOWRESULTS or raises the existing
%      singleton*.
%
%      H = SHOWRESULTS returns the handle to a new SHOWRESULTS or the handle to
%      the existing singleton*.
%
%      SHOWRESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHOWRESULTS.M with the given input arguments.
%
%      SHOWRESULTS('Property','Value',...) creates a new SHOWRESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before showResults_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to showResults_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help showResults

% Last Modified by GUIDE v2.5 19-Mar-2019 20:58:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @showResults_OpeningFcn, ...
    'gui_OutputFcn',  @showResults_OutputFcn, ...
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


% Style
laf = 'com.jgoodies.looks.plastic.Plastic3DLookAndFeel';
javax.swing.UIManager.setLookAndFeel(laf);
if(~isdeployed)
  cd(fileparts(which(mfilename)));
end
% End initialization code - DO NOT EDIT


% --- Executes just before showResults is made visible.
function showResults_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to showResults (see VARARGIN)

% Choose default command line output for showResults
handles.output = hObject;


% Add Path
addpath(genpath('../tools/'));
addpath(genpath('../util/'));
addpath(genpath('../rnmf/'));
addpath(genpath('../segment/'));

% Update handles structure
guidata(hObject, handles);
pushbuttonLoadTable_Callback(hObject, eventdata, handles);

% UIWAIT makes showResults wait for user response (see UIRESUME)
% uiwait(handles.showResults);


% --- Outputs from this function are returned to the command line.
function varargout = showResults_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenuParameter.
function popupmenuParameter_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuParameter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuParameter
currParam = get(handles.popupmenuParameter,'Value');
table = get(handles.uitableParameter, 'Data');
tableSelect = get(handles.uitableSelectedValues, 'Data');


% CHange Value Entries
if ischar(unique(cell2mat(table(1,currParam+1))))
    existingValues = (unique(table(:,currParam+1)));
else
    column = table(:,currParam+1);
    existingValues = unique(cell2mat(column));
    if(~iscell(existingValues))
        existingValues = num2cell(existingValues);
    end
end

currSetting = tableSelect(currParam,2);
setVar = 1;
for i = 1:numel(existingValues)
    if isequal( currSetting ,existingValues(i,1))
        setVar = i;
    end
end

set(handles.popupmenuValue, 'value', setVar);
set(handles.popupmenuValue,'String',existingValues);



% Plot Accuracy
plotTable(handles,hObject);





% --- Executes during object creation, after setting all properties.
function popupmenuParameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuValue.
function popupmenuValue_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuValue contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuValue

% Change current parameter - table entries
selectedValue=get(handles.popupmenuValue, 'value');
selectedValueString=get(handles.popupmenuValue, 'String');
selectedParameter=get(handles.popupmenuParameter, 'value');
tableValues = get(handles.uitableSelectedValues, 'Data');
num = str2double(selectedValueString(selectedValue));
if ~isnan(num)
    tableValues(selectedParameter,2) = {num};
else
    tableValues(selectedParameter,2) = selectedValueString(selectedValue);
end

set(handles.uitableSelectedValues, 'Data',tableValues);
tableValues(size(tableValues,1),1) = {'ID'};
id = getCurrentID(handles);
tableValues(size(tableValues,1),2) = id;
set(handles.uitableSelectedValues, 'Data',tableValues);

% Plot Video
loadCurVid(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupmenuValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderRunVideo_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRunVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
displayCurFrame(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderRunVideo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRunVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbuttonPlay.
function pushbuttonPlay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axesVideo);

% Get Video and Mask
res = handles.res;
mask = handles.mask;


%Check if Energy
entries = get(handles.popupmenuSelectVideo, 'String');
valueNr = get(handles.popupmenuSelectVideo, 'Value');
resCell = struct2cell(res);
vidShow = resCell{valueNr};
if strcmp(entries{valueNr},'Energy')
    plot(vidShow);
    set(handles.textFrame, 'String','x-axis: iterations');
else
    for currentFrame = 1: size(vidShow,3)
        % Plot Frame
        imshow(vidShow(:,:,currentFrame));
        set(handles.textFrame, 'String',['Frame: ', num2str(currentFrame)]);
        % Bounding Box
        if get(handles.checkboxWithMask, 'Value')
            if numel(mask) == 4
                %rectangle('Position',[mask(2),mask(1),mask(4), mask(3)],'Edgecolor', 'r');
                %maskGT = load_groundtruth_mask(video_name,1);
                %maskGT = maskGT.coordinates;
                rectangle('Position',[mask(2),mask(1),mask(4), mask(3)],'Edgecolor', 'r');
                %rectangle('Position',[maskGT(1),maskGT(2),maskGT(3), maskGT(4)],'Edgecolor', 'b');
            else
                hold on;
                currFrameMask = mask(:,:,currentFrame);
                currFrameMask(currFrameMask<0.75) = 0;
                B = bwboundaries(currFrameMask);
                visboundaries(B);
                hold off;
            end
        end
        drawnow;
    end
end
displayCurFrame(hObject, handles);



% --- Executes on button press in pushbuttonOpenFolderExplorer.
function pushbuttonOpenFolderExplorer_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOpenFolderExplorer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

winopen(handles.path);

% --- Executes on button press in checkboxWithMask.
function checkboxWithMask_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxWithMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxWithMask
displayCurFrame(hObject, handles);

% --- Executes on selection change in popupmenuSelectVideo.
function popupmenuSelectVideo_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSelectVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSelectVideo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSelectVideo
displayCurFrame(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuSelectVideo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSelectVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxSortTable.
function checkboxSortTable_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSortTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSortTable
newTableData = get(handles.uitableParameter,'Data'); 
sorted = get(handles.checkboxSortTable,'Value');
if sorted
    newTableData = sortrows(newTableData,size(newTableData,2),'descend');
else
    newTableData = sortrows(newTableData,1,'ascend');
end
set(handles.uitableParameter,'Data',newTableData); 



% --- Executes on button press in pushbuttonLoadTable.
function pushbuttonLoadTable_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hold all;
prepath = '../results/';
if ~exist(prepath,'dir')
    prepath = '../';
end
[file,path] = uigetfile([prepath,'*.xls'], 'Please select xls file.');
if file == 0
    return;
end
set(handles.showResults, 'Name', file);
loadedTable = readtable([path,file]);
handles.path = path;
handles.file = file;
guidata(hObject,handles)



% Table Data and Names
tableData = table2cell(loadedTable);
tableNames = loadedTable.Properties.VariableNames;

% Display Table
set(handles.uitableParameter, 'Data', tableData);
set(handles.uitableParameter, 'ColumnName',tableNames);
set(handles.uitableParameter, 'RowName',[]);

% PopupMenu Parameters
set(handles.popupmenuParameter,'Value',1); 
set(handles.popupmenuValue,'Value',1); 
nrParameter = size(tableNames,2);

% Table Names
tableNames = tableNames(2:nrParameter-3);
set(handles.popupmenuParameter,'String',tableNames);

% Table Entries
if ischar(unique(cell2mat(tableData(1,2))))
    entries = (unique(tableData(:,2)));
else
    entries = unique(cell2mat(tableData(:,2)));
    if(~iscell(entries))
        entries = num2cell(entries);
    end
end
set(handles.popupmenuValue,'String',entries);

% Init table with current status
curID = ones(size(tableNames,2),1);
setting =  cell2matTableEntries(tableData,tableNames,curID);
set(handles.uitableSelectedValues, 'RowName', []);
set(handles.uitableSelectedValues, 'ColumnName', []);
set(handles.uitableSelectedValues, 'Data', setting);
setting(size(setting,1)+1,1) = {'ID'};
id = getCurrentID(handles);
setting(size(setting,1),2) = id;
set(handles.uitableSelectedValues, 'Data', setting);
% Plot Accuracy Graph
plotTable(handles,hObject);

% Plot Video
loadCurVid(hObject,handles);

%% Functions




% Get Names from Tabel for indices
function setting =  cell2matTableEntries(tableData,tableNames,selectedValues)
    % Get Current Setting
%     value = get(handles.popupmenuValue,'Value');
%     valueParam = get(handles.popupmenuParameter,'Value')+1;
%     
%     % Set Selected Value in Popupmenu
%     selectedValues(valueParam) = value;
%     global selectedValues;  % Saves Current Setting

    % Get Current Setting for each Parameter
    setting = {};
    for val = 1:size(tableNames,2)
        if ischar(unique(cell2mat(tableData(1,val+1))))
            entry = (unique(tableData(:,val+1)));
            entry = entry(selectedValues(val));
            entry = cell2mat(entry);
        else
            entry = unique(cell2mat(tableData(:,val+1)));
            entry = entry(selectedValues(val));
        end
        
        
        setting{val,2} = entry;               % Return Current Parameter-Setting        
        setting{val,1} = tableNames{val};   % Return Coresponding Parameter Names
    end




function plotTable(handles,hObject)
    plotNr = get(handles.popupmenuParameter,'Value');
    tableData = get(handles.uitableParameter, 'Data');
    metric = get(handles.popupmenuClassificationMetric, 'Value') - 1; % 1 Acc, 2 rec, 3 prec 4 f1
    
    % Plot Graph
    axes(handles.axesAccuracy);
    nrParameter = size(tableData,2)-metric;
    deletedTableData = tableData;
    allParam = size(tableData,2);
    
    % Get Settings
    tableSelectValues = get(handles.uitableSelectedValues, 'Data');
    setValues = tableSelectValues(:,2);
    
    % for over every Parameter witout ID and Result and x-axis Parameter
    for i = 2:allParam-3
        
        % Check if Value for x-Axis
        if (i-1) == plotNr
            continue;
        end
        
        % Delete Rows in Table that are not in the Current Setting
        coli = deletedTableData(:,i);
        if ischar(setValues{i-1})
            deli = find( ~strcmp( (coli),setValues{i-1} ) );
        else
            deli = find(cell2mat(coli) ~= setValues{i-1});
        end
        deletedTableData(deli,:) = [];
        
    end
    
    % Check if Hold ON
    boolHold = get(handles.checkboxHoldOn,'Value');
    if boolHold
        hold on;
    else
        cla;
    end
 
    % Plot
    if(~ischar(cell2mat(deletedTableData(1,plotNr+1))))

        yValues = cell2mat(deletedTableData(:,nrParameter));
        xValues = cell2mat(deletedTableData(:,plotNr+1));
                
        if metric == 3 %F1 - Score
            rec = cell2mat(deletedTableData(:,allParam-1));
            prec = cell2mat(deletedTableData(:,allParam-2));
            yValues = (2 .* rec .* prec) ./ (rec + prec);
            yValues(isnan(yValues))=0;
        end
        
        if metric == 4 % IoU
            yValues = calc_intersection_over_union(handles);
            xValues = 0;
        end
        
        % sort
        [xValues,indices] = sort(xValues);
        yValues=yValues(indices);
        
        if boolHold
            sz = numel(handles.graphData);
            handles.graphData{sz+1} = {xValues,yValues};
        else
            handles.graphData = {};
            handles.graphData{1} = {xValues,yValues};
        end
        [maxVal,maxId] = max(yValues(:));

        set(handles.testMaxValue,'String',['Max. Value ',num2str(maxVal),' at ',num2str(xValues(maxId))]);
        hImage = plot(xValues,yValues);
        %title('Accuracy');
        stringParam = get(handles.popupmenuParameter,'String');
        xlabel(stringParam{plotNr});
        
        set(handles.axesAccuracy,'ButtonDownFcn',@saveGraph);
        
        guidata(hObject,handles)
    
    else
        plot([]);
        set(handles.testMaxValue,'String','');
        %title('Accuracy');
        stringParam = get(handles.popupmenuParameter,'String');
        xlabel(stringParam{plotNr});
    end
    
    
    
function id = getCurrentID(handles)
    tableData = get(handles.uitableParameter, 'Data');
    nrParameter = size(tableData,2);

    % Get Settings
    tableSelectValues = get(handles.uitableSelectedValues, 'Data');
    setValues = tableSelectValues(:,2);
    
    for i = 2:nrParameter-3
        % Delete Rows in Table that are not in the Current Setting
        coli = tableData(:,i);
        if ischar(setValues{i-1})
            deli = find( ~strcmp( (coli),setValues{i-1} ) );
        else
            deli = find(cell2mat(coli) ~= setValues{i-1});
        end
        tableData(deli,:) = [];
        
    end
    
    id = tableData(1);

    
function loadCurVid(hObject,handles)

% Load result struct
path = handles.path;
id = getCurrentID(handles);
file = strsplit(handles.file,'.'); 
file = strsplit(file{1},'_'); 
nameFile = dir([path,num2str(cell2mat(id)),'_',file{1},'*.mat']);
load([path,nameFile(numel(nameFile)).name],'res');


% Load popupmenuSelectVideo Values

% Check for W * H
if isfield(res,'W') && isfield(res,'H')
    res.WH = res.W * res.H;
    res.WH = reshape(res.WH,size(res.S,1),size(res.S,2),size(res.S,3));
    res = rmfield(res,'W');
    res = rmfield(res,'H');
end

%Check for Mask
if isfield(res,'M')
    handles.mask = res.M;
    handles.MaskPre = res.M;
    res = rmfield(res,'M'); 
end

% Add Original Video
res.Original = getOriginalVideo(handles);

set(handles.checkboxEnablePostprocessing,'Value',0);


% Save new res
handles.res = res;
guidata(hObject,handles)

% Show names in popup menu
names = fieldnames(res);
curVidSelect = get(handles.popupmenuSelectVideo, 'Value');
set(handles.popupmenuSelectVideo, 'Value',min(numel(names),curVidSelect));
set(handles.popupmenuSelectVideo, 'String', names);

% Display frame
displayCurFrame(hObject, handles);



function displayCurFrame(hObject, handles)



axes(handles.axesVideo);
% Get Video and Mask
res = handles.res;
mask = handles.mask;

% PostSegm
if isfield(res,'postSegm')
    set(handles.checkboxEnablePostprocessing,'enable','on');
else
	set(handles.checkboxEnablePostprocessing,'enable','off');
end

% Get Current Frame
sliderVal = get(handles.sliderRunVideo, 'Value');

%Check if Energy
entries = get(handles.popupmenuSelectVideo, 'String');
valueNr = get(handles.popupmenuSelectVideo, 'Value');
resCell = struct2cell(res);
vidShow = resCell{valueNr};
if strcmp(entries{valueNr},'Energy')
    set ( handles.axesVideo, 'NextPlot', 'replace' );
    plot(vidShow);
    set(handles.textFrame, 'String','x-axis: iterations');
else
    % Calculate and plot framenumber 
    currentFrame = max(round(sliderVal * size(vidShow,3)),1);
    set(handles.textFrame, 'String',['Frame: ', num2str(currentFrame)]);
    
    
	% Plot Frame
    imag = vidShow(:,:,currentFrame);
    set ( handles.axesVideo, 'NextPlot', 'replace' );
    hImage = imshow(imag); 
    set(hImage,'ButtonDownFcn',@saveVid);
    
    % Bounding Box
    if numel(mask) == 4
        set(handles.pushbuttonPostprocessing,'enable','off');
    else
        set(handles.pushbuttonPostprocessing,'enable','on');
    end
    if get(handles.checkboxWithMask, 'Value')
        
        % loads GT Mask
        tableSelectValues = get(handles.uitableSelectedValues, 'Data');
        video_name = cell2mat(tableSelectValues(1,2));
        
            
        if numel(mask) == 4
            maskGT = load_groundtruth_mask(video_name,1);
            maskGT = maskGT.coordinates;
            rectangle('Position',[mask(2),mask(1),mask(4), mask(3)],'Edgecolor', 'r');
            rectangle('Position',[maskGT(1),maskGT(2),maskGT(3), maskGT(4)],'Edgecolor', 'b');
        else
            hold on;
            %Calculated Mask
            currFrameMask = mask(:,:,currentFrame);
            currFrameMask(currFrameMask<0.75) = 0;
            B = bwboundaries(currFrameMask);
            visboundaries(B);
            % Mask GT
            %maskGT = load_groundtruth_mask(video_name,0);
            %maskGT = maskGT.mask;
            %currFrameMask = maskGT(:,:,currentFrame);
            %currFrameMask(currFrameMask<0.75) = 0;
            %B = bwboundaries(currFrameMask);
            %visboundaries(B);
            hold off;
            set(handles.pushbuttonPostprocessing,'enable','on');
        end
    end
end

function retCol = getTableColumn(handles,name) % Name mit " "

if strcmp(name,"F1-Score")
    retColPres = cell2mat(getTableColumn(handles,"Precision"));
    retColRec = cell2mat(getTableColumn(handles,"Recall"));
    retCol = num2cell((2 .* retColPres .* retColRec) ./ (retColPres + retColRec));
else
    % Get Table Data
    tableData = get(handles.uitableParameter, 'Data');
    ColumnName = get(handles.uitableParameter, 'ColumnName');
    columnNumber = find(ColumnName == name);
    retCol = tableData(:,columnNumber);
end


function retCol = getTableColumnDef(handles,name,table) % Name mit " "

if strcmp(name,"F1-Score")
    retColPres = cell2mat(getTableColumnDef(handles,"Precision",table));
    retColRec = cell2mat(getTableColumnDef(handles,"Recall",table));
    retCol = num2cell((2 .* retColPres .* retColRec) ./ (retColPres + retColRec));
else
    % Table Data and Names
    tableData = table2cell(table);
    ColumnName = table.Properties.VariableNames;
    columnNumber = find(ColumnName == name);
    retCol = tableData(:,columnNumber);
end


function loadedTable = loadTables(handles,ids)

% Load Path and File
path = handles.path;
file = handles.file;

% Extract Number in String
B = regexp(file,'\d*','Match');
nr = cell2mat(B(1));

loadedTable = {};

% Load All Tables
for i = 1:numel(ids)
    fileNew = strrep(file,['_',nr,'_'],['_',num2str(ids(i)),'_']);
    pathNew = strrep(path,[nr,'_'],[num2str(ids(i)),'_']);
    loadedTable{i} = readtable([pathNew,fileNew]);
    disp(['Loaded Table: ',fileNew]);
end

function TwoDPlotMult(handles,nameAcc)

    % Param1
    valCurParam = get(handles.popupmenuParameter, 'Value');
    if valCurParam == 1
        return;
    end
    stringCurParam = get(handles.popupmenuParameter, 'String');

    % Param2
    prompt = {'Enter parameter to compare:','Enter ids:'};
    dlgtitle = 'Parameters';
    dims = [1 35];
    curParam= stringCurParam(valCurParam);
    definput = {curParam{1},'1'}; 
    answer= inputdlg(prompt,dlgtitle,dims,definput);
    if isempty(answer)
        return;
    end
    string2Param = answer{1};
    ids = str2num(answer{2});
    tables = loadTables(handles,ids);
    cN_Mean = 0;
    
    for j =1:numel(tables)
        % Load Columns
        x = cell2mat(getTableColumnDef(handles,string(stringCurParam(valCurParam)),tables{j}));
        y = cell2mat(getTableColumnDef(handles,string(string2Param),tables{j}));
        C = cell2mat(getTableColumnDef(handles, string(nameAcc),tables{j}));
        C(isnan(C)) = 0;
        
        % Check size
        if numel(x) ~= numel(y)
            error(['Parameters dont match. Check if paramter name avialiable. Current table:',num2str(j)]);
        end
        if numel(C) ~= numel(y)
            error('Not right number of results.');
        end
        
        
        % Get Current Settings
        tableSelectValues = get(handles.uitableSelectedValues, 'Data');
        setValues = tableSelectValues(:,2);
        
        % Delete rows not used
        cTable = tables{j};
        dataMatrix = table2cell(cTable);
        ColumnName = cTable.Properties.VariableNames;
        idc = ones(size(cTable,1),1);
        for i = 3:size(cTable,2)-3
            if strcmp(ColumnName{i},stringCurParam{valCurParam}) || strcmp(ColumnName{i},string2Param)
                continue;
            end
            cellrow = cell2mat(dataMatrix(:,i));
            idc = idc & (cellrow==setValues{i-1});
        end

        rowVal = unique(x);
        colVal = unique(y);
        [xyUnique,~,uID] = unique([x,y], 'rows');
        cN = zeros(numel(rowVal),numel(colVal));

        for i = 1:size(xyUnique,1)
           cN(xyUnique(i,1)==rowVal,xyUnique(i,2)==colVal) = mean(C(uID==i & idc == 1));
        end
        
        cN_Mean = cN_Mean + cN;
    end
    cN_Mean = cN_Mean ./ numel(tables);
    figure('Name',['Mean Values of ...   ','(maximal value = ',num2str(max(cN_Mean(:))),')']),
    imagesc(cN_Mean); 
    %caxis([0 0.45]);
    colorbar;
    ylabel(string(stringCurParam(valCurParam)));
    xlabel(string(string2Param));
    title(string(nameAcc));
    yticks(1:numel(rowVal))
    xticks(1:numel(colVal))
    yticklabels(rowVal);
    xticklabels(colVal);

function TwoDPlot(handles,nameAcc)

    % Param1
    valCurParam = get(handles.popupmenuParameter, 'Value');
    if valCurParam == 1
        return;
    end
    stringCurParam = get(handles.popupmenuParameter, 'String');

    % Param2
    prompt = {'Enter parameter to compare:'};
    dlgtitle = 'Parameters';
    dims = [1 35];
    definput = stringCurParam(valCurParam);
    string2Param = inputdlg(prompt,dlgtitle,dims,definput);

    % Load Columns
    x = cell2mat(getTableColumn(handles,string(stringCurParam(valCurParam))));
    y = cell2mat(getTableColumn(handles,string(string2Param)));
    C = cell2mat(getTableColumn(handles, string(nameAcc)));
    C(isnan(C)) = 0; 
    % Check size
    if numel(x) ~= numel(y)
        error('Parameters dont match. Check if paramter name avialiable.');
    end
    if numel(C) ~= numel(y)
        error('Not right number of results.');
    end
    
    % Get Current Settings
        tableSelectValues = get(handles.uitableSelectedValues, 'Data');
        setValues = tableSelectValues(:,2);

    % Delete rows not used
        dataMatrix = get(handles.uitableParameter, 'Data');
        ColumnName = get(handles.uitableParameter, 'ColumnName');
        
        idc = ones(size(dataMatrix,1),1);
        for i = 3:size(dataMatrix,2)-3
            if strcmp(ColumnName{i},stringCurParam{valCurParam}) || strcmp(ColumnName{i},string2Param)
                continue;
            end
            cellrow = cell2mat(dataMatrix(:,i));
            idc = idc & (cellrow==setValues{i-1});
        end
        
    rowVal = unique(x);
    colVal = unique(y);
    [xyUnique,~,uID] = unique([x,y], 'rows');
    cN = zeros(numel(rowVal),numel(colVal));

    for i = 1:size(xyUnique,1)
       cN(xyUnique(i,1)==rowVal,xyUnique(i,2)==colVal) =  mean(C(uID==i & idc == 1));
    end
    
    figure('Name',['Mean Values of ...   ','(maximal value = ',num2str(max(cN(:))),')']),imagesc(cN); 
   
    %caxis([0.38 0.62]);
    colorbar;
    ylabel(string(stringCurParam(valCurParam)));
    xlabel(string(string2Param));
    title(string(nameAcc));
    yticks(1:numel(rowVal))
    xticks(1:numel(colVal))
    yticklabels(rowVal);
    xticklabels(colVal);
   % xtickangle(45);
    
function meanGraph(handles,ids)

    % Get Parameter of x-axis
    valCurParam = get(handles.popupmenuParameter, 'Value');
    if valCurParam == 1
        return;
    end
    stringCurParam = get(handles.popupmenuParameter, 'String');
    xAxisParam = stringCurParam{valCurParam};
    
    % Get Current Settings
    tableSelectValues = get(handles.uitableSelectedValues, 'Data');
    setValues = tableSelectValues(:,2);
    setNames = tableSelectValues(:,1);
    
    % Get Table Data
    if isempty(ids)
        tableData = get(handles.uitableParameter, 'Data');
        ColumnName = get(handles.uitableParameter, 'ColumnName');
    else
        tables = loadTables(handles,ids);
        % Table Data and Names
        tablesFin = tables{1};
        ColumnName = tables{1}.Properties.VariableNames;
        for j = 2:numel(tables)
            tablesFin = [tablesFin;tables{j}];
        end
        tableData = table2cell(tablesFin);
    end
    
    % Find Rows with Setting
    searchIdx = ones(size(tableData,1),1);
    for i =2:numel(setNames)-1
        if strcmp(xAxisParam,setNames{i})
            continue;
        end
        %columnNumber = find(~cellfun('isempty',strfind(ColumnName,setNames{i})));
        columnNumber = find(strcmp(ColumnName,setNames{i}));
        equalIdx = (setValues{i} == cell2mat(tableData(:,columnNumber)));
        searchIdx = searchIdx & equalIdx;
    end
    
    % Get Accuracy Value
    idNameAcc =  get(handles.popupmenuClassificationMetric, 'Value');
    nameAcc = get(handles.popupmenuClassificationMetric, 'String');
    if isempty(ids)
        retColAcc = getTableColumn(handles,string(nameAcc(idNameAcc)));
    else
        retColAcc = getTableColumnDef(handles,string(nameAcc(idNameAcc)),tablesFin);
    end
    
    
    % Plot
    %global figH;
    figH = figure('Name',nameAcc{idNameAcc});
    %figure(figH);
    hold on;
    videoData = unique(tableData(:,2));
    graphVal1Mean = 0;
    for i = 1:numel(videoData)
       idsVid = (strcmp(tableData(:,2),videoData(i)));
       graphVal1 = cell2mat(retColAcc(searchIdx&idsVid));
       graphVal1(isnan(graphVal1)) = 0;
       xAxisValues = cell2mat(tableData(searchIdx&idsVid,valCurParam+1));
       
       %sort
       [xAxisValues,indices] = sort(xAxisValues);
       graphVal1=graphVal1(indices);
       
       plot(xAxisValues,graphVal1);
       if numel(graphVal1Mean) ~= numel(graphVal1) && numel(graphVal1Mean) ~= 1
           error('One Graph multiple times: not allowed.');
       end

       graphVal1Mean = graphVal1Mean+graphVal1;
    end
    graphVal1Mean = graphVal1Mean./numel(videoData);
    
    
    
    plot(xAxisValues,graphVal1Mean,'r','linewidth',3);
    xlabel(string(xAxisParam));
    ylabel(string(nameAcc{idNameAcc}));
    set(figH,'Name',[nameAcc{idNameAcc},', Max Mean Value: ',num2str(max(graphVal1Mean(:)))]);
    

function saveGraph(hObject, ~)

% Get Handles
handles = guidata( ancestor(hObject, 'figure') );
if ~strcmp(get(gcbf, 'SelectionType'),'alt')
    return;
end

list = {'... Plot','... 2D Plot','...Plot all with Mean'};
[indx,tf] = listdlg('ListString',list,'PromptString','Create...:',...
                    'SelectionMode','single','ListSize',[200 80]);
if ~tf
    return;
end



idNameAcc =  get(handles.popupmenuClassificationMetric, 'Value');
nameAcc = get(handles.popupmenuClassificationMetric, 'String');
if indx == 3
    
    ids = [];
    if strcmp(get(handles.pushbuttonPostprocessing,'enable'),'on')
        prompt = {'Enter ids:'};
        dlgtitle = 'ID select:';
        dims = [1 35];
        definput = {'1'}; 
        answer= inputdlg(prompt,dlgtitle,dims,definput);
        if isempty(answer)
            return;
        end
        ids = str2num(answer{1});
    end
    meanGraph(handles,ids);
end
if indx == 2
    if strcmp(get(handles.pushbuttonPostprocessing,'enable'),'off')
        TwoDPlot(handles,nameAcc(idNameAcc));
    else
        TwoDPlotMult(handles,nameAcc(idNameAcc));
    end
end
if indx == 1
    figure('Name',nameAcc{idNameAcc});
    hold on;
    yx = handles.graphData;
    for i = 1: numel(yx)
        plot(yx{i}{1},yx{i}{2});
    end
end



function saveVid(hObject, eventdata)

handles = guidata( ancestor(hObject, 'figure') );

if ~strcmp(get(gcbf, 'SelectionType'),'alt')
    return;
end

res = handles.res;
mask = handles.mask;

list = {'... current frame as image','... current video as video',...
        '... current frame as .mat','... current video as .mat',...
        '... current video as 3D - Plot','... mask as 3D - Plot','... collage'};
[indx,tf] = listdlg('ListString',list,'PromptString','Save...:',...
                    'SelectionMode','single','ListSize',[200 80]);
if ~tf
    return;
end

% Get Current Video Display Setting
valueNr = get(handles.popupmenuSelectVideo, 'Value');
resCell = struct2cell(res);
vidSave = resCell{valueNr};



% Add Mask
if get(handles.checkboxWithMask, 'Value') && (indx == 1 || indx == 3 || indx == 2 || indx == 7)
    if numel(mask) == 4
        y = [mask(1),mask(1), mask(1) + mask(3), mask(1) + mask(3)];
        x = [mask(2), mask(2) + mask(4), mask(2) + mask(4),mask(2)];
        mask = poly2mask(x,y,size(vidSave,1),size(vidSave,2));
    end
    BW2 = bwperim(mask,8);
    bound = imdilate(BW2, strel('disk',1));
    vidSave = cat(ndims(vidSave)+1,cat(ndims(vidSave)+1,min(1, bound + vidSave),vidSave-bound),vidSave-bound);
    vidSave = min(max(vidSave,0),1);
    if ndims(vidSave) == 4
        vidSave = permute(vidSave,[1,2,4,3]);
    end
end

% Save Image
if indx == 1 || indx == 3
    sliderVal = get(handles.sliderRunVideo, 'Value');
    currentFrame = max(round(sliderVal * size(vidSave,ndims(vidSave))),1);
    if ndims(vidSave) == 4
        vidSave = vidSave(:,:,:,currentFrame);
    else
        vidSave = vidSave(:,:,currentFrame);
    end
end



% 3D Plot
if indx == 5
    set(handles.showResults, 'pointer', 'watch');
    drawnow;
    figure('Name','3D Plot');
	vid = getOriginalVideo(handles);
    if  get(handles.checkboxWithMask, 'Value')
        vid_small = imresize(vid, 0.5);
        mask_small = imresize(handles.mask, 0.5);
        create3DPlot(mask_small,vid_small);
    else     
        create3DPlot([],vid);
    end
    set(handles.showResults, 'pointer', 'arrow');
    drawnow;
end
if indx == 6
    set(handles.showResults, 'pointer', 'watch');
    drawnow;
    figure('Name','3D Plot');
    create3DPlot(handles.mask,[]);
    set(handles.showResults, 'pointer', 'arrow');
    drawnow;
end
if indx == 7

    prompt = {'Enter number plots:','Enter frames:'};
    definput = {'6',''};
    answer = inputdlg(prompt,'Settings',[1 35],definput);
    if isempty(answer)
        return;
    end
    if isempty(answer{2}) % Define Steps
        nrFrames = str2double(answer{1});
        counter = floor(size(vidSave,ndims(vidSave))/nrFrames);
        createCollage(vidSave,1:counter:size(vidSave,ndims(vidSave))-counter+1);
    else % Define Frames
        framesPlot = str2num(answer{2});
        createCollage(vidSave,framesPlot);
    end
end

% Save
if indx == 1
    [file,path] = uiputfile('*.png');
    if file == 0
        return;
    end
    imwrite(vidSave,[path,file]);
elseif indx == 2
    [file,path] = uiputfile('*.avi');
    if file == 0
        return;
    end
    saveVideo([path,file],vidSave);
elseif indx == 3 || indx == 4
    [file,path] = uiputfile('*.mat');
    if file == 0
        return;
    end
    save([path,file],'vidSave');
end

% --- Executes on button press in pushbuttonPostprocessing.
function pushbuttonPostprocessing_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPostprocessing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
res = handles.res;

mask = handles.mask;
if isfield(handles, 'MaskPre')
    mask = handles.MaskPre;
end

set(handles.showResults, 'pointer', 'watch');
drawnow;
res.postSegm = double(postprocessing(mask,0)) * 255;
handles.MaskPost = res.postSegm;
handles.MaskPre = mask;
set(handles.showResults, 'pointer', 'arrow');
drawnow;

handles.res = res;
guidata(hObject,handles);

% Show names in popup menu
names = fieldnames(res);
set(handles.popupmenuSelectVideo, 'String', names);
displayCurFrame(hObject, handles);

% --- Executes on button press in checkboxEnablePostprocessing.
function checkboxEnablePostprocessing_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxEnablePostprocessing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxEnablePostprocessing
val = get(handles.checkboxEnablePostprocessing, 'Value');
if val == 1
    handles.mask = handles.MaskPost;
else
    handles.mask = handles.MaskPre;
end
guidata(hObject,handles);
displayCurFrame(hObject, handles);

function checkboxHoldOn_Callback(hObject, eventdata, handles)
%
%

function vid = getOriginalVideo(handles)
dataTable = get(handles.uitableSelectedValues,'Data');
vidName = dataTable{1,2};
vid = loadVideo(['../data/original/',vidName,'.avi'],0);


% --- Executes on selection change in popupmenuClassificationMetric.
function popupmenuClassificationMetric_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuClassificationMetric (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuClassificationMetric contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuClassificationMetric
%popupmenuClassificationMetric
 plotTable(handles,hObject);
 
% --- Executes during object creation, after setting all properties.
function popupmenuClassificationMetric_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuClassificationMetric (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function IoU = calc_intersection_over_union(handles)
    % Calculates IoU
    % loads GT Mask
    tableSelectValues = get(handles.uitableSelectedValues, 'Data');
    video_name = cell2mat(tableSelectValues(1,2));
    maskGT = load_groundtruth_mask(video_name, 1);
    maskGT = maskGT.coordinates(:,[2 1 4 3]);
    
    % loads calculated mask
    maskCalc = handles.mask;
    
    IoU = bboxOverlapRatio(maskGT, maskCalc, 'Union');
    
    % Print Compared Result TODO
    print_compared_results(handles);

function gt_mask = load_groundtruth_mask(video_name, window)
    %  Window GT
    gt_mask = load(strcat('../data/ground_truth/gt_',video_name,'.mat'));
    if window == 1
        gt_mask = load(strcat('../data/ground_truth_window/gt_',video_name,'.mat'));
    end
    
    
function print_compared_results(handles)
    tableSelectValues = get(handles.uitableSelectedValues, 'Data');
    video_name = cell2mat(tableSelectValues(1,2));
    filename = strcat('/home/vsa_hannah/Desktop/Projects/Mitral Valve Segmentation/Baseline/REU Test Area/',video_name,'.mat');
    if isfile(filename)
        disp('Base:');
        base = load(filename);
        disp(base);
    end
    
    

    

    
