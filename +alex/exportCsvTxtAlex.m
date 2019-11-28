function exportCsvTxtAlex(filePath, movie, mapping, traces, peaksInPhotonStream, selectedFrames)
% export all data from the movie and the traces as a csv file
    
    if isempty(movie)
        error('alex:ExportCsv:NoMovie', 'movie is empty')
    end
    if isempty(traces)
        error('alex:ExportCsv:NoTraces', 'the list of traces is empty')
    end
    % select all frames from every trace if no selection was given
    if nargin <= 5
        selectedFrames = cell(length(traces), 1);
        % this assumes that all traces have the same length
        selectedFrames(:) = deal({1:traces(1).intensityCount});
    end
    % determine the pathname and extension
    [p, n, ext] = fileparts(filePath);
    % metadata
    % one variable per line. no exceptions!
    
    % TODO save color alignment and calibration
    metadata = cell(9, 3);
    metadata(1, 1) = {'### METADATA'};
    metadata(2, 1:2) = {'filePath',  movie.filePath};
    metadata(3, 1:2) = {'aquisitionMethod', movie.traceAquisitionMethod};
    metadata(4:7, 1) = deal({'Threshold'});
    metadata(4:7, 2) = deal(mapping.photonStreamNames);
    metadata(4:7, 3) = num2cell(movie.peakThresholds);
    metadata(8, 1:2) = {'pointRadius', num2str(movie.peakRadius)};
    metadata(9, 1) = {'In the data files the order of photon streams is DexDEm, below DexAem and then AexAem. The file with the background corrected signal additionally contains first E values, then S values.'};
    
    % determine species of traces 
    logicalDexDem = peaksInPhotonStream(:, mapping.getIndex('DexDem'));
    logicalDexAem = peaksInPhotonStream(:, mapping.getIndex('DexAem'));
    logicalAexAem = peaksInPhotonStream(:, mapping.getIndex('AexAem'));
    logicalDOnly = logicalDexDem & (~logicalAexAem);
    logicalAOnly = logicalAexAem & (~logicalDexDem);
    logicalCol = logicalDexDem & logicalAexAem;
    logicalColNoFRET = logicalDexDem & logicalAexAem & ~logicalDexAem;
    selectDOnly = find(logicalDOnly);
    selectAOnly = find(logicalAOnly);
    selectCol = find(logicalCol);
    selectColNoFRET = find(logicalColNoFRET);
    % determine the number of traces of a certain species
    numDOnly = sum(logicalDOnly);
    numAOnly = sum(logicalAOnly);
    numCol = sum(logicalCol);
    numColNoFRET = sum(logicalColNoFRET);
    
    % emission intensities
    % first column frameIndex then each column represents emission 
    % intensities either raw or background corrected
    % in the file with the background corrected data, you have first a
    % block with DexDem, then with DexAem, then with AexAem followed by E
    % and S. In the raw data, E and S are missing
    
    % trace/peak indices and position
    % one peak per line
    
    peaks = cell((6 + numDOnly + numAOnly + numCol + numColNoFRET), 3);
    peaks(1, 1) = {'### POINT COORDINATES'};
    peaks(2, 1:3) = {'pointIndex', 'X', 'Y'};
    peaks(3, 1) = {'D only'};
    if numDOnly ~= 0
        peaks(4:(4 + numDOnly - 1), 1) = {traces(selectDOnly).index};
        peaks(4:(4 + numDOnly - 1), 2:3) = num2cell(cell2mat(transpose({traces(selectDOnly).position})));
        DOnlyBackgroundCorrected = combineBackgroundCorrected(traces(selectDOnly));
        DOnlyRaw = combineRaw(traces(selectDOnly));
        DOnlyE = cell2mat(tracesObservablesAlex(traces(selectDOnly), 'E'));
        DOnlyS = cell2mat(tracesObservablesAlex(traces(selectDOnly), 'S'));
        dlmwrite(fullfile(p, [n, '-DOnlyBackgroundCorrected', ext]), DOnlyBackgroundCorrected);
        dlmwrite(fullfile(p, [n, '-DOnlyRaw', ext]), DOnlyRaw); 
        dlmwrite(fullfile(p, [n, '-DOnlyE', ext]), DOnlyE); 
        dlmwrite(fullfile(p, [n, '-DOnlyS', ext]), DOnlyS); 
    end
    peaks((4 + numDOnly), 1) = {'A only'};
    if numAOnly ~= 0
        peaks((5 + numDOnly):(5 + numDOnly + numAOnly - 1), 1) = {traces(selectAOnly).index};
        peaks((5 + numDOnly):(5 + numDOnly + numAOnly - 1), 2:3) = num2cell(cell2mat(transpose({traces(selectAOnly).position})));
        AOnlyBackgroundCorrected = combineBackgroundCorrected(traces(selectAOnly));
        AOnlyRaw = combineRaw(traces(selectAOnly));
        AOnlyE = cell2mat(tracesObservablesAlex(traces(selectAOnly), 'E'));
        AOnlyS = cell2mat(tracesObservablesAlex(traces(selectAOnly), 'S'));
        dlmwrite(fullfile(p, [n, '-AOnlyBackgroundCorrected', ext]), AOnlyBackgroundCorrected); 
        dlmwrite(fullfile(p, [n, '-AOnlyRaw', ext]), AOnlyRaw);
        dlmwrite(fullfile(p, [n, '-AOnlyE', ext]), AOnlyE); 
        dlmwrite(fullfile(p, [n, '-AOnlyS', ext]), AOnlyS); 
    end
    peaks((5 + numDOnly + numAOnly), 1) = {'Colocalized'};
    if numCol ~= 0
        peaks((6 + numDOnly + numAOnly):(6 + numDOnly + numAOnly + numCol - 1), 1) = {traces(selectCol).index};
        peaks((6 + numDOnly + numAOnly):(6 + numDOnly + numAOnly + numCol) - 1, 2:3) = num2cell(cell2mat(transpose({traces(selectCol).position})));
        ColBackgroundCorrected = combineBackgroundCorrected(traces(selectCol));
        ColRaw = combineRaw(traces(selectCol));
        ColE = cell2mat(tracesObservablesAlex(traces(selectCol), 'E'));
        ColS = cell2mat(tracesObservablesAlex(traces(selectCol), 'S'));
        dlmwrite(fullfile(p, [n, '-ColocalizedBackgroundCorrected', ext]), ColBackgroundCorrected);
        dlmwrite(fullfile(p, [n, '-ColocalizedRaw', ext]), ColRaw);
        dlmwrite(fullfile(p, [n, '-ColE', ext]), ColE); 
        dlmwrite(fullfile(p, [n, '-ColS', ext]), ColS); 
    end
    peaks((6 + numDOnly + numAOnly + numCol), 1) = {'Colocalized no FRET'};
    if numColNoFRET ~= 0
        peaks((7 + numDOnly + numAOnly + numCol):end, 1) = {traces(selectColNoFRET).index};
        peaks((7 + numDOnly + numAOnly + numCol):end, 2:3) = num2cell(cell2mat(transpose({traces(selectColNoFRET).position})));
        ColNoFRETBackgroundCorrected = combineBackgroundCorrected(traces(selectColNoFRET));
        ColNoFRETRaw = combineRaw(traces(selectColNoFRET));
        ColNoFRETE = cell2mat(tracesObservablesAlex(traces(selectColNoFRET), 'E'));
        ColNoFRETS = cell2mat(tracesObservablesAlex(traces(selectColNoFRET), 'S'));
        dlmwrite(fullfile(p, [n, '-ColocalizedNoFRETBackgroundCorrected', ext]), ColNoFRETBackgroundCorrected);   
        dlmwrite(fullfile(p, [n, '-ColocalizedNoFRETRaw', ext]), ColNoFRETRaw); 
        dlmwrite(fullfile(p, [n, '-ColNoFRETE', ext]), ColNoFRETE); 
        dlmwrite(fullfile(p, [n, '-ColNoFRETS', ext]), ColNoFRETS); 
    end
    
    % combine metadata and peaks for the header file
    header = [metadata; peaks];
    
    % create one header file and export it as csv because it contais both strings and numbers
    % and one txt file each for every species with background corrected or
    % raw signals
    alex.utilities.cell2csv(fullfile(p, [n, '-header.csv']), header);

