function uiFretAnalysis(movie, mapping, traces, peaksPhotonStream, selectedFrames)
% create and open the fret analysis user interface
    
    if isempty(traces)
        error('ui:FretAnalysis', ...
              'the list of traces was empty. but we NEED them!')
    end
    % select all frames  if no selection was given
    if nargin <= 4
        selectedFrames = cell(length(traces), 1);
        % this assumes that all traces have the same length
        selectedFrames(:) = deal({1:traces(1).intensityCount});
    end
    
    fig = figure( ...
            'MenuBar','none', ...
            'Toolbar','none', ...
            'Color', get(0,...
                     'defaultuicontrolbackgroundcolor'), ...
            'Name', ['Fret Analysis (', movie.filePath, ')'], ...
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
    panelPopulationSelection = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.01, .21, .38, .18], ...
        'Title', 'Population Selection');
    panelCorrectionFactors = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.01, .01, .38, .18], ...
        'Title', 'CorrectionFactors');
    panelES = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.40, .01, .59, .48], ...
        'Title', 'E-S Histogram for selected Traces/Frames');
    
    % panelSelection: lists to select traces and/or frames
    uicontrol( ...
        'Parent', panelSelection, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.03, .91, .30, .05], ...
        'String', 'traces');
    uicontrol( ...
        'Parent', panelSelection, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.35, .91, .30, .05], ...
        'String', 'frames of selected trace');
    uicontrol( ...
        'Parent', panelSelection, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'BackgroundColor', [1 0.6 0.6], ...
        'Position', [.67, .94, .30, .05], ...
        'String', 'frames of all traces: overwrites frames of selected traces');
    handles.traces = uicontrol( ...
        'Parent', panelSelection, ...
        'Style', 'listbox', ...
        'String', '', ...
        'Units','normalized',...
        'Position', [.03, .02, .30, .90], ...
        'Callback', @tracesCallback, ...
        'BusyAction', 'cancel', ...
        'Max', 2, 'Min', 0); % this allows multiple selections
    handles.frames = uicontrol( ...
        'Parent', panelSelection, ...
        'Style', 'listbox', ...
        'String', '', ...
        'Units','normalized',...
        'Position', [.35, .02, .30, .90], ...
        'Callback', @framesCallback, ...
        'BusyAction', 'cancel', ...
        'Max', 2, 'Min', 0); % this allows multiple selections
    handles.framesAllTraces = uicontrol( ...
        'Parent', panelSelection, ...
        'Style', 'listbox', ...
        'String', '', ...
        'Units','normalized',...
        'Position', [.67, .02, .30, .90], ...
        'Callback', @framesAllTracesCallback, ...
        'BusyAction', 'cancel', ...
        'Value', [], ...
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
    handles.traceES = axes( ...
        'Parent', panelTrace, ...
        'Units', 'normalized', ...
        'OuterPosition', [.01, .01, .98, .31], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren', ...
        'ButtonDownFcn', @traceButtonDownFcn);
    
    % panelPopulationSelection: controls to set the correction factors

   uicontrol( ...
        'Parent', panelPopulationSelection, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.01, .88, .98, .10], ...
        'String', 'Species Selection');
    handles.populationDOnly = uicontrol( ...
        'Parent', panelPopulationSelection, ...
        'Style', 'checkbox', ...
        'Units', 'normalized', ...
        'Position', [.01, .68, .15, .18], ...
        'String', 'D only', ...
        'Callback', @selectPopulationsCallback);
    handles.populationAOnly = uicontrol( ...
        'Parent', panelPopulationSelection, ...
        'Style', 'checkbox', ...
        'Units', 'normalized', ...
        'Position', [.18, .68, .15, .18], ...
        'String', 'A only', ...
        'Callback', @selectPopulationsCallback);
    handles.populationColocalized = uicontrol( ...
        'Parent', panelPopulationSelection, ...
        'Style', 'checkbox', ...
        'Units', 'normalized', ...
        'Position', [.35, .68, .15, .18], ...
        'String', 'colocalized', ...
        'Callback', @selectPopulationsCallback);
    handles.populationColocalizedNoFRET = uicontrol( ...
        'Parent', panelPopulationSelection, ...
        'Style', 'checkbox', ...
        'Units', 'normalized', ...
        'Position', [.52, .68, .25, .18], ...
        'String', 'colocalized + no FRET', ...
        'Callback', @selectPopulationsCallback);
    handles.populationAll = uicontrol( ...
        'Parent', panelPopulationSelection, ...
        'Style', 'checkbox', ...
        'Units', 'normalized', ...
        'Position', [.79, .68, .15, .18], ...
        'String', 'all traces', ...
        'Callback', @selectPopulationsCallback);
    uicontrol( ...
        'Parent', panelPopulationSelection, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.01, .48, .98, .10], ...
        'String', 'Photon Stream Selection');
    handles.populationDexDem = uicontrol( ...
        'Parent', panelPopulationSelection, ...
        'Style', 'checkbox', ...
        'Units', 'normalized', ...
        'Position', [.01, .28, .15, .18], ...
        'String', 'DexDem', ...
        'Callback', @selectPopulationsCallback);
    handles.populationDexAem = uicontrol( ...
        'Parent', panelPopulationSelection, ...
        'Style', 'checkbox', ...
        'Units', 'normalized', ...
        'Position', [.18, .28, .15, .18], ...
        'String', 'DexAem', ...
        'Callback', @selectPopulationsCallback);
    handles.populationAexAem = uicontrol( ...
        'Parent', panelPopulationSelection, ...
        'Style', 'checkbox', ...
        'Units', 'normalized', ...
        'Position', [.35, .28, .15, .18], ...
        'String', 'AexAem', ...
        'Callback', @selectPopulationsCallback);
    uicontrol( ...
        'Parent', panelPopulationSelection, ...
        'Style', 'text', ...
        'BackgroundColor', [1 0.6 0.6], ...
        'Units', 'normalized', ...
        'Position', [.52, .1, .22, .30], ...
        'String', 'Attention: Photon stream selections are only used if no species are selected!');
    

    
        % panelCorrectionFactors: controls to set the correction factors
    uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.02, .88, .97, .10], ...
        'String', 'leakage coefficient', ...
        'HorizontalAlignment', 'left');
    handles.leakage = uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'edit', ...
        'Units', 'normalized', ...
        'Position', [.01, .68, .98, .18], ...
        'String', num2str(0), ...
        'Callback', @leakageCallback);
    uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.02, .56, .97, .10], ...
        'String', 'direct excitation coefficient', ...
        'HorizontalAlignment', 'left');
    handles.directExcitation = uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'edit', ...
        'String', num2str(0), ...
        'Units', 'normalized', ...
        'Position', [.01, .36, .48, .18], ...
        'Callback', @directExcitationCallback);
    handles.directExcitationType = uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'popupmenu', ...
        'Units', 'normalized', ...
        'Position', [.51, .36, .48, .16], ...
        'String', strvcat('d', 'd prime'), ...
        'Value', 1, ...
        'Callback', @directExcitationTypeCallback);
    uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.02, .24, .97, .10], ...
        'String', 'gamma', ...
        'HorizontalAlignment', 'left');
    handles.gamma = uicontrol( ...
        'Parent', panelCorrectionFactors, ...
        'Style', 'edit', ...
        'Units', 'normalized', ...
        'Position', [.01, .04, .98, 0.18], ...
        'String', num2str(1), ...
        'Callback', @gammaCallback);
    
    
    % panelES: axes for e-s plots/histograms
    uicontrol( ...
        'Parent', panelES, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.02, .90, .30, .05], ...
        'String', 'Origin of E-S Values', ...
        'HorizontalAlignment', 'left');
    handles.esOrigin = uicontrol( ...
        'Parent', panelES, ...
        'Style', 'popupmenu', ...
        'Units', 'normalized', ...
        'Position', [.01, .80, .30, .08], ...
        'String', strvcat('frames', 'traces'), ...
        'Value', 1, ...
        'Callback', @esOriginCallback);
    handles.exportSpecies = uicontrol( ...
        'Parent', panelES, ...
        'Style', 'checkbox', ...
        'Units', 'normalized', ...
        'Position', [.01, .7, .25, .1], ...
        'Value', 1, ...
        'String', 'export all traces and all frames for all species');
    handles.exportAlex = uicontrol( ...
        'Parent', panelES, ...
        'Style', 'checkbox', ...
        'Units', 'normalized', ...
        'Position', [.01, .62, .25, .1], ...
        'String', 'export selected traces ALEX');
    uicontrol( ...
        'Parent', panelES, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.01, .5, .3, .1], ...
        'String', 'Export Traces', ...
        'Callback', @exportTracesCallback, ...
        'BusyAction', 'cancel');
    uicontrol( ...
        'Parent', panelES, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.01, .35, .3, .1], ...
        'String', 'Pop out ES Histogram', ...
        'Callback', @popoutCallback, ...
        'BusyAction', 'cancel');
    handles.es = axes( ...    % Axes for plotting the S-E-Plot
        'Parent', panelES , ...
        'Units', 'normalized', ...
        'HandleVisibility', 'callback', ...
        'XTick', [], ...
        'YTick', [], ...
        'Position',[.4 .1 .37 .53]); %ratio 1/0.7
    handles.sHist = axes( ...    % Axes for plotting the S-hist
        'Parent', panelES , ...
        'Units', 'normalized', ...
        'HandleVisibility','callback', ...
        'XTick', [], ...
        'YTick', [], ...
        'Position',[.82 .1 .17 .53]);%ratio 1/0.7
    set(get(handles.sHist, 'XLabel'), 'String', '#');
    set(get(handles.sHist, 'YLabel'), 'String', 'S');    
    handles.eHist = axes(...    % Axes for plotting the E-hist
        'Parent', panelES , ...
        'Units', 'normalized', ...
        'HandleVisibility','callback', ...
        'XTick', [], ...
        'YTick', [], ...
        'Position',[.4 .7 .37 .25]);%ratio 1/0.7
    set(get(handles.eHist, 'XLabel'), 'String', 'E');
    set(get(handles.eHist, 'YLabel'), 'String', '#');
    
    % setting visibility to "on" only nows speeds up the window creation
    set(fig, 'Visible', 'on');
    guidata(fig, handles);
    
    % use guidata only for handles related to the user interface itself
    % use appdata to store the data
    setappdata(fig, 'movie', movie);
    setappdata(fig, 'traces', traces);
    setappdata(fig, 'mapping', mapping);
    setappdata(fig, 'selectedTraces', 1:length(traces));
    setappdata(fig, 'peaksPhotonStream', peaksPhotonStream);
    setappdata(fig, 'selectedFrames', selectedFrames);
    
    % init the list of traces. select first trace
    set(handles.traces, 'String', {traces.name});
    set(handles.traces, 'Value', [1,]);
    
    % init the list of frames using the first trace. same names for every trace
    set(handles.frames, 'UserData', 1);
    names = cell(traces(1).intensityCount, 1);
    for i = 1:length(names)
        names(i) = {['frames ' int2str(2 * i - 1) ' + ' int2str(2 * i)]};
    end
    set(handles.frames, 'String', names);
    set(handles.frames, 'Value', selectedFrames{1});
    
    % init the list of frames for all traces. do not select anything at
    % the beginning
    set(handles.framesAllTraces, 'UserData', 1);
    names = cell(traces(1).intensityCount, 1);
    for i = 1:length(names)
        names(i) = {['frames ' int2str(2 * i - 1) ' + ' int2str(2 * i)]};
    end
    set(handles.framesAllTraces, 'String', names);
    % set(handles.frames, 'Value', selectedFrames{1});
    
    calculateObservables(fig);
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
    set(handles.framesAllTraces, 'Value', selectedFrames{selectedTrace});
    set(handles.framesAllTraces, 'UserData', selectedTrace);
    
    traces = getappdata(gcbf, 'traces');
    [e, s] = collectObservables(gcbf);
    ui.plotTraceIntensities(traces(selectedTrace), ...
        handles.trace1, handles.trace2);
    ui.plotTraceObservables(traces(selectedTrace), handles.traceES);
    ui.histogramES(e, s, handles.eHist, handles.sHist, handles.es);
