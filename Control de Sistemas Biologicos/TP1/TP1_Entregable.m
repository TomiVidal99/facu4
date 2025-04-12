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

sim_hours = 30; % la cantidad de horas que se van a simular

% Configuración de la simulación de Simulink
simConfig.StopTime = num2str(sim_hours);
simConfig.Solver = 'ode1';
simConfig.FixedStep = '0.01';

%% Fase de crecimiento - Sin alimentación de sustrato
n0=5;
p0=0;
s0=50;
x0=1;
D=0;

xi_in=[0,0; s_in,0; 0,n_in; 0,0];
xi0=[x0;s0;n0;p0];

% Ahora se grafica el plano de fase para los diferentes referencias (mur y sr)
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Plano de fase sustrato/plástico alimentación exponencial');
xlabel('Sustrato [g/g]');
ylabel('Biomasa [g/g]');
legends=cell(1, length(references)); legend_counter=1;
for j=1:length(references)
    mur=references{j}(1);
    sr=references{j}(2);
    sim_out = sim('TP1EJ3_2', simConfig);
    i=6+length(DD)+j;
    sim_results{i}.time = sim_out.tout;
    sim_results{i}.biomass = reshape(sim_out.x.Data, size(sim_results{i}.time));
    sim_results{i}.sustrate = reshape(sim_out.s.Data, size(sim_results{i}.time));
    sim_results{i}.nitrogen = reshape(sim_out.n.Data, size(sim_results{i}.time));
    sim_results{i}.plastic = reshape(sim_out.p.Data, size(sim_results{i}.time));
    sim_results{i}.rx = reshape(sim_out.rx.Data, size(sim_results{i}.time));
    sim_results{i}.rp = reshape(sim_out.rp.Data, size(sim_results{i}.time));
    % sim_results{i}.D = reshape(sim_out.D.Data, size(sim_results{i}.time));
    sim_results{i}.v = reshape(sim_out.v.Data, size(sim_results{i}.time));
    
    % Se grafica toda la etapa de crecimiento con alimentación exponencial
    plot(sim_results{i}.sustrate, sim_results{i}.plastic, 'LineWidth', 3);
    legends{1, legend_counter}=sprintf("mur=%.3f, sr=%.3f", mur, sr);
    legend_counter=legend_counter+1;
end
legend(legends)
saveas(fig, '../Informes/Images_tp1/D2_plano_fase_%d', 'png');

% Los estados están representados en términos de concentraciones
% por eso también calculo el volumen, para luego obtener las masas
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
xlabel('sustrato [g/g]');
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
title('Plano de fase sustrato/biomasa');
xlabel('Sustrato [g/g]');
ylabel('Biomasa [g/g]');
plot(sim_results{i}.sustrate, sim_results{i}.biomass, 'LineWidth', 3);

saveas(fig, '../Informes/Images_tp1/D0_plano_fase', 'png');

%% Fase de producción de plástico
% Se remueve el nitrógeno
n0=0;
p0=0;
s0=50;
x0=20;

xi_in=[0,0; s_in,0; 0,n_in; 0,0];
xi0=[x0;s0;n0;p0];

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

% Se grafica toda la etapa de producción de plástico
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title(sprintf('Fase de producción de plástico (n_{0}=0, x_{0}=%d)', round(x0)));
xlabel('Tiempo [Horas]');
ylabel('Masa [g]');
plot(sim_results{i}.time, sim_results{i}.biomass.*sim_results{i}.v, 'LineWidth', 3);
plot(sim_results{i}.time, sim_results{i}.sustrate.*sim_results{i}.v, 'LineWidth', 3);
plot(sim_results{i}.time, sim_results{i}.plastic.*sim_results{i}.v, 'LineWidth', 3);
legend('Biomasa', 'Sustrato', 'Plástico');

saveas(fig, '../Informes/Images_tp1/D0_prod_completa', 'png');

% Se remueve el nitrógeno
n0=0;
p0=0;
s0=50;
x0=1;

xi_in=[0,0; s_in,0; 0,n_in; 0,0];
xi0=[x0;s0;n0;p0];

