% test trace extraction using alex.traces.extract and a huge movie

clear all

% prepare a movie
c = alex.movie.Calibration('test_data/calibration.mat', 'horizontal', ...
    'green', 'green')
m = alex.movie.Movie('test_data/movie02.sif', c)

% find peaks
m.peakThresholds(2) = 70;
positions = alex.movie.findPeaks(m)

alex.traces.extract(m, positions, 'sum')