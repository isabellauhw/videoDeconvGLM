classdef linearEncodeModel
    properties
        % Define all the properties that is specific to the linear encode
        % model
  
        % Session identifiers
        mouseName % name of the animal (e.g., AMK035)
        expRef % experimental session reference of the animal (e.g., 2023_06_14)
        
        % I/O paths
        vidDataRoot = '/Volumes/Data/'; % Please change it accordingly
        bhvDataRoot = '/Users/heiwinglau/Documents/Research/DPhil/rotation/lak/deconvolGlm/videoDeconvGLM/data/behav'; % Please change it accordingly
        fluorDataRoot = '/Users/heiwinglau/Documents/Research/DPhil/rotation/lak/deconvolGlm/videoDeconvGLM/data/fluor'; % Please change it accordingly
        sessionPath
        
        % Behaviour
        bhv % behavioural data table
        bhvTrialCnt % the trial count of the behavioural task (height of the data shift - one row per trial)

        % Fluorescence
        fluor % fluoroscent data table
        
        % Behavioural variables (imported from the bahavioural data table)
        stimulusOnsetTimes % stimulus onset time
        stimulusContrast % stimulus contrast
        choiceStartTimes % choice start time 
        rewardOnsetTimes % reward/ feedback onset time
        rewardFeedback % the outcome of the reward (rewarded or unrewarded)

        % Common time axis
        sRate = 20;  % 20Hz for all data
        preTime = 0.5; % time before the onset of an event that is included in the time kernel
        postTime = 3; % (I put it as 3 for now) time after the onset of an event that is included in the time kernel
        globalTime % global time axis in seconds (array of time indices)
        globalStartTime % global time axis start time
        globalEndTime % global time axis end time

        % Behavioural regressors
        stim % (Binary): 1 for stimulus presentation, otherwise 0
        stimContrastR0 % (Binary): 1 for presentation of stimulus at 0 (0) contrast on the right (R), otherwise 0
        stimContrastR00625 % (Binary): 1 for presentation of stimulus at 0.0625 (00625) contrast on the right (R), otherwise 0
        stimContrastR0125 % (Binary): 1 for presentation of stimulus at 0.125 (0125) contrast on the right (R), otherwise 0
        stimContrastR025 % (Binary): 1 for presentation of stimulus at 0.25 (025) contrast on the right (R), otherwise 0
        stimContrastR05 % (Binary): 1 for presentation of stimulus at 0.5 (05) contrast on the right (R), otherwise 0
        stimContrastR1 % (Binary): 1 for presentation of stimulus at 1 (1) contrast on the right (R), otherwise 0
        stimContrastL0 % (Binary): 1 for presentation of stimulus at 0 (0) contrast on the right (R), otherwise 0
        stimContrastL00625 % (Binary): 1 for presentation of stimulus at 0.0625 (00625) contrast on the left (L), otherwise 0
        stimContrastL0125 % (Binary): 1 for presentation of stimulus at 0.125 (0125) contrast on the left (L), otherwise 0
        stimContrastL025 % (Binary): 1 for presentation of stimulus at 0.25 (025) contrast on the left (L), otherwise 0
        stimContrastL05 % (Binary): 1 for presentation of stimulus at 0.5 (05) contrast on the left (L), otherwise 0
        stimContrastL1 % (Binary): 1 for presentation of stimulus at 1 (1) contrast on the left (L), otherwise 0
        choiceL % (Binary): 1 for the animal's choice in turning the wheel left (L), otherwise 0
        choiceR % (Binary): 1 for the animal's choice in turning the wheel right (R), otherwise 0
        rewardR0 % (Binary): 1 for onset of the reward at 0 (0) contrast on the right (R), otherwise 0
        rewardR00625 % (Binary): 1 for onset of the reward at 0.0625 (00625) contrast on the right (R), otherwise 0
        rewardR0125 % (Binary): 1 for onset of the reward at 0.125 (0125) contrast on the right (R), otherwise 0
        rewardR025 % (Binary): 1 for onset of the reward at 0.25 (025) contrast on the right (R), otherwise 0
        rewardR05 % (Binary): 1 for onset of the reward at 0.5 (05) contrast on the right (R), otherwise 0
        rewardR1 % (Binary): 1 for onset of the reward at 1 (1) contrast on the right (R), otherwise 0
        rewardL0 % (Binary): 1 for onset of the reward at 0 (0) contrast on the left (L), otherwise 0
        rewardL00625 % (Binary): 1 for onset of the reward at 0.0625 (00625) contrast on the left (L), otherwise 0
        rewardL0125 % (Binary): 1 for onset of the reward at 0.125 (0125) contrast on the left (L), otherwise 0
        rewardL025 % (Binary): 1 for onset of the reward at 0.25 (025) contrast on the left (L), otherwise 0
        rewardL05 % (Binary): 1 for onset of the reward at 0.5 (05) contrast on the left (L), otherwise 0
        rewardL1 % (Binary): 1 for onset of the reward at 1 (1) contrast on the left (L), otherwise 0
        
        % Fluorescence outcome
        fluorDALeft % Contains all data in the time series
        fluorACHRight % Contains all data in the time series
        fluorDALeftTaskKernel % Contains data only within the define time kernel (e.g., -0.5-2s)
        fluorACHRightTaskKernel % Contains data only within the define time kernel (e.g., -0.5-2s)
        
        % Motion PCs
        motionPC % a matrix (frames x number of PCs) in *double* format that contains the principle 
        % components (PCs) of the motion energy extracted from facemap
       
    end
    
    methods
        function obj = linearEncodeModel(mouseName, expRef, motionData)
        % CONSTRUCTOR CLASS: a function that helps to initalise an instance
        % of a new object (for here, this is the the respective mouse name [mouseName],
        % experimental session reference [expRef], and the motion data + experimental 
        % time in global time scale [motionData]. This function first
        % define file and data paths, load behavioural and fluoroscent
        % data for the session, define global time axis (according to the task data), 
        % interpolate fluoroscent data and video PCs data with the respective time 
        % frames in the global time axis 

        % INPUT:
        % - *mouseName*: the name of the animal in *string* format (e.g., 'AMK035')
        % - *expRef*: the experiment session reference in *string* format (e.g., '2023-06-13_1')
        % - *motionData*: the data table that contains two variables in *table*
        % format: 1) the motion PCs that was extracted from facemap, and 2)
        % the callibrated event times in aligned global timeline (e.g., in sync 
        % with the fluoroscent and behavioural data)that was extracted (e.g., motionData)
        

        % OUTPUT:
        % - *obj* (could be of any name your have defined in your procedural
        % script): a class instance that contains 1) data table, or 2) empty regressor container
        % for all the necessary information for calling subsequent functions in *object* 
        % format (e.g., mouse name, data roots, behavioural and fluoroscent data tables)

            % Constructor
            obj.mouseName = mouseName;
            obj.expRef = expRef;

            % Video data path (on the server address mounted on my MacOS)
            obj.sessionPath = fullfile(obj.vidDataRoot, mouseName, expRef(1:10), expRef(12));
            
            % Load behavioral table (locally)
            bhvFile = fullfile(obj.bhvDataRoot, [obj.mouseName '_behav_probability_sessions.csv']);
            bhvOpts = detectImportOptions(bhvFile, 'Delimiter', ',', 'ReadVariableNames', true);
            bhvTable = readtable(bhvFile, bhvOpts);

            % Load fluorescence table (locally)
            fluorFile = fullfile(obj.fluorDataRoot, [obj.mouseName '_fluor_timeseries_probability_sessions.csv']);
            fluorOpts = detectImportOptions(fluorFile, 'Delimiter', ',', ...
                'ReadVariableNames', true);         
            fluorTable = readtable(fluorFile, fluorOpts);

            % Filter behavioural and fluoroscent tables for the session
            obj.bhv = bhvTable(strcmp(bhvTable.expRef, strcat(expRef(1:12), '_', mouseName)), :);
            obj.bhvTrialCnt = height(obj.bhv);
            obj.fluor = fluorTable(strcmp(fluorTable.expRef, strcat(expRef(1:12), '_', mouseName)), :);

            % Event timings (import from behavioural data table to the obj)
            obj.stimulusOnsetTimes = obj.bhv.stimulusOnsetTime;
            obj.stimulusContrast = obj.bhv.contrast;
            obj.choiceStartTimes   = obj.bhv.choiceStartTime;
            obj.rewardOnsetTimes   = obj.bhv.outcomeTime;
            obj.rewardFeedback = obj.bhv.feedback;
            
            % Note: All behavioural, video, and fluorscent data are aligned
            % to a common global time axis already in the data tables

            % Global time axis - just to 'paste' the data from different
            % source to the global axis for common alignment
            obj.globalStartTime = min(obj.stimulusOnsetTimes) - 5; % Add a 5s pre-trial buffer frame to the global timeline (fluor data earliest at -0.0094515)
            obj.globalEndTime   = max(obj.rewardOnsetTimes) + 5; % Add a 5s post-trial buffer frame to the global timeline (fluor data earliest at 2279.3, but it is more reasonable to define the timeframe to the last stimulus event)
            obj.globalTime = obj.globalStartTime : 1/obj.sRate : obj.globalEndTime;

            % Interpolate fluorescence to global time
            fluorTime = obj.fluor.Timestamp;
            obj.fluorDALeft = interp1(fluorTime, obj.fluor.LeftDLS_DA, obj.globalTime, 'linear', 'extrap');
            obj.fluorACHRight = interp1(fluorTime, obj.fluor.RightDLS_ACH, obj.globalTime, 'linear', 'extrap');
            
            % Load motion PCs (already resampled to 20Hz in allData)
            if nargin > 2 && ~isempty(motionData)
                motionPCs = motionData.MotionPC;  % Should be [N x 10]
                motionTimes = motionData.eventTimes;  % Should be [N x 1], in seconds
                nT = numel(obj.globalTime);  % Length of global time vector
            
                if size(motionPCs, 1) ~= nT
                    % Interpolate each PC dimension to match globalTime
                    nPC = size(motionPCs, 2);
                    interpolatedPCs = zeros(nT, nPC);
                    for i = 1:nPC
                        interpolatedPCs(:, i) = interp1(motionTimes, motionPCs(:, i), ...
                            obj.globalTime, 'linear', 'extrap');
                    end
                    obj.motionPC = interpolatedPCs;
                else
                    obj.motionPC = motionPCs;
                end
            end
        end

        function obj = buildBehaviorRegressors(obj)
            % *buildBehaviorRegressors*: a function that help to load the
            % behavioural regressors and compile them into a *non-time shifted 
            % design matrix.

            % INPUT: 
            % - *obj* (can be kept empty): the object instance from the linearEncodeModel class that was
            % created previously, in MATLAB this is just a syntax
            % to call the function as it belongs to the method of the class
            % linearEncodeModel()

            % OUTPUT: 
            % - *obj* (can be other names that you have defined previously):
            % the object instance from the linearEncodeModel class that has
            % seperate subfields that contains the defined behavioural regressors 
            % of the non-time shifted design matrix

                % Note: this function now categorise the following behavioural
                % regressors (for more details, please see 'Properties' above to 
                % refer to the definition of each regressor): 
           
                % stim, stimContrastR00625, stimContrastR0125,
                % stimContrastR025, stimContrastR05, stimContrastR1,
                % stimContrastL00625, stimContrastL0125, stimContrastL025, stimContrastL05, 
                % stimContrastL1, choiceL, choiceR, rewardR00625, rewardR0125,
                % rewardR025, rewardR05, rewardR1, rewardL00625, rewardL0125,
                % rewardL025, rewardL05, rewardL1
           
            % Initialise
            nT = numel(obj.globalTime);
            obj.stim = zeros(nT,1);
            obj.choiceL = zeros(nT,1);
            obj.choiceR = zeros(nT,1);
        
            % Define contrast and side keys
            contrastLevels = {'0', '00625', '0125', '025', '05', '1'};
            sides = {'R', 'L'};
            contrastMap = containers.Map({'0','0.0625','0.125','0.25','0.5','1'}, ...
                                         {'0','00625','0125','025','05','1'});
        
            % Initialise all stimContrast* and reward* regressors
            for s = 1:numel(sides)
                for c = 1:numel(contrastLevels)
                    obj.(['stimContrast' sides{s} contrastLevels{c}]) = zeros(nT,1);
                    obj.(['reward' sides{s} contrastLevels{c}]) = zeros(nT,1);
                end
            end
        
            % Iterate over trials
            for t = 1:obj.bhvTrialCnt
                % Stimulus window
                stimIdx = obj.globalTime >= obj.stimulusOnsetTimes(t) - obj.preTime & ...
                          obj.globalTime < obj.stimulusOnsetTimes(t) + obj.postTime;
                obj.stim(stimIdx) = 1;
        
                % Determine contrast key based on current contrast level
                contrastVal = obj.bhv.contrast(t);
                contrastStr = sprintf('%g', contrastVal);
                if ~isKey(contrastMap, contrastStr)
                    continue; % skip unknown contrast
                end
                contrastKey = contrastMap(contrastStr);
        
                % Choice window
                choiceIdx = obj.globalTime >= obj.choiceStartTimes(t) - obj.preTime & ...
                            obj.globalTime < obj.choiceStartTimes(t) + obj.postTime; % Only within the choice time frame
                choice = obj.bhv.choice(t);
                if strcmp(choice, 'Left')
                    obj.choiceL(choiceIdx) = 1;
                elseif strcmp(choice, 'Right')
                    obj.choiceR(choiceIdx) = 1;
                end
        
                % Infer stimulus side from choice and rewardFeedback
                if strcmp(obj.rewardFeedback(t), 'Rewarded')
                    stimSide = upper(obj.bhv.choice{t}(1));  % stimulus was on side of choice - get the upper case of the first letter of choice (e.g., 'L' or 'R')
                elseif strcmp(obj.rewardFeedback(t), 'Unrewarded')
                    if strcmp(choice, 'Right')
                        stimSide = 'L';
                    elseif strcmp(choice, 'Left')
                        stimSide = 'R';
                    else
                        stimSide = '';
                    end
                else
                    stimSide = '';
                end
        
                % Assign stimContrast regressor
                if ~isempty(stimSide)
                    stimField = ['stimContrast' stimSide contrastKey];
                    if isprop(obj, stimField)
                        obj.(stimField)(stimIdx) = 1;
                    end
        
                    % Reward window
                    if strcmp(obj.bhv.feedback(t), "Rewarded") % If there was a reward, assign the corresponding regresso as 1
                        rewardIdx = obj.globalTime >= obj.rewardOnsetTimes(t) - obj.preTime & ...
                                    obj.globalTime < obj.rewardOnsetTimes(t) + obj.postTime; % Only within the reward time frame
                        rewardField = ['reward' stimSide contrastKey];
                        if isprop(obj, rewardField)
                            obj.(rewardField)(rewardIdx) = 1;
                        end
                    % If there is no reward, keep it as zero (the vector is initalised as 0 already)
                    end
                end
            end
        end

        function fullR = getDesignMatrix(obj)
            % *getDesignMatrix*: a function that combines the behavioural and
            % video PCs regressors together into a non-time shifted design
            % matrix

            % INPUT:
            % - *obj*: (can be kept empty) the *object instance* of the class linearEncodeModel
            % that was previously created, in MATLAB this is just a syntax
            % to call the function as it belongs to the method of the class
            % linearEncodeModel()

            % OUTPUT: 
            % - *fullR*: a *table* that contains the non-time shifted
            % behavioural and video PCs regressors. 

            if isempty(obj.motionPC)
                error('Motion PCs must be loaded before building design matrix.');
            end
        
            % Assemble regressors
            contrastLevels = {'0', '00625', '0125', '025', '05', '1'};
            sides = ["R", "L"];
            
            stimVars = {};
            rewardVars = {};
        
            for s = ["R", "L"]
                for c = contrastLevels
                    stimVars{end+1} = strcat('stimContrast', s, c);
                    rewardVars{end+1} = strcat('reward', s, c);
                end
            end
        
            % Concatenate stimulus and reward regressors
            stimRegressors = zeros(numel(obj.globalTime), numel(stimVars));
            rewardRegressors = zeros(numel(obj.globalTime), numel(rewardVars));
            for i = 1:numel(stimVars)
                stimRegressors(:, i) = obj.(stimVars{i});
            end
            for i = 1:numel(rewardVars)
                rewardRegressors(:, i) = obj.(rewardVars{i});
            end
        
            % Convert matrix columns into separate cell arrays
            stimCells = num2cell(stimRegressors, 1);
            rewardCells = num2cell(rewardRegressors, 1);
            motionPCNames = "motionPC" + string(1:10);
            motionCells = num2cell(obj.motionPC(:, 1:10), 1);
        
            % Construct final table
            fullR = table(...
                obj.stim, ...
                stimCells{:}, ...
                obj.choiceL, ...
                obj.choiceR, ...
                rewardCells{:}, ...
                motionCells{:}, ...
                'VariableNames', ['stim', stimVars, 'choiceL', 'choiceR', rewardVars, motionPCNames]);
        end

        function [taskMat, taskIdx] = createTaskDesignMatrix(obj, fullR, taskLabels)
            % *createTaskDesignMatrix*: an embedded function that constructs 
            % a *time-shifted* design matrix for task parameters
            
            % INPUT:
            % - *obj*: (can be kept empty) the *object instance* of the class linearEncodeModel
            % that was previously created, in MATLAB this is just a syntax
            % to call the function as it belongs to the method of the class
            % linearEncodeModel()
            % - *fullR*: table of non-time shifted behavioral & movement regressors
            % - *taskLabels*: cell array of movement parameter names (e.g. {'wheelVel', 'lickRate'})
            
            % OUTPUT:
            % - *taskMat*: [frames x total_lags] time-shifted design matrix for task regressors
            % - *taskIdx*: [total_lags x 1] movement regressor index tracker
            
            % Setup
            kernel = obj.postTime - (-obj.preTime);  % Total time window in seconds
            frames = obj.sRate;
            framePerTrial = kernel * frames;
            nTrials = obj.bhvTrialCnt;
            selectedRows = fullR.stim == 1;
            
            % Helper function for design matrix creation
            function [matOut, idxOut] = buildTimeShiftedMatrix(labelList)
                nLabels = numel(labelList);
                matOut = {};
                idxOut = {};
                rawMat = zeros(sum(selectedRows), nLabels);
                
                % Extract label-specific time series
                for i = 1:nLabels
                    if ismember(labelList{i}, fullR.Properties.VariableNames)
                        rawMat(:, i) = fullR.(labelList{i})(selectedRows);
                    else
                        error('Label "%s" not found in fullR.', labelList{i});
                    end
                end
                
                if mod(size(rawMat, 1), nTrials * framePerTrial) ~= 0
                    error('Mismatch between frame count and trial count.');
                end
                
                rawMat = reshape(rawMat, framePerTrial, nTrials, nLabels);
                
                for iRegs = 1:nLabels
                    trace = reshape(rawMat(:, :, iRegs), [], 1);
                    nFrames = size(trace, 1);
                    regMat = zeros(nFrames, framePerTrial);
                    
                    for lag = 1:framePerTrial
                        shift = lag - 1;
                        if shift == 0
                            regMat(:, lag) = trace;
                        else
                            regMat(shift+1:end, lag) = trace(1:end-shift);
                        end
                    end
                    
                    validCols = any(regMat, 1);
                    matOut{iRegs} = regMat(:, validCols);
                    idxOut{iRegs} = repmat(iRegs, sum(validCols), 1);
                end
                
                matOut = cat(2, matOut{:});
                idxOut = cat(1, idxOut{:});
            end
        
            % Generate Design Matrix for Movement Labels
            [taskMat, taskIdx] = buildTimeShiftedMatrix(taskLabels);
        end

       function [vidMat, vidIdx] = createVideoDesignMatrix(obj, fullR, vidLabels)
            % *createVideoDesignMatrix*: generates a design matrix for video regressors
            % without applying time-lagging. Assumes video regressors are used as-is.
            
            % INPUT:
            % - obj: linearEncodeModel instance (not used here, but kept for consistency)
            % - fullR: a table containing all regressors
            % - vidLabels: cell array of strings with video PC regressor names
            
            % OUTPUT:
            % - vidMat: matrix [frames x number of video regressors]
            % - vidIdx: [number of video regressors x 1], each element is the regressor index
        
            nLabels = numel(vidLabels);
            selectedRows = fullR.stim == 1;  % Logical index for task trials only
            nFrames = sum(selectedRows);
        
            vidMat = zeros(nFrames, nLabels);
            vidIdx = (1:nLabels)';
        
            for i = 1:nLabels
                if ismember(vidLabels{i}, fullR.Properties.VariableNames)
                    vidMat(:, i) = fullR.(vidLabels{i})(selectedRows);
                else
                    error('Video label "%s" not found in fullR.', vidLabels{i});
                end
            end
       end

       function [fullR_ortho, regLabels] = checkAndOrthogonalise(obj, fullR_out, stimLabels, moveLabels, vidLabels, regLabels)
           % *checkAndOrthogonalise*: Check for rank deficiency and high correlation
           % between regressor groups (stim, move, video) after expansion.
           % Orthogonalise movement w.r.t stimulus, and video w.r.t stim + move
           % if necessary.

           % INPUTS:
           % - fullR_out: time-lagged, expanded design matrix [frames x regressors]
           % - stimLabels, moveLabels, vidLabels: cell arrays of label names
           % - regLabels: combined list of labels (same order as fullR_out columns)

           % OUTPUTS:
           % - fullR_ortho: orthogonalised version of fullR_out
           % - regLabels: unchanged, passed through

           % Group masks
           sInd = ismember(regLabels, stimLabels);
           mInd = ismember(regLabels, moveLabels);
           vInd = ismember(regLabels, vidLabels);

           % Slice expanded design matrix into groups
           stimBlock = fullR_out(:, sInd);
           moveBlock = fullR_out(:, mInd);
           vidBlock  = fullR_out(:, vInd);

           % Rank deficiency check after expansion
           smallR = [stimBlock, moveBlock, vidBlock];
           [~, R, E] = qr(smallR, 0);  % economy QR
           tol = max(size(smallR)) * eps(norm(R, 'fro'));
           r = sum(abs(diag(R)) > tol);
           rankDeficient = r < size(smallR, 2);

           % Step 2: Correlation check between group blocks after expansion
           % Compute mean absolute pairwise correlation between groups
           corrThresh = 0.95;
           crossCorrFlag = false;

           if ~isempty(stimBlock) && ~isempty(moveBlock)
               RstimMove = corr(stimBlock, moveBlock);
               if any(abs(RstimMove(:)) > corrThresh)
                   crossCorrFlag = true;
                   fprintf('High correlation detected between STIM and MOVE blocks.\n');
               end
           end

           if ~isempty([stimBlock, moveBlock]) && ~isempty(vidBlock)
               RprevVid = corr([stimBlock, moveBlock], vidBlock);
               if any(abs(RprevVid(:)) > corrThresh)
                   crossCorrFlag = true;
                   fprintf('High correlation detected between STIM+MOVE and VIDEO blocks.\n');
               end
           end

           % Orthogonalise if needed
           if rankDeficient || crossCorrFlag
               if rankDeficient
                   warning('Design matrix is rank deficient by %d column(s).', size(smallR,2) - r);
                   allLabels = [stimLabels, moveLabels, vidLabels];
                   depCols = sort(E(r+1:end));
                   fprintf('Linearly dependent regressors:\n');
                   disp(allLabels(depCols)');
               end

               % Separate regressor blocks
               stimBlock = fullR_out(:, sInd);  % Stimulus regressors
               moveBlock = fullR_out(:, mInd);  % Movement regressors
               vidBlock  = fullR_out(:, vInd);  % Video PC regressors

               % Step: Orthogonalise video w.r.t. stimulus + movement
               fprintf('Orthogonalising videoPCs w.r.t. stimulus + movement regressors...\n');
               [QstimMove, ~] = qr([stimBlock, moveBlock], 0);  % QR of combined stim + move
               vidOrth = vidBlock - QstimMove * (QstimMove' * vidBlock);  % Projection removal

               % Update matrix
               fullR_ortho = fullR_out;
               fullR_ortho(:, vInd) = vidOrth;

               % Final QR for consistency on video block
               [Q, ~] = qr(fullR_ortho(:, [sInd, mInd, vInd]), 0);
               nStim = sum(sInd); nMove = sum(mInd); nVid = sum(vInd);
               fullR_ortho(:, vInd) = Q(:, nStim + nMove + 1 : nStim + nMove + nVid);
           else
               disp('No linear dependence or high correlation detected. Skipping orthogonalisation.');
               fullR_ortho = fullR_out;
           end
       end

        function fluorTaskKernel = extractTrialFluor(obj, fluor)
            % *fluorTaskKernel*: a helper function that helps to trial-wise
            % fluoroscent data from the data table, to trimming to solely
            % within the time kernel (as per the stimulus onset variable obj.stim)
                % Note: all fluoroscent, video PC and task-related
                % variables are globally time-aligned, so they have the
                % same length, we just use obj.stim as an index to time-kernel
                % out the fluoroscent data 
            
            % INPUT:
            % - *obj*: (can be kept empty) the *object instance* of the class linearEncodeModel
            % that was previously created, in MATLAB this is just a syntax
            % to call the function as it belongs to the method of the class
            % linearEncodeModel()
            % - *fluor*: the fluoroscent data in *double* array format

            % OUTPUT:
            % - *fluorTaskKernel*: the *double* array formatted fluoroscent
            % data that was trimmed to only containing data within the time kernel

            idx = obj.stim == 1;
            if any(idx)
                fluorTaskKernel = fluor(idx);
            else
                warning('No stimulus times found (obj.stim == 1). Returning empty array.');
                fluorTaskKernel = [];
            end
        end

        function plotDesignMatrix(obj, fullR)
            % *plotDesignMatrix*: a helper function that plots the first 2 minutes of the
            % design matrix out for visualisation across all regressors (can be expanded/ non-expanded)
            % Plot the first 2 minutes of the design matrix
            % INPUT:
            % - *obj*: (can be kept empty) the *object instance* of the class linearEncodeModel
            % that was previously created, in MATLAB this is just a syntax
            % to call the function as it belongs to the method of the class
            % linearEncodeModel()
            % - *fullR*: the design matrix in *table* or *matrix* format
            % for visualisation
        
            % OUTPUT:
            % A heat map/ diagramme that shows the design matrix and
            % relative value for each data point in respective to other
            % data points
        
            figure;
            % Select first 2 minutes
            dataToPlot = fullR(1:120 * obj.sRate, :); 
        
            % Plot the heat map of the  design matrix
            imagesc(dataToPlot);
        
            % Set axis labels and title
            xlabel('Regressors');
            ylabel('Samples (first 2 minutes)');
            title('Design Matrix');
        
            % Adjust color bar limits to 0 and 1
            caxis([0, 1]);
            colorbar;  % Show color bar
        end

        function [lambda, betas, convergenceFailures] = ridgeMML(obj, X, Y, recenter, lambda, verbose, timeoutSec)
            % *ridgeMML*: a function that runs the ridge Regression with
            % marginal maximum likelihod (MML) - approach described in Karabatsos (2017).

            % INPUT:
            % - *obj*: (can be kept empty) the *object instance* of the class linearEncodeModel
            % that was previously created, in MATLAB this is just a syntax
            % to call the function as it belongs to the method of the class
            % linearEncodeModel()
            % - *X*: (matrix; in double) the time-lagged design matrix with
            % the dimension [frames x (number of lags x number of regressors)]
            % - *Y*: (vector; in double): the outcome of the design matrix,
            % with the dimension of [frames x 1], which the 1st dimension
            % must match with *X*
            % - *recenter*: (optional) (default: true)
            % - *L*: (optional) initial lambdas (optional)
            % - *verbose*: (optional) print progress every 10 regressions (default: true)
            % - *timeoutSec*: (optional) timeout in seconds per column (optional)

            % OUTPUT:
            % - *lambda*: (double) a value that shows the optimal ridge regularisation parameter 
            % λ (lambda) for a single output variable using the marginal maximum likelihood (MML) 
            % - *betas*: (vector, double) [frames x 1] the beta values
            % associated with each frame
            % - *convergenceFailures*: (vector, logical) whether the fminbnd failed to converge 
            % for each column of y (this happens frequently).
    
            if nargin < 4 || isempty(recenter), recenter = true; end
            if nargin < 5, lambda = NaN; end
            if nargin < 6, verbose = true; end
            if nargin < 7, timeoutSec = 15; end
    
            if size(Y, 1) ~= size(X, 1)
                error('X and Y must have the same number of rows');
            end
    
            computeL = isempty(lambda) || isnan(lambda(1));
            if computeL || recenter
                YMean = mean(Y, 1);
                Y = bsxfun(@minus, Y, YMean);
            end
    
            pY = size(Y, 2);
            XStd = std(X, 0, 1);
            X = bsxfun(@rdivide, X, XStd);
            if computeL || recenter
                XMean = mean(X, 1);
                X = bsxfun(@minus, X, XMean);
            end
    
            if computeL
                [U, S, V] = svd(X, 0);
                d = diag(S);
                n = size(X, 1);
                p = size(V, 2);
                q = sum(d' > eps(U(1)) * (1:p));
                d2 = d .^ 2;
                alph = S * U' * Y;
                alpha2 = alph .^ 2;
                YVar = sum(Y .^ 2, 1);
                lambda = NaN(1, pY);
                convergenceFailures = false(1, pY);
    
                for i = 1:pY
                    tStart = tic;
                    [lambda(i), flag] = obj.ridgeMMLOneY(q, d2, n, YVar(i), alpha2(:, i), timeoutSec);
                    convergenceFailures(i) = (flag < 1);
    
                    if verbose && mod(i, 10) == 0
                        fprintf('[%s] Processed %d/%d responses (%.2f sec)\n', ...
                            datestr(now,'HH:MM:SS'), i, pY, toc(tStart));
                    end
                end
            else
                p = size(X, 2);
            end
    
            if ~recenter
                if computeL
                    Y = bsxfun(@plus, Y, YMean);
                    X = bsxfun(@plus, X, XMean);
                end
                X = [ones(size(X, 1), 1), X];
                XTX = X' * X;
                ep = eye(p + 1); ep(1, 1) = 0;
                renorm = [1; XStd'];
                betas = NaN(p + 1, pY);
            else
                XTX = X' * X;
                ep = eye(p);
                renorm = XStd';
                betas = NaN(p, pY);
            end
    
            XTY = X' * Y;
            for i = 1:pY
                betas(:, i) = (XTX + lambda(i) * ep) \ XTY(:, i);
            end
            betas = bsxfun(@rdivide, betas, renorm);
            betas(isnan(betas)) = 0;
        end
    
        function [L, flag] = ridgeMMLOneY(obj, q, d2, n, YVar, alpha2, timeoutSec)
            % - *ridgeMMLOneY*: a helper function that helps to estimates the optimal 
            % ridge regularization parameter λ (lambda) for a single output variable using 
            % the marginal maximum likelihood (MML) approach described in Karabatsos (2017).

            % INPUT:
            % - *obj*: (can be kept empty) the *object instance* of the class linearEncodeModel
            % that was previously created, in MATLAB this is just a syntax
            % to call the function as it belongs to the method of the class
            % linearEncodeModel()
            % - *q*: (scalar) number of valid singular values (rank of the matrix).
            % - *d2*: [q×1] vector, squared singular values of the design matrix X (i.e., d.^2).
            % - *n*: (scalar)	number of observations (rows of X).
            % - *YVar*: (scalar) variance of the current output variable (Y(:, i)'s norm squared).
            % - *alpha2*: ([q×1] vector) squared SVD-projected values of the output variable (alpha.^2).
            % - *timeoutSec*: (scalar) (optional)	time limit in seconds for the lambda search. Default = inf if not specified.

            % OUTPUT:
            % - *L*: (scalar) optimal lambda value (regularization strength)
            % - *flag* (integer) convergence flag from fminbnd: 1 = success, 0 = failure.

            smooth = 7; stepSwitch = 25; stepDenom = 100;
            smBuffer = NaN(1, smooth); testValsL = NaN(1, smooth);
            smBufferI = 0;
            NLLFunc = @(L) -(q * log(L) - sum(log(L + d2(1:q))) ...
                            - n * log(YVar - sum(alpha2(1:q) ./ (L + d2(1:q)))));
    
            done = false; NLL = Inf;
            t0 = tic;
    
            for k = 0:stepSwitch * 4
                if toc(t0) > timeoutSec
                    warning('Timeout reached during lambda search');
                    L = 1; flag = 0;
                    return;
                end
                smBufferI = mod(smBufferI, smooth) + 1;
                prevNLL = NLL;
                NLL = NLLFunc(k / 4);
                smBuffer(smBufferI) = NLL;
                testValsL(smBufferI) = k / 4;
                if NLL > prevNLL
                    minL = (k - 2) / 4;
                    maxL = k / 4;
                    done = true;
                    break;
                end
            end
    
            if ~done
                L = k / 4;
                NLL = mean(smBuffer);
                while ~done
                    if toc(t0) > timeoutSec
                        warning('Timeout reached during extended lambda search');
                        L = 1; flag = 0;
                        return;
                    end
                    L = L + L / stepDenom;
                    smBufferI = mod(smBufferI, smooth) + 1;
                    prevNLL = NLL;
                    smBuffer(smBufferI) = NLLFunc(L);
                    testValsL(smBufferI) = L;
                    NLL = mean(smBuffer);
                    if NLL > prevNLL
                        smBufferI = smBufferI - (smooth - 1) / 2;
                        smBufferI = smBufferI + smooth * (smBufferI < 1);
                        maxL = testValsL(smBufferI);
                        smBufferI = smBufferI - 2;
                        smBufferI = smBufferI + smooth * (smBufferI < 1);
                        minL = testValsL(smBufferI);
                        done = true;
                    end
                end
            end
    
            opts = optimset('Display', 'off', 'MaxIter', 500, 'MaxFunEvals', 500);
            [L, ~, flag] = fminbnd(NLLFunc, max(0, minL), maxL, opts);
        end

        function plotRegressorGroupsOverTime(obj, betas, regLabels, regressorGroups)
            % plotRegressorGroupsOverTime: Plot beta weights over time (lags) for each group of regressors
            %
            % INPUT:
            % - obj: instance of linearEncodeModel (needed for sampling rate)
            % - betas: [numRegressors * numLags x 1] vector of beta weights
            % - regLabels: cell array of regressor base names (e.g. {'rewardR0', ..., 'motionPC10'})
            % - regressorGroups: cell array of groups, each is a cell array of regressor names to compare
            %
            % This function assumes time lags are stored **column-wise per regressor**.
            
                if nargin < 4
                    error('All inputs (obj, betas, regLabels, regressorGroups) must be provided.');
                end
            
                numLags = obj.sRate * (obj.postTime - (-obj.preTime));  % total time points (e.g. 50 lags)
                timeAxis = linspace(-obj.preTime, obj.postTime, numLags); % x-axis in seconds
            
                for groupIdx = 1:numel(regressorGroups)
                    group = regressorGroups{groupIdx};
                    figure; hold on;
                    title(['Beta Weights Over Time - Group ', num2str(groupIdx)]);
                    xlabel('Time (s)');
                    ylabel('Beta Weight');
                    
                    for i = 1:numel(group)
                        regName = group{i};
                        regIdx = find(strcmp(regLabels, regName));
                        if isempty(regIdx)
                            warning('Regressor "%s" not found in regLabels.', regName);
                            continue;
                        end
                        betaIdx = (regIdx - 1) * numLags + (1:numLags);
                        plot(timeAxis, betas(betaIdx), 'DisplayName', regName, 'LineWidth', 1.5);
                    end
            
                    legend('show');
                    grid on;
                end
        end
    end
end

