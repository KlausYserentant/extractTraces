% test export to csv file using alex.exportCsv

clear all

% prepare a movie
c = alex.movie.Calibration()
m = alex.movie.Movie('test_data/movie01.sif', c)
% extract traces (using the automatically computed thresholds)
positions = alex.movie.findPeaks(m);
traces = alex.traces.extract(m, positions)

% w/o calculated observables
alex.exportCsv('test_data/movie01.csv', m, traces(2:end))
% w/ calculated observables and selected frames
alex.traces.calculateObservables(traces, 0, 0, 1)
alex.exportCsv('test_data/movie01.csv', m, traces(2:3), {2:6, [3:8]})