function sif2avi(sifPath, aviPath)
% convert a sif file to an avi file
    
    [data, back, ref] = alex.sifread(sifPath);
    
    % normalize all the images to 8bit grayscale
    framesMin = min(data.imageData(:));
    framesMax = max(data.imageData(:));
    frames = ...
        uint8(((data.imageData - framesMin) * 256)/(framesMax - framesMin));
    
    aviobj = avifile(aviPath)
    aviobj.fps = 3;
    
    fig = figure();
    for i = 1:size(frames, 3)
        axes('Position', [0, 0, 1.0, 1.0])
        axis off;
        colormap('jet')
        image(frames(:, :, i))
        
        frame = getframe(fig);
        aviobj = addframe(aviobj, frame);
    end
    close(fig);
    
    aviobj = close(aviobj);
end