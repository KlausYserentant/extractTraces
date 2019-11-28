% test alex.movie.Calibration object

clear all

empty = alex.movie.Calibration('')

assert(isempty(empty.filePath))
assert(isempty(empty.transformation))
assert(isempty(empty.clipRectangle))

c1 = alex.movie.Calibration('test_data/calibration.mat', 'vertical', ...
    'green', 'green')

assert(strcmp(c1.filePath, 'test_data/calibration.mat'))
assert(not(isempty(c1.transformation)))
assert(not(isempty(c1.clipRectangle)))

assert(strcmp(c1.slitOrientation, 'vertical'))
assert(c1.rotationAngle == 90)

c1.slitOrientation = 'horizontal'
assert(strcmp(c1.slitOrientation, 'horizontal'))
assert(c1.rotationAngle == 0)

assert(strcmp(c1.excitationColorUneven, 'green'))
assert(strcmp(c1.emissionColorLeft, 'green'))
assert(isequal(c1.photonStreamNames, ...
    {'GreenExGreenEm', 'GreenExRedEm', 'RedExGreenEm', 'RedExRedEm'}))
assert(c1.photonStreamIndices('GreenExGreenEm') == 1)
assert(c1.photonStreamIndices('GreenExRedEm') == 2)
assert(c1.photonStreamIndices('RedExGreenEm') == 3)
assert(c1.photonStreamIndices('RedExRedEm') == 4)
assert(isequal(c1.calculateExcitationFrameIndices('green', 10), 1:2:10))
assert(isequal(c1.calculateExcitationFrameIndices('red', 10), 2:2:10))

c1.excitationColorUneven = 'red'
assert(strcmp(c1.excitationColorUneven, 'red'))
assert(strcmp(c1.emissionColorLeft, 'green'))
assert(isequal(c1.photonStreamNames, ...
    {'RedExGreenEm', 'RedExRedEm', 'GreenExGreenEm', 'GreenExRedEm'}))
assert(c1.photonStreamIndices('GreenExGreenEm') == 3)
assert(c1.photonStreamIndices('GreenExRedEm') == 4)
assert(c1.photonStreamIndices('RedExGreenEm') == 1)
assert(c1.photonStreamIndices('RedExRedEm') == 2)
assert(isequal(c1.calculateExcitationFrameIndices('green', 10), 2:2:10))
assert(isequal(c1.calculateExcitationFrameIndices('red', 10), 1:2:10))

c1.emissionColorLeft = 'red'
assert(strcmp(c1.emissionColorLeft, 'red'))
assert(strcmp(c1.excitationColorUneven, 'red'))
assert(isequal(c1.photonStreamNames, ...
    {'RedExRedEm', 'RedExGreenEm', 'GreenExRedEm', 'GreenExGreenEm'}))
assert(c1.photonStreamIndices('GreenExGreenEm') == 4)
assert(c1.photonStreamIndices('GreenExRedEm') == 3)
assert(c1.photonStreamIndices('RedExGreenEm') == 2)
assert(c1.photonStreamIndices('RedExRedEm') == 1)
