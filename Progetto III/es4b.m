clear all;
close all;
clc;

%% Caricamento tabella
load erogato;
erogato = tabella_erogato;

%% Eliminazione elementi negativi
for i=1:size(erogato,2)
    erogato(find(erogato(:,i) < 0),i) = NaN;
    erogato(isnan(erogato(:,i)),i) = round(nanmean(erogato(:,i)));
end


%% Algoritmo
c = 1;
data = erogato(:,c);

kms = [334 334 334 388 388 388 405 405 408 408 408 408 409 409 409 413 413];
types = ["B95" "B98" "Diesel" "B95" "B98" "Diesel" "B95" "Diesel" "B95" "B98" "GPL" "Diesel" "B95" "B98" "Diesel" "B95" "Diesel"];

prices = struct();
prices.B95 = 1.3;
prices.B98 = 1.4;
prices.Diesel = 1.1;
prices.GPL = 0.5;
    
N = length(data);
gasCost = prices.(types(c));
kmCost = 0.5;
maxCamionCapacity = 39000;
costOrder = 0.5 * kms(c);
mPercentage = 0.03;

lots = zeros(N,1);
tempoDiApprovigionamento = zeros(N,1);
sommaGiacenza = zeros(N,1);
oCost = zeros(N,1);
mCost = zeros(N,1);
cUnitProduct = zeros(N,1); %%Cost per unit of product
cUnitTime = zeros(N,1); %%Cost per unit of time

orders = zeros(N,1);
Q1 = zeros(N,1);
heuristic = "product"; %% product or period
totalNumberOrders = 0; 

yesterdayDemand = 0;

orderDay = 1;
i = 1;
while(i <= N)
    todayDemand = data(i);
    lots(i) = todayDemand + yesterdayDemand;
    
    g = lots(i);
    j = orderDay;
    giacenza = [];
    while(g > 0)
        g = g - data(j);
        giacenza = [giacenza g];
        j = j + 1;
    end
    
    tempoDiApprovigionamento(i) = length(giacenza);
    sommaGiacenza(i) = sum(giacenza);
        
    nOfCamions = ceil(lots(i)/maxCamionCapacity);
    oCost(i) = costOrder * nOfCamions;
    
    
    %E' costante per tutti quindi non cambia
    %bCost = lot * gasCost; 
    cm = gasCost * (mPercentage * (tempoDiApprovigionamento(i) / N));
    mCost(i) = sommaGiacenza(i) * cm;
    
    Q1(i) = round(oCost(i) / cm);
    
    cUnitProduct(i) = (mCost(i) + oCost(i)) / lots(i);
    cUnitTime(i) = (mCost(i) + oCost(i)) / tempoDiApprovigionamento(i);
    
    
    yesterdayDemand = yesterdayDemand + todayDemand;
    
    if(i ~= orderDay)
        needToOrder = 0;
        if(heuristic == "product"  && cUnitProduct(i) > cUnitProduct(i-1))
            needToOrder = 1;
        elseif(heuristic == "time" && (abs(Q1(i)- sommaGiacenza(i)) > abs(Q1(i-1)- sommaGiacenza(i-1))))
            needToOrder = 1;
        end
        
        if(needToOrder == 1)
            orders(orderDay) = lots(i-1);
            orderDay = i;
            yesterdayDemand = 0;
            i = i - 1;
            totalNumberOrders = totalNumberOrders +1; 
        end
    end
    
    i = i + 1;
end
t = array2table([lots tempoDiApprovigionamento sommaGiacenza oCost mCost cUnitProduct cUnitTime orders]);
t.Properties.VariableNames = {'Lotto' 'TempoApprovvigionamento' 'SommaGiacenze' 'CostoOrdinazione' 'CostoMantenimento' 'CostoUnitaProdotto' 'CostoUnitaTempo' 'Ordini'};

totalInventory = sum(sommaGiacenza);
totalInventoryCost = totalInventory * ((gasCost * mPercentage)/ N);
totalOrderCost = costOrder * totalNumberOrders;
totalCost = totalInventoryCost + totalOrderCost; 

fprintf("Stazione: " + kms(c) + ", euristica: " + heuristic + ", costo totale: "+ totalCost +...
    ", numero di ordini: "+ totalNumberOrders + "\n" );