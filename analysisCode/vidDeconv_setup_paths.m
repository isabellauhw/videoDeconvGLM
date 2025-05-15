function vidDeconv_setup_paths
% VIDDECONV_SETUP_PATHS Sets the MATLAB path for the video deconvolution analysis
%   Run this function from the working directory of the analysis (the
%   project folder). Paths will be added automatically based on the 
%   location of this file.
%   IN:     -
%   OUT:    -

% remove all other toolboxes 
restoredefaultpath; 

% add project path with all sub-paths 
pathProject = fileparts(mfilename('fullpath')); 
addpath(genpath(pathProject));
addpath(genpath('/Users/heiwinglau/Documents/MATLAB'));

end