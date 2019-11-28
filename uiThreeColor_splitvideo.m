function uiThreeColor()
% create and open the main three color (three emission channels) analysis ui
    
    fig = figure( ...
        'Units', 'pixel', ...
        'Position', [0, 0, 1000, 750], ...
        'Name', 'Trace Selection', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'NumberTitle', 'off', ...
        'Resize', 'on', ...
        'Visible', 'off');
    
    % save all gui object handles as guidata so they can be accessed later
    handles = guidata(fig);
    
    % slice the display up into separate panels to organize the controls
    panelPhotonStreams = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.01, .49, .79, .50], ...
        'Title', 'Photon Streams');
    panelMenu = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.81, .40, .18, .60], ...
        'Title', 'Menu');
    panelTrace = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.01, .01, .60, .47], ...
        'Title', 'Trace');
    panelTraces = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.62, .01, .18, .47], ...
        'Title', 'Trace Selection');
    panelSettings = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.81, .01, .18, .37], ...
        'Title', 'Calibration and Settings');
    
    % panelPhotonStreams: axes for all four photon streams
    handles.photonStreams = cell(3, 1);
    handles.photonStreams{1} = axes( ...
        'Parent', panelPhotonStreams, ...
        'Units', 'normalized', ...
        'OuterPosition', [.0, .0, .33, 1.0], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren');
    
       handles.photonStreams{2} = axes( ...
        'Parent', panelPhotonStreams, ...
        'Units', 'normalized', ...
        'OuterPosition', [.33, .0, .33, 1.0], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren');
    
       handles.photonStreams{3} = axes( ...
        'Parent', panelPhotonStreams, ...
        'Units', 'normalized', ...
        'OuterPosition', [.66, .0, .33, 1.0], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren');
    
    % panelMenu: buttons for all accessible actions
    uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.05, .94, .9, .05], ...
        'String', 'Data file format', ...
        'BusyAction', 'cancel');
     handles.dataFormat = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'popupmenu', ...
        'Units', 'normalized', ...
        'Position', [.05, .86, .9, .07], ...
        'String', strvcat('Full frame, ALEX','Split frame *not implemented*'), ... % TODO: add 'Full frame, 3 files'
        'Callback', @dataformatCallback, ...
        'Value', 1, ...
        'BusyAction', 'cancel', ...
        'Enable', 'off');
    uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .78, .9, .07], ...
        'String', 'New Calibration', ...
        'Callback', @newCalibrationCallback, ...
        'BusyAction', 'cancel');
    uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .70, .9, .07], ...
        'String', 'Load Calibration', ...
        'Callback', @loadCalibrationCallback, ...
        'BusyAction', 'cancel');
    handles.openMovie = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .62, .9, .07], ...
        'String', 'Open Split Movies', ...
        'Callback', @openMovieCallback, ...
        'BusyAction', 'cancel');
    
    uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.05, .54, .9, .07], ...
        'String', 'Photon Streams Frame', ...
        'BusyAction', 'cancel');
    handles.photonStreamsStart = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'edit', ...
        'Units', 'normalized', ...
        'Position', [.05, .42, .2, .13], ...
        'String', '1', ...
        'BusyAction', 'cancel', ...
        'Callback', @updateSumPhotonStreams, ...
        'Enable', 'off');
    handles.photonStreamsEnd = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'edit', ...
        'Units', 'normalized', ...
        'Position', [.29, .42, .2, .13], ...
        'String', '10', ...
        'Callback', @updateSumPhotonStreams, ...
        'BusyAction', 'cancel', ...
        'Enable', 'off');    
    handles.photonStreamsMethod = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'popupmenu', ...
        'Units', 'normalized', ...
        'Position', [.53, .49, .42, .06], ...
        'String', strvcat('sum', 'max projection'), ...
        'Value', 1, ...
        'Callback', @updateSumPhotonStreams, ...
        'BusyAction', 'cancel', ...
        'Enable', 'off');
    handles.photonStreamsNormalization = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'popupmenu', ...
        'Units', 'normalized', ...
        'Position', [.53, .42, .42, .06], ...
        'String', strvcat('relative', 'absolute'), ...
        'Value', 1, ...
        'Callback', @updateSumPhotonStreams, ...
        'BusyAction', 'cancel', ...
        'Enable', 'off');   
    handles.extractTraces = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .34, .9, .07], ...
        'String', 'Extract Traces', ...
        'Callback', @extractTracesCallback, ...
        'BusyAction', 'cancel', ...
        'Enable', 'off');
    handles.handpickTraces = uicontrol( ...
        'Parent' , panelMenu, ...
        'Style','pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .26, .9, .07], ...
        'String', 'Handpick Additional Traces', ...
        'Callback', @handpickTracesCallback, ...
        'BusyAction', 'cancel', ...
        'Enable', 'off');
    handles.exportTraces = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .18, .9, .07], ...
        'String', 'Export Traces', ...
        'Callback', @exportTracesCallback, ...
        'BusyAction', 'cancel', ...
        'Enable', 'off');
    handles.exportVideo = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .10, .9, .07], ...
        'String', 'Export Video', ...
        'Callback', @exportVideoCallback, ...
        'Enable', 'off');
    handles.saveData = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .02, .9, .07],...
        'String', 'Save Data', ...
        'Callback', @saveDataCallback, ...
        'BusyAction', 'cancel', ...
        'Enable', 'off');

