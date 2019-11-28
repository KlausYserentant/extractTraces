function [calibrationFilePath, slitOrientation] = uiFieldOfView()
% open a gui to calculate a new calibration and return path to resulting file
% here, only the field of view is changed, no transformation is applied
    
    [movieFilePath, filterIndex] = ...
        ui.dialogOpenFile({'*.tif';'*.sif'}, 'Select a Movie File');
    
    % we can't proceed w/o an movie file
    if isempty(movieFilePath)
        calibrationFilePath = '';
        return
    end
    
    % determine necessary image rotation
    % depending on the file extension, the image has to be rotated
    % differently
    [pathstr, name, ext] = fileparts(movieFilePath); 
    slitOrientation = 'Horizontal';
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
        otherwise
            error('ALEX:UI:UnknownSlitOrientation', 'unknown slit orientation')
    end
    
    % calculate the calibration (fieldofview)
    im = loadImage(movieFilePath, filterIndex, rotationAngle);
    posRect = selectFieldOfViewOneChannelDetection(im);

    % save the complete transformation
    calibrationFilePath = strcat(movieFilePath(1:end-3), 'mat');
    [fileName, pathName] = ...
        uiputfile('.mat', 'Save the Calibration File', calibrationFilePath);
    % only write file and return valid path if the user clicked 'save'
    if not(fileName == 0)
        calibrationFilePath = fullfile(pathName, fileName);
        save(calibrationFilePath, 'posRect');
    else
        calibrationFilePath = '';
    end
end

function img = loadImage(movieFilePath, filterIndex, rotationAngle)
% load left and right summary image from the movie
    
    % load movie and create summary image
    % allow different raw data formats, e.g. sif and tif
    if filterIndex == 2
        raw = alex.movie.SifFile(movieFilePath);
    elseif filterIndex == 1
        raw = alex.movie.TifFile(movieFilePath);
    end
    
    img = double(raw.readImage(1));
    for i = 2:raw.imageCount
        img = img + double(raw.readImage(i));
    end
    
    % rotate and beautify
    img = imrotate(img, rotationAngle);
    img = imageNormalizeAdjust(img);
end


function [img] = imageNormalizeAdjust(img)
% normalize and adjust an image
    imgMin = min(img(:));
    imgMax = max(img(:));
    img = imadjust((img - imgMin) / (imgMax - imgMin));
end


function fieldOfView = selectFieldOfViewOneChannelDetection(im)
% show image and select the field of view
    
    fig = figure( ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'Name', 'Raw Image', ...
        'NumberTitle', 'off', ...
        'NextPlot', 'add', ...
        'Resize', 'on');
    ax = axes( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.1, .1, .8, .8], ...
        'HitTest', 'off');
    
    axes(ax);
    img = zeros(size(im, 1), size(im, 2), 3, ...
                            'like', im);
    img(:, :, 1) = im;
    image(img);
    
    xlimits = get(ax, 'XLim');
    ylimits = get(ax, 'YLim');
    
    fcn = makeConstrainToRectFcn('imrect', xlimits, ylimits);
    rect = imrect(ax, [30 30 (xlimits(1, 2) - 60) (ylimits(1, 2) - 60)], 'PositionConstraintFcn', fcn)
    fieldOfView = round(wait(rect))
    delete(rect);
    
    rectangle('Position', fieldOfView, 'LineWidth', 2, 'EdgeColor', 'white');
    
    waitfor(fig)
end