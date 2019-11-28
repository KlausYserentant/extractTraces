function cc = collectCorrectionCoefficients(traces, selectedFrames, correctionCoefficient)
% combine selected correctionCoefficients from each selected intensity 
% frame of each trace
    
    cc = [];
    
    if strcmp(correctionCoefficient, 'l')
        for i = 1:length(traces)
            frameIndices = selectedFrames{i};
            cc = [cc; traces(i).leakageCoefficient(frameIndices)];
        end
    else
        for i = 1:length(traces)
            frameIndices = selectedFrames{i};
            cc = [cc; traces(i).directExcitationCoefficient(frameIndices)];
        end
    end
end