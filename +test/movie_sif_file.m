% test SifFile reader by comparing it to the working sifread function

clear all

sif1 = alex.utilities.sifread('test_data/movie01.sif')
sif2 = alex.utilities.SifFile('test_data/movie01.sif')

% test that the two methods give the same metadata results
assert(isequal(sif1.temperature,         sif2.temperature))
assert(isequal(sif1.exposureTime,        sif2.exposureTime))
assert(isequal(sif1.cycleTime,           sif2.cycleTime))
assert(isequal(sif1.accumulateCycles,    sif2.accumulateCycles))
assert(isequal(sif1.accumulateCycleTime, sif2.accumulateCycleTime))
assert(isequal(sif1.stackCycleTime,      sif2.stackCycleTime))
assert(isequal(sif1.pixelReadoutTime,    sif2.pixelReadoutTime))
assert(isequal(sif1.gainDAC,             sif2.gainDAC))
assert(isequal(sif1.detectorType,        sif2.detectorType))
assert(isequal(sif1.detectorSize,        sif2.detectorSize))
assert(isequal(sif1.fileName,            sif2.fileName))
assert(isequal(sif1.shutterTime,         sif2.shutterTime))
assert(isequal(sif1.frameAxis,           sif2.frameAxis))
assert(isequal(sif1.dataType,            sif2.dataType))
assert(isequal(sif1.imageAxis,           sif2.imageAxis))
assert(isequal(sif1.imageArea,           sif2.imageArea))
assert(isequal(sif1.frameArea,           sif2.frameArea))
assert(isequal(sif1.frameBins,           sif2.frameBins))
assert(isequal(sif1.timeStamp,           sif2.timeStamp))

% test that the two methods yield the same images
sif2.jumpToFirstImage();
for i = 1:size(sif1.imageData, 3)
    assert(isequal(sif1.imageData(:, :, i), sif2.readImage()))
end
for i = 1:size(sif1.imageData, 3)
    assert(isequal(sif1.imageData(:, :, i), sif2.readImage(i)))
end

% test wether consecutive and index based access yields the same result
sif2.jumpToFirstImage();
assert(isequal(sif2.readImage(), sif2.readImage(1)))
assert(isequal(sif2.readImage(), sif2.readImage(2)))
assert(isequal(sif2.readImage(), sif2.readImage(3)))

% test that the image size metadata is correct
image = sif2.readImage(1);
assert(isequal(sif2.imageSize, size(image)))

% this should break
fprintf('this should be followed by an out-of-bounds error\n')
sif2.readImage(sif2.imageCount + 1)

delete(sif2)