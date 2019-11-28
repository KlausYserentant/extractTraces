% test export to csv file using alex.exportPhotostabilityCsv

clear all

% prepare a movie
c = alex.movie.Calibration()
m = alex.movie.Movie('test_data/movie01.sif', c)
% extract traces (using the automatically computed thresholds)
positions = alex.movie.findPeaks(m);
traces = alex.traces.extract(m, positions)

% export photostability with all frames from all traces selected
frames = cell(length(traces), 1);
frames(:) = deal({1:traces(1).intensityCount});
alex.exportPhotostabilityCsv('test_data/movie01-photostability.csv', ...
    m, traces, frames)