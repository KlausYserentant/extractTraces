function cmax = circularSum(matrix, center, radius)
% calculate the maximal value inside a circle with a given radius

    x0 = center(1);
    y0 = center(2);
    xMax = size(matrix, 2);
    yMax = size(matrix, 1);

    % boundaries of box that contains the circle
    xStart = round(max(1, x0 - radius));
    xFinish = round(min(x0 + radius, xMax));
    yStart = round(max(1, y0 - radius));
    yFinish = round(min(y0 + radius, yMax));

    % mask out values that are not inside the circle
    matrix = utilities.drawInverseAperture(matrix, center, 0, radius, NaN);
    cmax = squeeze(nanmax(nanmax(matrix(yStart:yFinish, xStart:xFinish, :))));
end