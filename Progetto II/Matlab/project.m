
%% Step 1: Optimal make span Matrices
clear all; clc; close all;
startJob = [0 7 8 11 15; 
    7 15 18 24 29;
    15 25 27 34 38;
    25 30 34 36 43];
endJob = [7 8 11 15 20;
          15 18 24 29 38;
          25 27 34 36 43;
          30 34 36 37 49];
      
n = size(startJob, 1);
m = size(startJob, 2);
      
durations = endJob - startJob;
weights = [4 5 3 2]';

breakDown = [17 22];
jobs = [3 2 1 4]';
processTypes = ["V", "M", "U", "U", "V"];
processNames = ["V1", "M1", "U1", "U2", "V2"];

%% Step 1.1: Print original Matrix
fprintf("-----------\nOriginal Scheduling\n");
fprintf("Job\t");
for c = 1:m
    fprintf(processNames(1, c) + "\t");
end
fprintf("w_i\n");
for r = 1:n
    fprintf(jobs(r, 1) + "\t");
    for c = 1:m
        fprintf(sprintf("%i-%i\t", startJob(r,c), endJob(r,c)));
    end
    fprintf(weights(r, 1) + "\t");
    fprintf("\n");
end

%% Step 1.2: Gantt Chart

durationsGantt = zeros(n, 2*m);
previousEnd = zeros(n, 1);
k = 1;
for c=1:m
    durationsGantt(:,k) = startJob(:,c) - previousEnd;
    durationsGantt(:, k+1) = endJob(:,c) - startJob(:,c);
    previousEnd = endJob(:,c);
    k = k + 2;
end

H = barh(jobs, durationsGantt, 'stacked');
set(H(1:2:(2*m)),'Visible','off');
grid minor;
figure(2);

%% Step 1.3: Find makespan
makespan = endJob(end, end);
fprintf("Makespan: "+ makespan + "\n"); 

%% Step 1.4: Find mean weighted flow time
jobsDuration = endJob(:, end) - startJob(:, 1);
numerator = jobsDuration'*weights;
denumerator = sum(weights);
mwft = numerator/denumerator;
fprintf("Mean weighted flow time: "+ mwft + "\n"); 

%% Step 2: Find affected jobs
affected = zeros(n,m);

for r = 1:n
    for c = 1:m
        startOfJob = startJob(r,c);
        endOfJob = endJob(r,c);
        type = processTypes(c);
        
        if(type == "M")
            affected(r,c) = 0;
            continue;
        end
        
        if(breakDown(1) > startOfJob & breakDown(1) < endOfJob ...
                & breakDown(2) > endOfJob)
           affected(r,c) = breakDown(2) - breakDown(1); % The breakdown starts in between
        end
        
        if(breakDown(1) > startOfJob & breakDown(2) < endOfJob)
           affected(r,c) = breakDown(2) - breakDown(1); % The breakdown starts and ends in between
        end
        
        if(breakDown(2) > startOfJob & breakDown(2) < endOfJob ...
                & breakDown(1) < startOfJob)
           affected(r,c) = breakDown(2) - startOfJob; % The breakdown ends in between
        end
        
        if(breakDown(1) < startOfJob & breakDown(2) > endOfJob)
           affected(r,c) = breakDown(2) - startOfJob; % The breakdown starts and ends outside
        end
        
        if(type == "U" & affected(r,c))
            % If it's U and it's affected we overwrite with b-a
            affected(r,c) = breakDown(2) - startOfJob;
        end
        
    end
end

%% Step 3: Remove manual (category iii) jobs
% Done in step 2.

%% Step 4: Compute new processing time
newDuration = durations + affected;
newStartJob = zeros(n,m);
newEndJob = zeros(n,m);
for r = 1:n
    prevMachineEnd = 0;
    prevRow = zeros(1, m);
    if(r > 1)
        prevMachineEnd = newEndJob(r-1,1);
        prevRow = newEndJob(r-1,:);
    end
    for c = 1:m
        newStartJob(r,c) = max(prevMachineEnd, prevRow(1, c));
        newEndJob(r,c) = newStartJob(r,c) + newDuration(r,c);
        prevMachineEnd = newEndJob(r,c);
    end
end

%% Step 5: Print result
fprintf("-----------\nComputed Scheduling after Break-Down\n");
fprintf("Job\t");
for c = 1:m
    fprintf(processNames(1, c) + "\t");
end
fprintf("w_i\n");
for r = 1:n
    fprintf(jobs(r, 1) + "\t");
    for c = 1:m
        fprintf(sprintf("%i-%i\t", newStartJob(r,c), newEndJob(r,c)));
    end
    fprintf(weights(r, 1) + "\t");
    fprintf("\n");
end

%% Step 5.2: Find makespan
newMakespan = newEndJob(end, end);
fprintf("New Makespan: "+ newMakespan + "\n"); 

%% Step 5.3: Find mean weighted flow time
jobsDuration = newEndJob(:, end) - newStartJob(:, 1);
numerator = jobsDuration'*weights;
denumerator = sum(weights);
mwft = numerator/denumerator;
fprintf("New Mean weighted flow time: "+ mwft + "\n"); 

%% Step 6: Gantt chart

durations = zeros(n, 2*m);
previousEnd = zeros(n, 1);
k = 1;
for c=1:m
    durations(:,k) = newStartJob(:,c) - previousEnd;
    durations(:, k+1) = newEndJob(:,c) - newStartJob(:,c);
    previousEnd = newEndJob(:,c);
    k = k + 2;
end

H = barh(jobs, durations, 'stacked');
set(H(1:2:(2*m)),'Visible','off');
grid minor;