sim_out = sim('TP1EJ3', simConfig);
i=3;
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
title(sprintf('Fase de producción de plástico (n_{0}=0, x_{0}=%d)', round(x0)));
xlabel('Tiempo [Horas]');
ylabel('Masa [g]');
plot(sim_results{i}.time, sim_results{i}.biomass.*sim_results{i}.v, 'LineWidth', 3);
plot(sim_results{i}.time, sim_results{i}.sustrate.*sim_results{i}.v, 'LineWidth', 3);
plot(sim_results{i}.time, sim_results{i}.plastic.*sim_results{i}.v, 'LineWidth', 3);
legend('Biomasa', 'Sustrato', 'Plástico');

saveas(fig, '../Informes/Images_tp1/D0_prod_completa_min_biomass', 'png');

% Se grafica plano de fase sustrato/plástico
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Plano de fase sustrato/plástico');
xlabel('Sustrato [g/g]');
ylabel('Plástico [g/g]');
plot(sim_results{i}.sustrate, sim_results{i}.plastic, 'LineWidth', 3);

saveas(fig, '../Informes/Images_tp1/D0_plano_fase_plastic', 'png');

%% Fase de crecimiento - Con alimentación de sustrato constante
n0=140;
p0=0;
s0=50;
x0=20;
DD=[0.005, 0.008, 0.01, 0.1, 0.4];
xi_in=[0,0; s_in,0; 0,n_in; 0,0];
xi0=[x0;s0;n0;p0];

% Se simula el crecimiento para varios D
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Fase de crecimiento');
xlabel('Tiempo [Horas]');
ylabel('Masa [g]');
ylim([0 1e3]);
legends=cell(1, length(DD)); legend_counter=1;
for j=1:length(DD)

    D=DD(j);

    sim_out = sim('TP1EJ3', simConfig);
    i=3+j;
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
    plot(sim_results{i}.time, sim_results{i}.biomass.*sim_results{i}.v, 'LineWidth', 3);
    plot(sim_results{i}.time, sim_results{i}.sustrate.*sim_results{i}.v, '--', 'LineWidth', 3);
    legends{1, legend_counter}=sprintf("Biomasa (D=%.2f)", D);
    legends{1, legend_counter+1}=sprintf("Sustrato (D=%.2f)", D);
    legend_counter=legend_counter+2;
    
end
legend(legends);
saveas(fig, '../Informes/Images_tp1/D1_growth_complete', 'png');

%% Se simula el plano de fase para  el crecimiento cuando D=0.1
n0=140;
p0=0;
s0=50;
x0=20;
D=0.1;
xi_in=[0,0; s_in,0; 0,n_in; 0,0];
xi0=[x0;s0;n0;p0];

sim_out = sim('TP1EJ3', simConfig);
i=4+length(DD);
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

% Se grafica el plano de fase con D=0.1
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Plano de fase sustrato/biomasa (D=0.1)');
xlabel('Sustrato [g/g]');
ylabel('Biomasa [g/g]');
plot(sim_results{i}.sustrate, sim_results{i}.biomass, 'LineWidth', 3);

saveas(fig, '../Informes/Images_tp1/D1_plano_fase', 'png');

%% Se simula la fase de producción cuando D=0.1
n0=0;
p0=0;
s0=100;
x0=40;
D=0.01;
xi_in=[0,0; s_in,0; 0,n_in; 0,0];
xi0=[x0;s0;n0;p0];

simConfig.FixedStep = '0.001';
sim_out = sim('TP1EJ3', simConfig);
i=5+length(DD);
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

% Se grafica la fase de producción de plástico con D=0.1
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title(sprintf('Fase de producción de plástico (D=%.3f)', D));
xlabel('Tiempo [horas]');
ylabel('Concentración [g/g]');
plot(sim_results{i}.time, sim_results{i}.sustrate, 'LineWidth', 3);
plot(sim_results{i}.time, sim_results{i}.plastic, 'LineWidth', 3);
legend('Sustrato', 'Plástico');

% Se grafica el plano de fase con D=0.1
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title(sprintf('Plano de fase sustrato/plástico (D=%.3f)', D));
xlabel('Sustrato [g/g]');
ylabel('Biomasa [g/g]');
plot(sim_results{i}.sustrate, sim_results{i}.plastic, 'LineWidth', 3);

saveas(fig, '../Informes/Images_tp1/D1_plano_fase', 'png');

%% Fase de producción - Con alimentación de sustrato exponencial
n0=0;
p0=0;
s0=0;
x0=25;
DD=zeros(1,1);
xi_in=[0,0; s_in,0; 0,n_in; 0,0];
xi0=[x0;s0;n0;p0];

references={[0.103, 4.22], [0.103435, 3.57592]};

