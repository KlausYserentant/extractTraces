function matrix = drawFilledCircle(matrix, center, radius, value)
% draw a filled circle with the given parameters in a 2d matrix

    % default value to be used for pixel belonging to the circle
    if nargin < 4
        value = 1;
    end

    x0 = center(1);
    y0 = center(2);
    xMax = size(matrix, 2);
    yMax = size(matrix, 1);

    % only draw a circle if its center is inside the given matrix
    % TODO really necessary?
    if (x0 < 1) || (x0 > xMax) || (y0 < 1) || (y0 > yMax)
        return
    end
    
    % boundaries of box that contains the circle
    xStart = round(max(1, x0 - radius));
    xFinish = round(min(x0 + radius, xMax));
    yStart = round(max(1, y0 - radius));
    yFinish = round(min(y0 + radius, yMax));
    
    distanceToCenter = @(x, y) sqrt((x - x0)^2 + (y - y0)^2);
    
    for x = xStart:xFinish
        for y = yStart:yFinish
            if distanceToCenter(x, y) <= radius
                matrix(y, x, :) = value;
        end
    end
end