function uiCalculateCorrections(movie, traces, selectedFrames)
% create and open the fret analysis user interface
    
    if isempty(traces)
        error('ui:FretAnalysis', ...
            'the list of traces was empty. but we NEED them!')
    end
    % select all frames from every trace if no selection was given
    if nargin <= 2
        selectedFrames = cell(length(traces), 1);
        % this assumes that all traces have the same length
        selectedFrames(:) = deal({1:traces(1).intensityCount});
    end
    
    fig = figure( ...
            'MenuBar','none', ...
            'Toolbar','none', ...
            'Color', get(0,...
                     'defaultuicontrolbackgroundcolor'), ...
            'Name', ['Calculate Corrections (', movie.filePath, ')'], ...
            'NumberTitle', 'off', ...
            'Units', 'normalized', ...
            'Position', [.05, .05, .9, .9],...
            'Resize', 'on', ...
            'Visible', 'off');
    
    % save all gui object handles as guidata so they can be accessed later
    handles = guidata(fig);
    
    % slice the display up into separate panels to organize the controls
    panelSelection = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.01, .41, .38, .58], ...
        'Title', 'Selection');
    panelTrace = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.40, .51, .59, .48], ...
        'Title', 'Trace');
    panelCorrectionFactors = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.01, .01, .38, .38], ...
        'Title', 'CorrectionFactors');
    panelCC = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.40, .01, .59, .48], ...
        'Title', 'Histogram for Correction Coefficients');
    
    % panelSelection: lists to select traces and/or frames
    uicontrol( ...
        'Parent', panelSelection, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.01, .91, .48, .05], ...
        'String', 'traces');
    uicontrol( ...
        'Parent', panelSelection, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.51, .91, .48, .05], ...
        'String', 'frames of selected trace');
    handles.traces = uicontrol( ...
        'Parent', panelSelection, ...
        'Style', 'listbox', ...
        'String', '', ...
        'Units','normalized',...
        'Position', [.02, .02, .47, .90], ...
        'Callback', @tracesCallback, ...
        'BusyAction', 'cancel', ...
        'Max', 2, 'Min', 0); % this allows multiple selections
    handles.frames = uicontrol( ...
        'Parent', panelSelection, ...
        'Style', 'listbox', ...
        'String', '', ...
        'Units','normalized',...
        'Position', [.51, .02, .47, .90], ...
        'Callback', @framesCallback, ...
        'BusyAction', 'cancel', ...
        'Max', 2, 'Min', 0); % this allows multiple selections
    
    % panelTrace: show the currently selected trace
    handles.trace1 = axes( ...
        'Parent', panelTrace, ...
        'Units', 'normalized', ...
        'OuterPosition', [.01, .66, .98, .33], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren', ...
        'ButtonDownFcn', @traceButtonDownFcn);
    handles.trace2 = axes( ...
        'Parent', panelTrace, ...
        'Units', 'normalized', ...
        'OuterPosition', [.01, .32, .98, .33], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren', ...
        'ButtonDownFcn', @traceButtonDownFcn);
    handles.trace3 = axes( ...
        'Parent', panelTrace, ...
        'Units', 'normalized', ...
        'OuterPosition', [.01, .01, .98, .31], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren', ...
        'ButtonDownFcn', @traceButtonDownFcn);
    
    % panelCorrectionFactors: controls to calculate the correction factors
    uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.02, .9, .97, .05], ...
        'String', 'leakage coefficient', ...
        'HorizontalAlignment', 'left');
    handles.leakage = uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.01, .8, .98, .09], ...
        'String', 'Calculate', ...
        'Callback', @leakageCallback);
    uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.02, .7, .97, .05], ...
        'String', 'direct excitation coefficient', ...
        'HorizontalAlignment', 'left');
    handles.directExcitation = uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'pushbutton', ...
        'String', 'Calculate', ...
        'Units', 'normalized', ...
        'Position', [.01, .6, .48, .09], ...
        'Callback', @directExcitationCallback);
    handles.directExcitationType = uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'popupmenu', ...
        'Units', 'normalized', ...
        'Position', [.51, .6, .48, .08], ...
        'String', strvcat('d', 'd prime'), ...
        'Value', 1, ...
        'Callback', @directExcitationTypeCallback);
    uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.02, .5, .97, .05], ...
        'String', 'gamma', ...
        'HorizontalAlignment', 'left');
    handles.gamma = uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.01, .4, .98, 0.09], ...
        'String', 'Calculate', ...
        'Enable', 'Off', ...
        'Callback', @gammaCallback);
    
    % panelES: axes for e-s plots/histograms
