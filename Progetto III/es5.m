clear; close all; clc;

%% Caricamento tabella
load erogato;
erogato = tabella_erogato;

%% Eliminazione elementi negativi
for i=1:size(erogato,2)
    erogato(find(erogato(:,i) < 0),i) = NaN;
    erogato(isnan(erogato(:,i)),i) = round(nanmean(erogato(:,i)));
end


%% Data
M = 6;
T = 10;
C = 39000;

r = erogato(1:T, [3 6 8 12 15 17])';

d = 2*60*cos(pi/6);

c = [0   60  d   120 d   60  60;
     60  0   60  d   120 d   60;
     d   60  0   60  d   120 60;
     120 d   60  0   60  d   60;
     d   120 d   60  0   60  60;
     60  d   120 d   60  0   60;
     60  60  60  60  60  60  0];

c = 0.5*1000*c;

figure(1)
nodenames = {'PV1','PV3','PV4','PV5',...
    'Deposito','PV2','PV6'};
G = graph(c,nodenames);
p = plot(G);
p.NodeColor = 'r';

%% Decision variables

prob = optimproblem('ObjectiveSense','minimize');

x = optimvar('x', [M T],'Type','continuous','LowerBound',0);
z = optimvar('z',[M+1 T],'Type','integer','LowerBound',0,'UpperBound',1);
y = optimvar('y',[M+1 M+1 T],'Type','integer','LowerBound',0,'UpperBound',2);

%% Support variables

I = optimvar('I', [M T], 'Type','continuous','LowerBound',0);

%% Constraints 

c1 = optimconstr(M, T);
c2 = optimconstr(T);
c3 = optimconstr(M+1, T);
c4 = optimconstr(M, M, T);
c5 = optimconstr(M+1, T);
c6 = optimconstr(T);
c7 = optimconstr(M, M, T);
c8 = optimconstr(M);

for i=1:M
    invC = 0.5;
    c8(i) = I(i,1) == invC*sum(r(i,:));
end

for t=1:T
    % Capacity contraint
    c2(t) = sum(x(:,t)) <= C;
    for i=1:M
        if(t > 1)
            % Inventory definition at the retailers
            c1(i,t) = I(i,t) == I(i, t-1) + x(i, t-1) - r(i, t-1);
        end
        
        c5(i,t) = x(i,t) <= C*(sum(y(:, i, t)));
        
        % Constraint of binary of y^t_ij foreach t in T, i in M, and j in M
        for j=1:M
            c4(i,j,t) = y( i, j, t) <= 1;
            if(i <= j)
                c7(i,j,t) = y( i, j, t) == 0;
            end
        end
    end
end

for t=1:T
    c6(t) = sum(z(:, t)) <= 3;
    for i=1:M+1
       % Routing constraints
       leftHand = 0;
       if(i > 1)
           leftHand = leftHand + sum(y( i, 1:i-1, t));
       end
       if(i ~= M+1)
           leftHand = leftHand + sum(y(i+1:end, i, t));
       end
       c3(i, t) = leftHand == 2*z(i, t);
    end
end

prob.Constraints.c1 = c1;
prob.Constraints.c2 = c2;
prob.Constraints.c3 = c3;
prob.Constraints.c4 = c4;
prob.Constraints.c5 = c5;
prob.Constraints.c6 = c6;
prob.Constraints.c7 = c7;
prob.Constraints.c8 = c8;

%% Objective function

invCostRetailers = 0.03 / 365 * sum(sum(I));
routingCost = 0;
for i=1:M+1
    for j=1:M+1
        for t=1:T
            routingCost = routingCost + c(i,j)*y(i,j,t);
        end
    end
end
            

prob.Objective = invCostRetailers + routingCost;

%% Solution
sol = solve(prob);

%% Compute cost
finalInvCostRetailers = 0.03 / 365 * sum(sum(sol.I));
finalRoutingCost = 0;
for i=1:M+1
    for j=1:M+1
        for t=1:T
            finalRoutingCost = finalRoutingCost + c(i,j)*sol.y(i,j,t);
        end
    end
end

finalCost = finalInvCostRetailers + finalRoutingCost