%     handles.calculateCorrections = uicontrol( ...
%         'Parent', panelMenu, ...
%         'Style', 'pushbutton', ...
%         'Units', 'normalized', ...
%         'Position', [.05, .12, .9, .1], ...
%         'String', 'Calculate Corrections', ...
%         'Callback', @calculateCorrectionsCallback, ...
%         'BusyAction','cancel', ...
%         'Enable', 'off');
%     handles.fretAnalysis = uicontrol( ...
%         'Parent', panelMenu, ...
%         'Style', 'pushbutton', ...
%         'Units', 'normalized', ...
%         'Position', [.05, .02, .9, .1], ...
%         'String', 'Fret Analysis', ...
%         'Callback', @fretAnalysisCallback, ...
%         'BusyAction', 'cancel', ...
%         'Enable', 'off');

    
    % panelTrace: axes for the selected trace
    handles.trace1 = axes( ...
        'Parent', panelTrace, ...
        'Units', 'normalized', ...
        'OuterPosition', [.0, .5, .75, .5], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren');
    handles.traceHist1 = axes( ...
        'Parent', panelTrace, ...
        'Units', 'normalized', ...
        'OuterPosition', [.75, .5, .25, .5], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren');
    handles.trace2 = axes( ...
        'Parent', panelTrace, ...
        'Units', 'normalized', ...
        'OuterPosition', [.0, .0, .75, .5], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren'); 
    handles.traceHist2 = axes( ...
        'Parent', panelTrace, ...
        'Units', 'normalized', ...
        'OuterPosition', [.75, .0, .25, .5], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren');
    
    % panelTraces: list of available traces with checkboxes for export
    handles.selectAllTraces = uicontrol( ...
        'Style', 'checkbox',...
        'Parent', panelTraces, ...
        'Units','normalized',...
        'Position', [.02, .95, .96, .04], ... 
        'String', 'Select All', ...
        'Callback', @SelectAllTraces, ...
        'Value', 1, ...
        'Enable', 'off');
    handles.traces = uitable( ...
        'Parent', panelTraces, ...
        'Units','normalized',...
        'Position', [.02, .01, .96, .93], ...
        'CellSelectionCallback', @tracesCallback, ...
        'ColumnFormat', {'logical','char'} ,...
        'ColumnEditable', [true,false],...
        'ColumnWidth', {15 200}, ...
        'ColumnName', [], ...
        'RowName', [], ...
        'Data', '' );
    
    % panelTraces: listbox showing the available traces
    %handles.traces = uicontrol( ...
    %    'Parent', panelTraces, ...
    %    'Style', 'listbox', ...
    %    'String', '', ...
    %    'Units','normalized',...
    %    'Position', [.02, .01, .96, .97], ...
    %    'Callback', @tracesCallback, ...
    %    'BusyAction', 'cancel', ...
    %    'Max', 2, 'Min', 0); % this allows multiple selections
    
    % panelSettings: controls for calibration and alignment settings
    uicontrol( ...
        'Parent', panelSettings, ...
        'Style','text', ...
        'Units', 'normalized', ...
        'Position', [.02, .92, .96, .06], ...
        'String', 'Calibration File Path', ...
        'HorizontalAlignment', 'left');
    handles.calibrationFilePath = uicontrol( ...
        'Parent', panelSettings, ...
        'Style', 'edit', ...
        'Units', 'normalized', ...
        'Position', [.02, .86, .96, .06], ...
        'String', '', ...
        'UserData', '', ...
        'Callback', @calibrationFilePathCallback, ...
        'BusyAction', 'queue');
     uicontrol( ...
        'Parent', panelSettings, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.02, .78, .96, .06], ...
        'String', 'First frame', ...
        'HorizontalAlignment', 'left');        
    handles.frameOrder  = uicontrol( ...
         'Parent', panelSettings, ...
         'Style', 'popupmenu', ...
         'Units', 'normalized', ...
         'Position', [.02, .72, .96, .07], ...
         'String', strvcat('blue-green-red','blue-red-green', 'green-red-blue','green-blue-red','red-blue-green','red-green-blue'), ...
         'Value', 1, ...
         'Callback', @frameOrderCallback, ...
         'BusyAction', 'cancel');
    
%     uicontrol( ...
%         'Parent', panelSettings, ...
%         'Style','text', ...
%         'Units', 'normalized', ...
%         'Position', [.02, .78, .96, .06], ...
%         'String', 'Slit Orientation', ...
%         'HorizontalAlignment', 'left');
%     handles.slitOrientation = uicontrol( ...
%         'Parent', panelSettings, ...
%         'Style', 'popupmenu', ...
%         'Units', 'normalized', ...
%         'Position', [.02, .72, .96, .07], ...
%         'String', strvcat('horizontal', 'vertical'), ...
%         'Value', 1, ...
%         'Callback', @slitOrientationCallback, ...
%         'BusyAction', 'cancel');
%     uicontrol('Parent', panelSettings, ...
%         'Style','text', ...
%         'Units', 'normalized', ...
%         'Position', [.02, .64, .96, .06], ...
%         'String', 'Excitation Odd Images', ...
%         'HorizontalAlignment', 'left');
%     handles.excitationOdd = uicontrol( ...
%         'Parent', panelSettings, ...
%         'Style', 'popupmenu', ...
%         'Units', 'normalized', ...
%         'Position', [.02, .58, .96, .06], ...
%         'String', strvcat('donor', 'acceptor'), ...
%         'Value', 1, ...
%         'Callback', @excitationOddCallback, ...
%         'BusyAction', 'cancel');
%     uicontrol('Parent', panelSettings, ...
%         'Style','text', ...
%         'Units', 'normalized', ...
%         'Position', [.02, .50, .96, .06], ...
%         'String', 'Detection Left Channel', ...
%         'HorizontalAlignment', 'left');
%     handles.detectionLeft = uicontrol( ...
%         'Parent', panelSettings, ...
%         'Style', 'popupmenu', ...
%         'Units', 'normalized', ...
%         'Position', [.02, .44, .96, .06], ...
%         'String', strvcat('donor', 'acceptor'), ...
%         'Value', 2, ...
%         'Callback', @detectionLeftCallback, ...
%         'BusyAction', 'cancel');
    uicontrol( ...
        'Parent', panelSettings, ...
        'Style', 'text', ...
        'String', 'Peak Radius', ...
        'Units', 'normalized', ...
        'Position', [.02, .36, .96, .06], ...
        'HorizontalAlignment', 'left');
    handles.peakRadius = uicontrol( ...
        'Parent', panelSettings, ...
        'Style', 'edit', ...
        'Units', 'normalized', ...
        'Position', [.02, .30, .96, .07], ...
        'String', num2str(3), ...
        'Callback', @peakRadiusCallback, ...
        'BusyAction', 'cancel');
    uicontrol( ...
        'Parent', panelSettings, ...
        'Style', 'text', ...
        'String', 'Trace Acquisition Method', ...
        'Units', 'normalized', ...
        'Position', [.02, .22, .96, .06], ...
        'HorizontalAlignment', 'left');
    handles.traceAcquisitionMethod = uicontrol( ...
        'Parent', panelSettings, ...
        'Style', 'popupmenu', ...
        'Units', 'normalized', ...
        'Position', [.02, .16, .96, .06], ...
        'String', strvcat('max', 'pixel', 'sum'), ...
        'Value', 3, ...
        'Callback', @traceAcquisitionMethodCallback, ...
        'BusyAction', 'cancel');
    uicontrol( ...
        'Parent', panelSettings, ...
        'Style', 'text', ...
        'String', 'Display Colormap', ...
        'Units','normalized', ...
        'Position', [.02, .08, .96, .06], ...
        'HorizontalAlignment', 'left');
    handles.colormap = uicontrol(...
        'Parent', panelSettings, ...
        'Style', 'popupmenu', ...
        'Units', 'normalized', ...
        'Position', [.02, .02, .96, .06], ...
        'String', strvcat('gray', 'hot', 'hsv', 'jet'), ...
        'Value', 2, ...
        'Callback', @colormapCallback, ...
        'BusyAction', 'cancel');
    
    % setting visibility to "on" only now speeds up the window creation
    set(fig, 'Visible', 'on');
    guidata(fig, handles);
    
    % use guidata only for handles related to the actual user interface
    % use appdata to store the actual data
    
    % use default value for slitOriention - there is no slit anymore so
    % this only determines wether the image is rotated or not. The default
    % is 'Horizontal' resulting in a rotation angle of 0
    so = 'Full frame';
    % frameorder
    fo = ui.readPopupmenu(handles.frameOrder);

    % use default values from the ui
    df = ui.readPopupmenu(handles.dataFormat);
    % calibration for alex data w/o any transformations
    switch df
        case 'Split frame'
            setappdata(fig, 'calibration', alex.movie.Calibration(1, 3, so, df));
        case 'Full frame, ALEX'
            setappdata(fig, 'calibration', alex.movie.Calibration(3, 1, so, df));
    end
    
    % calibration for alex data w/o any transformations
    setappdata(fig, 'calibration', alex.movie.Calibration(3, 1, so));
    % default mapping between stream indices and names
    setappdata(fig, 'mapping', alex.movie.MappingThreeColors(fo)); 
    % store empty placeholder variables for movie and list of traces
    setappdata(fig, 'movie', []);
    setappdata(fig, 'peaks', []);
    setappdata(fig, 'traces', []);
end

% -----------------------------------------------------------------------------
% calibration callbacks

function newCalibrationCallback(hObject, eventdata)
% call uiCalibration to create a new calibration file and load it
    
    [filePath, slitOrientation] = uiCalibration();
    
    % create a calibration object from the newly created transformation file
    % and the current ui settings
    if not(isempty(filePath))
        handles = guidata(hObject);
        
        calibration = getappdata(gcbf, 'calibration');
        calibration.updateTransformationFromFile(filePath);
        set(handles.calibrationFilePath, 'String', calibration.filePath);
    end
end

function loadCalibrationCallback(hObject, eventdata)
% select a calibration file and load it
    
    filePath = ui.dialogOpenFile('.mat', 'Select a Calibration File');
    
    if not(isempty(filePath))
        handles = guidata(hObject);
        
        calibration = getappdata(gcbf, 'calibration');
        calibration.updateTransformationFromFile(filePath);
        set(handles.calibrationFilePath, 'String', calibration.filePath);
    end
end

function calibrationFilePathCallback(hObject, eventdata)
% restore the original value
%
% calibrationFile textedit must be enabled so that the whole path can be
% selected, but it should not be changed;
    
    calibration = getappdata(gcbf, 'calibration');
    set(hObject, 'String', calibration.filePath);
end

% -----------------------------------------------------------------------------
% movie callbacks

function openMovieCallback(hObject, eventdata)
% select a movie file and create the corresponding movie object
    
    [path_, filterIndex] = ui.dialogOpenFile({'*.tif'}, 'Select "_ap2" Movie File');
    path_ = alex.movie.combinetiffs(path_);
    
    if not(isempty(path_))
        % allow different raw data formats, e.g. sif and tif
        if filterIndex == 2
            raw = alex.movie.SifFile(path_);
        elseif filterIndex == 1
            raw = alex.movie.TifFile(path_);
        end

        movie = alex.movie.Movie(raw, getappdata(gcbf, 'calibration'));
        
        setappdata(gcbf, 'movie', movie);
        setappdata(gcbf, 'peaks', []);
        setappdata(gcbf, 'traces', []);
        
        handles = guidata(hObject);
        % update figure title
        set(gcbf, 'Name', ['Trace Selection (' movie.filePath ')']);
        % enable the newly accessible actions
        set(handles.photonStreamsStart, 'Enable', 'on');
        set(handles.photonStreamsEnd, 'Enable', 'on');
        set(handles.photonStreamsMethod, 'Enable', 'on');
        set(handles.photonStreamsNormalization, 'Enable', 'on');
        set(handles.extractTraces, 'Enable', 'on');
        set(handles.handpickTraces, 'Enable', 'on');
        set(handles.exportVideo, 'Enable', 'on');
        % the following actions need extracted traces (not available now)
%         set(handles.exportTraces, 'Enable', 'off');
%         set(handles.calculateCorrections, 'Enable', 'off');
%         set(handles.fretAnalysis, 'Enable', 'off');
        % clear tracelist
%        set(handles.traces, 'String', '');
        
        updatePhotonStreams();
        updateTraces();
        updateTrace();
    end
end

% -----------------------------------------------------------------------------
% peaks and traces callbacks

function extractTracesCallback(hObject, eventdata)
% select thresholds for the peak finder, run it and update the traces
    
    movie = getappdata(gcbf, 'movie');
    mapping = getappdata(gcbf, 'mapping');
    handles = guidata(hObject);
    
    uiThresholds(movie, mapping);
    movie.peakRadius = str2num(get(handles.peakRadius, 'String'));
    movie.traceAquisitionMethod = ui.readPopupmenu(handles.traceAcquisitionMethod);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%% Temp. solution: finPeaks can detect spots using an
    %%%%%%%%%%% algorithm implemented by Kristin Grußmayer or by using the
    %%%%%%%%%%% u-track particle detection implementation. 
    %%%%%%%%%%% findPeaks switches between both depending on the 2nd
    %%%%%%%%%%% argument which can either be 'kristin' or 'utrack'.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    peaks = alex.movie.findPeaks(movie);
    setappdata(gcbf, 'peaks', peaks);
    updatePhotonStreams();
    
    traces = alex.traces.extract(movie, mapping, peaks);
    setappdata(gcbf, 'traces', traces);
    updateTraces();
    updateTrace();
    
    % enable the actions that are now accessible with existing traces
    % TODO only enable if there are some resulting traces
    set(handles.exportTraces, 'Enable', 'on');
    set(handles.selectAllTraces, 'Enable', 'on');
    set(handles.saveData, 'Enable', 'on');
%     set(handles.calculateCorrections, 'Enable', 'on');
%     set(handles.fretAnalysis, 'Enable', 'on');
end

function handpickTracesCallback(hObject, eventdata)
% select points in the axes by left mouseclick,
% end selection by pressing the return button
    
    movie = getappdata(gcbf, 'movie');
    mapping = getappdata(gcbf, 'mapping');
    peaks = getappdata(gcbf, 'peaks');
    peaksPhotonStream = getappdata(gcbf, 'peaksInPhotonStream');
    handles = guidata(hObject);
    
    movie.peakRadius = str2num(get(handles.peakRadius, 'String'));
    movie.traceAquisitionMethod = ui.readPopupmenu(handles.traceAcquisitionMethod);
    
    peaks = alex.movie.handpickPeaks(movie, mapping, peaks, peaksPhotonStream, handles);
    setappdata(gcbf, 'peaks', peaks);
    updatePhotonStreams();

    traces = alex.traces.extract(movie, mapping, peaks);
    setappdata(gcbf, 'traces', traces);
    updateTraces();
    updateTrace();
    
    % enable the actions that are now accessible with existing traces
    % TODO only enable if there are some resulting traces
    set(handles.exportTraces, 'Enable', 'on');
%     set(handles.calculateCorrections, 'Enable', 'on');
%     set(handles.fretAnalysis, 'Enable', 'on');
end

function exportTracesCallback(hObject, eventdata)
% select a file name and export the currently selected traces to it
    
    handles = guidata(hObject);
    selected = get(handles.traces, 'Value');
    
    movie = getappdata(gcbf, 'movie');
    mapping = getappdata(gcbf, 'mapping');
    traces = getappdata(gcbf, 'traces');
    
    % you can choose between .csv and .txt export
    % not sure wether the internal structure of the file is differentt
    % suggest an export file based on the movie file path
    exportFileSuggestion = strcat(movie.filePath(1:end-4));
    [fileName, pathName, filterIndex] = ...
        uiputfile({'.csv'; '.txt'}, 'Select an Export File', exportFileSuggestion);
    
    if not(fileName == 0) % user canceled operation
        file_ = fullfile(pathName, fileName);
        % allow different export data formats, e.g. csv and sif
        if filterIndex == 1
            % STANDARD Csv EXPORT WITH FULL INFORMATION
            alex.exportCsvTxtThreeColors(file_, movie, mapping, traces(selected));
        elseif filterIndex == 2
            % STANDARD Txt EXPORT WITH FULL INFORMATION, header exported as
            % csv
            alex.exportCsvTxtThreeColors(file_, movie, mapping, traces(selected));
        end
    end
    
end

function exportVideoCallback(hObject, eventdata)
% Export calibrated video as three separate .tif files.
end

function saveDataCallback(hObject,eventdata)
% Save Trace object.
    movie = getappdata(gcbf, 'movie');
    mapping = getappdata(gcbf, 'mapping');
    traces = getappdata(gcbf, 'traces');
    
    exportFileSuggestion = strcat(movie.filePath(1:end-4),'_traces.mat');
    [fileName, pathName] = uiputfile({'.mat'}, 'Select an Export File', exportFileSuggestion);
    if not(fileName == 0) % user canceled operation
        file_ = fullfile(pathName, fileName);
        save(file_, 'traces');
    end
end

function tracesCallback(hObject, callbackdata)
% update the trace plot to show the newly selected trace
    
    updateTrace(hObject, callbackdata);
end

function frameOrderCallback(hObject,eventdata)
% resort the photon streams

    mapping = getappdata(gcbf, 'mapping');
    mapping.frameOrder = ui.readPopupmenu(hObject);
    
    updatePhotonStreams();
    updateTrace();

end

function peakRadiusCallback(hObject, eventdata)
% recalculate the traces with the new peak radius
    
    movie = getappdata(gcbf, 'movie');
    movie.peakRadius = str2num(get(hObject, 'String'));
    mapping = getappdata(gcbf, 'mapping');
    traces = alex.traces.extract(movie, mapping, getappdata(gcbf, 'peaks'));
    setappdata(gcbf, 'traces', traces);
    
    updatePhotonStreams();
    updateTraces();
    updateTrace();
end

function traceAcquisitionMethodCallback(hObject, eventdata)
% recalculate traces with the new aquisition method
    
    movie = getappdata(gcbf, 'movie');
    mapping = getappdata(gcbf, 'mapping');
    movie.traceAquisitionMethod = ui.readPopupmenu(hObject);
    
    traces = alex.traces.extract(movie, mapping, getappdata(gcbf, 'peaks'));
    setappdata(gcbf, 'traces', traces);
    
    updatePhotonStreams();
    updateTraces();
    updateTrace();
end

% -----------------------------------------------------------------------------
% further analysis callbacks
% 
% function fretAnalysisCallback(hObject, eventdata)
% % call fret analysis with the currently selected traces
%     
%     handles = guidata(hObject);
%     selected = get(handles.traces, 'Value');
%     
%     movie = getappdata(gcbf, 'movie');
%     mapping = getappdata(gcbf, 'mapping');
%     traces = getappdata(gcbf, 'traces');
%     
%     % uncomment the wanted filter
%     % WARNING need to comment/uncomment the corresponding section in the export
%     % function
%     
%     % FILTER FOR TF DETECTION (remove red only traces)
%     selectedTraces = alex.traces.filterTf(traces(selected));
%     % BLEACHING DETECTION
%     %selectedTraces = traces(selected);
%     selectedFrames = alex.traces.detectBleachingOutliersTf(selectedTraces);
%     uiFretAnalysis(movie, mapping, selectedTraces, selectedFrames);
%     % NO EXTRA FILTER
%      % uiFretAnalysis(movie, traces);
%     % FOR JESSICA (select only the first two frames)
% %     selectedTraces = traces(selected);
% %     selectedFrames = cell(length(selectedTraces), 1);
% %     for i = 1:length(selectedFrames)
% %         selectedFrames{i} = 1:1;
% %     end
% %     uiFretAnalysis(movie, selectedTraces, selectedFrames);
% end

% -----------------------------------------------------------------------------
% misc callbacks

function updateSumPhotonStreams(hObject, eventdata)
% replot the photon streams with the new start and end frame
    handles = guidata(gcbf);
    movie = getappdata(gcbf, 'movie');
    
    % recover the start and end frame from the gui
    startFrame = str2num(get(handles.photonStreamsStart, 'String'));
    endFrame = str2num(get(handles.photonStreamsEnd, 'String'));
    
    % recover wether sum or max projection should be used for photon stream
    % image
    method = ui.readPopupmenu(handles.photonStreamsMethod);
    normalization = ui.readPopupmenu(handles.photonStreamsNormalization);
    movie.summarizePhotonStreams(startFrame, endFrame - startFrame + 1, method,normalization);
    updatePhotonStreams();
end

function colormapCallback(hObject, eventdata)
% replot the photon streams with the new colormap
    
    updatePhotonStreams();
end

% -----------------------------------------------------------------------------
% update plotted data

function updatePhotonStreams()
% plot the photon stream sum images
    
    movie = getappdata(gcbf, 'movie');
    mapping = getappdata(gcbf, 'mapping');
    peaks = getappdata(gcbf, 'peaks');
    
    handles = guidata(gcbf);
    cm = ui.readPopupmenu(handles.colormap);
    axs = handles.photonStreams;
    
    % plot the photon streams
    images = alex.movie.createPhotonStreamImages(movie, peaks, cm);
    
    for i = 1:length(images)
        namePhotonStream = mapping.names{i};
        
        axes(axs{i});
        hold off;
        image(images{mapping.getIndex(namePhotonStream)});
        title(namePhotonStream);
        grid on;
        hold on;
    end
end

function updateTraces(hObject, eventdata)
% update the list of traces
    
    traces = getappdata(gcbf, 'traces');
    
    handles = guidata(gcbf);
    
    if not(isempty(traces))
        % remove old selection and update traces
        % set(handles.traces, 'Value', [1])
        Check = num2cell(true(1,length(traces)));
        Data = [Check;{traces.name}];
        set(handles.traces, 'Data', Data');
    else
        set(handles.traces, 'Data', '');
    end
end

function updateTrace(varargin)
% display the currently selected trace (if any exists)
    
    traces = getappdata(gcbf, 'traces');
    if nargin == 0; return; end
    if isempty(varargin{2}.Indices); return; end
    
    handles = guidata(gcbf);
    % listbox allows multiple selection; plot the first trace in selection
    indices = varargin{2}.Indices;
    t = traces(indices(1));
    
    ui.plotTraceIntensitiesThreeColor(t, handles.trace1, handles.trace2);
    
    axes(handles.traceHist1);
    % create histogram of both excitation channels and background channels
    photonCountsFem = t.rawByName('BlueEM');
    [n, xout] = hist(photonCountsFem, 30);
    barh(xout, n, 'FaceColor', [0,0,1], 'EdgeColor', [0,0,1]);
    hold on;
    photonCountsFemBkg = t.backgroundByName('BlueEM');
    [n, xout] = hist(photonCountsFemBkg, 30);
    barh(xout, n, 'FaceColor', [0,0,0.5], 'EdgeColor', [0,0,0.5]);
    hold off;
    set(gca, 'YLim',  get(handles.trace1, 'YLim'));
    
    axes(handles.traceHist2);
    % create histogram of background corrected excitation channel
    photonCountsFem = t.correctedByName('BlueEM');
    [n, xout] = hist(photonCountsFem, 30);
    barh(xout, n, 'FaceColor', [0,0,1], 'EdgeColor', [0,0,1]);
    hold on; 
    set(gca, 'YLim',  get(handles.trace2, 'YLim'));
    photonCountsFem = t.correctedByName('GreenEM');
    [n, xout] = hist(photonCountsFem, 30);
    barh(xout, n, 'FaceColor', [0,0,1], 'EdgeColor', [0,1,0]);
    set(gca, 'YLim',  get(handles.trace2, 'YLim'));
    photonCountsFem = t.correctedByName('RedEM');
    [n, xout] = hist(photonCountsFem, 30);
    barh(xout, n, 'FaceColor', [0,0,1], 'EdgeColor', [1,0,0]);
    hold off;
    set(gca, 'YLim',  get(handles.trace2, 'YLim'));
end

function SelectAllTraces(hObject, eventdata)

    handles = guidata(gcbf);
    SelectAll = handles.selectAllTraces.Value;
    traces = getappdata(gcbf, 'traces');
    
    Check = cell(1,length(traces));
    Check(:) = {logical(SelectAll)};
    Data = [Check;{traces.name}];
    
    set(handles.traces, 'Data', Data');

end