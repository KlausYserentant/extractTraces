function [peakPositions, peaksInPhotonStream] = findPeaks(movie)
% find peaks in all photon streams and return their positions
    
    numPhotonStreams = movie.numPhotonStreams;
    
    % according to the pkfnd documentation, 2*peakRadius + 2 should be the
    % size parameter. see the pkfnd documentation for further explanations
    % movie.peakRadius substituted by fixed radius 2
    peakSize = (2 * 2) + 2;
    
    unfiltered = [];
    numPeaksEachPhotonStream = zeros(1, numPhotonStreams);
    for i = 1:numPhotonStreams
        im = movie.photonStreamSums(:, :, i);
        out = alex.tracking.pkfnd(im, movie.peakThresholds(i), peakSize);
        numPeaksEachPhotonStream(1, i) = size(out, 1);
        unfiltered = cat(1, unfiltered, out);
    end
    
    if isempty(unfiltered)
        peakPositions = [];
        peaksInPhotonStream = [];
    else
        % mark double entries (anything closer together than the peak radius)
        % makes sure that peaks found in multiple images are only counted once
        valid = ones(size(unfiltered));
        % mark entries according to which PhotonStream they can be detected
        % in
        peaksInPhotonStream = zeros(size(unfiltered,1), numPhotonStreams);
        startIndex = 1;
        endIndex = 0;
        for i = 1:numPhotonStreams
            endIndex = endIndex + numPeaksEachPhotonStream(1, i);
            if endIndex >= startIndex
                peaksInPhotonStream(startIndex:endIndex, i) = 1;
            end
            startIndex = startIndex + numPeaksEachPhotonStream(1, i); 
        end
        
        for i = 1:length(unfiltered)
            for j = i+1:length(unfiltered)
                if norm(unfiltered(j, :) - unfiltered(i, :)) < movie.peakRadius
                    valid(j, :) = [0 0];
                    startIndex = 1;
                    endIndex = 0;
                    for k = 1:numPhotonStreams
                        endIndex = endIndex + numPeaksEachPhotonStream(1, k);
                        if (j >= startIndex) && (j <=  endIndex)
                            peaksInPhotonStream(i, k) = 1;
                        end
                        startIndex = startIndex + numPeaksEachPhotonStream(1, k);
                    end
                end
            end
        end

        % retain only the unmarked position
        % TODO check if this can be done without splitting the array
        % seems illogical that this is really needed
        valid = logical(valid);
        peakPositions = ...
            cat(2, unfiltered(valid(:, 1), 1), unfiltered(valid(:, 2), 2));
        peaksInPhotonStream = peaksInPhotonStream(valid(:, 1), :);
        % change dimension to 2xn
        peakPositions = transpose(peakPositions);
        % change dimension to numPhotonStreamsxn
        peaksInPhotonStream = transpose(peaksInPhotonStream);   
    end
end
