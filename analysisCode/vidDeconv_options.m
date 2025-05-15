function options = vidDeconv_options
%VIDDECOV_options Sets all options for the analysis of neuromodulators (DA/ ACh)
% from the instrumental task in the vidDeconv (video deconvolution) study.
%   OUT:    options         - the struct that holds all analysis options

%%%---- ENTER YOUR PATHS HERE -----------------------------------------%%%
% This is where we are now (where the code is to be found):
options.codeDir = fileparts(mfilename('fullpath'));

% This is the base root for both raw data and analysis:
options.mainDir = '/Users/heiwinglau/Documents/Research/DPhil/rotation/lak/';

% options.rawDir = fullfile(options.mainDir, 'rawData');
options.rawDir = fullfile(options.mainDir, 'rawData');
options.workDir = fullfile(options.mainDir, 'analysis');
%%%--------------------------------------------------------------------%%%
% Archived options
% options.subjectIDs = ['AMR035', 'MFE008', 'MFE015', 'MFE018', 'MFE029', 'MFE030', 'MFE033', 'MFE035', 'MFE036']; 
% options.dataReview.subjectIDs = ['AMR035', 'MFE008', 'MFE015', 'MFE018', 'MFE029', 'MFE030', 'MFE033', 'MFE035', 'MFE036'];

options.subjectIDs = 'AMR035'; 
options.dataReview.subjectIDs = 'AMR035';

%-- pca ------------------------------------------------------------%
options.pca.subjectIDs = options.dataReview.subjectIDs;
options.pca.doExclude = false;
% options.pca.excludedSubjectIDs = [17 20]; % see we need to exclude any animal here
% [~, options.pca.excludedSubjectIndices] = ismember(options.pca.excludedSubjectIDs, ...
%     options.pca.subjectIDs); 

%-- behaviour ------------------------------------------------------------%
options.behav.subjectIDs    = options.dataReview.subjectIDs;
options.behav.doExclude = false;
% options.behav.excludedSubjectIDs = [17 20]; % see we need to exclude any animal here
% [~, options.behav.excludedSubjectIndices] = ismember(options.behav.excludedSubjectIDs, ...
%     options.behav.subjectIDs); 

options.behav.flagLoadData = 1;
options.behav.flagPerformance = 1;
options.behav.flagKernels = 1;
options.behav.flagAdjustments = 1;
options.behav.flagReactionTimes = 1;
options.behav.flagMoveCost = 1;

options.behav.fsample = 60;
options.behav.preFirstLaserTime = 150/1000; % 150ms
options.behav.movAvgWin = 100;
options.behav.minResponseDistance = 20; % in samples, responses closer to that will be unified to one movement
options.behav.minStepSize = 10*pi/180; % in radians, everything below will be discarded as a small shield move
options.behav.kernelPreSamples = 5*options.behav.fsample;
options.behav.kernelPostSamples = 1*options.behav.fsample;
options.behav.kernelPreSamplesEvi = 5;
options.behav.kernelPostSamplesEvi = 4;
options.behav.flagBaselineCorrectKernels = 0;
options.behav.flagUseBinaryRegression = 0;
options.behav.flagNormaliseEvidence = 1;
options.behav.nSamplesKernelBaseline = 1.5*options.behav.fsample;
options.behav.adjustPreSamples = 1*options.behav.fsample;
options.behav.adjustPostSamples = 9*options.behav.fsample;
options.behav.flagNormaliseAdjustments = 1;

%-- fluoroscent ------------------------------------------------------------%
options.fluor.subjectIDs    = options.dataReview.subjectIDs;
options.fluor.doExclude = false;
% options.behav.excludedSubjectIDs = [17 20]; % see we need to exclude any animal here
% [~, options.fluor.excludedSubjectIndices] = ismember(options.fluor.excludedSubjectIDs, ...
%     options.fluor.subjectIDs); 

%-- Deconvolutional GLM ------------------------------------------------%
options.deconvGlm.frameRate = 20;
options.deconvGlm.sPostTime = ceil(6 * options.deconvGlm.frameRate);   % follow stim events for sPostStim in frames (used for eventType 2)
options.deconvGlm.mPreTime = ceil(0.5 * options.deconvGlm.frameRate);  % precede motor events to capture preparatory activity in frames (used for eventType 3)
options.deconvGlm.mPostTime = ceil(2 * options.deconvGlm.frameRate);   % follow motor events for mPostStim in frames (used for eventType 3)
% options.framesPerTrial = frames; % nr. of frames per trial
options.deconvGlm.folds = 10; %nr of folds for cross-validation

end