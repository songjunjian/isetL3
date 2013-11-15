%% s_L3MakeGlobalCameras
%
% This script creates global cameras for a series of L3 cameras.
% Global is a bad name but it means there are separate filters for each
% patch type (color of center pixel), luminance level, and saturation
% level.  But no separate filters for flat and texture.
%
% The global cameras inherit the sensor and optics from the L3 cameras but
% the flat and texture filters are ignored.  This is achieved by just
% changing the name of the camera to start with 'L3 Global' (vcimageCompute
% operates differently with this name).
%
% See s_L3TrainCamerasforCFAs to train L3 cameras for a variety of CFAs.
%
% (c) Stanford VISTA Team


%% File locations


% A global camera will be trained for each of the file of the form
% L3camera_XXX.mat in the following directory.  Generally XXX is the CFA
% name.
cameraFolder = fullfile(L3rootpath, 'Cameras', 'L3');

% All global cameras will be saved in the following subfolder of the
% Cameras folder.  The filename will be globalcamera_XXX.mat where XXX is
% the same as the L3 camera file.
saveFolder = fullfile(L3rootpath, 'Cameras', 'global');

%% If it doesn't exist, create the folder where files will be saved
if exist(saveFolder, 'dir')~=7
    mkdir(saveFolder)
end

%% Train Camera for each CFA 
cameraFiles = dir(fullfile(cameraFolder, '*.mat'));
for cameraFilenum = 1:length(cameraFiles)
    cameraFile = cameraFiles(cameraFilenum).name;
    disp(['Camera:  ', cameraFile, '  ', num2str(cameraFilenum),' / ', num2str(length(cameraFiles))])
    if length(cameraFile>9) & strcmp(cameraFile(1:9), 'L3camera_')
        data = load(fullfile(cameraFolder,cameraFile));
        if isfield(data, 'camera')
            camera = data.camera;
        else
            error('No camera found in file.')
        end
        
        camera = cameraSet(camera,'name',['Global L3 camera modified from ',cameraFile]);
        camera = cameraSet(camera,'vci name','L3 global');

        % Remove from camera any metrics
        camera.metrics=[];

        namesuffix = cameraFile(10:end);    %generally CFA name
        saveFile = fullfile(saveFolder, ['globalcamera_', namesuffix]);
        save(saveFile, 'camera')
    end
end