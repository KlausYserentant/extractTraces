function [] = calcCorr(traces, old)
%
%
%
%Traces is size (points selected,moviesize,G-R emission).
%first is number of selected points; n is framesize; first Green Emission,
%Red Emission

% Creates the list of available Traces for the PopUp-Menu
handles.avTra = ['TR' sprintf('%04d', old.pointSelected(1))];
for i = 2:size(traces,1)
    handles.avTra = cat(1,handles.avTra,['TR' sprintf('%04d', old.pointSelected(i))]);
end
% Table Adjustment
handles.columninfo.titles={'Green Em','Red Em'};  
handles.columninfo.formats = {'%4.6g','%4.6g'};  
handles.columninfo.weight = [ 1, 1];  
handles.columninfo.multipliers = [ 1, 1];  
handles.columninfo.isEditable = [ 0, 0];  
handles.columninfo.isNumeric = [ 1, 1];  
handles.columninfo.withCheck = true;  
handles.columninfo.chkLabel = 'Use';  
handles.rowHeight = 16;  
handles.gFont.size=9;  
handles.gFont.name='Helvetica';
handles.coefficient = ''
handles.old = old;

handles.traces = traces;
handles.select = struct('trace',[], 'row', []);

row = ones(1,size(handles.traces,2));
row= row==1;

for i =1:size(handles.traces,1)
   handles.select(i).trace = i;
   handles.select(i).row = row;
end

% GUI Outlay

fA_gui = figure(...       % The main GUI figure
        'MenuBar','none', ...
        'Toolbar','none', ...
        'Color', get(0,...
                 'defaultuicontrolbackgroundcolor'), ...
        'Name', ['Calculate Correction Factors:  ' handles.old.pathName handles.old.fileName], ...
        'NumberTitle', 'off', ...
        'Units', 'normalized', ...
        'Position', [.05, .05, .9, .9],...
        'Resize', 'on',...
        'ButtonDownFcn',@updatePlot);

handles.DatPlot = uipanel( ...
  'Parent', fA_gui, ...
	'Tag', 'Plot', ...
	'Units', 'normalized', ...
	'Position', [.33 .55 .65 .4], ...
	'BackgroundColor', [0.937 0.937 0.937]);   
handles.fA_axes1 = axes(...    % Axes for plotting the selected plot
        'Parent', handles.DatPlot , ...
        'Units', 'normalized', ...
        'HandleVisibility','callback', ...
        'Position',[.05 .1 .9 .85],...
        'NextPlot','replacechildren',...
        'ButtonDownFcn',@selectdata_ButtonDownFcn);

handles.StatPan = uipanel( ...
  'Parent', fA_gui, ...
	'Tag', 'Stat', ...
	'Units', 'normalized', ...
	'Position', [.33 .05 .65 .45], ...
	'BackgroundColor', [0.937 0.937 0.937]);

handles.hist = axes(...    % Axes for plotting the leakage coefficient or directional coefficient d or directional coefficient d prime Histogram
        'Parent', handles.StatPan , ...
        'Units', 'normalized', ...
        'HandleVisibility','callback', ...
        'XTick', [], 'YTick', [], ...
        'Position',[.4 .3 .37 .53]);%ratio 1/0.7

result = sprintf('%s\n%s','correction coefficient = NaN');

handles.result = uicontrol(...%displays mean and std leakage coefficient or directional coefficient d or directional coefficient d prime
    'Parent', handles.StatPan , ...
    'Style','text',...
    'String',result,...
    'Units','normalized',...
    'Position',[.01 .01 .2 .3],...
    'BackgroundColor', [0.937 0.937 0.937]);

uicontrol('Parent', handles.StatPan,...%text selected data
    'Style','text',...
    'String','Selected Data',...
    'BackgroundColor', [0.937 0.937 0.937],...
    'Units','normalized',...
    'Position',[.01 .82 .3 .05])

handles.selDat = uicontrol(...%displays a list of selected traces
    'Parent', handles.StatPan , ...
    'Style','listbox',...
    'String','no data selected',...
    'Units','normalized',...
    'Position',[.005 .4 .315 .4],...
    'Callback',@updateSelect,...
    'KeyPressFcn', @deleteEntry);

   
