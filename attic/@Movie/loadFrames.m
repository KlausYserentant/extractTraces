function loadFrames(obj)
% load and process the frames of a sif movie
    
    [data, back, ref] = alex.utilities.sifread(obj.filePath);
    
    % the code below is unsupported and untested code to read avi files as well
    % movieInfo = aviinfo(obj.filePath);
    % movieData = aviread(obj.filePath);
    % imageData = zeros(movieInfo.Height, movieInfo.Width, movieInfo.NumFrames);
    % for i = 1:movieInfo.NumFrames
    %     imageData(:, :, i) = single( ...
    %         (movieData(i).cdata(:, :, 1) * 0.2989) + ...
    %         (movieData(i).cdata(:, :, 2) * 0.5870) + ...
    %         (movieData(i).cdata(:, :, 3) * 0.1140));
    % end
    
    [obj.framesLeft, obj.framesRight] = ...
        obj.calibration.calibrateImages(data.imageData);
end
