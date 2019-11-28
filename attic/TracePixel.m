classdef TracePixel < alex.Trace
% trace extraction using the photon count at the position

methods
    function obj = TracePixel(movie, position, otherPositions)
        obj = obj@alex.Trace(movie, position, otherPositions);
    end
end

methods (Access = protected)
    function [photonCounts, backgrounds] = ...
            extractPhotonStream(obj, photonStream)
        
        photonCounts = ...
            squeeze(photonStream(obj.position(2), obj.position(1), :));
        
        backgroundAreaFrames = obj.extractBackgroundArea(photonStream);
        backgrounds = squeeze(nanmean(nanmean(backgroundAreaFrames, 1), 2));
    end
end

end % classdef
