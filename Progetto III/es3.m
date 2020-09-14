clear; clc, close all;

%% Data
mu = 150;
sigma = 5;
tau = 10;
zeta = 1.65; %% 95% safety 

%% Formulas

d = mu;
Ss = zeta*sigma*sqrt(tau);
S0 = d*tau + Ss;


%% Experiment

zetas = linspace(0, 2, 100);
fails = zeros(1,100);

for z=1:length(zetas)
    
    zeta = zetas(z);
    Ss = zeta*sigma*sqrt(tau);
    S0 = d*tau + Ss;
    
    nOfFails = 0;
    test = 2000;
    for j = 1:test
        initialStock = S0;
        for i = 1:10
            order = mvnrnd(mu, sigma);
            initialStock = initialStock - order;
        end
        if(initialStock < 0)
            nOfFails = nOfFails + 1;
        end
    end
    failPercentage = (nOfFails / test) * 100;
    fails(z) = failPercentage;
    fprintf(z + "\n");
end

plot(zetas, fails);