end

function framesCallback(hObject, eventdata)
% save changed frame selection and plot the change ES plot
    
    selectedTrace = get(hObject, 'UserData'); % see tracesCallback
    
    % save the new selection
    selectedFrames = getappdata(gcbf, 'selectedFrames');
    selectedFrames{selectedTrace} = get(hObject, 'Value');
    setappdata(gcbf, 'selectedFrames', selectedFrames);
    
    handles = guidata(hObject);
    [e, s] = collectObservables(gcbf);
    ui.histogramES(e, s, handles.eHist, handles.sHist, handles.es);

end

function framesAllTracesCallback(hObject, eventdata)
% save changed frame selection and plot the change ES plot
    
    selectedTrace = get(hObject, 'UserData'); % see tracesCallback
    
    % save the new selection
    selectedFrames = getappdata(gcbf, 'selectedFrames');
    for i=1:size(selectedFrames)
        selectedFrames{i} = get(hObject, 'Value');
    end
    setappdata(gcbf, 'selectedFrames', selectedFrames);
    
    handles = guidata(hObject);
    [e, s] = collectObservables(gcbf);
    ui.histogramES(e, s, handles.eHist, handles.sHist, handles.es);

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
    
    [e, s] = collectObservables(gcbf);
    ui.histogramES(e, s, handles.eHist, handles.sHist, handles.es);
