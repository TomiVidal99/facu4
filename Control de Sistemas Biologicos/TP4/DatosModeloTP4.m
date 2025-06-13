% Datos dados
ks1=1/0.48;
ks2=1/0.3;
s_in=25;
x0=1;
s0=2;
n0=100;

kN=1/8.9;
n_in=0;

mu_max=0.46;
Ks=1.2;
Kis=16.728;
Kn=0.254;

v0=1;
states0 = [x0;s0]*1.5;

% Parámetros que van dentro del modelo del sistema
modelParameters.K = [1;-ks1];
modelParameters.xi_in = [0;s_in];
modelParameters.ks1=ks1;
modelParameters.ks2=ks2;

% Defino los parámetros de los modelos cinéticos
modelParameters.mu_model.mu_max=mu_max;
modelParameters.mu_model.Ks=Ks;
modelParameters.mu_model.Kis=Kis;
modelParameters.mu_model.Kn=Kn;

% F=zeros(length(modelParameters.K),1);
% Q=zeros(length(modelParameters.K),1);