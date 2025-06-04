% Datos dados
ks=1/0.48;
s_in=50;
x0=5;
s0=0.1;
mu_max=0.46;
Ks=1.2;
Kis=16.728;

v0=0.1;
states0 = [x0;s0]*1.5;

% Parámetros que van dentro del modelo del sistema
modelParameters.K = [1;-ks];
modelParameters.xi_in = [0;s_in];
modelParameters.ks=ks;

% Defino los parámetros de los modelos cinéticos
modelParameters.mu_model.mu_max=mu_max;
modelParameters.mu_model.Ks=Ks;
modelParameters.mu_model.Kis=Kis;

F=zeros(length(modelParameters.K),1);
Q=zeros(length(modelParameters.K),1);