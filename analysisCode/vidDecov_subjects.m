function details = vidDecov_subjects(subID)
% VIDDECOV_SUBJECTS - Returns subject-specific details for the DAP PayProb study
%   IN:  subID - string, subject ID (e.g., 'AMR035')
%   OUT: details - struct with subject details

% Store subject ID
details.subjName = subID;

% Define subject-specific number of sessions
switch subID
    case 'AMR035'
        details.nSessions = 8;
    case 'MFE008'
        details.nSessions = 5;
    case 'MFE015'
        details.nSessions = 7;
    case 'MFE018'
        details.nSessions = 9;
    case 'MFE029'
        details.nSessions = 42;
    case 'MFE030'
        details.nSessions = 29;
    case 'MFE033'
        details.nSessions = 8;
    case 'MFE035'
        details.nSessions = 6;
    case 'MFE036'
        details.nSessions = 17;
    otherwise
        error('Unknown subject ID: %s', subID);
end

%% subject directories
details.raw.behav.folder = fullfile(options.rawDir, 'behaviour', details.subjName);
details.raw.fluor.folder = fullfile(options.rawDir, 'flouroscent', details.subjName);
details.analysis.folder = fullfile(options.workDir, 'subjects', details.subjName);
if ~exist(details.analysis.folder, 'dir')
    mkdir(details.analysis.folder);
end

% Define folder structure for behavioural and fluorescent data
for iSes = 1:details.nSessions
    sessionStr = ['ses-' num2str(iSes)];
    
    % Behavioural data folder
    details.behav{iSes}.folder = fullfile(details.baseFolder, ...
        details.subjName, details.date, sessionStr, 'behav');
    if ~exist(details.behav{iSes}.folder, 'dir')
        mkdir(details.behav{iSes}.folder);
    end
    
    % Fluorescent data folder
    details.fluor{iSes}.folder = fullfile(details.baseFolder, ...
        details.subjName, details.date, sessionStr, 'fluor');
    if ~exist(details.fluor{iSes}.folder, 'dir')
        mkdir(details.fluor{iSes}.folder);
    end

    % Example: define raw file names if needed
    details.behav{iSes}.file = fullfile(details.behav{iSes}.folder, ...
        [details.subjName '_' details.date '_' sessionStr '_behav.csv']);
    
    details.fluor{iSes}.file = fullfile(details.fluor{iSes}.folder, ...
        [details.subjName '_' details.date '_' sessionStr '_fluor.mat']);
end

end