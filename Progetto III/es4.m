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

%% 

kms = [334 334 334 388 388 388 405 405 408 408 408 408 409 409 409 413 413];
types = ["B95" "B98" "Diesel" "B95" "B98" "Diesel" "B95" "Diesel" "B95" "B98" "GPL" "Diesel" "B95" "B98" "Diesel" "B95" "Diesel"];

prices = struct();
prices.B95 = 1.3;
prices.B98 = 1.4;
prices.Diesel = 1.1;
prices.GPL = 0.5;

for c = 1:length(kms)
    
    gasCost = prices.(types(c));
    kmCost = 0.5;
    maxCamionCapacity = 39000;
    N = size(erogato, 1);
    start = 2000;
    
    D = sum(erogato(:, c));
    costOrder = 0.5 * kms(c);
    
    Q = zeros(1,N);
    mCost = zeros(1,N);
    bCost = zeros(1,N);
    oCost = zeros(1,N);
    
    for q=start:D
        i = q - start + 1;
        Q(i) = q;
        mCost(i) = 0.03 * gasCost * q / 2;
        
        nOfCamions = ceil(q/maxCamionCapacity);
        
        oCost(i) = (costOrder * nOfCamions) * (D / q);
        bCost(i) = gasCost * D;
    end
    
    
    tCost = bCost + mCost + oCost;
    if(c == 3)
        figure(c);
        hold on;
        subplot(2,2,1);
        plot(Q, mCost, "LineWidth", 2);
        title("Costo di manutenzione");

        subplot(2,2,2);
        plot(Q, bCost, "LineWidth", 2);
        title("Costo di acquisto");

        subplot(2,2,3);
        plot(Q, oCost, "LineWidth", 2);
        title("Costo di ordine");

        subplot(2,2,4);
        plot(Q, tCost, "LineWidth", 2);
        title("Costo totale");
    end
    
    [minQ Qstar] = min(tCost);
    Qstar = Qstar + start;
    Tstar = (Qstar)/D * N;
    
    fprintf(sprintf("Stazione n° %i - Type %s\n", kms(c), types(c)));
    fprintf(sprintf("Qstar = %i\nTstar = %.0i\n", Qstar, round(Tstar)));
    fprintf("------------\n");
end
