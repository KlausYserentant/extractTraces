% test trace extraction using alex.traces.extract

clear all

% prepare a movie
c = alex.movie.Calibration('test_data/calibration.mat', 'horizontal', ...
    'green', 'green')
m = alex.movie.Movie('test_data/movie01.sif', c)

% find some peaks
m.peakThresholds(2) = 70;
positions = alex.movie.findPeaks(m);

% extract traces
traces = alex.traces.extract(m, positions)

traces(2)
assert(isequal(traces(2).raw(:, 3), traces(2).rawByName('RedExGreenEm')))
