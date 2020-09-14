clc; clear all;
%% Data
X = [5 10 12 15 20 35 50 80 90 100]';
Y = [4 15 25 34 48 70 125 360 540 900]';

%% Stats
scatter(X,Y);
correlation = corr(X,Y);

%% Linear Regression
mdl = fitlm(X,Y,'linear');
Yf = predict(mdl,X);

hold on;
plot(mdl);