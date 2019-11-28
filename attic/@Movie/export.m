function export(obj, filePath, selectedTraces, selectedFrames)
% export all movie data in a file format dependent on the given file type
%
% selectedPeaks is a list of indices of selected peaks that should be exported
% use all peaks if no list is supplied
% selectedFrames is a cell array of lists that indicate which frames from each
% trace should be exported. all frames will be exported if now argument is
% given
    
    if nargin == 2
        selectedTraces = 1:size(obj.peakPositions, 1);
    end
    if nargin < 4
        % maxium number of frames in a trace; actual size depends on selection
        selectedFrames = cell(length(obj.traces), 1);
        selectedFrames(:) = deal({1:size(obj.photonStreams{1}, 3)});
    end
    
    % check which file type we should export to by checking the file extension
    fileType = lower(filePath(end-2:end));
    switch fileType
        case 'csv'
            obj.exportCsv(filePath, selectedTraces, selectedFrames);
        otherwise
            error('ALEX:Movie:UnknownFiletype', ...
                  'can not export to filetype %s', fileType)
    end
end
