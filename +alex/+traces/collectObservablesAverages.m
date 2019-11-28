function [e, s] = collectObservablesAverages(traces, selectedFrames)
% combine average observables from each trace
    
    e = zeros(length(traces), 1);
    s = zeros(length(traces), 1);
    for i = 1:length(traces)
        frameIndices = selectedFrames{i};
        e(i) = mean(traces(i).fretEfficiency(frameIndices));
        s(i) = mean(traces(i).stoichiometry(frameIndices));
    end
end