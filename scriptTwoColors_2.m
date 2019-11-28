% Parameters that have to be set are
% filePath (Full calibration file path)
% calibration.slitOrientation ('vertical' or 'horizontal')
% filedir (directory containing tif-files)
% movie.peakThresholds (threshold for left/right channel, t sets threshold to 5 times standard deviation over mean)
% movie.peakRadius (numeric value)
% movie.traceAquisitionMethod ('sum' or 'max' or 'pixel')
% pathname (output file directory)


function scriptTwoColors_2()  
    % use default values from the ui
    so = 'vertical';
    dl = 'acceptor';
    % calibration for alex data w/o any transformations
    % setappdata(fig, 'calibration', alex.movie.Calibration(1, 2, so));
    calibration = alex.movie.Calibration(1, 2, so);
    % default mapping between stream indices and names
    % setappdata(fig, 'mapping', alex.movie.MappingTwoColors(dl));
    mapping = alex.movie.MappingTwoColors(dl);
    % store empty placeholder variables for movie and list of traces
    
% select a calibration file and load it
    
% define calibration file path

    filePath = 'd:\Felix Data\00_TIRF\20151112\calibration.mat';
    
    calibration.updateTransformationFromFile(filePath);
    
    calibration.slitOrientation = 'vertical';
    
 
filedir = 'd:\Felix Data\00_TIRF\20151112\titration\';

fileindex = dir(strcat(filedir,'*.tif'));


for i=1:length(fileindex)
    
% define movie-file path_ and filterIndex (sif: 1, tif: 2)
    path_ = strcat(filedir,fileindex(i).name);
    filterIndex = 2;
        
    if not(isempty(path_))
        % allow different raw data formats, e.g. sif and tif
        if filterIndex == 1
            raw = alex.movie.SifFile(path_);
        elseif filterIndex == 2
            raw = alex.movie.TifFile(path_);
        end
        
        movie = alex.movie.Movie(raw, calibration);
        
    end

    
% define threshold for lower/right channel to max, knock out
      
% use a value that is five times the standard deviation above
% the mean as a threshold estimate

    s = movie.photonStreamSums(:, :, 1);
    t = round(mean(s(:)) + 4 * std(s(:)));
    % fix the thresholds in hard lower and upper bounds
    t = min([t, 255]);
    % t = max([t, 50]);
    
% Set thresholds for two channels [left right]
% t: five times the standard deviation above the mean

    movie.peakThresholds = [255 t];

    
    movie.peakRadius = 3;
    movie.traceAquisitionMethod = 'sum';
    
    peaks = alex.movie.findPeaks(movie);
    
    traces = alex.traces.extract(movie, mapping, peaks);
        
    
% you can choose between .csv and .txt export
% not sure wether the internal structure of the file is differentt
% suggest an export file based on the movie file path
% % exportFileSuggestion = strcat(movie.filePath(1:end-4));
% filterIndex: csv 1, txt 2


% TODO output bearing original extension --> change to csv/txt

    fileName = fileindex(i).name;
    pathName = 'd:\Felix Data\00_TIRF\20151112\titration\extracted\';
    filterIndex = 1;
   
    if not(fileName == 0) % user canceled operation
        file_ = fullfile(pathName, fileName);
% allow different export data formats, e.g. csv and sif
        if filterIndex == 1
% STANDARD Csv EXPORT WITH FULL INFORMATION
% (selected) removed from arguments to force saving of all traces
    alex.exportCsvTwoColors(file_, movie, mapping, traces);
        elseif filterIndex == 2
            % STANDARD Txt EXPORT WITH FULL INFORMATION, header exported as
            % csv
    alex.exportCsvTxtTwoColors(file_, movie, mapping, traces);
        end
    end
end
end