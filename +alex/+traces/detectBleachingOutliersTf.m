function selectedFrames = detectBleachingOutliersTf(traces, threshold)
% detect and deselect bleached frames for the transcription factor analysis
    
    if nargin <= 2
        % default raw over background threshold for signal detection
        threshold = 1.2;
    end
    
    % calculate e-s with default coefficients for the outlier rejection
    alex.traces.calculateObservables(traces, 0.0, 0.0, 1.0);
    
    selectedFrames = cell(length(traces), 1);
    for i = 1:length(traces)
        framesNotBleached = simpleThresholding(traces(i), threshold);
        framesNotOutliers = framesInRange(traces(i));
        selectedFrames(i) = {find(framesNotBleached & framesNotOutliers)};
    end
end

function frameMask = simpleThresholding(trace_, threshold)
% detect bleaching in a single trace using a simple thresholding method
    
    % transcription factor specific:
    % do the bleach detection only for selected photon streams
    signalsDexDem = trace_.rawByName('DexDem') ./ ...
        trace_.backgroundByName('DexDem') > threshold;
    signalsAexAem = trace_.rawByName('AexAem') ./ ...
        trace_.backgroundByName('AexAem') > threshold;
    
    if sum(signalsDexDem) > 1 && sum(signalsAexAem) > 1
        % there is a signal in both photon streams
        frameMask = signalsDexDem & signalsAexAem;
    elseif sum(signalsDexDem) > 1
        frameMask = signalsDexDem;
    else
        frameMask = signalsAexAem;
    end
end

function frameMask = framesInRange(trace_)
% select all frames where E and S is inside the physical range are marked
    
    frameMask = trace_.fretEfficiency > -0.25 & ...
        trace_.fretEfficiency < 1.25  & ...
        trace_.stoichiometry > -0.25 & ...
        trace_.stoichiometry < 1.25;
end
