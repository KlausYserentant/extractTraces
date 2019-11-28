% test bleach detection using alex.traces.detectBleaching

clear all

% prepare a movie
c = alex.movie.Calibration('test_data/calibration.mat', 'horizontal', ...
    'red', 'green')
m = alex.movie.Movie('test_data/movie01.sif', c)
m.traceAquisitionMethod = 'sum'
% extract traces (using the automatically computed thresholds)
positions = alex.movie.findPeaks(m);
traces = alex.traces.extract(m, positions);

alex.traces.detectBleaching(traces)