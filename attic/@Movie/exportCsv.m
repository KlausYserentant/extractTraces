function exportCsv(obj, filePath, selectedTraces, selectedFrames)
% export all data from the movie as a csv file
%
% selectedTraces is a list of indices of selected peaks that should be exported
% selectedFrames is a cell array of lists that indicate which frames from each
% trace should be exported.
    
    % selectedTraces originates from the selection in the traces listbox
    % it is expected to have the dimensionality 1xn for n selected traces
    % we need it the other way round nx1
    selectedTraces = transpose(selectedTraces);
    selectionSize = size(selectedTraces, 1);    
    
    % maxium number of frames in a trace; actual size depends on selection
    traceMaxSize = size(obj.photonStreams{1}, 3);
    
    % metadata
    % one variable per line. no exceptions!
    [pathName, fileName, fileExtension, fileVersion] = fileparts(obj.filePath);
    
    % TODO save color alignment and calibration
    metadata = cell(9, 16);
    metadata(1, 1)   = {'### METADATA'};
    metadata(2, 1:2) = {'pathName',  pathName};
    metadata(3, 1:2) = {'fileName', [fileName fileExtension]};
    metadata(4, 1:2) = {'aquisitionMethod', obj.traceAquisitionMethod};
    metadata(5:8, 1) = deal({'Threshold'});
    metadata(5:8, 2) = deal(obj.photonStreamTitles);
    metadata(5:8, 3) = num2cell(obj.peakThresholds);
    metadata(9, 1:2) = {'pointRadius', num2str(obj.peakRadius)};
    
    % trace/peak indices and position
    % one peak per line
    peaks = cell(2 + selectionSize, 16);
    peaks(1, 1)       = {'### POINT COORDINATES'};
    peaks(2, 1:3)     = {'pointIndex', 'X', 'Y'};
    peaks(3:end, 1)   = num2cell(selectedTraces);
    peaks(3:end, 2:3) = num2cell(cat(1, obj.traces(selectedTraces).position));
    
    % emission intensities
    % one peak and one frame per line.
    % reserve as many lines as there could possibly be; could be less depending
    % on the selection of frames
    emissions = cell(2 + (selectionSize * traceMaxSize), 16);
    emissions(1, 1) = {'### EMISSION INTENSITIES'};
    emissions(2, 1:16) = {'pointIndex', 'frameIndex', ...
        'greenExGreenEmRaw', 'greenExRedEmRaw', ...
        'redExGreenEmRaw', 'redExRedEmRaw', ...
        'greenExGreenEmBkg', 'greenExRedEmBkg', ...
        'redExGreenEmBkg', 'redExRedEmBkg', ...
        'fretEfficiency', 'stoichiometry', ...
        'leakageCoefficientL', ...
        'directionalCoefficientD', 'directionalCoefficientDPrime', 'gamma'};
    
    % average fret analysis values for each trace
    % leave empty to have the same file format for everything
    % one peak/trace per line
    fret = cell(2 + selectionSize, 16);
    fret(1, 1)     = {'### POINT AVERAGES'};
    fret(2, 1:3)   = {'pointIndex', 'averageFretEfficiency', 'averageStoichiometry'};
    fret(3:end, 1) = num2cell(selectedTraces);
    
    indicesStart = 3; %
    for i = 1:size(selectedTraces, 1)
        traceIndex = selectedTraces(i);
        t = obj.traces(traceIndex);
        
        frameIndices = selectedFrames{traceIndex};
        
        % indices of selected frames of the in the emissions array
        indices = indicesStart:indicesStart + length(frameIndices) - 1;
        indicesStart = indicesStart + length(frameIndices);
        
        emissions(indices, 1) = deal(num2cell(traceIndex));
        % use greenEx movie frames numbers for the frame index
        emissions(indices, 2) = num2cell(obj.indicesGreenEx(frameIndices));
        % extract selected frames from intensities
        rawGreenExGreenEm = t.photonCounts('GreenExGreenEm');
        rawGreenExRedEm = t.photonCounts('GreenExRedEm');
        rawRedExGreenEm = t.photonCounts('RedExGreenEm');
        rawRedExRedEm = t.photonCounts('RedExRedEm');
        bkgGreenExGreenEm = t.backgrounds('GreenExGreenEm');
        bkgGreenExRedEm = t.backgrounds('GreenExRedEm');
        bkgRedExGreenEm = t.backgrounds('RedExGreenEm');
        bkgRedExRedEm = t.backgrounds('RedExRedEm');
        emissions(indices, 3) = num2cell(rawGreenExGreenEm(frameIndices));
        emissions(indices, 4) = num2cell(rawGreenExRedEm(frameIndices));
        emissions(indices, 5) = num2cell(rawRedExGreenEm(frameIndices));
        emissions(indices, 6) = num2cell(rawRedExRedEm(frameIndices));
        emissions(indices, 7) = num2cell(bkgGreenExGreenEm(frameIndices));
        emissions(indices, 8) = num2cell(bkgGreenExRedEm(frameIndices));
        emissions(indices, 9) = num2cell(bkgRedExGreenEm(frameIndices));
        emissions(indices, 10) = num2cell(bkgRedExRedEm(frameIndices));
        
        % export fret observables if they exists
        if not(isempty(t.fretEfficiency))
            emissions(indices, 11) = num2cell(t.fretEfficiency(frameIndices));
            emissions(indices, 12) = num2cell(t.stochiometry(frameIndices));
            emissions(indices, 13) = deal(num2cell(t.leakage));
            emissions(indices, 14) = deal(num2cell(t.directExcitation));
            emissions(indices, 15) = deal(num2cell(t.directExcitationPrime));
            emissions(indices, 16) = deal(num2cell(t.gamma));
            
            fret(i + 2, 2) = num2cell(t.fretEfficiencyAverage);
            fret(i + 2, 3) = num2cell(t.stochiometryAverage);
        end
    end
    
    fullData = [metadata; peaks; emissions; fret];
    alex.utilities.cell2csv(filePath, fullData, ',');
end