end

% -----------------------------------------------------------------------------
% export callback

function exportTracesCallback(hObject, eventdata)
% select a file name and export the currently selected traces to it
    
    % get the indices of the currently selected traces
    handles = guidata(hObject);
    
    movie = getappdata(gcbf, 'movie');
    mapping = getappdata(gcbf, 'mapping');
    traces = getappdata(gcbf, 'traces');
    peaksPhotonStream = transpose(getappdata(gcbf, 'peaksPhotonStream'));
    selectedTraces = getappdata(gcbf, 'selectedTraces');
    selectedFrames = getappdata(gcbf, 'selectedFrames');
    
    % uncomment below if you use exportCsvTF instead of exportCsv
%     [numberGreen numberGreenRed] = alex.traces.determineTraceCount(traces(selectedTraces));
%     
%     prompt = {'DNA concentration [nM]:',...
%         'TF concentration [nM]:', ...
%         'incubation time [min]', ...
%         'incubation temperature [?C]'};
%     name = 'Measurement Conditions';
%     numlines = 1;
%     defaultanswer = {'5', '1', '30', 'RT'};
%     answer = inputdlg(prompt,name,numlines,defaultanswer);
    
    % suggest an export file based on the movie file path
    exportFileSuggestion = strcat(movie.filePath(1:end-3), 'csv');
    [fileName, pathName] = ...
        uiputfile('.csv', 'Select an Export File', exportFileSuggestion);
    
    if not(fileName == 0) % user canceled operation
        if get(handles.exportAlex, 'Value') == 1
            alex.exportCsv(fullfile(pathName, fileName), movie, mapping,...
                traces(selectedTraces), selectedFrames(selectedTraces));
        elseif get(handles.exportSpecies, 'Value') == 1
            alex.exportCsvTxtAlex(fullfile(pathName, fileName), movie, mapping, ...
                traces, peaksPhotonStream);
        end
    end