%     uicontrol( ...
%         'Parent', panelES, ...
%         'Style', 'text', ...
%         'Units', 'normalized', ...
%         'Position', [.02, .90, .30, .05], ...
%         'String', 'Origin of E-S Values', ...
%         'HorizontalAlignment', 'left');
%     handles.esOrigin = uicontrol( ...
%         'Parent', panelES, ...
%         'Style', 'popupmenu', ...
%         'Units', 'normalized', ...
%         'Position', [.01, .80, .30, .08], ...
%         'String', strvcat('frames', 'traces'), ...
%         'Value', 1, ...
%         'Callback', @esOriginCallback);
    handles.result = uicontrol( ...
        'Parent', panelCC, ...
        'Style', 'text', ...
        'String', 'NaN', ...
        'Units', 'normalized', ...
        'Position', [.01, .6, .3, .1], ...
        'String', 'Export Traces', ...
        'BusyAction', 'cancel');
    handles.popoutCallback = uicontrol( ...
        'Parent', panelCC, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.01, .45, .3, .1], ...
        'String', 'Pop out Histogram', ...
        'Callback', @popoutCallback, ...
        'Enable', 'Off', ...
        'BusyAction', 'cancel');
    % Axes for plotting the correction coefficients histogram
    handles.coefficients = axes( ...    
        'Parent', panelCC , ...
        'Units', 'normalized', ...
        'HandleVisibility', 'callback', ...
        'XTick', [], ...
        'YTick', [], ...
        'Position',[.4 .1 .5 .8]); 
    
    % setting visibility to "on" only nows speeds up the window creation
    set(fig, 'Visible', 'on');
    guidata(fig, handles);
    
    % use guidata only for handles related to the user interface itself
    % use appdata to store the data
    setappdata(fig, 'movie', movie);
    setappdata(fig, 'traces', traces);
    setappdata(fig, 'selectedTraces', 1:length(traces));
    setappdata(fig, 'selectedFrames', selectedFrames);
    
    % init the list of traces. select first trace
    set(handles.traces, 'String', {traces.name});
    set(handles.traces, 'Value', [1]);
    
    % init the list of frames using the first trace. same names for every trace
    set(handles.frames, 'UserData', 1);
    names = cell(traces(1).intensityCount, 1);
    for i = 1:length(names)
        names(i) = {['frames ' int2str(2 * i - 1) ' + ' int2str(2 * i)]};
    end
    set(handles.frames, 'String', names);
    set(handles.frames, 'Value', selectedFrames{1});
    
    % calculateObservables(fig);
    % enabling this does not seem to work if uiFretAnalysis gets called on its
    % own and not from uiAlexAnalysis. there must be some confusion regarding
    % the current axes. the last plot will be drawn into the whole figure and
    % not into the selected axes
    % ui.plotTraceIntensities(traces(1), handles.trace1, handles.trace2);
    % ui.plotTraceObservables(traces(1), handles.traceES);
end

% -----------------------------------------------------------------------------
% trace and intensity frame selection