handles.selTra = uicontrol(...%popupmenu to select trace to be shown in intensity plot
    'Parent', fA_gui, ...
    'Style','popupmenu',...
    'String', handles.avTra,...
    'Value',1,...
    'Units','normalized',...
    'Position',[0.05 0.24 0.23 0.05],...
    'Callback', @update_tab_data);


handles.calcLButton = uicontrol(...
    'Parent', fA_gui, ...
    'Style','pushbutton',...
    'String', 'calculate l',...
    'Units','normalized',...
    'Position',[0.05 0.16 0.08 0.04],...
      'callback', @calculateL);
  
% handles.calcGammaButton = uicontrol(...
%     'Parent', fA_gui, ...
%     'Style','pushbutton',...
%     'String', 'calculate gamma',...
%     'Units','normalized',...
%     'Position',[0.05 0.21 0.1 0.04],...
%       'callback', @calculateGamma);

handles.calcDTxt = uicontrol('Parent', fA_gui,...
    'Style','text',...
    'String','select Dir calculation method',...
    'Units','normalized',...
    'Position',[0.18 0.21 0.1 0.04]);

handles.calcDirPopup = uicontrol(...
    'Parent', fA_gui, ...
    'Style','popupmenu',...
    'String', 'no selection|d A-only|d prime, E=0',...
    'Value',1,...
    'Units','normalized',...
    'Position',[0.18 0.16 0.12 0.04],...
    'callback', @calculateDir);


% handles.bkgGreenTxt = uicontrol('Parent', fA_gui,...%text for display Green background
%     'Style','text',...
%     'String','Green BKG',...
%     'Units','normalized',...
%     'Position',[0.01 0.12 0.1 0.04]);
% 
% handles.bkgGreen = uicontrol(...%displays Green background value
%     'Parent', fA_gui, ...
%     'Style','edit',...
%     'String', num2str(handles.old.bkgGreen),...
%     'Units','normalized',...
%     'BackgroundColor', [0.937 0.937 0.937],...
%     'Position',[0.1 0.12 0.06 0.04]);
% 
% handles.bkgRedTxt = uicontrol('Parent', fA_gui,...%text for display Red background
%     'Style','text',...
%     'String','Red BKG',...
%     'Units','normalized',...
%     'Position',[0.16 0.12 0.1 0.04]);
% 
% handles.bkgRed = uicontrol(...%displays Red background value
%     'Parent', fA_gui, ...
%     'Style','edit',...
%     'String', num2str(handles.old.bkgRed),...
%     'Units','normalized',...
%     'BackgroundColor', [0.937 0.937 0.937],...
%     'Position',[0.24 0.12 0.06 0.04]);

handles.export = uicontrol(...%button for exporting data to csv file
    'Parent', fA_gui, ...
    'Style','pushbutton',...
    'String', 'Export Data',...
    'Units','normalized',...
    'Position',[0.05 0.015 0.25 0.04],...
    'Callback', @exportData);

uicontrol(...%button that enables selecting frames out of the trace that is shown in intensity plot
    'Parent', fA_gui, ...
    'Style','pushbutton',...
    'String', 'Select Data',...
    'Units','normalized',...
    'Position',[0.05 0.07 0.25 0.04],...
    'Callback', @selectData);





tab_data = num2cell(transpose(cat(1,traces(1,:,1), traces(1,:,2))));    
             


handles.tbl = axes('units', 'normalized','position', [0.05 0.3 0.23 0.65],'Parent', fA_gui,...
    'ButtonDownFcn',@updatePlot, 'HitTest', 'off' ); 

mltable(fA_gui, handles.tbl, 'CreateTable', handles.columninfo, handles.rowHeight, tab_data,...  
        handles.gFont);
    

axes(handles.fA_axes1);
handles.data = plot(1:size(traces,2), traces(1,:,1), 'g.', ...
    1:size(traces,2), traces(1,:,2), 'r.', ...
    1:size(traces,2), traces(1,:,3), 'g-', ...
    1:size(traces,2), traces(1,:,4), 'r-', ...
    'Parent', handles.fA_axes1);
