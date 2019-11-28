function combineCorrection(varargin)

    handles.combineCorrection = figure(...       % The main GUI figure
            'MenuBar','none', ...
            'Toolbar','none', ...
            'Color', get(0,...
                     'defaultuicontrolbackgroundcolor'), ...
            'Name', 'Import Data from csv-files, Combine and Calculate Correction Coefficients-Histograms', ...
            'NumberTitle', 'off', ...
            'Units', 'normalized', ...
            'Position', [.05, .05, .9, .9],...
            'Resize', 'on');

    handles.StatPan = uipanel( ...
            'Parent', handles.combineCorrection, ...
            'Tag', 'Stat', ...
            'Units', 'normalized', ...
            'Position', [.25 .1 .7 .8], ...
            'BackgroundColor', [0.937 0.937 0.937]);

    handles.hist = axes(...    % Axes for plotting the correction coefficients histogram
            'Parent', handles.StatPan , ...
            'Units', 'normalized', ...
            'HandleVisibility','callback', ...
            'XTick', [], 'YTick', [], ...
            'Position',[.35 .2 .6 .6]);

    result = sprintf('%s\n%s','Correction Coefficient = NaN');
    
    handles.result = uicontrol(...
        'Parent', handles.StatPan , ...
        'Style','text',...
        'String',result,...
        'Units','normalized',...
        'Position',[.05 .5 .2 .3],...
        'BackgroundColor', [0.937 0.937 0.937]);
    
    names = 'No Data Available'
    
    handles.names = uicontrol(...
        'Parent', handles.StatPan , ...
        'Style','listbox',...
        'String',names,...
        'Units','normalized',...
        'Position',[.05 .1 .2 .5]);
    
    handles.namesText = uicontrol(...
        'Parent', handles.StatPan , ...
        'Style','text',...
        'String','List of Uploaded Files',...
        'Units','normalized',...
        'Position',[.05 .6 .2 .05]);
    
    handles.pshPanel = uipanel('Parent',handles.combineCorrection,...
    'Position',[.05 .3 0.15 0.4]);
    
    uicontrol(...
        'Parent', handles.pshPanel, ...
        'Style','pushbutton',...
        'String', 'Import Next File',...
        'Units','normalized',...
        'Position',[.05 .8 0.9 0.1],...
        'Callback', @combineData);
    
    uicontrol(...
        'Parent', handles.pshPanel, ...
        'Style','pushbutton',...
        'String', 'Calculate Correction',...
        'Units','normalized',...
        'Position',[.05 .65 0.9 0.1],...
        'Callback', @calculateCorrection);    
    
    uicontrol(...
        'Parent', handles.pshPanel, ...
        'Style','pushbutton',...
        'String', 'Clear Graphs',...
        'Units','normalized',...
        'Position',[.05 .5 0.9 0.1],...
        'Callback', @clearGraphs);
    
     uicontrol(...
        'Parent', handles.pshPanel, ...
        'Style','pushbutton',...
        'String', 'Export Graph',...
        'Units','normalized',...
        'Position',[.05 .35 0.9 0.1],...
        'Callback', @exportGraph);
    
     uicontrol(...
        'Parent', handles.pshPanel, ...
        'Style','pushbutton',...
        'String', 'Export Data',...
        'Units','normalized',...
        'Position',[.05 .2 0.9 0.1],...
        'Callback', @exportData); 
    
     handles.checkbox = uicontrol(...
        'Parent', handles.pshPanel, ...
        'Style','checkbox',...
        'String', 'Histogram Normalized',...
        'Units','normalized',...
        'Position',[.05 .05 0.9 0.1],...
        'Callback', @normalize);     
   

    handles.eff = [];
    handles.stoch = [];
    handles.leakageCoefficientsL = []; 
    handles.directionalCoefficientsD = []; 
    handles.directionalCoefficientsDPrime = [];
    handles.averageFretEfficiency = [];
    handles.averageStoichiometry = [];
    handles.pointIndexSingle = [];
    handles.pathNames = {};
    handles.fileNames = {};
    handles.greenExGreenEmRaw = [];
    handles.greenExRedEmRaw = [];
    handles.redExGreenEmRaw = [];
    handles.redExRedEmRaw = []; 
    handles.greenExGreenEmBkg = [];
    handles.greenExRedEmBkg = [];
    handles.redExGreenEmBkg = [];
    handles.redExRedEmBkg = []; 
    handles.pointIdent = [];
    handles.frameIdent = [];
    handles.fileNamesLong = {};
    handles.pathNamesLong = {};  
    handles.numberOfFrames = [];   
    
