clear all

% test alex.movie.createPhotonStreamImages function

clear all

filePathCalibration = 'Y:\Kristin\20140715\S1 VPS\S1 VPS before GAP_1.mat';
filePathMovie = 'Y:\Kristin\20140715\S1 VPS\S1 VPS before GAP_3.tif';
% 'horizontal' for sif files, 'vertical' for tif files
slitOrientation = 'vertical';

% create a calibration object for the transformation. the parameters are:
% Calibration(numExcitationChannels, numDetectionChannels, slitOrientation)
% - the number of excitation channels
% - the number of detection channels
% - the slit orientation
c = alex.movie.Calibration(1, 2, slitOrientation);
% load a transformation .mat file for the calibration. the parameters are:
% - the filePath
c.updateTransformationFromFile(filePathCalibration);



% create a movie object that holds all relevant information. the parameters are
% - (relative) path to the movie sif file
% first read in the file information
% allow different raw data formats, e.g. sif and tif
% the parameters are the filePath to the movie

[pathstr,name,ext] = fileparts(filePathMovie) 
if strcmp(ext, '.sif')
    raw = alex.movie.SifFile(filePathMovie);
elseif strcmp(ext, '.tif')
    raw = alex.movie.TifFile(filePathMovie);
end
        
% - the calibration object created above (no need to edit this)
m = alex.movie.Movie(raw, c)

% select the two images that should be overlayed. the last index indicates
% where they originate from:
% (1) odd frames left
% (2) odd frames right
% (3) even frames left
% (4) even frames right
image_ = m.photonStreamSums(:, :, 1);

% place a scale bar in the right lower corner of the image
% that is length nm long. you have to adjust the pixel resolution of the camera
% substitute image_ by image_scalebar in imshow

length = 5000;
resolution = 104;
pixel = round(length/resolution);
image_scalebar = image_;
image_scalebar(435:436, 160:160+pixel) = 255;

%display the image in green or in red using rgb. it is not possible to
%rescale the image!
%overlay = zeros(m.halfFrameSize(1), m.halfFrameSize(2), 3);
%overlay(:, :, 1) = image_; % display in red
%overlay(:, :, 2) = image_; %display in green
%figure()
%imshow(overlay / 256) 

% display the image with a chosen colormap: hot (black to red to white)
% or make a colormap greenHot (black to green to white) and use it then
% if you want the picture to display in green, uncomment (remove%) in front
% of the last 4 lines
% to rescale the image, change the min and max number in the brackets []
figure()
imshow(image_scalebar, [1 255])
colormap('hot');
% cmapHot = colormap()
% greenHot = cmapHot;
% greenHot(:, 1) = cmapHot(:, 2);
% greenHot(:, 2) = cmapHot(:, 1);
% colormap(greenHot);

% cmapHot = colormap()
% blueHot = cmapHot;
% blueHot(:, 1) = cmapHot(:, 3);
% blueHot(:, 3) = cmapHot(:, 1);
% colormap(blueHot);
