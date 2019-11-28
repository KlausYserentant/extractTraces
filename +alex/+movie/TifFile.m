classdef TifFile < handle
% on demand image reader for tif image files
%
% to use this reader class you need to do the following:
% - create an object for the tif file you want to read
%       tif = alex.movie.TifFile('path/to/file')
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
        
        % internal variables
        nextImageIndex = 1;            % index of the next image to be read
    end
    
    methods
        function obj = TifFile(filePath)
        % check header, but no image data
            
            obj.filePath = filePath;
            
            info = imfinfo(obj.filePath);
            obj.imageSize = [info(1,1).Width, info(1,1).Height];
            obj.imageCount = length(info);
            % TODO catch errors and emit custom error as in SifFile            
%             if obj.fileHandle < 0
%                 error('TiffFile:Open', ...
%                     'could not open file \"%s\"', obj.filePath)
%             end

%             if not(strcmp(info.Format, '.tif'))
%                 error('TifFile:WrongFormat', ...
%                       '\"%s\" is not an TIF image file', obj.filePath)
%             end
        end
%         
%         function delete(obj)
%         % close file
%             fclose(obj.fileHandle);
%         end
        
        function jumpToFirstImage(obj)
        % reset the position in the file to the position of the first image
            nextImageIndex = 1;
%             fseek(obj.fileHandle, obj.firstImagePosition, 'bof');
            % set file position indicator to beginning of first slice in
            % image.
            % Seems to be unused in the Alex scripts?!
        end
        
        function image = readImage(obj, index)
        % read the n-th image from the file
            
            if nargin >= 2
                if index < 1 || index > obj.imageCount
                    error('TifFile:IndexOutOfBounds', 'index is out of bounds')
                else
                    obj.nextImageIndex = index;
                end
            end
            
            image = imread(obj.filePath, obj.nextImageIndex);
            obj.nextImageIndex = obj.nextImageIndex + 1;
        end
    end
end