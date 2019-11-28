% test uiThresholds user interface

clear all

% with an empty calibration
c = alex.movie.Calibration('test_data/calibration.mat', 'vertical', ...
    'green', 'green');
m = alex.movie.Movie('test_data/movie01.sif', c);

disp(c)
disp(m.peakThresholds)

uiThresholds(m)

disp(m.peakThresholds)
