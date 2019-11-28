% test alex.movie.createPhotonStreamImages function

clear all

filePathCalibration = 'Y:\Kristin\20140715\S1 VPS\S1 VPS before GAP_1.mat';
filePathMovie = 'Y:\Kristin\20140715\S1 VPS\S1 VPS 10min 1,1uM  GAP and wash other_9.tif';
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
% (1) uneven frames left
% (2) uneven frames right
% (3) even frames left
% (4) even frames right
image_red = m.photonStreamSums(:, :, 2);
image_blue = m.photonStreamSums(:, :, 1);

% overlay the two images. image_red will look red and image_green will look
% ... (i don't want to spoil the surprise)
overlay = zeros(size(image_red, 1), size(image_red, 2), 3);
overlay(:, :, 1) = image_red;
overlay(:, :, 2) = image_blue;

% display the image
figure()
imshow(overlay/255);
