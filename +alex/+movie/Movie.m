classdef Movie < handle
    % storage class to hold all the information for a movie
    %
    % this class is designed to be a container for all the relevant movie
    % information and aims to have as little logic on its own. extra
    % functionality to operate on this data should be provided by helper
    % functions that use this object, e.g. to extract traces and calculate
    % observables
    %
    % the data in a movie is accesssed as logical frames that can compries
    % multiple consecutive images in the movie file. each logical frame is
    % automatically split into the different photon streams, i.e. all
    % possible combinations of excitations channels and detection channels.
    %
    % example:
    % ALEX data uses two excitation cycles and two detection channels.
    % each logical frame comprises two physical movie images that are split
    % into a total of four photon streams. the numbering is as follows:
    %   1: odd frames, left detection channel
    %   2: odd frames, right detection channel
    %   3: even frames, left detection channel
    %   3: even frames, right detection channel
    
    properties
        file = []; % object to access raw data, e.g. alex.movie.SifFile
        calibration = []; % must be an alex.movie.Calibration object
        
        % summary data for the photon streams
        photonStreamSums = [];
        photonStreamHistograms = [];
        photonStreamHistogramEdges = transpose(0:2:255); % do not change
        
        % variables for peak finding/trace calculation
        % these variables do not belong to the movie object, but more so to
        % peaks or traces. stored here for convenience
        peakThresholds = [255 255 255 255];
        peakRadius = 3;
        traceAquisitionMethod = 'sum';
    end
    
    properties (Dependent)
        filePath;
        frameCount;
        numPhotonStreams;
    end
    
    methods
        function obj = Movie(file, calibration, varargin)
        % load metadata and prepare summary variables
            
            if nargin == 0; return; end  
                      
            obj.file = file;
            obj.calibration = calibration;
            
            if nargin == 6
                obj.summarizePhotonStreams(varargin{1},varargin{2},varargin{3},varargin{4});
            else
                obj.summarizePhotonStreams(1, 10, 'sum', 'relative');
            end
                      
        end
        
        function truth = isempty(obj)
            truth = (obj.frameCount == 0);
        end
        
        function path_ = get.filePath(obj)
            % return the file path of the underlying image file object
            
            path_ = obj.file.filePath;
        end
        
        function n = get.frameCount(obj)
            % number of logical frames in the movie
            
            nImgs = double(obj.file.imageCount);
            nExs = double(obj.calibration.numExcitationChannels);
            n = floor(nImgs / nExs);
        end
        
        function num = get.numPhotonStreams(obj)
            % number of photon streams created by this movie
            
            numE = obj.calibration.numExcitationChannels;
            numD = obj.calibration.numDetectionChannels;
            num = numE * numD;
        end
        
        function streams = readFrame(obj, idxFrame)
            % read all calibrated photon streams for a single logical frame
            %
            % output data is indexed as [y, x, iPhotonStream]

            if idxFrame < 1 || idxFrame > obj.frameCount
                error('Movie:IndexOutOfBounds', ...
                      'frame index %d is out of bounds', idxFrame)
            end
            
            numE = obj.calibration.numExcitationChannels;
            numD = obj.calibration.numDetectionChannels;
            so = obj.calibration.slitOrientation;
            df = obj.calibration.dataFormat;
            
            % determine output size of a single detection channel
            % split of detection channels is always along x
            % take into account that .tif is rotated 90� compared to .sif
            
             [pathstr, name, ext] = fileparts(obj.file.filePath);
            
            % distinguish between split frame and full frame data
            switch df
                case 'Full frame, ALEX'
                    if (strcmpi(ext, '.sif'))
                        xSize = obj.file.imageSize(1);
                        ySize = obj.file.imageSize(2);
                    else
                        xSize = obj.file.imageSize(2);
                        ySize = obj.file.imageSize(1);
                    end
                        
                case 'Split frame'
                    if (strcmpi(so, 'vertical') && strcmpi(ext, '.sif')) || (strcmpi(so, 'horizontal') && strcmpi(ext, '.tif'))
                        xSizeRaw = obj.file.imageSize(1);
                        ySize = obj.file.imageSize(2);
                    else
                        xSizeRaw = obj.file.imageSize(2);
                        ySize = obj.file.imageSize(1);
                    end
                    
                    xSize = floor(double(xSizeRaw) / double(numD));

            end
            streams = zeros(ySize, xSize, (numE * numD));
            
            % read one physical image for each excitation cycle
            for idxE = 0:(numE - 1)
                
                % idxFrame starts at 1
                idxImage = (numE * (idxFrame - 1)) + idxE + 1;
                image = obj.file.readImage(idxImage);
                
                if (strcmpi(so, 'vertical') && strcmpi(ext, '.sif')) || (strcmpi(so, 'horizontal') && strcmpi(ext, '.tif'))
                    image = imrotate(image, 90.0);
                end
                
                % split the current image into different detection channels
                for idxD = 0:(numD - 1)
                    
                    % where is the current detection channel
                    xBegin = round((idxD * xSize) + 1);
                    xEnd = xBegin + xSize - 1;
                    % photon stream index for this detection channel
                    idxP = (idxE * numD) + idxD + 1;
                    
                    streams(:, :, idxP) = image(:, xBegin:xEnd);
                    streams(:, :, idxP) = obj.calibration.calibrateImage( ...
                        streams(:, :, idxP), (idxD + 1));
                end
            end
            
            streams = obj.calibration.clipImages(streams);
        end
        
        function summarizePhotonStreams(obj, start, length, summation, normalization)
            % create summaries using a subset of the available frames
            obj.updatePhotonStreamSums(start, min(obj.frameCount, length), summation, normalization);
            obj.updatePhotonStreamHistograms(normalization);
            obj.estimatePeakThresholds();
        end
    end
    
    methods (Access = protected)

        function updatePhotonStreamSums(obj, start, length, method, normalization)
        % calculate the normalized sum or max projection for each photon 
        % stream; the default is the sum of the first 10 frames and later
        % on you can choose between sum or max projection and the number of
        % frames that should be used
            wh = waitbar(0, sprintf('reading frame %d to %d', start, start + length - 1));
            sums = obj.readFrame(start);
            switch method
                case 'sum'% sum of frames
                    for i = (start + 1):(length - 1)
                        sums = sums + obj.readFrame(i);
                        wh = waitbar(i / length, wh);
                    end
                case 'max projection' % max projection of frames
                    for i = (start + 1):(start + length - 1)
                        sums = max(sums, obj.readFrame(i));
                        wh = waitbar(i / length, wh);
                    end
            end
            close(wh);
            
         % choose if image is normalized to 8 bit relative to min and max
         % value or absolute in dependence of original bit depth.
         % Absolute normalization is only possible for tif files.
         % If normalization parameter is missing, 'relative' is set by
         % default
         
            if nargin<5
                normalization = 'relative';
            end

            switch normalization
                case 'relative' % normalize to 8bit grayscale between min and max
                    for i = 1:size(sums, 3)
                        im = sums(:, :, i);
                        imMin = min(im(:));
                        imMax = max(im(:));
                        sums(:, :, i) = uint8(((im - imMin) * 256)/(imMax - imMin));
                    end
            
                case 'absolute' % read bit depth from file and normalize to 8bit
                    % return error message for sif-files
                    if strcmpi(obj.filePath(end-2:end),'sif')
                        error('Normalization to absolute 8bit scale not implemented');
                    else
                        info = imfinfo(obj.filePath);
                        depth = info.BitDepth;
                        sums = sums * 2^(8 - depth);
                    end
            end
            
            obj.photonStreamSums = sums;
        end
        
        function updatePhotonStreamHistograms(obj,normalization)
            nP = size(obj.photonStreamSums, 3);
            hs = zeros(length(obj.photonStreamHistogramEdges), nP);

            % calculate histograms for the normalized sum of each photon
            % and stream update photonStreamHistogramEdges if necessary
                        
            for i = 1:nP
                vals = obj.photonStreamSums(:, :, i);
                if strcmp(normalization,'absolute')
                    obj.photonStreamHistogramEdges = linspace(min(obj.photonStreamSums(:)),max(obj.photonStreamSums(:)),128); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                hs(:, i) = histc(vals(:), obj.photonStreamHistogramEdges);
            end
            
            obj.photonStreamHistograms = hs;
        end
        
        function estimatePeakThresholds(obj)
        % estimate the peak thresholds using the photon stream histograms
            
            nP = size(obj.photonStreamSums, 3);
            obj.peakThresholds = zeros(nP, 1);
            
            % use a value that is five times the standard deviation above
            % the mean as a threshold estimate
            for i = 1:nP
                s = obj.photonStreamSums(:, :, i);
                t = round(mean(s(:)) + 4 * std(s(:)));
                % fix the thresholds in hard lower and upper bounds
                t = min([t, 255]);
                % t = max([t, 50]);
                obj.peakThresholds(i) = t;
            end
        end
    end
end
