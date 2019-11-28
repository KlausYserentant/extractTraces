classdef Trace < handle
% abstract base class for the trace calculation
%
% this class is an abstract base class and does not contain the actual code to
% extract a trace from a movie. it contains all the necessary surrounding code,
% leaving the specific trace calculation to the implementation of a subclass
    
    % TODO set correct property access (i.e. public, protected or private)
    properties
        position = [1, 1];
        otherPositions = []; % all other peak positions
        peakRadius = 3;
        backgroundRadius = 8;
        
        indicesRedEx = [];
        indicesGreenEx = [];
        
        numberOfFrames = 0;
        
        photonCounts = [];
        backgrounds = [];
        calibrated = [];
        
        fretEfficiency = [];
        fretEfficiencyAverage = [];
        stochiometry = [];
        stochiometryAverage = [];
        
        leakage = 0;
        directExcitation = 0;
        directExcitationPrime = 0;
        gamma = 1;
    end
    
    methods
        function obj = Trace(movie, position, otherPositions)
        % construct the Trace object and extract traces for all photon streams
            
            obj.position = position;
            obj.otherPositions = otherPositions;
            obj.peakRadius = round(movie.peakRadius);
            % background calculation should not start immediately where the
            % peak ends. 1 - 2 pixel ring should be left out to reduce effect
            % from smeared out peaks on background
            % background radius should be at least peak radius + 3
            % TODO optimize size; maybe something like scale with peak radius
            obj.backgroundRadius = obj.peakRadius + 5;
            
            obj.indicesRedEx = movie.indicesRedEx;
            obj.indicesGreenEx = movie.indicesGreenEx;
            
            % TODO update once Movie uses containers.Map as well
            % use extractPhotonStream to extract traces for each stream
            obj.photonCounts = containers.Map();
            obj.backgrounds = containers.Map();
            obj.calibrated = containers.Map();
            for i = 1:length(movie.photonStreamTitles)
                name = movie.photonStreamTitles{i};
                [raw, backgrounds] = ...
                    obj.extractPhotonStream(movie.photonStreams{i});
                obj.numberOfFrames = size(raw, 1);
                obj.photonCounts(name) = raw;
                obj.backgrounds(name) = backgrounds;
                obj.calibrated(name) = (raw - backgrounds);
            end
        end
        
        function calcObservables(obj, leakage, directExcitation, gamma_, dType)
        % calculate fret efficiency and stochiometry for this trace
        %
        % dType is the type of the direct excitation coefficient. d corresponds
        % to the normal one and everything else to d prime
            
            obj.leakage = leakage;
            obj.gamma = gamma_;
            
            if strcmpi(dType, 'd')
                obj.directExcitation = directExcitation;
                obj.directExcitationPrime = 0;
                calcE = @alex.fret.calcFretEfficiency;
                calcS = @alex.fret.calcStochiometry;
            else
                obj.directExcitation = 0;
                obj.directExcitationPrime = directExcitation;
                calcE = @alex.fret.calcFretEfficiencyPrime;
                calcS = @alex.fret.calcStochiometryPrime;
            end
            
            obj.fretEfficiency = calcE( ...
                obj.calibrated, leakage, directExcitation, gamma_);
            obj.fretEfficiencyAverage = mean(obj.fretEfficiency(:));
            
            obj.stochiometry = calcS( ...
                obj.calibrated, leakage, directExcitation, gamma_);
            obj.stochiometryAverage = mean(obj.stochiometry(:));
        end
    end
    
    methods (Access = protected)
        function frames = extractPeakArea(obj, photonStream)
        % select a circle around the peak and mask out the rest with NaN
            
            % boundaries of box containing the circle
            x0 = obj.position(1);
            y0 = obj.position(2);
            xStart0 = max(1, x0 - obj.peakRadius);
            xFinish0 = min(x0 + obj.peakRadius, size(photonStream, 2));
            yStart0 = max(1, y0 - obj.peakRadius);
            yFinish0 = min(y0 + obj.peakRadius, size(photonStream, 1));
            
            % coordinates in the new coordinate system of the cut out area
            x1 = x0 - xStart0 + 1; % +1 because matlab starts indices at 1
            y1 = y0 - yStart0 + 1;
            % distance to peak center in the new coordinate system
            distanceSquared = @(x, y) double(x - x1)^2 + double(y - y1)^2;
            
            % cut out the box and mask out everything not in the peak circle
            frames = photonStream(yStart0:yFinish0, xStart0:xFinish0, :);
            for x = 1:size(frames, 2)
                for y = 1:size(frames, 1)
                    if distanceSquared(x, y) > obj.peakRadius^2
                        frames(y, x, :) = NaN;
                    end
                end
            end
        end
        
        function frames = extractBackgroundArea(obj, photonStream)
        % select aperture shaped background area and mask out the rest with NaN
            
            % radius where the background calculations starts and ends
            % leave a security ring between peak and background of at least 2
            innerRadius = obj.peakRadius + 2;
            outerRadius = obj.backgroundRadius;
            
            % boundaries of box containing the aperture
            x0 = obj.position(1);
            y0 = obj.position(2);
            xStart0 = max(1, x0 - outerRadius);
            xFinish0 = min(x0 + outerRadius, size(photonStream, 2));
            yStart0 = max(1, y0 - outerRadius);
            yFinish0 = min(y0 + outerRadius, size(photonStream, 1));
            
            % coordinates in the new coordinate system of the cut out area
            x1 = x0 - xStart0 + 1; % +1 because matlab starts indices at 1
            y1 = y0 - yStart0 + 1;
            % distance to peak center in the new coordinate system
            distanceSquared = @(x, y) double(x - x1)^2 + double(y - y1)^2;
            
            % cut out the box and mask out everything outside the aperture
            frames = photonStream(yStart0:yFinish0, xStart0:xFinish0, :);
            for x = 1:size(frames, 2)
                for y = 1:size(frames, 1)
                    if distanceSquared(x, y) <= innerRadius^2 ...
                            || distanceSquared(x, y) > outerRadius^2
                        frames(y, x, :) = NaN;
                    end
                end
            end
            
            % mark out other peaks that might lie too close
            for i = 1:length(obj.otherPositions)
                % coordinates of this other point in the coordinate system of
                % the cut out area
                xi = obj.otherPositions(i, 1) - xStart0 + 1; % see above
                yi = obj.otherPositions(i, 2) - yStart0 + 1;
                % distance to other peak center
                distanceSquared = @(x, y) double(x - xi)^2 + double(y - yi)^2;
                
                for x = 1:size(frames, 2)
                    for y = 1:size(frames, 1)
                        if distanceSquared(x, y) <= innerRadius^2
                            frames(y, x, :) = NaN;
                        end
                    end
                end
            end
        end
    end
    
    methods (Access = protected, Abstract)
        [photonCounts, backgrounds] = extractPhotonStream(obj, photonStream);
    end
    
end % classdef