guidata(fA_gui, handles)

% function calculateGamma(hObject, eventdata)
%     questionGamma = questdlg('Sorry, not implemented yet!','correct dataset?','Try later','Try later')
%     return

function calculateDir(hObject, eventdata)
    handles = guidata(hObject)
    if get(handles.calcDirPopup,'Value') == 2
        questionD = questdlg('Are you analyzing A-only data or did you set the Threshold to analyze A-only?','correct dataset?','Yes','No','Cancel','Yes');
        switch questionD
            case {'Yes'}
                listSelDat(handles)
            case {'No'}
                questdlg('oh no!','comment','start again', 'start again')
        end
        
    elseif get(handles.calcDirPopup,'Value') == 3 
        questionDPrime = questdlg('Are you analyzing data with E=0? Did you already calculate the leakage coefficient l?','correct dataset?','Yes','No','Cancel','Yes');
            switch questionDPrime
                case {'Yes'}
                    prompt = {'Please enter the value for l'};
                    dlgTitle = 'Enter leakage coefficient';
                    numLines = 1;
                    def = {'0'}
                    options.Resize='on';
                    askForL = inputdlg(prompt,dlgTitle,numLines,def,options);
                    handles.lValue = str2double(askForL{1})
                    guidata(hObject, handles)
                    listSelDat(handles) 
                case {'No'}
                    questdlg('oh no!','comment','start again', 'start again')
            end
    end

    
function calculateL(hObject, eventdata)
    handles = guidata(hObject);   
    questionL = questdlg('Are you analyzing D-only data or did you set the Threshold to analyze D-only?','correct dataset?','Yes','No','Cancel','Yes');
        switch questionL
            case {'Yes'}
                listSelDat(handles) 
            case {'No'}
                questdlg('oh no!','comment','start again', 'start again')
        end;

                
                
function update_tab_data(hObject,eventdata)
n = get(hObject,'Value');
handles = guidata(get(hObject,'Parent'));

tab_data = num2cell(transpose(cat(1,handles.traces(n,:,1), handles.traces(n,:,2))));
mltable(get(hObject,'Parent'), handles.tbl, 'DestroyTable');  
mltable(get(hObject,'Parent'), handles.tbl, 'CreateTable', handles.columninfo, handles.rowHeight, tab_data,...  
       handles.gFont);
   
axes(handles.fA_axes1); 
handles.data = plot(1:size(handles.traces,2), handles.traces(n,:,1), 'g.', ...
    1:size(handles.traces,2),handles.traces(n,:,2), 'r.', ...
    1:size(handles.traces,2),handles.traces(n,:,3), 'g-', ...
    1:size(handles.traces,2),handles.traces(n,:,4), 'r-', ...
    'Parent', handles.fA_axes1);

row = ones(1,size(handles.traces,2));
row= row==1;
mltable(get(hObject,'Parent'), handles.tbl, 'SetCheck', [], [], [],...  
    [], 1:size(handles.traces,2), 1);
updatePlot(handles, n, row);
calcstat(handles,n);
guidata(get(hObject,'Parent'));
    
function selectdata_ButtonDownFcn(hObject, varargin)
    handles = guidata(get(hObject,'Parent'));
    n = get(handles.selTra,'Value');
    
    mltable(get(hObject,'Parent'), handles.tbl, 'SetCheck', [], [], [],...  
    [], 1:size(handles.traces,2), 0);
    
    point1 = get(hObject,'CurrentPoint');
    rbbox;
    point2 = get(hObject,'CurrentPoint'); % button up detected
    point1 = point1(1,1:2);                     % extract x and y
    point2 = point2(1,1:2);
    p1 = min(point1,point2);                    % calculate locations
    offset = abs(point1-point2);                % and dimensions
    xrange = round([p1(1) p1(1)+offset(1)]);
    if xrange(1)<=0 %
        xrange(1)=1;
    elseif mod(xrange(1),2)==0 %Begins uneven
        xrange(1)=xrange(1)+1;
    end
    if xrange(2)>=size(handles.traces,2)
        xrange(2)=size(handles.traces,2);
    elseif mod(xrange(2),2)==1 %Ends even
        xrange(2)=xrange(2)-1;
    end
    if xrange(2)==0
       n = 'nodata'; 
    end
