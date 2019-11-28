function exportCsvTxtThreeColors(filePath, movie, mapping, traces, selectedFrames)
% export all data from the movie and the traces as a csv file
    
    if isempty(movie)
        error('alex:ExportCsv:NoMovie', 'movie is empty')
    end
    if isempty(traces)
        error('alex:ExportCsv:NoTraces', 'the list of traces is empty')
    end
    % select all frames from every trace if no selection was given
    if nargin <= 4
        selectedFrames = cell(length(traces), 1);
        % this assumes that all traces have the same length
        selectedFrames(:) = deal({1:traces(1).intensityCount});
    end
    
    % metadata
    % one variable per line. no exceptions!
    
    % TODO save color alignment and calibration
    metadata = cell(7, 3);
    metadata(1, 1) = {'### METADATA'};
    metadata(2, 1:2) = {'filePath',  movie.filePath};
    metadata(3, 1:2) = {'aquisitionMethod', movie.traceAquisitionMethod};
    metadata(4:6, 1) = deal({'Threshold'});
    metadata(4:6, 2) = deal(mapping.photonStreamNames);
    metadata(4:6, 3) = num2cell(movie.peakThresholds);
    metadata(7, 1:2) = {'pointRadius', num2str(movie.peakRadius)};
    
    % trace/peak indices and position
    % one peak per line
    peaks = cell(2 + length(traces), 3);
    peaks(1, 1) = {'### POINT COORDINATES'};
    peaks(2, 1:3) = {'pointIndex', 'X', 'Y'};
    peaks(3:end, 1) = {traces.index};
    peaks(3:end, 2:3) = num2cell(cell2mat(transpose({traces.position})));
    
    % combine metadata and peaks for the header file

    header = [metadata; peaks];
    
    % emission intensities
    % first column frameIndex then each column represents emission 
    % intensities either raw, background or backgrund corrected
    
    blueRawSignals = cell2mat(tracesEmissions(traces, 'BlueEM', 'raw'));
    blueBackgrounds = cell2mat(tracesEmissions(traces, 'BlueEM', 'background'));
    blueBackgroundCorrectedSignals = cell2mat(tracesEmissions(traces, 'BlueEM', 'corrected'));
    greenRawSignals = cell2mat(tracesEmissions(traces, 'GreenEM', 'raw'));
    greenBackgrounds = cell2mat(tracesEmissions(traces, 'GreenEM', 'background'));
    greenBackgroundCorrectedSignals = cell2mat(tracesEmissions(traces, 'GreenEM', 'corrected'));
    redRawSignals = cell2mat(tracesEmissions(traces, 'RedEM', 'raw'));
    redBackgrounds = cell2mat(tracesEmissions(traces, 'RedEM', 'background'));
    redBackgroundCorrectedSignals = cell2mat(tracesEmissions(traces, 'RedEM', 'corrected'));
    
    % create one header file and export it as csv because it contais both strings and numbers
    % and one txt file each for every channel
    [p, n, ext] = fileparts(filePath);
    alex.utilities.cell2csv(fullfile(p, [n, '-header.csv']), header);
    dlmwrite(fullfile(p, [n, '-blueRaw', ext]), blueRawSignals); 
    dlmwrite(fullfile(p, [n, '-blueBackground', ext]), blueBackgrounds); 
    dlmwrite(fullfile(p, [n, '-blueBackgroundCorrected', ext]), blueBackgroundCorrectedSignals);
    dlmwrite(fullfile(p, [n, '-greenRaw', ext]), greenRawSignals); 
    dlmwrite(fullfile(p, [n, '-greenBackground', ext]), greenBackgrounds); 
    dlmwrite(fullfile(p, [n, '-greenBackgroundCorrected', ext]), greenBackgroundCorrectedSignals);
    dlmwrite(fullfile(p, [n, '-redRaw', ext]), redRawSignals); 
    dlmwrite(fullfile(p, [n, '-redBackground', ext]), redBackgrounds); 
    dlmwrite(fullfile(p, [n, '-redBackgroundCorrected', ext]), redBackgroundCorrectedSignals);
end

function cells = tracesEmissions(traces, byName, type_)
% create a cell array with the signal values from all traces
% each column represents one trace
    
    if length(traces) < 1
        cells = cell();
        return
    else
        frameCount = traces(1).intensityCount;
        cells = cell(frameCount, length(traces) + 1);
    end
    
    cells(:, 1) = num2cell(1:frameCount);
    
    for i = 1:length(traces)
        values = zeros(frameCount, 1);
        if strcmp('BlueEM', byName)
            if strcmp('raw', type_)
                values(1:1:end) = traces(i).rawByName('BlueEM');
            elseif strcmp('background', type_)
                values(1:1:end) = traces(i).backgroundByName('BlueEM');
            else strcmp('corrected', type_)
                values(1:1:end) = traces(i).correctedByName('BlueEM');

            end
        elseif strcmp('GreenEM', byName)
            if strcmp('raw', type_)
                values(1:1:end) = traces(i).rawByName('GreenEM');
            elseif strcmp('background', type_)
                values(1:1:end) = traces(i).backgroundByName('GreenEM');
            else strcmp('corrected', type_)
                values(1:1:end) = traces(i).correctedByName('GreenEM');

            end

        elseif strcmp('RedEM', byName)
            if strcmp('raw', type_)
                values(1:1:end) = traces(i).rawByName('RedEM');
            elseif strcmp('background', type_)
                values(1:1:end) = traces(i).backgroundByName('RedEM');
            else strcmp('corrected', type_)
                values(1:1:end) = traces(i).correctedByName('RedEM');

            end


        end
        
        cells(:, i + 1) = num2cell(values);
    end
end
