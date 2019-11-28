function [path_combined combstack] = combinetiffs(path_)
% Combine three individual .tif image file to a single file compaitble with
% uiThreeColor GUI of ALEXforAll.

%%%%%% Adjustable parameters %%%%%%%%%%%%%
names = {'ap2','virus','titin'}; %
namesep = '_';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

seps = findstr(path_,namesep);
paths = {'','',''};

% Extract full paths to all image files & and check if image files exist.
for j=1:length(paths)
    paths{j} = strcat(path_(1:seps(end)),names{j},'.tif');
end

paths2 = paths;

for i=1:length(paths)
    if exist(paths{i},'file') ==2
    else
        sprintf('Could not locate %s image file. Locate manually',names{i})
        dialogTitle = strcat('Did not find "',names{i},'" Movie File. Select manually!');
        [paths{i}, filterIndex] = ui.dialogOpenFile({'*.tif'},dialogTitle);
    end
end

% Determine dimensions of image files & create emtpy matrix
iminf = imfinfo(paths{1});
imlg = length(imfinfo(paths{1}));
combstack = zeros(iminf(1,1).Width,iminf(1,1).Height,imlg*3);

for i=1:imlg
    combstack(:,:,i*3-2) = imread(paths{1},'index',i);
    combstack(:,:,i*3-1) = imread(paths{2},'index',i);
    combstack(:,:,i*3) = imread(paths{3},'index',i);
end

% convert doubles to 16-bit integers to facilitate export as 16-bit tif file
combstack = uint16(combstack);

% Save combined stack as .tif
[pn,fn,fe] = fileparts(path_);

fn_seps = findstr(fn,namesep);
path_combined = strcat(pn,filesep,fn(1:fn_seps(end)),'combined.tif');
t = Tiff(path_combined,'w');

tagstruct.ImageLength = size(combstack,1);
tagstruct.ImageWidth = size(combstack,2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 16;
tagstruct.SamplesPerPixel = 1;
tagstruct.RowsPerStrip = 256;
%setTag(t,'TileWidth',512)
%setTag(t,'TileLength',512)
tagstruct.Compression = Tiff.Compression.None;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software = 'MATLAB';

t.setTag(tagstruct);
write(t,combstack(:,:,1));

for j=2:imlg*3
    t.writeDirectory();
    t.setTag(tagstruct);
    write(t,combstack(:,:,j));
end
t.close
end

