function selection = readPopupmenu(handle)
% get the currently selected string from a popupmenu
    
    % TODO check that handle really is a popupmenu uicontrol
    selection_list = get(handle, 'String');
    selection = strtrim(selection_list(get(handle, 'Value'), :));
end
