
%% ELE829 Final Project Fall 2018
% Part 1 - Linear regression modeling
% Load and plot dataset for identification and validation
% Load your dataset at the specified place with following syntax:
%   load proj1datasetXX.mat
% where
% XX is the assigned flag number for Part 1 of the project 
% Last Revision: Nov. 2018                     
%***************************************************************
clc
clear all 
close all

% load your data file here

load proj1dataset01.mat

%************************************************************************
disp('********************************************************************')
disp(' ')
disp(['Part 1: Dataset # ' num2str(flag) ' is sampled at Ts = 0.02sec, do not change it!'])
disp(' ')
disp('The output is corrupted by additive zero-mean Gaussion noise')
disp(' ')
disp('Samples of noisy data for identification and validation will be displayed')
disp(' ')
disp('You have generated N_id = 100 samples of identification data')
disp('and N_val = 50 samples of validation data')   
disp(' ')
disp('********************************************************************')

% plot dataset to get an idea of how the function looks; 
% There are two dataset: Identification data and Validation data

figure;
subplot(211)
plot(tid,yid,'o'),grid on
xlabel('time(sec)'),ylabel('Identification data')
title(['Part1: Noisy dataset # ',  num2str(flag), ', Ts = 0.02'])
subplot(212)
plot(tval,yval,'*'),grid on
xlabel('time(sec)'),ylabel('Validation data')

%% Calcuations for MSE
Y = yid';
MSE_error = 1000;                                                           %initialize MSE error value
for n=1:10;                                                                 %Range for model order
     X = zeros(max(size(tid')),n+1);                                        %initialize matrix of regressors
        for i=1:n+1
            X(:,i) = tid'.^(n+1-i);                                         %Generate matrix of regressors
        end
     theta_est = pinv(X)*Y;                                                 %LS estimated parameters
     
     y_est= zeros(size(tval'));                                             %initialize estimated output
     for i=1:n+1
         y_est = y_est+ theta_est(i)*tval'.^(n+1-i);                        %estimated y
     end
     error(n) = immse(yval',y_est);                                         %Mean squared error for each n
     
     if error(n) < MSE_error
         MSE_error = error(n);
         order = n;                                                         %Optimum Model order
     end

end

%% Optimum Model Order Selection and Plotting MSE
n = order;                                                                  %Model order  
figure (2)
plot(error, 'b--o');
title('Loss Function Evaluation of Validated Data');
xlabel('Model Order');
ylabel('MSE');


%% Estimating Linear Regressing Model 
X = zeros(max(size(tid')),n+1);                                             %initialize matrix of regressors
for i=1:n+1
    X(:,i) = tid'.^(n+1-i);                                                 %Generate matrix of regressors
end

%% Linear Regression Model
theta_est = pinv(X)*Y                                                      %LS estimated parameters

%% Estimated Model
y_est = zeros(size(tval'));                                                 %initializing estimated output
for i=1:n+1
    y_est = y_est+ theta_est(i)*tval'.^(n+1-i);                             %estimated model
end

t_est = zeros(size(tid'));                                                 %initializing estimated output
for i=1:n+1
    t_est = t_est+ theta_est(i)*tid'.^(n+1-i);                             %estimated model
end

%% Plotting Estimated Model and Identification Data
figure (3)
plot (tid',t_est);                                                         %Plot estimated model and validation data
hold on
plot(tid,yid,'*');
hold off
title ('Estimated Model using Identification Data Input');
xlabel ('Input Data');
legend('Estimated Model', 'Identification Data Input');


%% Plotting Estimated model and Validated Data
figure (4)
plot (tval',y_est);                                                         %Plot estimated model and validation data
hold on
plot(tval,yval,'*');
hold off
title ('Estimated Model using Validation Data Input');
xlabel ('Input Data');
legend('Estimated Model', 'Validation Data Input');

%% Residual 
residual = y_est - yval';                                                   %Residuals
figure (5)
autocorr(residual)                                                          %ACF of residuals
title ('Auto Correlation Function (ACF) of Residuals');
figure (6)
crosscorr(residual, tval)                                                   %CCF between residuals and input dat
title ('Cross Correlation Function (CCF) of Residuals');

%% Chi-Squared Test
m = 25;                                                                     %degree of freedom
[Sr,xr] = chisq(m,residual,0)                                               %Chi-squared test for ACF
[Sru,xru] = chisq(m,residual,tval, 0)   