function tracesCallback(hObject, eventdata)
% save changed trace selection, show frames of selected trace and plot it
    
    handles = guidata(hObject);
    selectedTraces = get(hObject, 'Value');
    selectedTrace = selectedTraces(1);
    
    % save new selection
    setappdata(gcbf, 'selectedTraces', selectedTraces);
    
    % show frames of selected trace and save which trace is currently displayed
    selectedFrames = getappdata(gcbf, 'selectedFrames');
    set(handles.frames, 'Value', selectedFrames{selectedTrace});
    set(handles.frames, 'UserData', selectedTrace);
    
    traces = getappdata(gcbf, 'traces');
    if isappdata(gcbf, 'correctionCoefficient')
        correctionCoefficient = getappdata(gcbf, 'correctionCoefficient');
    end
    
    ui.plotTraceIntensities(traces(selectedTrace), ...
        handles.trace1, handles.trace2);
    
    if isappdata(gcbf, 'correctionCoefficient')
        ui.plotTraceCorrectionCoefficients(traces(selectedTrace), handles.trace3, correctionCoefficient);
        cc = collectCorrectionCoefficients(gcbf);
        [ccAverage, ccStd] = ui.histogramCorrectionCoefficient(cc, handles.coefficients);
    end
end

function framesCallback(hObject, eventdata)
% save changed frame selection and plot the change ES plot
    
    selectedTrace = get(hObject, 'UserData'); % see tracesCallback
    
    % save the new selection
    selectedFrames = getappdata(gcbf, 'selectedFrames');
    selectedFrames{selectedTrace} = get(hObject, 'Value');
    setappdata(gcbf, 'selectedFrames', selectedFrames);
    
    handles = guidata(hObject);
    if isappdata(gcbf, 'correctionCoefficient')
        cc = collectCorrectionCoefficients(gcbf);
        [ccAverage, ccStd] = ui.histogramCorrectionCoefficient(cc, handles.coefficients);
    end
end

function traceButtonDownFcn(hObject, eventdata)
% select frames using a draggable rectangle and update selection
    
    handles = guidata(hObject);
    selectedTrace = get(handles.frames, 'UserData'); % see tracesCallback
    
    % select coordinates
    point1 = get(hObject, 'CurrentPoint');
    rbbox; % resizable selection box
    point2 = get(hObject, 'CurrentPoint');
    
    % selected x coordinates is in movie frames, but selection should be in
    % terms of photon stream intensities. they are scaled by a factor of two as
    % each intensity index in the photon stream correpond to two frame indices
    % (red and green excitation) in the movie
    frameStart = round(min(point1(1, 1), point2(1, 1)) / 2);
    frameStop = round(max(point1(1, 1), point2(1, 1)) / 2);
    
    % save new selection
    selectedFrames = getappdata(gcbf, 'selectedFrames');
    selectedFrames{selectedTrace} = frameStart:frameStop;
    setappdata(gcbf, 'selectedFrames', selectedFrames);
    
    % update the selection in the frames list as well
    set(handles.frames, 'Value', selectedFrames{selectedTrace});
    
end

% -----------------------------------------------------------------------------
% export callback

function exportTracesCallback(hObject, eventdata)
% select a file name and export the currently selected traces to it
    
    % get the indices of the currently selected traces
    handles = guidata(hObject);
    
    movie = getappdata(gcbf, 'movie');
    traces = getappdata(gcbf, 'traces');
    selectedTraces = getappdata(gcbf, 'selectedTraces');
    selectedFrames = getappdata(gcbf, 'selectedFrames');
    
    [numberGreen numberGreenRed] = alex.traces.determineTraceCount(traces(selectedTraces));
    
    prompt = {'DNA concentration [nM]:',...
        'TF concentration [nM]:', ...
        'incubation time [min]', ...
        'incubation temperature [�C]'};
    name = 'Measurement Conditions';
    numlines = 1;
    defaultanswer = {'1', '100', '30', 'RT'};
    answer = inputdlg(prompt,name,numlines,defaultanswer);
    
    % suggest an export file based on the movie file path
    exportFileSuggestion = strcat(movie.filePath(1:end-3), 'csv');
    [fileName, pathName] = ...
        uiputfile('.csv', 'Select an Export File', exportFileSuggestion);
    
    if not(fileName == 0) % user canceled operation
        alex.exportCsvTF(fullfile(pathName, fileName), movie, ...
            traces(selectedTraces), selectedFrames(selectedTraces), ...
            answer{1}, answer{2}, answer{3}, answer{4}, numberGreen, numberGreenRed);
    end
end

% -----------------------------------------------------------------------------
% correction factor callbacks

