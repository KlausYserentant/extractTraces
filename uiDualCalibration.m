function [calibrationFilePath, slitOrientation] = uiDualCalibration()
% open a gui to calculate a new calibration and return path to resulting file
    
    [movieFilePath, filterIndex] = ...
        ui.dialogOpenFile({'*.tif';'*.sif'}, 'Select a Movie File');
    
    % we can't proceed w/o a movie file
    if isempty(movieFilePath)
        calibrationFilePath = '';
        return
    end
    
    % determine necessary image rotation
    % depending on the file extension, the image has to be rotated
    % differently
    [pathstr, name, ext] = fileparts(movieFilePath); 
    slitOrientation = questdlg( ...
        'Orientation of the slit in the detection path?', ...
        'Determine slit orientation', ...
        'Horizontal', 'Vertical', 'Full frame','Full frame');
    switch slitOrientation
        case {'Horizontal'}
            if strcmp(ext, '.sif')
                rotationAngle = 0;
            elseif strcmp(ext, '.tif')
                rotationAngle = 90;
            end
        case {'Vertical'}
            if strcmp(ext, '.sif')
                rotationAngle = 90;
            elseif strcmp(ext, '.tif')
                rotationAngle = 0;
            end
        case {'Full frame'}
            channelNumber = questdlg('Number of separate channels to align', 'Channel number', '2 channels', '3 channels', '2 channels');
            rotationAngle = 0;
        otherwise
            error('ALEX:UI:UnknownSlitOrientation', 'unknown slit orientation')
    end
    
    % calculate the calibration (transformation and fieldofview),
    % distinguish between 2 and 3 color channel data.
    if strcmpi(slitOrientation,'Full frame') && strcmpi(channelNumber, '3 channels')
            ch23Separator = 2;
            [ch1, ch2] = loadImages(movieFilePath, filterIndex, rotationAngle, slitOrientation,ch23Separator);
            transMat12 = calculateTransformation(ch1, ch2);
            ch23Separator = 3;
            [ch1, ch3] = loadImages(movieFilePath, filterIndex, rotationAngle, slitOrientation,ch23Separator);
            transMat13 = calculateTransformation(ch1, ch3);
            
    else
        [imageLeft, imageRight] = loadImages(movieFilePath, filterIndex, rotationAngle, slitOrientation);
        transMat = calculateTransformation(imageLeft, imageRight);
        posRect = selectFieldOfView(imageLeft, imageRight, transMat);
    end
    
    % save the complete transformation
    calibrationFilePath = strcat(movieFilePath(1:end-3), 'mat');
    [fileName, pathName] = ...
        uiputfile('.mat', 'Save the Calibration File', calibrationFilePath);
    % only write file and return valid path if the user clicked 'save'
    if not(fileName == 0)
        calibrationFilePath = fullfile(pathName, fileName);
        save(calibrationFilePath, 'transMat', 'posRect');
    else
        calibrationFilePath = '';
    end
end

function [img] = imageNormalizeAdjust(img)
% normalize and adjust an image
    imgMin = min(img(:));
    imgMax = max(img(:));
    img = imadjust((img - imgMin) / (imgMax - imgMin));
end

function [imgLeft, imgRight] = loadImages(path_, filterIndex, rotationAngle, slitOrientation,varargin)
% load left and right summary image from the movie
    % load movie and create summary image
    % allow different raw data formats, e.g. sif and tif
    if filterIndex == 2
        raw = alex.movie.SifFile(path_);
    elseif filterIndex == 1
        raw = alex.movie.TifFile(path_);
    end

    % For full screen, ALEX, separate full frames from stack by reading
    % every second frame
    if strcmpi(slitOrientation, 'Full frame') && strcmpi(channelNumber, '2 channels');
        imgLeft = double(raw.readImage(1));
        imgRight = double(raw.readImage(2));
        for i = 3:2:raw.imageCount
            imgLeft = imgLeft + double(raw.readImage(i));
        end
        for i = 4:2:raw.imageCount
            imgRight = imgRight + double(raw.readImage(i));
        end
    elseif strcmpi(slitOrientation, 'Full frame') && strcmpi(channelNumber, '3 channels');
            imgLeft = double(raw.readImage(1));
        if varargin(1) == 2;
            imgRight = double(raw.readImage(2));
        elseif varargin(1) == 3;
            imgRight = double(raw.readImage(3));
        end
    end
        
    % For split screen, split along vertical/horizontal axis    
    else 
        img = double(raw.readImage(1));
        for i = 2:raw.imageCount
            img = img + double(raw.readImage(i));
        end
    
        % rotate and split
        img = imrotate(img, rotationAngle);
        imgLeft = img(:, 1:(size(img, 2) / 2));
        imgRight = img(:, ((size(img, 2) / 2) + 1):size(img, 2));
    end
    % beautify
    imgLeft = imageNormalizeAdjust(imgLeft);
    imgRight = imageNormalizeAdjust(imgRight);
end

function tform = calculateTransformation(imageLeft, imageRight)
% calculate the transformation tform
%
% imageLeft is taken as the base image and imageRight will be transformed
    
    % order of images is not yet important here; will only produce coordinates
    [pointsLeft, pointsRight] = cpselect(imageLeft, imageRight, 'Wait', true);
    % TODO: check if projective transformation is optimal; maybe polynomial
    % transform right image to fit to left image
    tform = cp2tform(pointsRight, pointsLeft, 'projective');
end

function fieldOfView = selectFieldOfView(imageLeft, imageRight, tform)
% show left and transformed right image overlayed and select the field of view
    
    fig = figure( ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'Name', 'Overlay of left and transformed right image', ...
        'NumberTitle', 'off', ...
        'NextPlot', 'add', ...
        'Resize', 'on');
    ax = axes( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.1, .1, .8, .8], ...
        'HitTest', 'off');
    
    imageRightTransformed = imtransform(imageRight, tform, ...
        'XData', [1, size(imageLeft, 2)], ...
        'YData', [1, size(imageLeft, 1)]);
    imageRightTransformed = imageNormalizeAdjust(imageRightTransformed);
    
    % plot the two images overlayed with each image assigned to one color
    % red: left image
    % green: transformed right image
    % blue: no image
    % well aligned points should appear as a single yellow point
    % bad aligned points show up as points with the two distinct colors
    overlayedImages = zeros(size(imageLeft, 1), size(imageLeft, 2), 3, ...
                            'like', imageLeft);
    overlayedImages(:, :, 1) = imageLeft;
    overlayedImages(:, :, 2) = imageRightTransformed;
    
    axes(ax);
    image(overlayedImages);
    
    fcn = makeConstrainToRectFcn('imrect', get(ax, 'XLim'), get(ax,'YLim'));
    rect = imrect(ax, [30 30 206 450], 'PositionConstraintFcn', fcn);
    fieldOfView = round(wait(rect));
    delete(rect);
    
    rectangle('Position', fieldOfView, 'LineWidth', 2, 'EdgeColor', 'white');
    
    waitfor(fig)
end