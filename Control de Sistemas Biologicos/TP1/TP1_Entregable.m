% TP 1. Ejercicio 3 (Entregable)
% Tomás Vidal 69854/4
% Se modela el proceso PHB:
% - Etapa de crecimiento -> refiere a cuando se incrementa la biomasa.
% - Etapa de producción de plástico -> se emplea la biomasa para producir
% plástico (el producto).
%
% Notas:
% - En la etapa de crecimiento el nitrógeno tiene que estar presente y ser
% suficiente así como lo es el sustrato.
% - En la etapa de producción de plástico no tiene que haber nitrógeno para
% que se dé la producción (es una condición de la bacteria).

%%
clear all; close all; clc;

%% Datos dados del modelo
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
p0=0;
s0=50;
x0=1;
n0=5;
v0=10;
D=0;
F=zeros(4,1);
Q=zeros(4,1);

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

%% Fase de crecimiento - Sin alimentación de sustrato
xi_in=[0,0; s_in,0; 0,n_in; 0,0];
D=zeros(2,1);
xi0=[x0;s0;n0;p0];

simConfig.StopTime = "30";
simConfig.Solver = 'ode1';
simConfig.FixedStep = '0.01';
sim_out = sim('TP1EJ3', simConfig);

i=1;
sim_results{i}.time = sim_out.tout;
sim_results{i}.biomass = reshape(sim_out.x.Data, size(sim_results{i}.time));
sim_results{i}.sustrate = reshape(sim_out.s.Data, size(sim_results{i}.time));
sim_results{i}.nitrogen = reshape(sim_out.n.Data, size(sim_results{i}.time));
sim_results{i}.plastic = reshape(sim_out.p.Data, size(sim_results{i}.time));
sim_results{i}.rx = reshape(sim_out.rx.Data, size(sim_results{i}.time));
sim_results{i}.rp = reshape(sim_out.rp.Data, size(sim_results{i}.time));
sim_results{i}.mu = reshape(sim_out.mu.Data, size(sim_results{i}.time));
sim_results{i}.qp = reshape(sim_out.qp.Data, size(sim_results{i}.time));
sim_results{i}.v = reshape(sim_out.v.Data, size(sim_results{i}.time));

% Se grafica toda la etapa de crecimiento
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Fase de crecimiento');
xlabel('Tiempo [Horas]');
ylabel('Masa [g]');
plot(sim_results{i}.time, sim_results{i}.biomass.*sim_results{i}.v, 'LineWidth', 3);
plot(sim_results{i}.time, sim_results{i}.sustrate.*sim_results{i}.v, 'LineWidth', 3);
plot(sim_results{i}.time, sim_results{i}.nitrogen.*sim_results{i}.v, 'LineWidth', 3);
legend('Biomasa', 'Sustrato', 'Nitrógeno');

saveas(fig, '../Informes/Images_tp1/D0_crecimiento_completo', 'png');

% Se grafica el mu teórico vs el mu simulado
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('\mu_{modelo}(s) vs \mu_{simulado}(s)');
xlabel('sustrato');
ylabel('\mu(s)');
plot(sim_results{i}.sustrate, sim_results{i}.mu, 'LineWidth', 3);
plot(sim_results{i}.sustrate, HaldaneMonodModel(sim_results{i}.sustrate, sim_results{i}.nitrogen, modelParameters.rx_params), 'k--', 'LineWidth', 3);
xline(sqrt(Ks*Kis), 'r', 'LineWidth', 3);
legend('Modelo', 'Simulación', '(K_{s}K_{is})^{1/2}');

saveas(fig, '../Informes/Images_tp1/D0_mus', 'png');

% Se grafica el plano de fase
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Plano de fase');
xlabel('Sustrato [g/g]');
ylabel('Biomasa [g/g]');
plot(sim_results{i}.sustrate, sim_results{i}.biomass, 'LineWidth', 3);

saveas(fig, '../Informes/Images_tp1/D0_plano_fase', 'png');