function leakageCallback(hObject, eventdata)
% calculate leakage coefficients

    correctionCoefficient = 'l';
    calculateCorrectionCoefficients(gcbf, correctionCoefficient);
    setappdata(gcbf, 'correctionCoefficient', correctionCoefficient);
    
    cc = collectCorrectionCoefficients(gcbf);
    handles = guidata(hObject);
    [ccAverage, ccStd] = ui.histogramCorrectionCoefficient(cc, handles.coefficients);
    set(handles.popoutCallback, 'Enable', 'On');
    result = sprintf('l = %f�%f', ccAverage, ccStd); 
    set(handles.result, 'String', result);
end

function directExcitationCallback(hObject, eventdata)
% calculate direct excitation coefficient
    
    correctionCoefficient = 'd';
    calculateCorrectionCoefficients(gcbf, correctionCoefficient);
    setappdata(gcbf, 'correctionCoefficient', correctionCoefficient);
    
    cc = collectCorrectionCoefficients(gcbf);
    handles = guidata(hObject);
    [ccAverage, ccStd] = ui.histogramCorrectionCoefficient(cc, handles.coefficients);
    set(handles.popoutCallback, 'Enable', 'On');
    result = sprintf('d = %f�%f', ccAverage, ccStd); 
    set(handles.result, 'String', result);
end

function directExcitationTypeCallback(hObject, eventdata)
% calculate a different type of direct excitation coefficient
    
    correctionCoefficient = 'd';
    calculateCorrectionCoefficients(gcbf, correctionCoefficient);
    setappdata(gcbf, 'correctionCoefficient', correctionCoefficient);
    
    cc = collectCorrectionCoefficients(gcbf);
    handles = guidata(hObject);
    [ccAverage, ccStd] = ui.histogramCorrectionCoefficient(cc, handles.coefficients);        
end

% function gammaCallback(hObject, eventdata)
% % recalculate traces with a new gamma coefficient
% 
%     handles = guidata(hObject);
% end

% function esOriginCallback(hObject, eventdata)
% % recalculate traces with different observable sources
%     
%     [e, s] = collectObservables(gcbf);
%     
%     handles = guidata(hObject);
%     ui.histogramES(e, s, handles.eHist, handles.sHist, handles.es);
% end

function popoutCallback(hObject, eventdata)
% create a new figure and replot the correctionCoeffcient histogram into it
    
    handles = guidata(hObject); % handles for the main ui
    
    % create new figure with correctly named axes
    % they must be same as in the main figure
    fig = figure();
    gui = guidata(fig);
    

    % Axes for plotting the correction coefficients histogram
    gui.coefficients = axes( ...    
        'Parent', fig , ...
        'Units', 'normalized', ...
        'HandleVisibility', 'callback', ...
        'XTick', [], ...
        'YTick', [], ...
        'Position',[.1 .15 .8 .75]); 
    
    cc = collectCorrectionCoefficients(gcbf);
    ui.histogramCorrectionCoefficient(cc, gui.coefficients);
    result = get(handles.result, 'String');
    axes(gui.coefficients);
    xlabel(result);
end

% -----------------------------------------------------------------------------
% observables

function calculateCorrectionCoefficients(figure_handle, correctionCoefficient)
% calculate fret efficiency, stoichiometry with the current settings
    
    handles = guidata(figure_handle);
    
    dIsPrime = strcmpi(ui.readPopupmenu(handles.directExcitationType), 'd prime');
    
    traces = getappdata(figure_handle, 'traces');
    alex.traces.calculateCorrections(traces, correctionCoefficient, dIsPrime);
end

function cc = collectCorrectionCoefficients(figure_handle)
% combine leakageCoefficient and directExcitationCoefficient values from selected traces/frames
    
    handles = guidata(figure_handle);
    
    traces = getappdata(figure_handle, 'traces');
    correctionCoefficient = getappdata(figure_handle, 'correctionCoefficient');
    selectedTraces = getappdata(figure_handle, 'selectedTraces');
    selectedFrames = getappdata(figure_handle, 'selectedFrames');
    
    cc = alex.traces.collectCorrectionCoefficients( ...
            traces(selectedTraces), selectedFrames(selectedTraces), correctionCoefficient);
end