simConfig.FixedStep = '0.01';
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Etapa de crecimiento, alimentación exponencial');
xlabel('Tiempo [Horas]');
ylabel('Masa [g]');
ylim([0 100]);
legends=cell(1, length(references)*2); legend_counter=1;
for j=1:length(references)
    mur=references{j}(1);
    sr=references{j}(2);
    sim_out = sim('TP1EJ3_2', simConfig);
    i=6+length(DD)+j;
    sim_results{i}.time = sim_out.tout;
    sim_results{i}.biomass = reshape(sim_out.x.Data, size(sim_results{i}.time));
    sim_results{i}.sustrate = reshape(sim_out.s.Data, size(sim_results{i}.time));
    sim_results{i}.nitrogen = reshape(sim_out.n.Data, size(sim_results{i}.time));
    sim_results{i}.plastic = reshape(sim_out.p.Data, size(sim_results{i}.time));
    sim_results{i}.rx = reshape(sim_out.rx.Data, size(sim_results{i}.time));
    sim_results{i}.rp = reshape(sim_out.rp.Data, size(sim_results{i}.time));
    sim_results{i}.D = reshape(sim_out.D.Data, size(sim_results{i}.time));
    sim_results{i}.v = reshape(sim_out.v.Data, size(sim_results{i}.time));
    
    % Se grafica toda la etapa de crecimiento con alimentación exponencial
    plot(sim_results{i}.time, sim_results{i}.plastic.*sim_results{i}.v, 'LineWidth', 3);
    plot(sim_results{i}.time, sim_results{i}.sustrate.*sim_results{i}.v, '--', 'LineWidth', 3);
   
    legends{1, legend_counter}=sprintf("Plástico (mur=%.3f, sr=%.3f)", mur, sr);
    legends{1, legend_counter+1}=sprintf("Sustrato (mur=%.3f, sr=%.3f)", mur, sr);
    legend_counter=legend_counter+2;
end
legend(legends);
saveas(fig, '../Informes/Images_tp1/D2_mur_%d', 'png');

% Se grafica la dilución 'D' para cada mu
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Dilución exponencial');
xlabel('Tiempo [Horas]');
ylabel('Masa [g]');
% ylim([0 1]);
legends=cell(1, length(references)); legend_counter=1;
for j=1:length(references)
    mur=references{j}(1);
    sr=references{j}(2);
    plot(sim_results{i}.time, sim_results{i}.D, 'LineWidth', 3);
    legends{1, legend_counter}=sprintf("Dilución (mur=%.3f, sr=%.3f)", mur, sr);
    legend_counter=legend_counter+1;
end
legend(legends);
saveas(fig, '../Informes/Images_tp1/D2_Ds', 'png');

% Ahora se grafica el plano de fase para los diferentes referencias (mur y sr)
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Plano de fase sustrato/plástico alimentación exponencial');
xlabel('Sustrato [g/g]');
ylabel('Biomasa [g/g]');
legends=cell(1, length(references)); legend_counter=1;
for j=1:length(references)
    mur=references{j}(1);
    sr=references{j}(2);
    sim_out = sim('TP1EJ3_2', simConfig);
    i=6+length(DD)+j;
    sim_results{i}.time = sim_out.tout;
    sim_results{i}.biomass = reshape(sim_out.x.Data, size(sim_results{i}.time));
    sim_results{i}.sustrate = reshape(sim_out.s.Data, size(sim_results{i}.time));
    sim_results{i}.nitrogen = reshape(sim_out.n.Data, size(sim_results{i}.time));
    sim_results{i}.plastic = reshape(sim_out.p.Data, size(sim_results{i}.time));
    sim_results{i}.rx = reshape(sim_out.rx.Data, size(sim_results{i}.time));
    sim_results{i}.rp = reshape(sim_out.rp.Data, size(sim_results{i}.time));
    % sim_results{i}.D = reshape(sim_out.D.Data, size(sim_results{i}.time));
    sim_results{i}.v = reshape(sim_out.v.Data, size(sim_results{i}.time));
    
    % Se grafica toda la etapa de crecimiento con alimentación exponencial
    plot(sim_results{i}.sustrate, sim_results{i}.plastic, 'LineWidth', 3);
    legends{1, legend_counter}=sprintf("mur=%.3f, sr=%.3f", mur, sr);
    legend_counter=legend_counter+1;
end
legend(legends)
saveas(fig, '../Informes/Images_tp1/D2_plano_fase_%d', 'png');