end

function mat = combineBackgroundCorrected(traces)
    DexDem = tracesEmissionsAlex(traces, 'DexDem', 'corrected');
    DexAem = tracesEmissionsAlex(traces, 'DexAem', 'corrected');
    AexAem = tracesEmissionsAlex(traces, 'AexAem', 'corrected');
    
    mat = cell2mat([DexDem; DexAem; AexAem]);
end

function mat = combineRaw(traces)
    DexDem = tracesEmissionsAlex(traces, 'DexDem', 'raw');
    DexAem = tracesEmissionsAlex(traces, 'DexAem', 'raw');
    AexAem = tracesEmissionsAlex(traces, 'AexAem', 'raw');
    
    mat = cell2mat([DexDem; DexAem; AexAem]);
end

function cells = tracesEmissionsAlex(traces, byName, type_)
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
        if strcmp('DexDem', byName)
            if strcmp('raw', type_)
                values(1:1:end) = traces(i).rawByName('DexDem');
            elseif strcmp('background', type_)
                values(1:1:end) = traces(i).backgroundByName('DexDem');
            else strcmp('corrected', type_)
                values(1:1:end) = traces(i).correctedByName('DexDem');

            end
        elseif strcmp('DexAem', byName)
            if strcmp('raw', type_)
                values(1:1:end) = traces(i).rawByName('DexAem');
            elseif strcmp('background', type_)
                values(1:1:end) = traces(i).backgroundByName('DexAem');
            else strcmp('corrected', type_)
                values(1:1:end) = traces(i).correctedByName('DexAem');

            end
        elseif strcmp('AexAem', byName)
            if strcmp('raw', type_)
                values(1:1:end) = traces(i).rawByName('AexAem');
            elseif strcmp('background', type_)
                values(1:1:end) = traces(i).backgroundByName('AexAem');
            else strcmp('corrected', type_)
                values(1:1:end) = traces(i).correctedByName('AexAem');

            end
        end
        
        cells(:, i + 1) = num2cell(values);
    end
end

function cells = tracesObservablesAlex(traces, observable_)
% create a cell array with first the signal values from all traces
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
        if strcmp('E', observable_)
                values(1:1:end) = traces(i).fretEfficiency;
        elseif strcmp('S', observable_)
                values(1:1:end) = traces(i).stoichiometry;
        end
        
        cells(:, i + 1) = num2cell(values);
    end
end
