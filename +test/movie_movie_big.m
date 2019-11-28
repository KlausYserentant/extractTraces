% test alex.movie.Movie object with a big movie file

clear all

c = alex.movie.Calibration('test_data/calibration.mat', 'vertical', ...
    'green', 'green')
m = alex.movie.Movie('test_data/movie02.sif', c)