selVal = xrange(1):xrange(2);
mltable(get(hObject,'Parent'), handles.tbl, 'SetCheck', [], [], [],...  
    [], selVal, 1);

info = get(handles.tbl, 'userdata');
row = info.isChecked==1;
updatePlot(handles, n, row);
calcstat(handles,n);

function histogramm(hist_data, number_of_bins)
    [bin_count, bin_position] = hist(hist_data,number_of_bins)
    axes(handles.hist)
    bar(bin_position, bin_count,'b')
    result = mean(hist_data);
    stdresult = std(hist_data);

function calcstat(handles, num)
% Calculate the leakage Lk coefficient l or the directional Dir coefficient
% d or d prime
%Data is (selectedPoints,moviesize,greenEm-redEm)
%l = Int(green ex, red em)/Int(green ex,green em)
%d = Int(green ex, red em)/Int(red ex, red em)
%d prime = [Int(green ex, red em) - l*Int(green ex, green em)]/Int(green
%ex,green em)
%
% bkgRed = str2double(get(handles.bkgRed,'String'));
% bkgGreen = str2double(get(handles.bkgGreen,'String'));

if isnumeric(num)
    info = get(handles.tbl, 'userdata');
    row = info.isChecked==1;
    data = squeeze(permute(handles.traces(num,row,:),[2 1 3])); %Transpose Matrix
elseif strcmp(num,'select')
    data = squeeze(permute(handles.traces(handles.select(1).trace,handles.select(1).row,:),[2 1 3]));
    for i=2:size(handles.select,2)
       data =cat(1,data,squeeze(permute(handles.traces(handles.select(i).trace,handles.select(i).row,:),[2 1 3])));
    end
elseif strcmp(num,'nodata')
    cla(handles.hist)
    return
else
   return
end

grExRaw = data(1:2:end, 1:2);%gr ex ist first image 
redExRaw = data(2:2:end, 1:2);% red ex is second image
grExBkg = data(1:2:end, 3:4);%gr ex ist first image 
redExBkg = data(2:2:end, 3:4);% red ex is second image
grExgrEm = grExRaw(:,1) - grExBkg(:,1);
grExredEm = grExRaw(:,2) - grExBkg(:,2);
redExgrEm = redExRaw(:,1) - redExBkg(:,1);
redExredEm = redExRaw(:,2) - redExBkg(:,2);
%data is (selectedPoints,moviesize,greenEm-redEm-greenBkg-redBkg) 
%grExRaw(:,1) = grExgrEmRaw
%grExRaw(:,2) = grExredEmRaw
%redExRaw(:,1) = redExgrEmRaw
%redExRaw(:,2) = redExredEmRaw
%grExBkg(:,1) = grExgrEmBkg
%grExBkg(:,2) = grExredEmBkg
%redExBkg(:,1) = redExgrEmBkg
%redExBkg(:,2) = redExredEmBkg


%initialize 1xsize(grExRaw,1) matrix to write values for l, d or d prime

global leakageCoefficientsL directionalCoefficientsD directionalCoefficientsDPrime

leakageCoefficientsL = zeros(1,size(grExRaw,1));
directionalCoefficientsD = leakageCoefficientsL;
directionalCoefficientsDPrime = leakageCoefficientsL;


%choose which correction factor to calculate
if get(handles.calcDirPopup,'Value') == 2 %selection d
    coefficient = 'direct excitation coefficient d = '
    for i=1:size(grExRaw,1)%write values into directionalCofficientsD
       directionalCoefficientsD(i) = grExredEm(i)/redExredEm(i);
    end
    % construct and plot directionalCofficientsD Histogram
    numberOfBins = 100
    [binCount, binPosition] = hist(directionalCoefficientsD,numberOfBins)
    axes(handles.hist)
    bar(binPosition, binCount,'b')
    result = mean(directionalCoefficientsD);
    stdResult = std(directionalCoefficientsD);
    xlabel('direct excitation coefficient d')
    ylabel('#')
    