end

% -----------------------------------------------------------------------------
% correction factor callbacks

function leakageCallback(hObject, eventdata)
% recalculate traces with new leakage coefficient
    
    calculateObservables(gcbf);
    [e, s] = collectObservables(gcbf);
    
    handles = guidata(hObject);
    ui.histogramES(e, s, handles.eHist, handles.sHist, handles.es);
end

function directExcitationCallback(hObject, eventdata)
% recalculate traces with new direct excitation coefficient
    
    calculateObservables(gcbf);
    [e, s] = collectObservables(gcbf);
    
    handles = guidata(hObject);
    ui.histogramES(e, s, handles.eHist, handles.sHist, handles.es);
end

function directExcitationTypeCallback(hObject, eventdata)
% recalculate traces with a different type of direct excitation coefficient
    
    calculateObservables(gcbf);
    [e, s] = collectObservables(gcbf);
    
    handles = guidata(hObject);
    ui.histogramES(e, s, handles.eHist, handles.sHist, handles.es);
end

function gammaCallback(hObject, eventdata)
% recalculate traces with a new gamma coefficient
    
    calculateObservables(gcbf);
    [e, s] = collectObservables(gcbf);
    
    handles = guidata(hObject);
    ui.histogramES(e, s, handles.eHist, handles.sHist, handles.es);
end

function esOriginCallback(hObject, eventdata)
% recalculate traces with different observable sources
    
    [e, s] = collectObservables(gcbf);
    
    handles = guidata(hObject);
    ui.histogramES(e, s, handles.eHist, handles.sHist, handles.es);