guidata(handles.combineCorrection, handles);


function [handles] = getData(handles)
    
    persistent pathName
    if isempty(pathName)
        [fileName, pathName] = uigetfile({'*.csv'},'Pick a csv-file');
    else
        [fileName, pathName] = uigetfile({'*.csv'},'Pick a csv-file', pathName);
    end

    %updates list of data files uploaded and displays fileNames 
    %(pathName not displayed) 
    handles.pathNames = [handles.pathNames pathName];
    handles.fileNames = [handles.fileNames fileName];
    names = handles.fileNames;
    set(handles.names, 'String', names);
    
    % convert data from csv to cell array
    fullData = csv2cell([pathName fileName], 'fromfile');
    
    % search through cell array fullData until ### EMISSION INTENSITIES
    % cell is found 
    % increase line counter until the ### ... statement is found
    % after the loop i is the position of the ### ... line
    i = 1;
    while not(strcmp(fullData(i, 1), '### EMISSION INTENSITIES'))
        i = i+1;
    end
    
    % search through cell array fullData until ###POINT AVERAGES
    % cell is found 
    % increase line counter until the ### ... statement is found
    % after the loop k is the position of the ### ... line
    k = 1;
    while not(strcmp(fullData(k, 1), '###POINT AVERAGES'))
        k = k+1;
    end
    
    % add additional eff and stoch, coefficients data to list of original and filtered
    % E and S lists
    % there are two header lines after ### ...
    eff = transpose(cellfun(@str2num, fullData(i+3:k-1, 11)));
    stoch = transpose(cellfun(@str2num, fullData(i+3:k-1, 12)));
    leakageCoefficientsL = transpose(cellfun(@str2num, fullData(i+3:k-1, 13))); 
    directionalCoefficientsD = transpose(cellfun(@str2num, fullData(i+3:k-1, 14))); 
    directionalCoefficientsDPrime = transpose(cellfun(@str2num, fullData(i+3:k-1, 15)));
    handles.leakageCoefficientsL = [handles.leakageCoefficientsL, leakageCoefficientsL]; 
    handles.directionalCoefficientsD = [handles.directionalCoefficientsD, directionalCoefficientsD]; 
    handles.directionalCoefficientsDPrime = [handles.directionalCoefficientsDPrime, directionalCoefficientsDPrime];
    handles.eff = [handles.eff, eff];
    handles.stoch = [handles.stoch, stoch];
    
    %add additional averageFretEfficiency, averageStoichiometry and
    %pointIndexSingle to lists
    averageFretEfficiency = transpose(cellfun(@str2num, fullData(k+2:end, 2)));
    averageStoichiometry = transpose(cellfun(@str2num, fullData(k+2:end, 3)));
    pointIndexSingle = transpose(cellfun(@str2num, fullData(k+2:end, 1))); 
    handles.averageFretEfficiency = [handles.averageFretEfficiency, averageFretEfficiency];
    handles.averageStoichiometry = [handles.averageStoichiometry, averageStoichiometry];
    handles.pointIndexSingle = [handles.pointIndexSingle, pointIndexSingle];
    
    % add additional raw data and bkg values to original and filtered lists
    greenExGreenEmRaw = transpose(cellfun(@str2num, fullData(i+3:k-1, 3)));
    greenExRedEmRaw = transpose(cellfun(@str2num, fullData(i+3:k-1, 4)));
    redExGreenEmRaw = transpose(cellfun(@str2num, fullData(i+3:k-1, 5)));
    redExRedEmRaw = transpose(cellfun(@str2num, fullData(i+3:k-1, 6)));
    greenExGreenEmBkg = transpose(cellfun(@str2num, fullData(i+3:k-1, 7)));
    greenExRedEmBkg = transpose(cellfun(@str2num, fullData(i+3:k-1, 8)));
    redExGreenEmBkg = transpose(cellfun(@str2num, fullData(i+3:k-1, 9)));
    redExRedEmBkg = transpose(cellfun(@str2num, fullData(i+3:k-1, 10)));
    
    handles.greenExGreenEmRaw = [handles.greenExGreenEmRaw, greenExGreenEmRaw];
    handles.greenExRedEmRaw = [handles.greenExRedEmRaw, greenExRedEmRaw];
    handles.redExGreenEmRaw = [handles.redExGreenEmRaw, redExGreenEmRaw];
    handles.redExRedEmRaw = [handles.redExRedEmRaw, redExRedEmRaw];
    handles.greenExGreenEmBkg = [handles.greenExGreenEmBkg, greenExGreenEmBkg];
    handles.greenExRedEmBkg = [handles.greenExRedEmBkg, greenExRedEmBkg];
    handles.redExGreenEmBkg = [handles.redExGreenEmBkg, redExGreenEmBkg];
    handles.redExRedEmBkg = [handles.redExRedEmBkg, redExRedEmBkg];
    
    %add additional point and frame identifier to original and filtered lists
    pointIdent = transpose(cellfun(@str2num, fullData(i+3:k-1, 1)));
    frameIdent = transpose(cellfun(@str2num, fullData(i+3:k-1, 2)));
    handles.pointIdent = [handles.pointIdent, pointIdent];
    handles.frameIdent = [handles.frameIdent, frameIdent];
    
    %add additional information on amount of frames analyzed per file
    %can be used to delete data from one file from combineFretAnalysis
    numberOfFrames = size(frameIdent, 2);
    handles.numberOfFrames = [handles.numberOfFrames, numberOfFrames];
    % compute total number of frames originally uploaded
    handles.totalNumberOfFrames = size(handles.frameIdent, 2);
       
    %make a list of file names 
    %where fileName bkg is repeated numberOfFrames times
    fileNamesLong = {};
    
    for i = 1:numberOfFrames
        fileNamesLong = [fileNamesLong fileName];
    end
     
    handles.fileNamesLong = [handles.fileNamesLong fileNamesLong];
        

    
