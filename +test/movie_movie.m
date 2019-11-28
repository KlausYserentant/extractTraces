% test alex.movie.Movie object

clear all

% with an empty calibration
c_empty = alex.movie.Calibration('')
m1 = alex.movie.Movie('test_data/movie01.sif', c_empty)

% with a normal calibration
c = alex.movie.Calibration('test_data/calibration.mat', 'vertical', ...
    'green', 'green')
m2 = alex.movie.Movie('test_data/movie01.sif', c)
m2.sif
