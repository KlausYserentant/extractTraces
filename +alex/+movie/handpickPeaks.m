function [peakPositions, peaksInPhotonStream] = handpickPeaks(movie, mapping, peaks, peaksPhotonStream, handles)
% handpick peaks in all photon streams and return their positions
    
    unfiltered = transpose(peaks);
    oldNumPeaks = size(unfiltered, 1);
    
    unfiltered = cat(1, unfiltered, selectPeaks(unfiltered, movie, mapping, peaks, handles));
    
    if isempty(unfiltered)
        peakPositions = [];
    elseif size(unfiltered, 1) == 1
        peakPositions = transpose(unfiltered);
    else
        % mark double entries (anything closer together than the peak radius)
        % makes sure that peaks found in multiple images are only counted once
        valid = ones(size(unfiltered));
        for i = 1:length(unfiltered)
            for j = i+1:length(unfiltered)
                if norm(unfiltered(j, :) - unfiltered(i, :)) < movie.peakRadius
                    valid(j, :) = [0 0];
                end
            end
        end
        
        % retain only the unmarked position
        % TODO check if this can be done without splitting the array
        % seems illogical that this is really needed
        valid = logical(valid);
        peakPositions = ...
            cat(2, unfiltered(valid(:, 1), 1), unfiltered(valid(:, 2), 2));
        % change dimension to 2xn
        peakPositions = transpose(peakPositions);
    end
    
    newNumPeaks = size(peakPositions, 2);
    % determine the number of added peaks and extend the list to mark entries 
    % according to which PhotonStream they can be detected in, add zeros in
    % each channel because so far identity is not clear
    
    peaksInPhotonStream = cat(1, peaksPhotonStream, zeros((newNumPeaks - oldNumPeaks), 4));
    peaksInPhotonStream = transpose(peaksInPhotonStream);
end

function unfiltered = selectPeaks(unfiltered, movie, mapping, peaks, handles)

    button = 1;
    while all(button == 1)
        [x(1), y(1), button(1)]=selectOnePeak(movie, handles);
        if any(button == 0)
            break
        end
        % make a list of unfiltered peak positions
        % temporarily also show all positions in the image
        unfiltered = cat(1, unfiltered, [x(1),y(1)]);
        peaksUnfiltered = cat(2, peaks, transpose(unfiltered));
        updatePhotonStreamsHandpicking(movie, mapping, peaksUnfiltered, handles);
    end
    
end

function [x,y, button] = selectOnePeak(movie, handles)

    [x, y, button] = ginput(1);
    x = round(x);
    y = round(y);
    
    if isempty(x)
        [x, y, button]=deal(0);
        return
    end
    
    xMinMax = get(handles.photonStreams{1}, 'xlim')-movie.peakRadius;
    xMax = xMinMax(1, 2);
    yMinMax = get(handles.photonStreams{1}, 'ylim')-movie.peakRadius;
    yMax = yMinMax(1, 2);
    if x <= movie.peakRadius || x > xMax || y <=movie.peakRadius || y > yMax
        msgbox('Out of Box with current Radius');
        return;
    end

end 

function updatePhotonStreamsHandpicking(movie, mapping, peaks, handles)
% plot the photon stream sum images
    
    cm = ui.readPopupmenu(handles.colormap);
    axs = handles.photonStreams;
    
    % plot the photon streams
    images = alex.movie.createPhotonStreamImages(movie, peaks, cm);
    
    for i = 1:length(images)
        namePhotonStream = mapping.names{i};
        
        axes(axs{i});
        hold off;
        image(images{mapping.getIndex(namePhotonStream)});
        title(namePhotonStream);
        grid on;
        hold on;
    end
end
