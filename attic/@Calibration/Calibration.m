classdef Calibration
% image calibration settings and calibration methods
%
% once the calibration is loaded it shall not be changed.
    
    % TODO set correct property access (i.e. public, protected or private)
    properties
        filePath = '';
        slitOrientation = 'horizontal';
        
        transformation = [];
        clipRectangle = []; % given by [xMin, yMin, width, height]
    end
    
    properties (Dependent)
        rotationAngle;
    end
    
    methods
        function obj = Calibration(slitOrientation, filePath)
        % constructor method for the Calibration class
            
            if nargin == 0, return, end
            if nargin >= 1
                obj.slitOrientation = slitOrientation;
            end
            if nargin >= 2
                obj.filePath = filePath;
                
                % TODO should we test for file existence?
                tmp = load(obj.filePath);
                obj.transformation = tmp.transMat;
                obj.clipRectangle = tmp.posRect;
            end
        end
        
        function obj = set.slitOrientation(obj, orientation)
        % check that only valid orientations can be set
            
            if not(strcmpi(orientation, 'horizontal') ...
                    || strcmpi(orientation, 'vertical'))
                error('ALEX:Calibration:InvalidSlitOrientation', ...
                      'the slit orientation \"%s\" is invalid', orientation)
            else
                obj.slitOrientation = lower(orientation);
            end
        end
        
        function rho = get.rotationAngle(obj)
        % return the correct rotation angle for the current slit orientation
            
            if strcmpi(obj.slitOrientation, 'horizontal')
                rho = 0;
            else
                rho = 90;
            end
        end
        
        [framesLeft, framesRight] = calibrateImages(obj, images);
    end
end