elseif get(handles.calcDirPopup,'Value') == 3 %selection d prime
    coefficient = 'direct excitation coefficient d prime = '
    for i=1:size(grExRaw,1)%write values into
        directionalCoefficientsDPrime(i) = (grExredEm(i)-handles.lValue*grExgrEm(i))/grExgrEm(i);
    end
    % construct and plot directionalCoefficientsDPrime Histogram
    numberOfBins = 100;
    [binCount, binPosition] = hist(directionalCoefficientsDPrime,numberOfBins);
    axes(handles.hist);
    bar(binPosition, binCount,'b');
    result = mean(directionalCoefficientsDPrime);
    stdResult = std(directionalCoefficientsDPrime);
    xlabel('direct excitation coefficient d prime');
    ylabel('#');
else
    coefficient = 'leakage coefficient l = '
    for i=1:size(grExRaw,1)%write values into leakageCofficientsL
       leakageCoefficientsL(i) = grExredEm(i)/grExgrEm(i);
    end
    % construct and plot leakageCofficientsL Histogram
    numberOfBins = 100;
    [binCount, binPosition] = hist(leakageCoefficientsL,numberOfBins);
    axes(handles.hist);
    bar(binPosition, binCount,'b');
    result = mean(leakageCoefficientsL);
    stdResult = std(leakageCoefficientsL);
    xlabel('leakage coefficient l');
    ylabel('#');
end

result = sprintf('%s\n%s',[ coefficient num2str(result) ' +/- ' num2str(stdResult)]);

set(handles.result, 'String', result);

function exportData(hObject, eventdata)
    % Export Data in csv format
    handles = guidata(get(hObject,'Parent'));

    if isempty(handles.select(1).trace)%checks if data is selected and gives an error message if not
       msgbox('no data selected')
       return 
    end
    
    data = squeeze(permute(handles.traces(handles.select(1).trace,handles.select(1).row,:),[2 1 3]));
    pointIdent = ones(size(data,1)/2,1)*handles.select(1).trace;                                                            
                                                              
    tmp = find(handles.select(1).row);
    frameIdent = transpose(tmp(1:2:end));

    for i=2:size(handles.select,2)
       data =cat(1,data,squeeze(permute(handles.traces(handles.select(i).trace,handles.select(i).row,:),[2 1 3])));
       pointIdent = cat(1,pointIdent,ones(size(data,1)/2-size(pointIdent,1),1)*handles.select(i).trace);
       % matrix that contains the point index for each selected point number of
       % frames per point selected times

       tmp = find(handles.select(i).row);
       frameIdent = cat(1,frameIdent,transpose(tmp(1:2:end)));% matrix that contains the frame...
                                 % index for all selected points starting
                                 % with lowest point index 
    end

    grExRaw = data(1:2:end, 1:2);%gr ex ist first image 
    redExRaw = data(2:2:end, 1:2);% red ex is second image  
%     bkgGreenEm = handles.old.bkgGreen;
%     bkgRedEm = handles.old.bkgRed;
    numberOfCalculatedValues = size(pointIdent, 1);% number of frames that are analyzed in total for all points
    %make a list of the respective bkg value for each point and frame
    greenExGreenEmBkg = data(1:2:end, 3);
    greenExRedEmBkg = data(1:2:end, 4);
    redExGreenEmBkg = data(2:2:end, 3);
    redExRedEmBkg = data(2:2:end, 4);
    %make a list of zeros for eff and stoch nd averages,
    %they are not calculated in this part of the program 
    eff = zeros(1, numberOfCalculatedValues);
    stoch = zeros(1, numberOfCalculatedValues);
    
    
