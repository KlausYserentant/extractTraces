function [framesLeft, framesRight] = calibrateImages(obj, images)
% create a transformed, clipped and split up version of the given image stack
%
% images is expected to be 3d matrix with indices [y, x, t]
    
    % rotation
    images = imrotate(images, obj.rotationAngle);
    
    % transform the right side; left side stays fixed
    xSize = size(images, 2) / 2;
    ySize = size(images, 1);
    xIndicesLeft = 1:xSize;
    xIndicesRight = xIndicesLeft + xSize;
    if not(isempty(obj.transformation))
        images(:, xIndicesRight, :) = imtransform( ...
            images(:, xIndicesRight, :), ...
            obj.transformation, ...
            'XData', [1, xSize], ...
            'YData', [1, ySize], ...
            'FillValues', 0);
    end
    
    % clip images or use the whole if no clipping rectangle is defined
    if isempty(obj.clipRectangle)
        yIndices = 1:ySize;
    else
        xIndicesLeft = ...
            obj.clipRectangle(1):(obj.clipRectangle(1) + obj.clipRectangle(3));
        xIndicesRight = xIndicesLeft + xSize;
        yIndices = ...
            obj.clipRectangle(2):(obj.clipRectangle(2) + obj.clipRectangle(4));
    end
    
    framesLeft = images(yIndices, xIndicesLeft, :);
    framesRight = images(yIndices, xIndicesRight, :);
end