function [resCoefficients, stdResCoefficients, result] = plotStat(handles)      
    
    % construct and plot coefficients Histogram
    numberOfBins = 100;
    [binCount, binPosition] = hist(handles.coefficients,numberOfBins);
    
    %check wether Histograms should be normalized and do so if wanted
    
    if (get(handles.checkbox,'Value') == get(handles.checkbox,'Max'))
     % Checkbox is checked-normalize
     normC = sum(binCount);
     cLabel = '# normalized';
 
    else
     % Checkbox is not checked-dont normalize
     normC = 1;
     
     cLabel = '#';
     
    end
    
    binCount = binCount./ normC;
    
    axes(handles.hist);
    bar(binPosition, binCount,'b');
    xlabel(handles.coefficientName);
    ylabel(cLabel);


    resCoefficients = mean(handles.coefficients);
    stdResCoefficients = std(handles.coefficients);
    
    result = sprintf('%s\n%s',[handles.coefficientName ' = ' num2str(resCoefficients) ' +/- ' num2str(stdResCoefficients)]);

    set(handles.result, 'String', result);
 
function combineData(hObject, eventdata)
    handles = guidata(hObject);
    [handles] = getData(handles);
    
    %find out which correction factor was calculated
    if not(sum(handles.directionalCoefficientsD) == 0) %selection d
        coefficientName = 'directionalCoefficientD';
        handles.coefficients = handles.directionalCoefficientsD;
        
    elseif not(sum(handles.directionalCoefficientsDPrime) == 0)%selection d prime
        coefficientName = 'directionalCoefficientDPrime';
        handles.coefficients = handles.directionalCoefficientsDPrime;
        
    else
        coefficientName = 'leakageCoefficientL';
        handles.coefficients = handles.leakageCoefficientsL;
    end
        
    handles.coefficientName = coefficientName;
    
    [resCoefficients, stdResCoefficients, result] = plotStat(handles);
    guidata(hObject, handles);    
    
    
function normalize(hObject, eventdata)
    handles = guidata(hObject);
    
    [resCoefficients, stdResCoefficients, result] = plotStat(handles);
    guidata(hObject, handles); 
    
function calculateCorrection(hObject, eventdata)
    handles = guidata(hObject);    
    handles = getData(handles);
    
    questionC = questdlg('Select the correction factor you would like to calculate.',...
        'choose correction factor?','leakage coefficient l','directional coefficient d',...
        'directional coefficient d prime','directional coefficient d prime');
    switch questionC
        case {'leakage coefficient l'}
            handles.coefficientName = 'leakageCoefficientL';
            [coefficients] = calculateL(handles);
            handles.leakageCoefficientsL = coefficients;
        
        case {'directional coefficient d'}
            handles.coefficientName = 'directionalCoefficientD';
            [coefficients] = calculateDir(handles);
            handles.directionalCoefficientsD = coefficients;

        case {'directional coefficient d prime'}
            handles.coefficientName = 'directionalCoefficientDPrime';
            [coefficients] = calculateDirPrime(handles);
            handles.directionalCoefficientsDPrime = coefficients;
    end
    
    handles.coefficients = coefficients;
    
    [resCoefficients, stdResCoefficients, result] = plotStat(handles);
    
    guidata(hObject, handles);
           
                
    
