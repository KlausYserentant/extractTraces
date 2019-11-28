function uiAnalyzeTraces ()

    % create and open the main trace analysis ui
    fig = figure( ...
        'Units', 'pixel', ...
        'Position', [100, 100, 1000, 750], ...
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
    panelFile = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.01, .82, .3, .17], ...
        'Title', 'File');
    panelTraces = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.01, .01, .3, .80], ...
        'Title', 'Traces');
    panelTrace = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.32, .51, .67, .48], ...
        'Title', 'Trace');
%     panelFunctions = uipanel( ...
%         'Parent', fig, ...
%         'Units', 'normalized', ...
%         'Position', [.32, .01, .33, .49], ...
%         'Title', 'Function');
    panelInfo = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.66, .01, .33, .49], ...
        'Title', 'Info');
    
    % file panel: buttons for open, save, import, etc.
    uicontrol( ...
        'Parent', panelFile, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.04, .525, .44, .43], ...
        'String', 'Open', ...
        'Callback', @openTraceAnalysis, ...
        'BusyAction', 'cancel');
    uicontrol( ...
        'Parent', panelFile, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.515, .525, .44, .43], ...
        'String', 'Save', ...
        'Callback', @saveTraceAnalysis, ...
        'BusyAction', 'cancel');
    uicontrol( ...
        'Parent', panelFile, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.04, .05, .44, .43], ...
        'String', 'Import', ...
        'Callback', @importTracesCallback, ...
        'BusyAction', 'cancel');
     uicontrol( ...
        'Parent', panelFile, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.515, .05, .44, .43], ...
        'String', 'Export', ...
        'Callback', @exportTracesCallback, ...
        'BusyAction', 'cancel');
    
    % traces panel: list of available traces
    
    handles.traces = uitable(...
        'Parent', panelTraces, ...
        'Units','normalized',...
        'Position', [.04, .02, .92, .96], ...
        'CellSelectionCallback', @tracesCallback, ...
        'ColumnFormat', {} ,...
        'ColumnEditable', [false],...
        'ColumnWidth', {'auto'}, ...
        'ColumnName', [], ...
        'RowName', [], ...
        'Data', '' );
    
    % trace panel: plot of the selected trace    
    handles.trace = axes( ...
    'Parent', panelTrace, ...
    'Units', 'normalized', ...
    'OuterPosition', [0, .02, .98, 1], ...
    'Position', [.08, .1, .88, .8],...
    'HandleVisibility', 'callback', ...
    'NextPlot', 'replacechildren');

    % function panel:
    handles.activeFunction = uicontrol(...
        'Parent', fig, ...
        'Style','popupmenu',...
        'Units', 'normalized', ...
        'String',{'function1','function2','function3'},...
        'Position', [.32, .45, .33, .04],...
        'Value',1,...
        'Callback', @FunctionCallback);
    handles.function = cell(3, 1);
    handles.function{1} = uipanel(...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.32, .01, .33, .44], ...
        'Title', 'Function 1',...
        'Visible', 'on');
    handles.function{2} = uipanel(...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.32, .01, .33, .44], ...
        'Title', 'Function 2',...
        'Visible', 'off');
    handles.function{3} = uipanel(...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.32, .01, .33, .44], ...
        'Title', 'Function 3',...
        'Visible', 'off');
        

    % setting visibility to "on" only now speeds up the window creation
    set(fig, 'Visible', 'on');
    guidata(fig, handles);

end

function FunctionCallback(hObject, eventdate)

handles = guidata(hObject);

for i=1:length(handles.function)
    if i==handles.activeFunction.Value
        set(handles.function{i}, 'Visible', 'on');
    else set(handles.function{i}, 'Visible', 'off');
    end
end

end

function importTracesCallback(hObject, eventdata)

handles = guidata(hObject);

SampleTraces = struct;

SampleTraces.name = {'trace1', 'trace2', 'trace3'};
SampleTraces.raw = {[1, 2, 5, 10, 0],[5, 5, 5, 5, 5],[6, 0, 6, 0, 6]};

setappdata(gcbf, 'traces', traces)

TraceList = [SampleTraces.name]';

set(handles.traces, 'Data', TraceList)

end

function TracesCallback(hObject, callbackdata)



end



% function [pathname] = uigetdir2(start_path, dialog_title)
% % Pick a directory with the Java widgets instead of uigetdir
% 
% import javax.swing.JFileChooser;
% 
% if nargin == 0 || start_path == '' || start_path == 0 % Allow a null argument.
%     start_path = pwd;
% end
% 
% jchooser = javaObjectEDT('javax.swing.JFileChooser', start_path);
% 
% jchooser.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
% if nargin > 1
%     jchooser.setDialogTitle(dialog_title);
% end
% 
% jchooser.setMultiSelectionEnabled(true);
% 
% status = jchooser.showOpenDialog([]);
% 
% if status == JFileChooser.APPROVE_OPTION
%     jFile = jchooser.getSelectedFiles();
%     pathname{size(jFile, 1)}=[];
%     for i=1:size(jFile, 1)
%         pathname{i} = char(jFile(i).getAbsolutePath);
%     end
% 
% elseif status == JFileChooser.CANCEL_OPTION
%     pathname = [];
% else
%     error('Error occured while picking file.');
% end