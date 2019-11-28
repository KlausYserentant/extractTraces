function summarizePhotonStreams(obj)
% calculate summed images and corresponding histograms for each photon stream
%
% the images will be normalized to 8bit grayscale
    
    if obj.isEmpty(), return, end
    
    % create cell arrays automatically to avoid hardcoded sizes
    if isempty(obj.images)
        obj.images = cell(size(obj.photonStreams));
    end
    if isempty(obj.histograms)
        obj.histograms = cell(size(obj.photonStreams)); 
    end
    
    % create normalized images and caculate their intensity histograms 
    for i = 1:length(obj.photonStreams)
        im = sum(obj.photonStreams{i}, 3, 'native');
        imMin = min(im(:));
        imMax = max(im(:));
        obj.images{i} = uint8(((im - imMin) * 256)/(imMax - imMin));
        
        obj.histograms{i} = histc(obj.images{i}(:), obj.histogramsEdges);
    end
end