function [coefficients] = calculateDir(handles)

    questionD = questdlg('Are you analyzing A-only data or did you select the A-only population?',...
        'correct dataset?','Yes','No','Cancel','Yes');
    switch questionD
        case {'Yes'}
            [coefficients] = calcStat(handles);
        case {'No'}
            questdlg('oh no!','comment','start again', 'start again');
    end

        
function [coefficients] = calculateDirPrime(handles)
    handles.coefficientName
    questionDPrime = questdlg('Are you analyzing data with E=0 or did you select the E=0 population?? Did you already calculate the leakage coefficient l?',...
        'correct dataset?','Yes','No','Cancel','Yes');
    switch questionDPrime
        case {'Yes'}
            prompt = {'Please enter the value for l'};
            dlgTitle = 'Enter leakage coefficient';
            numLines = 1;
            def = {'0'};
            options.Resize='on';
            askForL = inputdlg(prompt,dlgTitle,numLines,def,options);
            handles.lValue = str2double(askForL{1});
            [coefficients] = calcStat(handles); 
        case {'No'}
            questdlg('oh no!','comment','start again', 'start again');
    end

    
function [coefficients] = calculateL(handles)
     
    questionL = questdlg('Are you analyzing D-only data or did you set the Threshold to analyze D-only?','correct dataset?','Yes','No','Cancel','Yes');
    switch questionL
        case {'Yes'}
            [coefficients] = calcStat(handles);
        case {'No'}
            questdlg('oh no!','comment','start again', 'start again');
    end;
    

    
function [coefficients] = calcStat(handles)
    % Calculate the leakage Lk coefficient l or the directional Dir coefficient
    % d or d prime
    %l = Int(green ex, red em)/Int(green ex,green em)
    %d = Int(green ex, red em)/Int(red ex, red em)
    %d prime = [Int(green ex, red em) - l*Int(green ex, green em)]/Int(green
    %ex,green em)
    %

    
    grExgrEm = handles.greenExGreenEmRaw-handles.greenExGreenEmBkg; 
    grExredEm = handles.greenExRedEmRaw-handles.greenExRedEmBkg;
    redExgrEm = handles.redExGreenEmRaw-handles.redExGreenEmBkg;
    redExredEm = handles.redExRedEmRaw-handles.redExRedEmBkg;

    coefficients = zeros(1,size(handles.greenExGreenEmRaw,2));

    %choose which correction factor to calculate
    if strcmp(handles.coefficientName, 'directionalCoefficientD')%selection d
        for i=1:size(grExgrEm,2)%write values into handles.coefficients
           coefficients(i) = grExredEm(i)/redExredEm(i);
        end


    elseif strcmp(handles.coefficientName, 'directionalCoefficientDPrime') %selection d prime
        for i=1:size(grExgrEm,2)%write values into handles.coefficients
            coefficients(i) = (grExredEm(i)-handles.lValue*grExgrEm(i))/grExgrEm(i);
        end

    else %selection l
        for i=1:size(grExgrEm,2)%write values into handles.coefficients
           coefficients(i) = grExredEm(i)/grExgrEm(i);
        end

    end


function clearGraphs(hObject, eventdata)
    handles = guidata(hObject);

    handles.eff = [];
    handles.stoch = [];
    handles.leakageCoefficientsL = []; 
    handles.directionalCoefficientsD = []; 
    handles.directionalCoefficientsDPrime = [];
    handles.averageFretEfficiency = [];
    handles.averageStoichiometry = [];
    handles.pointIndexSingle = [];
    handles.pathNames = {};
    handles.fileNames = {};
    handles.greenExGreenEmRaw = [];
    handles.greenExRedEmRaw = [];
    handles.redExGreenEmRaw = [];
    handles.redExRedEmRaw = []; 
    handles.greenExGreenEmBkg = [];
    handles.greenExRedEmBkg = [];
    handles.redExGreenEmBkg = [];
    handles.redExRedEmBkg = []; 
    handles.pointIdent = [];
    handles.frameIdent = [];
    handles.fileNamesLong = {};
    handles.pathNamesLong = {};  
    handles.numberOfFrames = []; 
    cla(handles.hist);

    names = 'No Data Available';
    set(handles.names, 'String', names);
    
    result = sprintf('%s\n%s','Correction Coefficient = NaN');
    set(handles.result, 'String', result);
    
    guidata(hObject, handles);
    
