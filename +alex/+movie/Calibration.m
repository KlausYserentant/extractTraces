classdef Calibration < handle
    % settings and helper methods to calibrate movie images
    %
    % contains all required settings to go from raw images in a movie file
    % to calibrated photon streams.
    
    properties
        numExcitationChannels = 1; % how many raw images in one logical frame
        numDetectionChannels = 1;  % split each image into n parts
        slitOrientation = 'horizontal'; % must be either horizontal or vertical
        dataFormat = 'Split frame'; % must be either 'Split frame' or 'Full frame, ALEX'.
        
        % list of transformations. one for each detection channel
        transformations = [];
        % one clipping rectangle for all detection channels
        % must be [xMin, yMin, width, height]
        clipRectangle = [];
        
        % internal settings
        filePath = '';
    end
    
    methods
        function obj = Calibration(numExcitationChannels, ...
                                   numDetectionChannels, slitOrientation, varargin)
            
            obj.numExcitationChannels = numExcitationChannels;
            obj.numDetectionChannels = numDetectionChannels;
            obj.slitOrientation = slitOrientation;
            if not(isempty(varargin));
                obj.dataFormat = varargin{1};
            end
            obj.transformations = cell(numDetectionChannels, 1);
        end
        
        function set.slitOrientation(obj, value)
            if ~strcmpi(value, {'horizontal', 'vertical', 'Full frame'})
                error('Calibration:InvalidSlitOrientation', ...
                      '\"%s\" is invalid. must be \"horizontal\", \"vertical\", or \"Full frame\"', value)
            end
            obj.slitOrientation = value;
        end
        
        function updateTransformationFromFile(obj, filePath)
            % read transformation data from a file
            
            if ~exist(filePath, 'file')
                error('Calibration:MissingCalibrationFile', ...
                      '\"%s\" does not exists', filePath)
            end
            
            tmp = load(filePath);
            
            % check the type of calibration file.
            
            % two detection channels, e.g. for ALEX
            if all(isfield(tmp, {'transMat', 'posRect'})) || (obj.numDetectionChannels == 2)
                obj.transformations{1} = [];
                obj.transformations{2} = tmp.transMat;
                obj.clipRectangle = tmp.posRect;
                obj.filePath = filePath;
                
            % single detection channel. ignore transformation
            elseif isfield(tmp, 'posRect') || (obj.numDetectionChannels == 1)
                obj.transformations{1} = [];
                obj.clipRectangle = tmp.posRect;
                obj.filePath = filePath;
            
            % three detection channels
            elseif all(isfield(tmp, {'transMat12', 'transMat13', 'posRect'})) || (obj.numDetectionChannels == 3)
                obj.transformations{1} = [];
                obj.transformations{2} = tmp.transMat12;
                obj.transformations{3} = tmp.transMat13;
                obj.clipRectangle = tmp.posRect;
                obj.filePath = filePath;
                
            else
                error('Calibration:InvalidCalibrationFile', ...
                      '\"%s\" does not match the number of detection channels %d', ...
                      filePath, obj.numDetectionChannels)
            end
        end
        
        function calibrated = calibrateImage(obj, image, idxDetectionChannel)
            % calibrate the image
            %
            % use the transformation of the specified detection channel
            % to calibrate the input image
            
            xSize = size(image, 2);
            ySize = size(image, 1);
            
            % transform if required
            tf = obj.transformations{idxDetectionChannel};
            if ~isempty(tf)
                calibrated = imtransform(image, tf, ...
                                         'XData', [1, xSize], ...
                                         'YData', [1, ySize], ...
                                         'FillValues', 0);
            else
                calibrated = image;
            end
        end
        
        function clipped = clipImages(obj, images)
            % clip the images for all photon streams
            %
            % images are indexed [y, x, iPhotonStream]
            
            if isempty(obj.clipRectangle)
                clipped = images;
            else
                xMin = obj.clipRectangle(1);
                yMin = obj.clipRectangle(2);
                xSize = obj.clipRectangle(3);
                ySize = obj.clipRectangle(4);
                clipped = images(yMin:(yMin + ySize - 1), ...
                                 xMin:(xMin + xSize - 1), :);
            end
        end
    end
end