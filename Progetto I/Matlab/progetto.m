clear; clc;
%definizione parametri vedi pagina 36
m = 1140;
I_z = 1436.24;
l_f = 1.165;
l_r = 1.165;
c_f = 155494.663;
c_r = 155494.663;
v_x = 1.1765; % parametro non disponibile 
t_sample = 0.01;
% matrice delle eq di stato secondo pagina 32
A = [0 1 0 0; ...
    0 -(c_f+c_r)/(m*v_x) (c_f+c_r)/(m) 0; ...
    0 0 0 1; ...
    0 0 0 -((l_f^2)*c_f + (l_r^2)*c_r)/(I_z*v_x)];

B1 = [0 c_f/m 0 (l_f*c_f)/I_z]';
B2 = [0 -v_x 0 -((l_f^2)*c_f + (l_r^2)*c_r)/(I_z*v_x)]';

C=eye(4);
D=zeros(4,1);

%%
%parametri funzione costo ec.. per riccati
R = 1;
q1 = 5;
Q = [q1 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0];
Qf = Q;
horizon = 10;
t=0:t_sample:horizon;
N=length(t)-1;

%%
% creo sistema come definito per controllo pagina 37
sys = ss(A, B1, C, D);
% eig(A) = [0 -27.2798 0 -29.3880]'
% isstable(sys) = 0

% discretizzo 
sys_d = c2d(sys,t_sample);
A_d = sys_d.A;
B_d = sys_d.B;

[P, K]=pk_riccati(A_d,B_d,Q,Qf,R,N);
[Kinf,Pinf,error] = dlqr(A_d,B_d,Q,R); 

%%
%stato iniziale 
x0 = [2 6.25 -pi/2 0]';

x(:,:,1)=x0;
%aplico controllo ottimo 
for i=1:N
    %optimal control
    u(:,i)=-K(:,:,i)*x(:,i);
    %optimal state
    x(:,i+1)=A_d*x(:,i)+B_d*u(:,i);
end

%%
subplot(2,1,1);
plot(t(1:N),x(:,1:N));
title('state');
legend("distance from path", "drift velocity", "angle from path", "angular velocity");

subplot(2,1,2);
plot(t(1:N),u(:,1:N));
title('control');

%tolgo la dimensione in più(1X4xcAmpioni)
K_s = squeeze(K);

%variabile per simulink
k2simulink =[t(1:N)',-K_s'];