end

function popoutCallback(hObject, eventdata)
% create a new figure and replot the e-s histogram into it
    
    handles = guidata(hObject); % handles for the main ui
    
    % create new figure with correctly named axes
    % they must be same as in the main figure
    fig = figure();
    gui = guidata(fig);
    
    gui.es = axes( ...    % Axes for plotting the S-E-Plot
        'Parent', fig , ...
        'Units', 'normalized', ...
        'HandleVisibility', 'callback', ...
        'XTick', [], ...
        'YTick', [], ...
        'Position',[.1 .1 .5 .5]); %ratio 1/0.7
    gui.sHist = axes( ...    % Axes for plotting the S-hist
        'Parent', fig , ...
        'Units', 'normalized', ...
        'HandleVisibility','callback', ...
        'XTick', [], ...
        'YTick', [], ...
        'Position',[.7 .1 .2 .5]);%ratio 1/0.7
    set(get(gui.sHist, 'XLabel'), 'String', '#');
    set(get(gui.sHist, 'YLabel'), 'String', 'S');    
    gui.eHist = axes(...    % Axes for plotting the E-hist
        'Parent', fig , ...
        'Units', 'normalized', ...
        'HandleVisibility','callback', ...
        'XTick', [], ...
        'YTick', [], ...
        'Position',[.1 .7 .5 .2]);%ratio 1/0.7
    set(get(gui.eHist, 'XLabel'), 'String', 'E');
    set(get(gui.eHist, 'YLabel'), 'String', '#');
    
    % % ugly hack to enable the use of plotES.
    % gui.esOrigin = handles.esOrigin;
    % guidata(fig, gui);
    % 
    % % and more ugly hacks to enable the use of plotES
    % setappdata(fig, 'selectedTraces', getappdata(gcbf, 'selectedTraces'));
    % setappdata(fig, 'selectedFrames', getappdata(gcbf, 'selectedFrames'));
    
    [e, s] = collectObservables(gcbf);
    % plot es histogram into the newly created figure
    ui.histogramES(e, s, gui.eHist, gui.sHist, gui.es);
end

function selectPopulationsCallback(hObject, eventdata)
% save changed trace selection, show frames of selected trace and plot it
    
    handles = guidata(hObject);
    selectedTraces = selectPopulations(gcbf);
    
    if ~isempty(selectedTraces)
        selectedTrace = selectedTraces(1);
        % save new selection
        setappdata(gcbf, 'selectedTraces', selectedTraces);
        % show frames of selected trace and save which trace is currently displayed
        selectedFrames = getappdata(gcbf, 'selectedFrames');
        set(handles.frames, 'Value', selectedFrames{selectedTrace});
        set(handles.frames, 'UserData', selectedTrace);

        traces = getappdata(gcbf, 'traces');
        [e, s] = collectObservables(gcbf);
        ui.plotTraceIntensities(traces(selectedTrace), ...
            handles.trace1, handles.trace2);
        ui.plotTraceObservables(traces(selectedTrace), handles.traceES);
        ui.histogramES(e, s, handles.eHist, handles.sHist, handles.es);
    else
        cla(handles.es), cla(handles.sHist), cla(handles.eHist);
        cla(handles.trace1), cla(handles.trace2), cla(handles.traceES);
    end
    
    set(handles.traces, 'Value', selectedTraces);
end

% -----------------------------------------------------------------------------
% observables and selection

function calculateObservables(figure_handle)
% calculate fret efficiency, stoichiometry with the current settings
    
    handles = guidata(figure_handle);
    
    leakage = str2double(get(handles.leakage, 'String'));
    d = str2double(get(handles.directExcitation, 'String'));
    gamma_ = str2double(get(handles.gamma, 'String'));
    dIsPrime = strcmpi(ui.readPopupmenu(handles.directExcitationType), 'd');
    
    traces = getappdata(figure_handle, 'traces');
    alex.traces.calculateObservables(traces, leakage, d, gamma_, dIsPrime);
end

