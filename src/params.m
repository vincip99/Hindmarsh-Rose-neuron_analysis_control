clearvars
close all
clc

addpath('functions')
%% Model Parameters
a = 1;
b = 3;
c = 1;
d = 5;
s = 4;
x_r = -8/5;
r = 0.003;
I = 1.28;
I_eq = 0;

% initial condition
x_0 = [0.1; 0.1; 0.1];

% Simulation Time for regulation and tracking
T_reg = 20;
T_track = 5000;

% Regulation vs tracking
regulation = 0;
tracking = 1 - regulation;

if regulation == 1
    T = T_reg;
else 
    T = T_track;
end

% Regulation eq
eq = hr_equilibria(a,b,c,d,s,x_r,I_eq);
x_eq = eq(1,1);

% Disturbance choice
choice = 3;

% Uncertainty
uncertainty = 0;

%% PID params
Kp = 108.97;
Kd = 2.67;
Ki = 49.48;

% Jacobian for regulation
A = hr_jacobian(x_eq, a, b, d, r, s);
% Input and output matrices
B = [1; 0; 0];
C = [1, 0, 0];
D = 0;

%% IO FBL Parameters
Kp_fbl = 2.5;
Ki_fbl = 0;
Kd_fbl = 0;
d_filter = 100;

%% SMC parameters
p1 = 1.33;
k_smc = 1.2;
