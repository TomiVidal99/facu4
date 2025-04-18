% Datos dados
ks1=1/0.48;
ks2=1/0.3;
kn=1/8.9;
kp1=0.0657;
s_in=25;
n_in=0;
mu_max=0.46;
Ks=1.2;
Kis=16.728;
Kn=0.254;
Kin=1.5;
qp_max=0.126;
Kps=4.1;
Kips=80;
Kipn=0.262;
n0=100;
p0=0;
s0=50;
x0=1;
v0=1;
D=0;

% Defino los parámetros de los modelos cinéticos
modelParameters.rx_params.max=mu_max;
modelParameters.rx_params.k1=Ks;
modelParameters.rx_params.k2=Kis;
modelParameters.rx_params.k3=Kn;

modelParameters.rp_params.max=qp_max;
modelParameters.rp_params.k1=Kps;
modelParameters.rp_params.k2=Kips;
modelParameters.rp_params.k3=Kipn;

modelParameters.Kipn=Kipn;
modelParameters.K=[1,0;-ks1,-ks2;-kn,0;kp1,1];

F=zeros(length(modelParameters.K),1);
Q=zeros(length(modelParameters.K),1);