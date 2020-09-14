clear all;
clf;
close all;
clc;

%% Data
stones = 400;
costStone = 1400;
costOrder = 1000;

%% Graph

N = 450;
Q = zeros(1,N);
mCost = zeros(1,N);
oCost = zeros(1,N);
bCost = zeros(1,N);

for q=1:N
    Q(q) = q;
    mCost(q) = 0.25 * costStone * q / 2; 
    
    discount = 0;
    if( q >= 400)
        discount = 0.1;
    elseif( q >= 100)
        discount = 0.05;
    end;
    
    %oCost(q) = costOrder * (stones / q);
    bCost(q) = costOrder * (1 - discount) * stones;    
end

hold on;
plot(Q, mCost);
plot(Q, oCost);
plot(Q, bCost);
totalCost = bCost + oCost + mCost;
plot(Q, bCost + oCost + mCost);
legend("mCost", "oCost", "bCost", "tCost");

[minCost Qstar] = min(totalCost);


%% Simulation
% 
% N = 450;
% totals = ones(1, N ) * +Inf;
% totOrders = ones(1, N ) * +Inf;
% costoOrdines = ones(1, N ) * +Inf;
% costoMantenimentos = ones(1, N ) * +Inf;
% 
% for Qstar=3:1:N 
%     
%     Tstar = floor(Qstar/stones * 365);
%     
%     period = 1:1:365;
%     
%     maintenance = costStone * 0.25 / 365;
%     
%     daysToOrder = [1];
%     d = 1;
%     while(d < 365)
%         d = d + Tstar;
%         daysToOrder = [daysToOrder d];
%     end
%     
%     domanda = zeros(1, 365);
%     ordini = zeros(1, 365);
%     costoOrdini = zeros(1, 365);
%     giacenza = zeros(1, 365);
%     
%     left = stones;
%     
%     for d=1:365
%         domanda(d) = 400 / 365;
%         ordini(d) = 0;
%         if(~isempty(find(daysToOrder == d)))
%             ordini(d) = min([Qstar left]);
%             left = left - ordini(d);
%             discount = 0;
%             if(ordini(d) >= 400)
%                 discount = 0.10;
%             elseif(ordini(d) >= 100)
%                 discount = 0.05;
%             end
%             costoOrdini(d) = (costStone * (1 - discount))*ordini(d);
%         end
%         if(d == 1)
%             giacenza(d) = ordini(d) - domanda(d);
%         else
%             giacenza(d) = giacenza(d-1) + ordini(d) - domanda(d);
%         end
%     end
%     
%     %Totale Ordine
%     totOrdine = ordini * 1000;
%     %Costi mantenimento
%     costoMantenimento = giacenza * maintenance;
%      
%     totOrders(Qstar) = sum(costoOrdini);
%     costoMantenimentos(Qstar) = sum(costoMantenimento);
%     costoOrdines(Qstar) = ceil(stones/Qstar) * 1000;
%     
%     total = totOrders(Qstar) + costoMantenimentos(Qstar) + costoOrdines(Qstar);
%     
%     totals(Qstar) = total;
% end
% 
% 
% [minTotal minQstar] = min(totals)
% 
% figure(3);
% hold on;
% plot(1:N, costoMantenimentos);
% plot(1:N, costoOrdines);
% plot(1:N, totOrders);
% plot(1:N, totals);
% 
% legend("mCost", "oCost", "bCost", "tCost");
% 
% legend("totOrders", "costoMantenimentos", "costoOrdines", "totals");


