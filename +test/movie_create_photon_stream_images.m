% test alex.movie.createPhotonStreamImages function

clear all

% prepare a movie
c = alex.movie.Calibration('test_data/calibration.mat', 'horizontal', ...
    'green', 'green')
m = alex.movie.Movie('test_data/movie01.sif', c)
m.peakThresholds(2) = 70;

positions = alex.movie.findPeaks(m)

images1 = alex.movie.createPhotonStreamImages(m, positions, 'gray');
imshow(images1{2})

images2 = alex.movie.createPhotonStreamImages(m, positions, 'hot');
figure()
imshow(images2{2})