function [e, s] = collectObservables(figure_handle)
% combine fret efficiency and stochiometry values from selected traces/frames
    
    handles = guidata(figure_handle);
    esOrigin = ui.readPopupmenu(handles.esOrigin);
    
    traces = getappdata(figure_handle, 'traces');
    selectedTraces = getappdata(figure_handle, 'selectedTraces');
    selectedFrames = getappdata(figure_handle, 'selectedFrames');
    
    if strcmpi(esOrigin, 'frames')
        [e, s] = alex.traces.collectObservables( ...
            traces(selectedTraces), selectedFrames(selectedTraces));
    else
        [e, s] = alex.traces.collectObservablesAverages( ...
            traces(selectedTraces), selectedFrames(selectedTraces));
    end
end

function selectedTraces = selectPopulations(figure_handle)
% select traces according to which population they belong to

    handles = guidata(figure_handle);
    peaksPhotonStream = transpose(getappdata(figure_handle, 'peaksPhotonStream'));
    mapping = getappdata(figure_handle, 'mapping');
    
    logicalDexDem = peaksPhotonStream(:, mapping.getIndex('DexDem'));
    logicalDexAem = peaksPhotonStream(:, mapping.getIndex('DexAem'));
    logicalAexAem = peaksPhotonStream(:, mapping.getIndex('AexAem'));
    logicalDOnly = logicalDexDem & (~logicalAexAem);
    logicalAOnly = logicalAexAem & (~logicalDexDem);
    logicalCol = logicalDexDem & logicalAexAem;
    logicalColNoFRET = logicalDexDem & logicalAexAem & ~logicalDexAem;
        
    isAll = get(handles.populationAll, 'Value');
    isDexDem = get(handles.populationDexDem, 'Value');
    isDexAem = get(handles.populationDexAem, 'Value');
    isAexAem = get(handles.populationAexAem, 'Value');
    isDOnly = get(handles.populationDOnly, 'Value');
    isAOnly = get(handles.populationAOnly, 'Value');
    isCol = get(handles.populationColocalized, 'Value');
    isColNoFRET = get(handles.populationColocalizedNoFRET, 'Value');
    
    if (isDOnly + isAOnly + isCol + isColNoFRET + isAll + isDexDem + isDexAem + isAexAem)  == 0
        % so far, just select all if there is no selection
        selectedTraces = find(sum(peaksPhotonStream, 2));   
    elseif (isDOnly + isAOnly + isCol + isColNoFRET + isAll) > 0
        if isAll == 1 || (isDOnly && isAOnly && isCol)
            selectedTraces = find(sum(peaksPhotonStream, 2));
        elseif isDOnly && isAOnly && isColNoFRET
            selectedTraces = find(logicalDOnly + logicalAOnly + logicalColNoFRET);
        elseif isDOnly && isAOnly
            selectedTraces = find(logicalDOnly + logicalAOnly);
        elseif isDOnly && isCol 
            selectedTraces = find(logicalDOnly + logicalCol);
        elseif isAOnly && isCol
            selectedTraces = find(logicalAOnly + logicalCol);
        elseif isDOnly && isColNoFRET 
            selectedTraces = find(logicalDOnly + logicalColNoFRET);
        elseif isAOnly && isColNoFRET
            selectedTraces = find(logicalAOnly + logicalColNoFRET);
        elseif isDOnly
            selectedTraces = find(logicalDOnly);
        elseif isAOnly
            selectedTraces = find(logicalAOnly);
        elseif isCol
            selectedTraces = find(logicalCol);
        elseif isColNoFRET
            selectedTraces = find(logicalColNoFRET);
        end
    elseif ((isDOnly + isAOnly + isCol + isColNoFRET + isAll) == 0) && (isDexDem + isDexAem + isAexAem) > 0
        if isDexDem && isDexAem && isAexAem 
            selectedTraces = find(logicalDexDem + logicalDexAem + logicalAexAem);
        elseif isDexDem && isDexAem  
            selectedTraces = find(logicalDexDem + logicalDexAem);
        elseif isDexDem && isAexAem 
            selectedTraces = find(logicalDexDem + logicalAexAem);
        elseif isDexAem && isAexAem 
            selectedTraces = find(logicalDexAem + logicalAexAem);
        elseif isDexDem
            selectedTraces = find(logicalDexDem);
        elseif isDexAem 
            selectedTraces = find(logicalDexAem);
        elseif isAexAem 
            selectedTraces = find(logicalAexAem);
        end
    end
    
    
      
end