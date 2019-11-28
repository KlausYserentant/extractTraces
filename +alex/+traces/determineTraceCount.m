function [numberGreen numberGreenRed] = determineTraceCount(traces, threshold)
% returns the number of green containing traces and the number of red and 
% green containing traces (red only are filtered before) determined by trace counting where traces are
% counted as red and green if the number of frames that the signal to
% background is higher than a certain threshold exceeds a certain number
    
    if nargin <= 2
        % default raw over background threshold for signal detection
        threshold = 1.4 ;
    end
    
    selectionGreenRed = zeros(length(traces), 1);
    for i = 1:length(traces)
        selectionGreenRed(i) = hasRedExRedEmAndGreenExGreenEmSignal(traces(i), threshold);
    end
    
    selectionGreen = zeros(length(traces), 1);
    for i = 1:length(traces)
        selectionGreen(i) = hasGreenExGreenEmSignal(traces(i), threshold);
    end
    
    numberGreenRed = sum(selectionGreenRed);
    numberGreen = sum(selectionGreen);
end

function truth = hasRedExRedEmAndGreenExGreenEmSignal(trace_, threshold)
% check if the given trace has a signal in the RedExRedEm and GreenExGreenEm 
% photon stream
    
    truth = hasSignal(trace_, 'AexAem', threshold, 1) && ...
            hasSignal(trace_, 'DexDem', threshold, 1);
end

function truth = hasGreenExGreenEmSignal(trace_, threshold)
% check if the given trace has a signal in the GreenExGreenEm photon stream
    
    truth = hasSignal(trace_, 'DexDem', threshold, 1);
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