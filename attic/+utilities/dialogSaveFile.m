function filePath = dialogSavefile(filterSpec, dialogTitle)
% dialogbox to save a single file; keeps track of the last opened directory
%
% this basically is a wrapper to uiputfile
    
    if nargin == 0
        filterSpec = '';
        dialogTitle = 'Select File to Write';
    elseif nargin == 1
        dialogTitle = 'Select File to Write';
    end
    
    persistent pathName
    
    if isempty(pathName)
        [fileName, pathName] = uiputfile(filterSpec, dialogTitle);
    else
        [fileName, pathName] = uiputfile(filterSpec, dialogTitle, pathName);
    end
    
    % check if dialog box was canceled
    if fileName == 0
        filePath = 0;
    else
        filePath = strcat(pathName, fileName);
    end
end