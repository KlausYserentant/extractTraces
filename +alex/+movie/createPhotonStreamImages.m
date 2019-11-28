function images = createPhotonStreamImages(movie, peakPositions, colormapName)
% create rgb images with labeled peak positions for all photon stream sums
    
    % choose the optimal color for the label based on the colormap that is used
    switch colormapName
        case 'gray'
            labelColor = [1.0, 0, 0];
        case 'hot'
            labelColor = [0, 1.0, 0];
        case 'hsv'
            labelColor = [0, 0, 0];
        case 'jet'
            labelColor = [1.0, 1.0, 1.0];
        otherwise
            labelColor = [1.0, 0, 1.0];
    end
    
    images = cell(movie.numPhotonStreams, 1);
    for i = 1:size(images, 1)
        im = alex.utilities.grs2rgb(movie.photonStreamSums(:, :, i), ...
            colormap(colormapName));
        
        for j = 1:size(peakPositions, 2)
            xy = peakPositions(:, j);
            im = labelPosition(im, xy, movie.peakRadius, labelColor);
        end
        
        images{i} = im;
    end
end

function image = labelPosition(image, coordinates, radius, color)
% label a position in the image with a circle of the given radius and color
    
    x0 = coordinates(1);
    y0 = coordinates(2);
    xMax = size(image, 2);
    yMax = size(image, 1);
    
    % boundaries of the box that contains the circle
    xStart = round(max(1, x0 - radius));
    xFinish = round(min(x0 + radius, xMax));
    yStart = round(max(1, y0 - radius));
    yFinish = round(min(y0 + radius, yMax));
    
    % for a discretized circle, only integer values for the radius make sense
    radius = round(radius);
    distanceToCenter = @(x, y) round(sqrt((x - x0)^2 + (y - y0)^2));
    
    for x = xStart:xFinish
        for y = yStart:yFinish
            if distanceToCenter(x, y) == radius
                image(y, x, :) = color;
            end
        end
    end
end