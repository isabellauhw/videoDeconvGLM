%By Max Melin. Trains the ridge regression model described in Musall 2019 
%on that same dataset. In this code, no state regressors are added. Rather, 
%trials are split up by state (predicted by the Ashwood GLM-HMM) and used to
%train seperate encoding models for each behavioral state. A model is built 
%for each of the following states: ___,___,___.