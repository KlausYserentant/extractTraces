% select a movie file and create the corresponding movie object
    
inPath = [uigetdir('D:\Felix Local\Microscopy\2016-10-07_SMDA_SummerInTheCity\secondset\test',...
    'Choose a movie file folder') '\'];

fileindex = dir(strcat(inPath,'\','*.tif'));

calibration = alex.movie.Calibration(1, 1, 'Horizontal');

mapping = alex.movie.MappingOneColor();

peakRadius = 3;


startFrame = 1;
endFrame = 10;
traceAquisitionMethod = 'sum';
traceNormalizationMethod = 'absolute';

peakThreshold = 25;

outPath = uigetdir(inPath, 'Choose a export folder');

for i=1:length(fileindex)
    
%     OPEN MOVIE
    
% define movie-file path_ and filterIndex (sif: 1, tif: 2)
    inPut = strcat(inPath, fileindex(i).name);
    
    raw = alex.movie.TifFile(inPut);
    
    movie = alex.movie.Movie(raw, calibration, startFrame, endFrame,...
        traceAquisitionMethod, traceNormalizationMethod);

%     EXTRACT TRACES

    movie.peakRadius = peakRadius;
    movie.traceAquisitionMethod = traceAquisitionMethod;
    movie.peakThresholds = peakThreshold;
    
    peaks = alex.movie.findPeaks(movie);
    
    traces = alex.traces.extract(movie, mapping, peaks);

%     EXPORT TRACES

    fileName = fileindex(i).name;
    outPut = fullfile(outPath, fileName);

    alex.exportCsvOneColor(outPut, movie, mapping, traces);
        
end