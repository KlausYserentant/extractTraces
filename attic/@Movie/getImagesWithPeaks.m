function images = getImagesWithPeaks(obj, colormapName)
% return the summarized images with marked peak positions
%
% the images will be rgb images converted from the greyscale images using the
% given colormap
% w/o peaks the normal images will be returned (as rgb images)
    
    if nargin == 1
        colormapName = 'grey'; % default colormap
    end
    
    % best color for a chosen colormap to mark the peaks
    switch colormapName
        case 'gray'
            markColor = [1.0, 0, 0];
        case 'hot'
            markColor = [0, 1.0, 0];
        case 'hsv'
            markColor = [0, 0, 0];
        case 'jet'
            markColor = [1.0, 1.0, 1.0];
        otherwise
            markColor = [1.0, 0, 1.0];
    end
    
    images = cell(size(obj.images));
    
    for i = 1:size(images, 1)
        im = alex.utilities.grs2rgb(obj.images{i}, colormap(colormapName));
        
        for j = 1:size(obj.traces, 1)
            im = alex.Movie.markImagePosition(...
                im, ...
                obj.traces(j).position, ...
                obj.peakRadius, ...
                markColor);
        end
        
        images{i} = im;
    end
end
