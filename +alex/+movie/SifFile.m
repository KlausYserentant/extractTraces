classdef SifFile < handle
% on demand image reader for Andor SIF multi-channel image files
%
% to use this reader class you need to do the following:
% - create an object for the sif file you want to read
%       sif = alex.movie.SifFile('path/to/file')
% - call readImage without arguments to read the image at the current file
%   position. this automatically advances the internal file position such that
%   the next call will yield the following image. a call to jumpToFirstImage
%   will move the position back to the first image
% - call readImage with an index to read an image from a specific position
%
% the implementation details are based on the sifread library written by
% Marcel Leutenegger
    
    properties
        % required information
        filePath = '';
        imageSize = [0, 0];            % size of one image [size_x, size_y]
        imageCount = 0;                % number of images
        
        % optional metadata
        % TODO all metadata should be contained in a single variable, e.g
        % a struct array or a map, to be able to have dynamic metadata.
        temperature = 0                % CCD temperature [C]
        exposureTime = 0               % Exposure time [s]
        cycleTime = 0                  % Time per full image take [s]
        accumulateCycles = 0           % Number of accumulation cycles
        accumulateCycleTime = 0        % Time per accumulated image [s]
        stackCycleTime = 0             % Interval in image series [s]
        pixelReadoutTime = 0           % Time per pixel readout [s]
        gainDAC = 0                    % no idea
        detectorType = 0               % CCD type
        detectorSize = [0, 0]          % Number of read CCD pixels [x,y]
        fileName = ''                  % Original file name
        shutterTime = [0, 0]           % Time to open/close the shutter [s]
        frameAxis = ''                 % Axis unit of CCD frame
        dataType = ''                  % Type of image data
        imageAxis = ''                 % Axis unit of image
        imageArea = [0, 0, 0; 0, 0, 0] % Image limits [x1,y1,first image;
                                       %               x2,y2,last image]
        frameArea = [0, 0; 0, 0]       % Frame limits [x1,y1;x2,y2]
        frameBins = [0, 0]             % Binned pixels [x,y]
        timeStamp = 0                  % Time stamp in image series
        comments = [];                 % comments for each image
        
        % internal variables
        fileHandle = -1;
        firstImagePosition = 0;
    end
    
    methods
        function obj = SifFile(filePath)
        % process the header but not the frames
            
            obj.filePath = filePath;
            obj.fileHandle = fopen(filePath, 'r');
            
            if obj.fileHandle < 0
                error('SifFile:Open', ...
                    'could not open file \"%s\"', obj.filePath)
            end
            if not(isequal(fgetl(obj.fileHandle), ...
                'Andor Technology Multi-Channel File'))
               fclose(obj.fileHandle);
               error('SifFile:WrongFormat', ...
                   '\"%s\" is not an andor sif image file', obj.filePath)
            end
            
            % read the first section of the sif file. any further sections
            % in the file are ignored and reading them is not supported
            obj.skipLines(1);
            obj.readSection();
        end
        
        function delete(obj)
        % close file
            
            fclose(obj.fileHandle);
        end
        
        function jumpToFirstImage(obj)
        % reset the position in the file to the position of the first image
            
            fseek(obj.fileHandle, obj.firstImagePosition, 'bof');
        end
        
        function image = readImage(obj, index)
        % read the n-th image or one at the current position from file
            
            imageLength = prod(obj.imageSize);
            
            if nargin >= 2
                if index < 1 || index > obj.imageCount
                    error('SifFile:IndexOutOfBounds', 'index is out of bounds')
                else
                    % image values are stored as 32 bit floats but ftell uses
                    % byte addresses. thus one value corresponds to 4 byte 
                    % addresses
                    position = obj.firstImagePosition + ...
                        (index - 1) * 4 * imageLength;
                    fseek(obj.fileHandle, position, 'bof');
                end
            end
            
            image = reshape(fread(obj.fileHandle, imageLength, ...
                'single=>single'), obj.imageSize);
        end
    end
    
    methods (Access=protected)
        function readSection(obj)
            % read the header of a file section
            
            o = fscanf(obj.fileHandle, '%f', 6);
            obj.temperature = o(6);
            obj.skipBytes(10);
            o = fscanf(obj.fileHandle, '%f', 5);
            obj.exposureTime = o(2);
            obj.cycleTime = o(3);
            obj.accumulateCycles = o(5);
            obj.accumulateCycleTime = o(4);
            obj.skipBytes(2);
            o = fscanf(obj.fileHandle, '%f', 2);
            obj.stackCycleTime = o(1);
            obj.pixelReadoutTime = o(2);
            o = fscanf(obj.fileHandle, '%d', 3);
            obj.gainDAC = o(3);
            obj.skipLines(1);
            obj.detectorType = obj.readLine();
            obj.detectorSize = fscanf(obj.fileHandle, '%d', [1 2]);
            obj.fileName = obj.readString();
            obj.skipLines(3);
            obj.skipBytes(14);
            obj.shutterTime = fscanf(obj.fileHandle, '%f', [1 2]);
            obj.skipLines(10);
            fscanf(obj.fileHandle, '%s', 22);
            
            obj.frameAxis = obj.readString();
            obj.dataType = obj.readString();
            obj.imageAxis = obj.readString();
            o = fscanf(obj.fileHandle, ...
                '65538 %d %d %d %d %d %d %d %d 65538 %d %d %d %d %d %d',14);
            
            if isempty(o)
                error('SifFile:OldFormat', ...
                    '\"%s\" uses an old an unsupported format', obj.filePath)
            end
            
            obj.imageArea = [o(1), o(4), o(6); o(3), o(2), o(5)];
            obj.frameArea = [o(9), o(12); o(11), o(10)];
            obj.frameBins = [o(14), o(13)];
            obj.imageSize = (diff(obj.frameArea) + 1) ./ obj.frameBins;
            obj.imageCount = diff(obj.imageArea(5:6)) + 1;
            if prod(obj.imageSize) ~= o(8) || o(8) * obj.imageCount ~= o(7)
                fclose(obj.fileHandle);
                error('SifFile:Inconsistency', 'inconsistent image header')
            end
            
            obj.skipBytes(4);
            obj.comments = cell(obj.imageCount, 1);
            for n=1:obj.imageCount
                o = obj.readLine();
                obj.comments(n) = {o};
            end
            obj.timeStamp = fscanf(obj.fileHandle, '%d', 1);
            
            obj.firstImagePosition = ftell(obj.fileHandle);
        end
        
        function s = readString(obj)
        % read a character string from the current position in the file
            
            n = fscanf(obj.fileHandle, '%d', 1);
            if isempty(n) || n < 0 || isequal(fgetl(obj.fileHandle), -1)
                fclose(obj.fileHandle);
                error('SifFile:Inconsistency', 'inconsistent string')
            end
            s = fread(obj.fileHandle, [1 n], 'uint8=>char');
        end
        
        function l = readLine(obj)
        % read a text line from the current position in the file
            
            l = fgetl(obj.fileHandle);
            if isequal(l, -1)
                fclose(obj.fileHandle);
                error('SifFile:Inconsistency', 'inconsistent image header')
            end
            l = deblank(l);
        end
        
        function skipBytes(obj, N)
        % move the internal file pointer N bytes forward
            
            [s, n] = fread(obj.fileHandle, N, 'uint8');
            if n < N
                fclose(obj.fileHandle);
                error('SifFile:Inconsistency', 'inconsistent image header')
            end
        end
        
        function skipLines(obj, N)
        % move the internal file pointer N lines forward
            
            for n=1:N
                if isequal(fgetl(obj.fileHandle), -1)
                    fclose(obj.fileHandle);
                    error('SifFile:Inconsistency', 'inconsistent image header')
                end
            end
        end
    end
end