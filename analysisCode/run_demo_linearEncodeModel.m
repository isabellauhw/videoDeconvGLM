%% Build data struct %%

% -- linearEncodeModel --

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

model = linearEncodeModel('AMR035', '2023-06-13_1', allData);

%% Build behavioural variables (non-time-lagged) design matrix %%
% -- buildBehaviorRegressors --
% a function that help to load the behavioural regressors and compile them into a 
% *non-time shifted design matrix.

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

model = model.buildBehaviorRegressors();

%% Build initial, non-time-lagged design matrix %%
% -- getDesignMatrix --
% A function that combines the behavioural and video PCs regressors together into a 
% non-time shifted design matrix

% INPUT:
% - *obj*: (can be kept empty) the *object instance* of the class linearEncodeModel
% that was previously created, in MATLAB this is just a syntax
% to call the function as it belongs to the method of the class
% linearEncodeModel()

% OUTPUT:
% - *fullR*: a *table* that contains the non-time shifted
% behavioural and video PCs regressors.

R = model.getDesignMatrix();

%% -- Create time-lagged design matrix, and orthogonalise regressors if needed %%

 % -- timeLagOrtho --
 % Constructs a time-lagged design matrix, checks for linear dependence, 
 % and orthogonalises operant and spontaneous regressors if needed (when the matrix
 % fails the qr decomposition test).

 % INPUT:
 % - obj: instance of linearEncodeModel (optional for method call)
 % - fullR: table of all regressors
 % - stimLabels, moveLabels, vidLabels: selected labels for regressor groups

 % OUTPUT:
 % - fullR_out: GLM-ready matrix with optional orthogonalisation
 % - regIdx: group index vector
 % - regLabels: labels for regressors in fullR_out
        
% Preparations - Divide the model into different parts
stimLabels = {'rewardR0','rewardR00625', 'rewardR0125', 'rewardR025', 'rewardR05', 'rewardR1', ... 
    'rewardL0','rewardL00625', 'rewardL0125', 'rewardL025', 'rewardL05', 'rewardL1', ...
    'stimContrastR0','stimContrastR00625', 'stimContrastR0125', 'stimContrastR025', 'stimContrastR05', ...
    'stimContrastR1', 'stimContrastL0', 'stimContrastL00625', 'stimContrastL0125', ...
    'stimContrastL025', 'stimContrastL05', 'stimContrastL1'};

moveLabels = {'choiceL', 'choiceR'};

vidLabels = {'motionPC1', 'motionPC2', 'motionPC3', 'motionPC4', ...
             'motionPC5', 'motionPC6', 'motionPC7', 'motionPC8', ...
             'motionPC9', 'motionPC10'};

% Main function - Split regressors according to regressor type, and expand matrix
[expandR, regIdx, regLabels] = model.timeLagOrtho(R, stimLabels, moveLabels, vidLabels);

%% Trim the outcome variables so that they are epoched (concatenated time kernel data) %%
% -- fluorTaskKernel -- 
% A helper function that helps to trial-wise fluoroscent data from the data table, to trimming to solely
% within the time kernel (as per the stimulus onset variable obj.stim)

% INPUT:
% - *obj*: (can be kept empty) the *object instance* of the class linearEncodeModel
% that was previously created, in MATLAB this is just a syntax
% to call the function as it belongs to the method of the class
% linearEncodeModel()
% - *fluor*: the fluoroscent data in *double* array format

% OUTPUT:
% - *fluorTaskKernel*: the *double* array formatted fluoroscent
% data that was trimmed to only containing data within the time kernel

% Extract trial-wise DA and ACh fluoroscent signals
model.fluorDALeftTaskKernel = model.extractTrialFluor(model.fluorDALeft);
model.fluorACHRightTaskKernel = model.extractTrialFluor(model.fluorACHRight);

%% Run the ridge regression with marginal maximum likelihood (MML) for each outcome (DA, ACh) %%
% -- ridgeMML -- 
% A function that runs the ridge Regression with marginal maximum likelihod (MML)(Karabatsos, 2017).

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
% - *betas*: (vector, double) [size(X,2) x size(Y,2)] the beta values
% associated with each frame
% - *convergenceFailures*: (vector, logical) whether the fminbnd failed to converge
% for each column of y (this happens frequently).

% Run ridge regression for the behavioural and video PC regressors against
% the fluorDALeft and fluorACHRight outcomes
[ridgeDALambda, ridgeDABeta] = model.ridgeMML(expandR, model.fluorDALeftTaskKernel', true, [], true, 30); %get ridge penalties and beta weights.
[ridgeACHVLambda, ridgeACHBeta] = model.ridgeMML(expandR, model.fluorACHRightTaskKernel, true, [], true, 30); %get ridge penalties and beta weights.

%% Visualise the expand matrix %%

% -- plotDesignMatrix --
% A helper function that plots the first 2 minutes of the design matrix out for visualisation 
% across all regressors (can be expanded/ non-expanded)

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

% Plot regressors (for the first 2 minutes for visualisation)
model.plotDesignMatrix(expandR);

%% Plot the beta values out for all averaged time kernels
% -- plotEpochAverageBetas -- 
% A function that takes in betas, epochs every 50 frames and average them, and 
% plot the betas for the matrix as a curve over time

% INPUT:
% - *obj*: (object, linearEncodeModel) the object instance, which contains sRate
% - *betas*: (matrix, double) the beta values [frames x number of regressors]

% OUTPUT:
% - A plot of beta values over time (frames), averaged across epochs
  
regressorGroups = {
    {'rewardR0', 'rewardR00625', 'rewardR0125', 'rewardR025', 'rewardR05', 'rewardR1'}, ...
    {'stimContrastR0', 'stimContrastR00625', 'stimContrastR0125'}, ...
    {'choiceL', 'choiceR'}, ...
};

plotRegressorGroupsOverTime(model, ridgeDABeta, regLabels, regressorGroups);



