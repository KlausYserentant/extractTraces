function traces = extract(movie, mapping, peakPositions)
% extract traces for all given positions and return a list of trace objects

    peakRadius = movie.peakRadius;
    method = movie.traceAquisitionMethod;
    numFrames = movie.frameCount;
    numPositions = size(peakPositions, 2);
    
    % read first frame to extract image size and number of photon streams
    first = movie.readFrame(1);
    xSize = size(first, 2);
    ySize = size(first, 1);
    numPhotonStreams = size(first, 3);
    
    % select the correct intensity extraction method
    if strcmpi(method, 'max')
        f = @extractIntensityRawMax;
    elseif strcmpi(method, 'pixel')
        f = @extractIntensityRawPixel;
    elseif strcmpi(method, 'sum')
        f = @extractIntensityRawSum;
    else
        error('traces:InvalidAquisitionMethod', ...
              'the trace aquisition method \"%s\" is invalid', method);
    end
    
    % precalculate the indices of all the pixels in an image that belong to a
    % specific peak and its background. we look at each frame separately, so
    % this only needs to be calculated once
    [peaksIndices, backgroundsIndices] = calculateIndices( ...
        [ySize, xSize], peakPositions, peakRadius);
    
    % intensities for all frames, all photon streams and all peak positions
    raw = zeros(numFrames, numPhotonStreams, numPositions);
    backgrounds = zeros(numFrames, numPhotonStreams, numPositions);
    
    % extract intensities for each photon stream in each frame
    wh = waitbar(0, 'extracting traces ...');
    for i = 1:numFrames
        streams = movie.readFrame(i);
        for j = 1:numPhotonStreams
            [raw(i, j, :),  backgrounds(i, j, :)] = extractIntensities( ...
                streams(:, :, j), ...
                peakPositions, peaksIndices, backgroundsIndices, f);
        end
        wh = waitbar(i / numFrames, wh);
    end
    close(wh);
    
    % create an empty 1xN array of Trace* objects
    traces = alex.traces.Trace.empty(numPositions, 0);
    for p = 1:numPositions
        traces(p) = alex.traces.Trace( ...
            p, peakPositions(:, p), ...
            raw(:, :, p), backgrounds(:, :, p), mapping);
    end
end

function [raw, background] = extractIntensities(image, peakPositions, ...
    peaksIndices, backgroundsIndices, extractFunction)
% extract raw and background intensities for all positions from a single image
    
    positionCount = size(peakPositions, 2);
    
    % intensities of this frame for all positions
    raw = zeros(positionCount, 1);
    background = zeros(positionCount, 1);
    % the number of pixels used for extraction for each position
    pixelCounts = zeros(positionCount, 1);
    
    % extract the raw intensities with the given method
    for p = 1:positionCount
        [raw(p), pixelCounts(p)] = extractFunction(image, ...
            peakPositions(:, p), peaksIndices{p});
    end
    % mask out the peak areas
    for p = 1:positionCount
        image(peaksIndices{p}) = NaN;
    end
    % extract the mean background intensities
    for p = 1:positionCount
        background(p) = nanmean(image(backgroundsIndices{p}));
    end
    
    % scale background to the same number of pixels used for the raw intensity
    background = background .* pixelCounts;
end

% the following functions implement the different trace aquisition methods for
% extracting the intensity signal from an image. they all operate on a single
% image and a single peak and must have the same calling signature, i.e. they
% must take the same input variables and return the same output variables, so
% they can be used interchangeably
function [intensity, pixelCount] = extractIntensityRawMax(image, position, ...
    indices)
% extract the maximum intensity from the area defined by the indices
    
    intensity = nanmax(image(indices));
    pixelCount = 1;
end

function [intensity, pixelCount] = extractIntensityRawPixel(image, ...
    position, indices)
% extract the intensity at the given position
    
    intensity = image(position(2), position(1));
    pixelCount = 1;
end

function [intensity, pixelCount] = extractIntensityRawSum(image, position, ...
    indices)
% extract the summed intensity from the area defined by the indices
    
    intensity = nansum(image(indices));
    pixelCount = sum(isfinite(image(indices)));
end

function [peaksIndices, backgroundsIndices] = calculateIndices( ...
    imageSize, peakPositions, peakRadius)
% calculate the indices of the peak and the background area for all positions
%
% imageSize is the size of a single image (e.g. left part of a frame) as given
% by size(...)
    
    positionCount = size(peakPositions, 2);
    peaksIndices = cell(positionCount, 1);
    backgroundsIndices = cell(positionCount, 1);
    
    for positionIndex = 1:positionCount
        position = peakPositions(:, positionIndex);
        [peaksIndices{positionIndex}, backgroundsIndices{positionIndex}] = ...
            calculateIndicesSinglePeak(imageSize, position, peakRadius);
    end
end

function [peakIndices, backgroundIndices] = calculateIndicesSinglePeak( ...
    imageSize, peakPosition, peakRadius)
% calculate the linear indices of the peak and background area for one position
%
% imageSize is the size of a single image (e.g. left part of a frame) as given
% by size(...)
    
    xMax = imageSize(2);
    yMax = imageSize(1);
    
    x0 = peakPosition(1);
    y0 = peakPosition(2);
    
    % leave a security ring between peak and background
    % TODO use more flexible background radius setting
    innerBackgroundRadius = peakRadius + 2;
    outerBackgroundRadius = peakRadius + 5;
    
    % boundaries of the box containing the peak and the outer background circle
    xStart = max(x0 - outerBackgroundRadius, 1);
    xFinish = min(x0 + outerBackgroundRadius, xMax);
    yStart = max(y0 - outerBackgroundRadius, 1);
    yFinish = min(y0 + outerBackgroundRadius, yMax);
    
    % distance calculations
    peakRadiusSquared = peakRadius^2;
    innerBackgroundRadiusSquared = innerBackgroundRadius^2;
    outerBackgroundRadiusSquared = outerBackgroundRadius^2;
    distanceSquared = @(x, y) double(x - x0)^2 + double(y - y0)^2;
    
    % allocate space for the maxium number of indices (size of bounding box)
    peakXIndices = zeros((2 * peakRadius)^2, 1);
    peakYIndices = zeros((2 * peakRadius)^2, 1);
    backgroundXIndices = zeros((2 * outerBackgroundRadius)^2, 1);
    backgroundYIndices = zeros((2 * outerBackgroundRadius)^2, 1);
    n = 0; % counting the peak area indices
    m = 0; % counting the background area indices
    
    for x = xStart:xFinish
        for y = yStart:yFinish
            % subscript index (x, y) is inside the peak area
            if distanceSquared(x, y) <= peakRadiusSquared
                n = n + 1;
                peakXIndices(n) = x;
                peakYIndices(n) = y;
            % subscript index (x, y) is inside the background area
            elseif distanceSquared(x, y) > innerBackgroundRadiusSquared && ...
                    distanceSquared(x, y) <= outerBackgroundRadiusSquared
                m = m + 1;
                backgroundXIndices(m) = x;
                backgroundYIndices(m) = y;
            end
        end
    end
    
    % convert the subscript indices to linear indices
    peakIndices = sub2ind(imageSize, peakYIndices(1:n), peakXIndices(1:n));
    backgroundIndices = sub2ind(imageSize, backgroundYIndices(1:m), ...
        backgroundXIndices(1:m));
end
