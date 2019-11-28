function [e, s] = collectObservables(traces, selectedFrames)
% combine observables from each selected intensity frame of each trace
    
    e = [];
    s = [];
    for i = 1:length(traces)
        frameIndices = selectedFrames{i};
        e = [e; traces(i).fretEfficiency(frameIndices)];
        s = [s; traces(i).stoichiometry(frameIndices)];
    end
end