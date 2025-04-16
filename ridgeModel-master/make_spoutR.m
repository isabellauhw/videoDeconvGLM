%this is testing code to see if makeDesignMatrix.m outputs the same fullR
%design matrices that are seen in delayDec_RegressModel.m. Seems to work
%when tested with spoutR 

clear all;
load('spoutTime.mat') %get spout times relative to stim onset
load('temp_spoutTime_opts.mat') %load proper opts for making spoutR
numtrials = length(spoutTime);
eventType = 2;
frames = opts.framesPerTrial;
sRate = opts.sRate;
spoutbinary = [];

opts.sPostTime = 200;


for i = 1:numtrials
    trialbinary = false(frames,1); %initialize array for one trial
    spoutIdx = round((opts.preStimDur + spoutTime(i)) * sRate);
    trialbinary(spoutIdx) = 1;
    spoutbinary = [spoutbinary; trialbinary];
end

[spoutR, eventIdx] = makeDesignMatrix(spoutbinary, eventType, opts);