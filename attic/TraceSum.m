classdef TraceSum < alex.Trace
% trace extraction using the sum of all photon counts around the position

methods
    function obj = TraceSum(movie, position, otherPositions)
        obj = obj@alex.Trace(movie, position, otherPositions);
    end
end

methods (Access = protected)
    function [photonCounts, backgrounds] = ...
            extractPhotonStream(obj, photonStream)
        
        peakAreaFrames = obj.extractPeakArea(photonStream);
        % we need the number of pixel that will be involved in the sum
        pixelCount = sum(sum(isfinite(peakAreaFrames(:, :, 1))));
        photonCounts = squeeze(nansum(nansum(peakAreaFrames, 1), 2));
        
        backgroundAreaFrames = obj.extractBackgroundArea(photonStream);
        % scale backgrounds to the number of pixel used for photon count
        backgrounds = ...
            pixelCount * squeeze(nanmean(nanmean(backgroundAreaFrames, 1), 2));
    end
end

end % classdef
