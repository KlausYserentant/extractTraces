function matrix = drawAperture(matrix, center, innerRadius, outerRadius, value)
% draw an inverse aperture with the given parameters in a 2d matrix
%
% the aperture will be drawn inside a square with the 2 times the outerRadius
% lenght

    % default value to be used for pixel belonging to the circle
    if nargin < 5
        value = 1;
    end

    if (innerRadius >= outerRadius)
        fprintf('WARNING: trying to draw inverse aperture with innerRadius >= outerRadius\n');
        fprintf('WARNING: innerRadius %d outerRadius %d\n', [innerRadius outerRadius]);
        return
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
    xStart = round(max(1, x0 - outerRadius));
    xFinish = round(min(x0 + outerRadius, xMax));
    yStart = round(max(1, y0 - outerRadius));
    yFinish = round(min(y0 + outerRadius, yMax));
    
    distanceToCenter = @(x, y) sqrt(double(x - x0)^2 + double(y - y0)^2);
    
    for x = xStart:xFinish
        for y = yStart:yFinish
            if distanceToCenter(x, y) > outerRadius || ...
                    distanceToCenter(x, y) < innerRadius
                matrix(y, x, :) = value;
        end
    end
end