%% Fase de producción de plástico
n0=0;
sim_out = sim('TP1EJ3', simConfig);
i=2;
sim_results{i}.time = sim_out.tout;
sim_results{i}.biomass = reshape(sim_out.x.Data, size(sim_results{i}.time));
sim_results{i}.sustrate = reshape(sim_out.s.Data, size(sim_results{i}.time));
sim_results{i}.nitrogen = reshape(sim_out.n.Data, size(sim_results{i}.time));
sim_results{i}.plastic = reshape(sim_out.p.Data, size(sim_results{i}.time));
sim_results{i}.rx = reshape(sim_out.rx.Data, size(sim_results{i}.time));
sim_results{i}.rp = reshape(sim_out.rp.Data, size(sim_results{i}.time));
sim_results{i}.mu = reshape(sim_out.mu.Data, size(sim_results{i}.time));
sim_results{i}.qp = reshape(sim_out.qp.Data, size(sim_results{i}.time));
sim_results{i}.v = reshape(sim_out.v.Data, size(sim_results{i}.time));

% Se grafica toda la etapa de crecimiento
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Fase de producción de plástico');
xlabel('Tiempo [Horas]');
ylabel('Masa [g]');
plot(sim_results{i}.time, sim_results{i}.biomass.*sim_results{i}.v, 'LineWidth', 3);
plot(sim_results{i}.time, sim_results{i}.sustrate.*sim_results{i}.v, 'LineWidth', 3);
plot(sim_results{i}.time, sim_results{i}.nitrogen.*sim_results{i}.v, 'LineWidth', 3);
legend('Biomasa', 'Sustrato', 'Nitrógeno');

saveas(fig, '../Informes/Images_tp1/D0_prod_completa', 'png');

% Se grafica el mu teórico vs el mu simulado
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('\mu_{modelo}(s) vs \mu_{simulado}(s)');
xlabel('sustrato');
ylabel('\mu(s)');
plot(sim_results{i}.sustrate, sim_results{i}.mu, 'LineWidth', 3);
plot(sim_results{i}.sustrate, HaldaneMonodModel(sim_results{i}.sustrate, sim_results{i}.nitrogen, modelParameters.rx_params), 'k--', 'LineWidth', 3);
xline(sqrt(Ks*Kis), 'r', 'LineWidth', 3);
legend('Modelo', 'Simulación', '(K_{s}K_{is})^{1/2}');

saveas(fig, '../Informes/Images_tp1/D0_mus', 'png');

% Se grafica el plano de fase
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Plano de fase');
xlabel('Sustrato [g/g]');
ylabel('Biomasa [g/g]');
plot(sim_results{i}.sustrate, sim_results{i}.biomass, 'LineWidth', 3);

saveas(fig, '../Informes/Images_tp1/D0_plano_fase', 'png');

% %% Fase de crecimiento - Sin alimentación de sustrato
% xi_in=[0,0; s_in,0; 0,n_in; 0,0];
% D=[Ds; Dn];
% xi0=[x0;s0;n0;p0];
% 
% simConfig.StopTime = "21";
% simConfig.Solver = 'ode1';
% simConfig.FixedStep = '0.01';
% sim_out = sim('TP1\TP1EJ3', simConfig);
% 
% sim_results{i}.time = sim_out.tout;
% sim_results{i}.biomass = reshape(sim_out.x.Data, size(sim_results{i}.time));
% sim_results{i}.sustrate = reshape(sim_out.s.Data, size(sim_results{i}.time));
% sim_results{i}.nitrogen = reshape(sim_out.n.Data, size(sim_results{i}.time));
% sim_results{i}.plastic = reshape(sim_out.p.Data, size(sim_results{i}.time));
% sim_results{i}.rx = reshape(sim_out.rx.Data, size(sim_results{i}.time));
% sim_results{i}.rp = reshape(sim_out.rp.Data, size(sim_results{i}.time));
% sim_results{i}.v = reshape(sim_out.v.Data, size(sim_results{i}.time));
% sim_results{i}.sim_data = sim_data{i};
% 
% % Se grafica
% figure();
% hold on; grid on;
% title('Fase de crecimiento');
% xlabel('tiempo [Horas]');
% ylabel('Concentraciones [g/g]');
% i=1;
% plot(sim_results{i}.time, sim_results{i}.biomass, 'LineWidth', 3);
% plot(sim_results{i}.time, sim_results{i}.sustrate, 'LineWidth', 3);
% plot(sim_results{i}.time, sim_results{i}.nitrogen, 'LineWidth', 3);
% plot(sim_results{i}.time, sim_results{i}.plastic, 'LineWidth', 3);
% legend('Biomasa', 'Sustrato', 'Nitrógeno', 'Plástico');