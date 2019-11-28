classdef TraceMax < alex.Trace
% trace extraction using the maximum photon count around the position

methods
    function obj = TraceMax(movie, position, otherPositions)
        obj = obj@alex.Trace(movie, position, otherPositions);
    end
end

methods (Access = protected)
    function [photonCounts, backgrounds] = ...
            extractPhotonStream(obj, photonStream)
        
        peakAreaFrames = obj.extractPeakArea(photonStream);
        photonCounts = squeeze(nanmax(nanmax(peakAreaFrames, [], 1), [], 2));
        
        backgroundAreaFrames = obj.extractBackgroundArea(photonStream);
        backgrounds = squeeze(nanmean(nanmean(backgroundAreaFrames, 1), 2));
    end
end

end % classdef
