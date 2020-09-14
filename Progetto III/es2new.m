clear all;
clf;
close all;
clc;

%% Data
stones = 400;
costStone = 1400;
costOrder = 1000;

%% Graph with 25% manteinance cost

N = 450;
Q = zeros(1,N);
mCost = zeros(1,N);
bCost = zeros(1,N);

for q=1:N
    Q(q) = q;
    mCost(q) = 0.25 * costStone * q / 2; 
    
    discount = 0;
    if( q >= 400)
        discount = 0.1;
    elseif( q >= 100)
        discount = 0.05;
    end
    
    bCost(q) = costOrder * (1 - discount) * stones;    
end

hold on;
plot(Q, mCost);
plot(Q, bCost);
tCost = bCost + mCost;
plot(Q, tCost);
legend("mCost", "bCost", "tCost");

[minCost Qstar] = min(tCost);
buyP = (bCost(Qstar)/minCost)*100;
mP = (mCost(Qstar)/minCost)*100;
Tstar = Qstar/stones * 365;

fprintf("Qstar : " + Qstar + "\nTstar: " + Tstar + "\nBuy_percentage: "+ buyP +...
    "\nM_percentage: "+ mP + "\n" );

%% Analiticamente

% tCost(400) = tCost(100)
% cm1 * 1400 * 200 + 1000 * 0.90 * 400 = ...
%     cm1 * 1400 * 50 + 1000 * 0.95 * 400; 
% => cm1 = 0.095

%% Graph with 9.5% mantenaince cost
figure(2);
N = 450;
Q = zeros(1,N);
mCost = zeros(1,N);
bCost = zeros(1,N);

for q=1:N
    Q(q) = q;
    mCost(q) = 0.095 * costStone * q / 2; 
    
    discount = 0;
    if( q >= 400)
        discount = 0.1;
    elseif( q >= 100)
        discount = 0.05;
    end
    
    bCost(q) = costOrder * (1 - discount) * stones;    
end

hold on;
plot(Q, mCost);
plot(Q, bCost);
tCost = bCost + mCost;
plot(Q, tCost);
legend("mCost", "bCost", "tCost");

[minCost Qstar] = min(tCost);

Tstar = Qstar/stones * 365;

fprintf("Qstar : " + Qstar + "\nTstar: " + Tstar + "\n");



