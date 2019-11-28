function exportCsv(filePath, movie, mapping, traces, selectedFrames)
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
    metadata = cell(8, 16);
    metadata(1, 1) = {'### METADATA'};
    metadata(2, 1:2) = {'filePath',  movie.filePath};
    metadata(3, 1:2) = {'aquisitionMethod', movie.traceAquisitionMethod};
    metadata(4:7, 1) = deal({'Threshold'});
    metadata(4:7, 2) = deal(mapping.photonStreamNames);
    metadata(4:7, 3) = num2cell(movie.peakThresholds);
    metadata(8, 1:2) = {'pointRadius', num2str(movie.peakRadius)};
    
    % trace/peak indices and position
    % one peak per line
    peaks = cell(2 + length(traces), 16);
    peaks(1, 1) = {'### POINT COORDINATES'};
    peaks(2, 1:3) = {'pointIndex', 'X', 'Y'};
    peaks(3:end, 1) = {traces.index};
    peaks(3:end, 2:3) = num2cell(cell2mat(transpose({traces.position})));
    
    % emission intensities
    % one peak and one frame per line.
    emissions = cell(2, 16);
    emissions(1, 1) = {'### EMISSION INTENSITIES'};
    emissions(2, 1:16) = {'pointIndex', 'frameIndex', ...
        'DexDemRaw', 'DexAemRaw', ...
        'AexDemRaw', 'AexAemRaw', ...
        'DexDemBkg', 'DexAemBkg', ...
        'AexDemBkg', 'AexAemBkg', ...
        'fretEfficiency', 'stoichiometry', ...
        'leakageCoefficientL', ...
        'directionalCoefficientD', 'directionalCoefficientDPrime', 'gamma'};
    % average fret analysis values for each trace and selected frames
    % one peak/trace per line
    fret = cell(2, 16);
    fret(1, 1)     = {'### POINT AVERAGES'};
    fret(2, 1:3)   = {'pointIndex', 'averageFretEfficiency', ...
        'averageStoichiometry'};
    
    for i = 1:length(traces)
        emissions = [emissions; traceFrames(traces(i), selectedFrames{i})];
        fret = [fret; traceAverage(traces(i), selectedFrames{i})];
    end
    
    fullData = [metadata; peaks; emissions; fret];
    alex.utilities.cell2csv(filePath, fullData, ',');
end

function values = traceFrames(trace_, selectedFrames)
% create a cell array with all the values for each trace frame
    
    values = cell(length(selectedFrames), 16);
    if length(selectedFrames) == 0
        return
    end
    
    values(:, 1) = deal({trace_.index});
    % always use the uneven frame numbers
    values(:, 2) = num2cell(2 * selectedFrames - 1);
    
    % extract selected frames from intensities
    rawGreenExGreenEm = trace_.rawByName('DexDem');
    rawGreenExRedEm = trace_.rawByName('DexAem');
    rawRedExGreenEm = trace_.rawByName('AexDem');
    rawRedExRedEm = trace_.rawByName('AexAem');
    bkgGreenExGreenEm = trace_.backgroundByName('DexDem');
    bkgGreenExRedEm = trace_.backgroundByName('DexAem');
    bkgRedExGreenEm = trace_.backgroundByName('AexDem');
    bkgRedExRedEm = trace_.backgroundByName('AexAem');
    values(:, 3) = num2cell(rawGreenExGreenEm(selectedFrames));
    values(:, 4) = num2cell(rawGreenExRedEm(selectedFrames));
    values(:, 5) = num2cell(rawRedExGreenEm(selectedFrames));
    values(:, 6) = num2cell(rawRedExRedEm(selectedFrames));
    values(:, 7) = num2cell(bkgGreenExGreenEm(selectedFrames));
    values(:, 8) = num2cell(bkgGreenExRedEm(selectedFrames));
    values(:, 9) = num2cell(bkgRedExGreenEm(selectedFrames));
    values(:, 10) = num2cell(bkgRedExRedEm(selectedFrames));
    
    % export fret observables if they exists
    if not(isempty(trace_.fretEfficiency) || isempty(trace_.stoichiometry))
        values(:, 11) = num2cell(trace_.fretEfficiency(selectedFrames));
        values(:, 12) = num2cell(trace_.stoichiometry(selectedFrames));
        values(:, 13) = deal({trace_.leakage});
        values(:, 14) = deal({trace_.directExcitation});
        values(:, 15) = deal({trace_.directExcitationPrime});
        values(:, 16) = deal({trace_.gamma});
    end
end

function values = traceAverage(trace_, selectedFrames)
% create a cell array with the averages values over the selected trace frames
    
    if length(selectedFrames) == 0
        values = cell(0, 16);
    else
        values = cell(1, 16);
        values(1) = {trace_.index};
        if not(isempty(trace_.fretEfficiency) || isempty(trace_.stoichiometry))
            values(2) = {mean(trace_.fretEfficiency(selectedFrames))};
            values(3) = {mean(trace_.stoichiometry(selectedFrames))};
        end
    end
end
