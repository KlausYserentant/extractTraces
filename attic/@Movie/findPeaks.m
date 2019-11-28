function peakPositions = findPeaks(obj)
% determine position of peaks in the four photon streams
%
% use the current settings for thresholds, radius, etc. and return a list
% with the found positions
    
    unfiltered = [];
    for i = 1:length(obj.images)
        % 2*peakRadius + 2 should be the optimal size parameter; see the pkfnd
        % documentation for further explanations
        out = alex.tracking.pkfnd(obj.images{i}, obj.peakThresholds(i), ...
                                  (2 * obj.peakRadius) + 2);
        unfiltered = cat(1, unfiltered, out);
    end
    
    if isempty(unfiltered)
        peakPositions = [];
    else
        % mark double entries (anything closer together than the peak radius)
        % makes sure that peaks found in multiple images are only counted once
        valid = ones(size(unfiltered));
        for i = 1:length(unfiltered)
            for j = i+1:length(unfiltered)
                if norm(unfiltered(j, :) - unfiltered(i, :)) < obj.peakRadius
                    valid(j, :) = [0 0];
                end
            end
        end
        
        % retain only the unmarked position
        % TODO check if this can be done without splitting the array
        % seems illogical that this is really needed
        valid = logical(valid);
        peakPositions = ...
            cat(2, unfiltered(valid(:, 1), 1), unfiltered(valid(:, 2), 2));
    end
end