%     if  isempty(handles.old.bkgCor)
%         handles.old.bkgCor = ['M','M';'M','M'];
%     end
    
    % get the filepath to the csv file to be written to
    persistent pathName
    if isempty(pathName) 
        [fileName, pathName, filter] = uiputfile('*.csv', 'Save Data to csv-file');
    else
        [fileName, pathName, filter] = uiputfile('*.csv', 'Save Data to csv-file', pathName);
    end

    if filter~= 1
        fileName =  [fileName(1:end-4) '.csv'];
    end
    %\ is recognized as stop by OpenOffice
    path = handles.old.pathName;
    for i = 1:size(handles.old.pathName,2)
        if strcmp(handles.old.pathName(i),'\')
            path(i) = '/';
        end
    end
    handles.old.pathName = path;
    
    % Gets the Stringarray for methods, for indexing right method
    methods = get(handles.old.method, 'String');
    method = methods(get(handles.old.method, 'Value'), :);
    pointNumbers = handles.old.pointSelected; %List of point numbers after autoselect
    numberOfPoints = size(pointNumbers, 2);% number of points that can be analyzed in fretAnalysis
    pointIndex = [1:numberOfPoints]; % List of Indexes from 1 to numberOfPoints
    xPositions = handles.old.points(1:numberOfPoints,1);
    yPositions = handles.old.points(1:numberOfPoints,2);
    %get mean and std of results for correction factor
    result = get(handles.result, 'String');
    %get information which image displays which ex em to correctly identify
    %threshholds
    titleIm1 = cell2mat(handles.old.titles(1));
    titleIm2 = cell2mat(handles.old.titles(2));
    titleIm3 = cell2mat(handles.old.titles(3));
    titleIm4 = cell2mat(handles.old.titles(4));
    %get threshhold values associated with images
    threshIm1 = handles.old.th(1);
    threshIm2 = handles.old.th(2);
    threshIm3 = handles.old.th(3);
    threshIm4 = handles.old.th(4);
    
    global leakageCoefficientsL directionalCoefficientsD directionalCoefficientsDPrime
    
    leakageCoefficientsL = leakageCoefficientsL;
    directionalCoefficientsD = directionalCoefficientsD; 
    directionalCoefficientsDPrime = directionalCoefficientsDPrime;
    
    % write metadata one variable per line. no excemptions!
    metadata = cell(16, 15);
    metadata(1, 1) = {'### METADATA'};
    metadata(2, 1:3) = {'fileName', handles.old.pathName, handles.old.fileName};
    metadata(3, 1:1) = {result};
    metadata(4, 1:2) = {'aquisitionMethod', method};
    metadata(5, 1:3) = {'Threshhold', titleIm1, threshIm1};
    metadata(6, 1:3) = {'Threshhold', titleIm2, threshIm2};
    metadata(7, 1:3) = {'Threshhold', titleIm3, threshIm3};
    metadata(8, 1:3) = {'Threshhold', titleIm4, threshIm4};
    metadata(9, 1:2) = {'pointRadius', handles.old.radius};
%     metadata(10, 1:2) = {'backgroundGreen', handles.old.bkgGreen};
%     metadata(11, 1:2) = {'backgroundGreenX', handles.old.bkgCor(1,1)};
%     metadata(12, 1:2) = {'backgroundGreenY', handles.old.bkgCor(2,1)};
%     metadata(13, 1:2) = {'backgroundRed', handles.old.bkgRed};
%     metadata(14, 1:2) = {'backgroundRedX', handles.old.bkgCor(1,2)};
%     metadata(15, 1:2) = {'backgroundRedY', handles.old.bkgCor(2,2)};
%     metadata(16, 1:2) = {'backgroundRadius', handles.old.bkgRadius};

    % write positions of selected points. one line for each point 
    % point index counts from 1 to number of points, point number is
    % number of point/ trace after autoselect
    pointsData = cell(numberOfPoints+2, 15);
    pointsData(1, 1) = {'### POINT COORDINATES'};
    pointsData(2, 1:4) = {'Point Index', 'Point Number', 'X', 'Y'};
    pointsData(3:end, 1:4) = num2cell([transpose(pointIndex), transpose(pointNumbers), xPositions, yPositions]);

    % write emission intensities. one frame and one point per line.
    emissionsData = cell(numberOfCalculatedValues+2, 15);
    emissionsData(1, 1) = {'### EMISSION INTENSITIES'};
    emissionsData(2, 1:15) = {'pointIndex', 'frameIndex', 'greenExGreenEmRaw', 'greenExRedEmRaw', 'redExGreenEmRaw', 'redExRedEmRaw',...
        'greenExGreenEmBkg', 'greenExRedEmBkg', 'redExGreenEmBkg', 'redExRedEmBkg','fretEfficiency', 'stoichiometry',...
        'leakageCoefficientL', 'directionalCoefficientD', 'directionalCoefficientDPrime'};
    emissionsData(3:end,1:15) = num2cell([pointIdent, frameIdent,...
        grExRaw(:,1), grExRaw(:,2), redExRaw(:,1), redExRaw(:,2), ...
        greenExGreenEmBkg, greenExRedEmBkg, redExGreenEmBkg, redExRedEmBkg, transpose(eff), transpose(stoch),...
        transpose(leakageCoefficientsL), transpose(directionalCoefficientsD), transpose(directionalCoefficientsDPrime)]);


    emissionsDataAverage = cell(numberOfPoints+2, 15);
    emissionsDataAverage(1, 1) = {'###POINT AVERAGES'};
    emissionsDataAverage(2, 1:3) = {'pointIndex', 'averageFretEfficiency', 'averageStoichiometry'};
    emissionsDataAverage(3:end, 1:3) = deal({0});

    fullData = [metadata; pointsData; emissionsData; emissionsDataAverage];
    cell2csv([pathName fileName], fullData, ',', 1999);
 
function selectData(hObject, eventdata)
handles = guidata(get(hObject,'Parent'));
info = get(handles.tbl, 'userdata');
row = info.isChecked==1;

tmp.trace=get(handles.selTra, 'Value');
tmp.row = row;
%concatenate the struct
if isempty(handles.select(1).row)
    handles.select = tmp;
else
    handles.select(size(handles.select,2)+1) = tmp;    
end

listSelDat(handles)

guidata(get(hObject,'Parent'),handles);

function deleteEntry(hObject, eventdata)
handles = guidata(get(hObject,'Parent'));
if strcmp(eventdata.Key,'delete') || strcmp(eventdata.Key,'backspace')
    n = get(handles.selDat, 'Value');
    for i = n:size(handles.select,2)-1
       handles.select(i) = handles.select(i+1);
    end
    if size(handles.select,2)==1
    handles.select(size(handles.select,2)) = struct('trace',[], 'row', []);
    else
    handles.select(size(handles.select,2)) = [];
    end
    set(handles.selDat, 'Value',size(handles.select,2));
    listSelDat(handles);   
end
guidata(get(hObject,'Parent'),handles);

function listSelDat(handles)
if isempty(handles.select(1).row)
    str = 'no Data selected';
    calcstat(handles, 'nodata');
else
    pos=find(handles.select(1).row);
    str = [handles.avTra(handles.select(1).trace,:) ' Values: ' num2str(pos(1),'%04.0f') ' - ' num2str(pos(end),'%04.0f')];
    for i=2:size(handles.select,2)
        pos=find(handles.select(i).row);
        str = cat(1,str,[handles.avTra(handles.select(i).trace,:) ' Values: ' num2str(pos(1),'%04.0f') ' - ' num2str(pos(end),'%04.0f')]);
    end
    calcstat(handles, 'select');
end
set(handles.selDat,'String', str);

function updateSelect(hObject, eventdata)
handles = guidata(get(hObject,'Parent'));
listSelDat(handles);

function updatePlot(handles, trace, row)
if strcmp(trace,'nodata')
   cla(handles.fA_axes1)
   return
end
axes(handles.fA_axes1);
handles.data = plot(find(row), handles.traces(trace,row,1),'g.',...
    find(~row), handles.traces(trace,~row,1),'gx',....
    find(row), handles.traces(trace,row,2),'r.',...
    find(~row), handles.traces(trace,~row,2),'rx',....
    1:size(handles.traces,2),handles.traces(trace,:,3),'g-',1:size(handles.traces,2),handles.traces(trace,:,4),'r-',...
    'Parent',handles.fA_axes1);