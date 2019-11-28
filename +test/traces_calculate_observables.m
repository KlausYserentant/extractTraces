% test observable calculation using alex.traces.calculateObservables

clear all

% prepare a movie
c = alex.movie.Calibration('test_data/calibration.mat', 'horizontal', ...
    'green', 'green');
m = alex.movie.Movie('test_data/movie01.sif', c);

% find some peaks
m.peakThresholds(2) = 70;
positions = alex.movie.findPeaks(m);

% extract traces
traces = alex.traces.extract(m, positions);

% calculate observables
alex.traces.calculateObservables(traces, 0.01, 0.1, 0.2);

traces(2)
traces(2).stoichiometry
