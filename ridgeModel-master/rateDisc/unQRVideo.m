function betas = unQRVideo(dimBeta, qrR, recIdx, recLabels)
% betas = unQRVideo(dimBeta, qrR, recIdx, recLabels)
% 
% Given the regression coefficients that come out of our widefield linear
% model, undo the QR step to recover the "true" coefficients for the SVD'd
% video.
% 
% The output betas will have size nVidRegressors x 1.

%% Find video regressors

vidID = find(strcmp(recLabels, 'bhvVideo'), 1);
vidElems = recIdx == vidID;


%% Invert R

RInv = inv(qrR);


%% Use relevant portions of matrices to undo QR

betas = dimBeta(vidElems, :);
RInv = RInv(vidElems, vidElems);

betas = RInv * betas;
