classdef Movie < handle
% encapsulates all the information of an ALEX movie
%
% properties that exists separately for each photon stream (e.g. summary
% images) are stored in a cell array ordered according to the following list:
%     RedExRedEm, RedExGreenEm, GreenExRedEm, GreenExGreenEm
    
    % TODO set correct property access (i.e. public, protected or private)
    properties
        filePath = '';
        calibration = [];
        firstFrameExcitation = 'green'; % must be either red or green
        leftFrameEmission = 'red'; % must be either red or green
        
        framesLeft = []; % calibrated frames loaded from the movie file
        framesRight = [];
        
        photonStreamTitles = {'RedExRedEm', 'RedExGreenEm', ...
            'GreenExRedEm', 'GreenExGreenEm'};
        images = []; % summary images for the photon streams
        histograms = []; % corresponding histograms
        
        % variables for peak finding/trace calculation
        peakThresholds = [256 256 256 256];
        peakRadius = 3;
        peakPositions = [];
        traceAquisitionMethod = 'max';
        traces = [];
    end
    
    properties (Dependent)
        indicesRedEx;
        indicesGreenEx;
        
        photonStreams; % the calibrated movie frames for each photon stream
    end
    
    properties (Constant)
        % bin edges for summary images histograms; images are 8bit grayscale
        % and therefore the range and bins can be fixed
        histogramsEdges = transpose(0:2:256);
    end
    
    methods
        function obj = Movie(filePath, calibration, ...
            firstFrameExcitation, leftFrameEmission)
        % construct Movie object; allows variable number of input parameters
            
            if nargin == 0
                return
            elseif nargin == 1
                obj.filePath = filePath;
                obj.calibration = alex.Calibration(); % create an empty one
            else
                obj.filePath = filePath;
                obj.calibration = calibration;
            end
            if nargin >= 3, obj.firstFrameExcitation = firstFrameExcitation; end
            if nargin >= 4, obj.leftFrameEmission = leftFrameEmission; end
            
            if not(exist(obj.filePath, 'file'))
                error('ALEX:Movie:NoMovieFile', ...
                      'the given movie file \"%s\" does not exists', ...
                      obj.filePath)
            elseif not(strcmpi(obj.filePath(end - 2:end), 'sif')) ...
                error('ALEX:Movie:InvalidMovieFile', ...
                      'the given movie file \"%s\" is not a sif file', ...
                      obj.filePath)
            else
                obj.loadFrames();
                obj.summarizePhotonStreams();
            end            
        end
        
        function obj = set.firstFrameExcitation(obj, color)
        % check that color is valid and recalculate dependent properties
            
            if not(strcmpi(color, 'red') || strcmpi(color, 'green'))
                error('ALEX:Movie:InvalidExcitationColor', ...
                      'excitation color \"%s\" is invalid', color)
            elseif not(strcmpi(obj.firstFrameExcitation, color))
                obj.firstFrameExcitation = lower(color);
                obj.summarizePhotonStreams();
            end
        end
        
        function obj = set.leftFrameEmission(obj, color)
        % check that color is valid and recalculate dependent properties
            
            if not(strcmpi(color, 'red') || strcmpi(color, 'green'))
                error('ALEX:Movie:InvalidEmissionColor', ...
                      'emission color \"%s\" is invalid', color)
            elseif not(strcmpi(obj.leftFrameEmission, color))
                obj.leftFrameEmission = lower(color);
                obj.summarizePhotonStreams();
            end
        end
        
        function indices = get.indicesRedEx(obj)
        % get frame indices corresponding to red excitation
            
            % drop last frame if we have an uneven number of them
            indexMax = size(obj.framesLeft, 3) - mod(size(obj.framesLeft, 3), 2);
            if strcmpi(obj.firstFrameExcitation, 'red')
                indices = 1:2:indexMax;
            else
                indices = 2:2:indexMax;
            end
        end
        
        function indices = get.indicesGreenEx(obj)
        % get frame indices corresponding to green excitation
            
            % drop last frame if we have an uneven number of them
            indexMax = size(obj.framesLeft, 3) - mod(size(obj.framesLeft, 3), 2);
            if strcmpi(obj.firstFrameExcitation, 'green')
                indices = 1:2:indexMax;
            else
                indices = 2:2:indexMax;
            end
        end
        
        function streams = get.photonStreams(obj);
        % get photon streams depending on current excitation/emission settings
            
            streams = cell(4, 1);
            % order: RedExRedEm, RedExGreenEm, GreenExRedEm, GreenExGreenEm
            if strcmpi(obj.leftFrameEmission, 'red')
                streams{1} = obj.framesLeft(:, :, obj.indicesRedEx);
                streams{2} = obj.framesRight(:, :, obj.indicesRedEx);
                streams{3} = obj.framesLeft(:, :, obj.indicesGreenEx);
                streams{4} = obj.framesRight(:, :, obj.indicesGreenEx);
            else
                streams{1} = obj.framesRight(:, :, obj.indicesRedEx);
                streams{2} = obj.framesLeft(:, :, obj.indicesRedEx);
                streams{3} = obj.framesRight(:, :, obj.indicesGreenEx);
                streams{4} = obj.framesLeft(:, :, obj.indicesGreenEx);
            end
        end
        
        function truth = isEmpty(obj)
            truth = (isempty(obj.framesLeft) || isempty(obj.framesRight));
        end
        
        images = getImagesWithPeaks(obj, colormapName);
        extractTraces(obj, method);
        export(obj, filePath, selectedTraces, selectedFrames);
    end
    
    methods (Access = protected)
        loadFrames(obj);
        summarizePhotonStreams(obj);
        peakPositions = findPeaks(obj);
        exportCsv(obj, filePath, selectedTraces, selectedFrames);
    end
    
methods (Static)
    function image = markImagePosition(image, coordinates, radius, color)
    % mark an image at a specific position with a circle of the given radius
        
        if nargin < 4
            error('ALEX:NotEnoughParameters', ...
                  'markPosition needs 4 parameters')
        end
        
        x0 = coordinates(1);
        y0 = coordinates(2);
        xMax = size(image, 2);
        yMax = size(image, 1);
        
        % only draw a circle if its center is inside the given matrix
        % TODO really necessary?
        if (x0 < 1) || (x0 > xMax) || (y0 < 1) || (y0 > yMax)
            return
        end
        
        % boundaries of box that contains the circle
        xStart = round(max(1, x0 - radius));
        xFinish = round(min(x0 + radius, xMax));
        yStart = round(max(1, y0 - radius));
        yFinish = round(min(y0 + radius, yMax));
        
        % for a discretized circle, only integer values for the radius make sense
        radius = round(radius);
        
        distanceToCenter = @(x, y) round(sqrt((x - x0)^2 + (y - y0)^2));
        
        for x = xStart:xFinish
            for y = yStart:yFinish
                if distanceToCenter(x, y) == radius
                    image(y, x, :) = color;
                end
            end
        end
    end
end

end % classdef
