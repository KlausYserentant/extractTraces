function selectedTraces = filterTf(traces, threshold)
% filter the list of traces for the transcription factor analysis
%
% returns a list of traces where all traces that only have a signal in
% RedExRedEm are removed
    
    if nargin <= 2
        % default raw over background threshold for signal detection
        threshold = 1.2;
    end
    
    selection = zeros(length(traces), 1);
    for i = 1:length(traces)
        selection(i) = not(hasOnlyRedExRedEmSignal(traces(i), threshold));
    end
    
    selectedTraces = traces(logical(selection));
end

function truth = hasOnlyRedExRedEmSignal(trace_, threshold)
% check if the given trace has a signal only in the RedExRedEm photon stream
    
    truth = hasSignal(trace_, 'AexAem', threshold, 0) && ...
        not(hasSignal(trace_, 'DexAem', threshold, 1)) && ...
        not(hasSignal(trace_, 'DexDem', threshold, 2));
end

function truth = hasSignal(trace_, streamName, threshold, sumSignals)
% use simple thresholding to check if there is a signal in a photonStream
    
    raw = trace_.rawByName(streamName);
    background = trace_.backgroundByName(streamName);
    
    signals = raw ./ background > threshold;
    % TODO check optimal number of allowed r / b frames to still consider
    % this photon stream "signalless"
    truth = (sum(signals) > sumSignals);
end