function exportGraph(hObject, eventdata)
    handles = guidata(hObject);
    exportFigure = figure('Name','Histogram of Correction Coefficients')
    % copy axes into the new figure
    axesList = [handles.hist, handles.result]
    newaxes = copyobj(axesList,exportFigure)
    set(newaxes(1), 'Position', [0.1,0.1,0.8,0.8]);
    set(newaxes(2), 'Position', [0.5,0.6,0.3,0.1]);


function exportData(hObject, eventdata)
    handles = guidata(hObject);
    
    %checks if files are selected and gives an error message if not
    if isempty(handles.fileNames)
       msgbox('No csv-Files Selected')
       return 
    end
    
    %selects path and lets you specify the filename
    persistent pathName
    if isempty(pathName)
        [fileName, pathName, filter] = uiputfile('*.csv', 'Save Data to csv-file');
    else
        [fileName, pathName, filter] = uiputfile('*.csv', 'Save Data to csv-file', pathName);
    end
    
    if filter~= 1
        fileName =  [fileName(1:end-4) '.csv'];
    end
    
    %get number of files analyzed and total number of frames in E-,
    %S-Histograms
    handles.numberOfFiles = size(handles.fileNames, 2);
    % compute total number of frames originally uploaded
    handles.totalNumberOfFrames = size(handles.frameIdent, 2);
    %compute the number of points originally uploaded
    numberOfPoints = size(handles.pointIndexSingle, 2);
    
    % get the mean and std of the calculated correction coefficient
    result = get(handles.result, 'String');
    
    % write metadata one variable per line. no excemptions!
    metadata = cell(handles.numberOfFiles+3, 16);
    metadata(1, 1) = {'### METADATA'};
    metadata(2, 1) = {result};
    metadata(3, 1:2) = {'pathNames', 'fileNames'};
    metadata(4:end,1:2) = [transpose(handles.pathNames) transpose(handles.fileNames)];

    % write emission intensities. one frame and one point per line.
    emissionsData = cell(handles.totalNumberOfFrames+2, 16);
    emissionsData(1, 1) = {'### EMISSION INTENSITIES'};
    emissionsData(2, 1:16) = {'pointIndex', 'frameIndex', 'greenExGreenEmRaw', 'greenExRedEmRaw', 'redExGreenEmRaw', 'redExRedEmRaw',...
        'greenExGreenEmBkg', 'greenExRedEmBkg', 'redExGreenEmBkg', 'redExRedEmBkg','fretEfficiency', 'stoichiometry',...
        'leakageCoefficientL', 'directionalCoefficientD', 'directionalCoefficientDPrime', 'File Name'};
    emissionsData(3:end,1:16) = [num2cell([transpose(handles.pointIdent), transpose(handles.frameIdent),...
        transpose(handles.greenExGreenEmRaw), transpose(handles.greenExRedEmRaw),...
        transpose(handles.redExGreenEmRaw), transpose(handles.redExRedEmRaw),...
        transpose(handles.greenExGreenEmBkg), transpose(handles.greenExRedEmBkg),...
        transpose(handles.redExGreenEmBkg), transpose(handles.redExRedEmBkg),...        
        transpose(handles.eff), transpose(handles.stoch)...
        transpose(handles.leakageCoefficientsL), transpose(handles.directionalCoefficientsD), ...
        transpose(handles.directionalCoefficientsDPrime)]) transpose(handles.fileNamesLong)];
    
    
    emissionsDataAverage = cell(numberOfPoints+2, 16);
    emissionsDataAverage(1, 1) = {'###POINT AVERAGES'};
    emissionsDataAverage(2, 1:3) = {'pointIndex', 'averageFretEfficiency', 'averageStoichiometry'};
    emissionsDataAverage(3:end, 1:3) = num2cell([transpose(handles.pointIndexSingle), transpose(handles.averageFretEfficiency), ...
        transpose(handles.averageStoichiometry)]);
    
    fullData = [metadata; emissionsData; emissionsDataAverage];
    cell2csv([pathName fileName], fullData, ',', 1999);
        
    
    

    


