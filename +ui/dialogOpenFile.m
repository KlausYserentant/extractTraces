function [filePath, filterIndex] = dialogOpenFile(filterSpec, dialogTitle)
% dialogbox to open a single file; return the selected file or an empty string
% and the index of the filter that was used
%
% this basically is a wrapper to uigetfile w/o support for multiple files
% and which keeps track of the directory between calls
    
    if nargin == 0
        filterSpec = '';
        dialogTitle = 'Select File to Open';
    elseif nargin == 1
        dialogTitle = 'Select File to Open';
    end
    
    persistent pathName
    % if uigetfile was canceled the last time dialogOpenFile was called,
    % pathName will have the value 0; don't no a better way to test for that
    % pathName == 0 doesn't work, because, if pathName is a string, it will
    % return an array, e.g. pathName = 'test -> pathName == 0 := [0 0 0 0] and
    % break the short-circuit or ||
    if isempty(pathName) || isnumeric(pathName)
        [fileName, pathName, filterIndex] = uigetfile(filterSpec, dialogTitle);
    else
        [fileName, pathName, filterIndex] = uigetfile(filterSpec, dialogTitle, pathName);
    end
    
    % check if dialog box was canceled
    if fileName == 0
        filePath = '';
    else
        filePath = fullfile(pathName, fileName);
    end
end