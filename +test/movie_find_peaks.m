% test alex.movie.findPeaks function

clear all

% prepare a movie
c = alex.movie.Calibration('test_data/calibration.mat', 'vertical', ...
    'green', 'green')
m = alex.movie.Movie('test_data/movie01.sif', c)
m.peakThresholds(2) = 70;

alex.movie.findPeaks(m)
