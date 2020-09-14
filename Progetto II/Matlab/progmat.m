clear all;
clc; close all;
%% Def problem
prob = optimproblem('ObjectiveSense','minimize');
%% Def var
n = 4;
m = 5;
bigM = 10000;
duration = [10     2     7     2     5
            8     3     6     5     9
            7     1     3     4     5
            5    4     2     1     6];
weights = [3 5 4 2]';


time = optimvar('time', [4 5],'Type','integer','LowerBound',0);
x = optimvar('x',[5 4 4],'Type','integer','LowerBound',0,'UpperBound',1);
CMax = optimvar('CMax','Type','integer','LowerBound',0);

%% Def Constrains
con1 = optimconstr(m,n,n);
con2 = optimconstr(m,n,n);
con3 = optimconstr(n,m);
con4 = optimconstr(n);

for i = 1:n
    % Constraint to compute Cmax as an upper bound of every t_i,k + d_i,k
    con4(i) = CMax >= time(i,m) + duration(i,m);
    for k = 1:m
        % Constraint of sequentiality for machines
        if(k < m)
            con3(i,k) = time(i,k) + duration(i,k) <= time(i , k +1);
        end
        for j = 1:n
            if(i ~= j)
                % Constraints to avoid overlapping of jobs
                con1(k,i,j) = time(j,k) >= time(i,k) + duration(i,k) - bigM*(1 - x(k,i,j));
                con2(k,i,j) = time(i,k) >= time(j,k) + duration(j,k) - bigM*(x(k,i,j));
            end
        end
    end
end

prob.Constraints.con1 = con1;
prob.Constraints.con2 = con2;
prob.Constraints.con3 = con3;
prob.Constraints.con4 = con4;

%% Def Cost function
%{
- 'cmax': Makespan
- 'mwft': Mean Weighted Flow Time 
- 'mwct': Mean Weighted Completion Time
%}
optimizeWhat = 'cmax'; 
if strcmp(optimizeWhat,'cmax')
    prob.Objective = CMax;
elseif strcmp(optimizeWhat,'mwft')
    jobsDuration = (time(:, end) + duration(:, end)) - time(:, 1);
    mwft = (jobsDuration'*weights)/sum(weights);
    prob.Objective = mwft + sum(time(:,end));
elseif strcmp(optimizeWhat,'mwct')
    jobsCompletions = (time(:, end) + duration(:, end));
    mwct = (jobsCompletions'*weights)/sum(weights);
    prob.Objective = mwct;
end

%% Solution
sol = solve(prob);

%% Gantt chart

durations = zeros(n, 2*m);
previousEnd = zeros(n, 1);
k = 1;
for c=1:m
    durations(:,k) = sol.time(:,c) - previousEnd;
    durations(:, k+1) = duration(:,c);
    previousEnd = sol.time(:,c) + duration(:,c);
    k = k + 2;
end

H = barh(1:n, durations, 'stacked');
set(H(1:2:(2*m)),'Visible','off');
for i=1:2:(2*m)
    set(get(get(H(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end
xlabel('Time')
ylabel('Jobs')
legend({'Machine 1','Machine 2','Machine 3','Machine 4','Machine 5'});
grid minor;


