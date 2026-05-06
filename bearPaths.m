
% Path to this folder and the tbx/ subfolder
bearPath = fileparts(mfilename("fullpath"));
bearTbxPath = fullfile(bearPath, "tbx");

% Add the subfolders to the Matlab path
addpath(fullfile(bearTbxPath, "bear"), "-end");
addpath(fullfile(bearTbxPath, "bearing"), "-end");
addpath(fullfile(bearTbxPath, "gui"), "-end");

