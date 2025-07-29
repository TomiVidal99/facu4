% TP 3 (Entregable)
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
%
% IMPORTANTE:
% Si se corre por sección, correr al menos una vez todo secuencialmente.
% Así se asegura de que todas las variables han sido definidas previamente.
%
% También se espera que todos los archivos del proyecto estén en la misma
% carpeta (directorio)

%% Carga de datos de simulación
DatosModeloTP4

sim_hours = 50; % la cantidad de horas que se van a simular
timeStep = 1e-2;

% Configuración de la simulación de Simulink
simConfig.StopTime = num2str(sim_hours);
simConfig.Solver = 'ode1';
simConfig.FixedStep = num2str(timeStep);

% Si se quieren generar los gráficos
% si se quieren gráficos -> 1
% no, no se quieren -> 0
shouldSavePlot = 1;

%% Proceso sin ningún controlador (respuesta del sistema)
% Solo para ver lo que está pasando con el sistema,
% antes de empezar a controlar nada
DatosModeloTP4

D=0.1;
params={1};
for i=1:length(params)

    sim_out = sim('simulaciones/TP4_sin_control', simConfig);
    
    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass = reshape(states(:,1), size(time));
    sustrate = reshape(states(:,2), size(time));
    mu = sim_out.mu_s.Data;
    
end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Proceso de producción de plástico PHB');
xlabel('Tiempo [Horas]');
ylabel('Masa [g]');
plot(time, biomass.*volume, 'r', 'LineWidth', 2);
plot(time, sustrate.*volume, 'b', 'LineWidth', 2);
legend('Biomasa', 'Sustrato');
savePlot(shouldSavePlot, fig, 'sin_control')

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Sin control \mu(s)');
xlabel('Tiempo [Horas]');
ylabel('\mu(s)');
plot(time, mu, 'k', 'LineWidth', 2);
savePlot(shouldSavePlot, fig, 'sin_control_mu')

%% Control con alimentación exponencial
% Se alimenta de sustrato de manera exponencial
% Pero para implementarlo, ya que se tenía el control con
% dilución (además así funciona en el vida real) lo que se
% hace es dividir por el volumen
%   El punto de referencia elegido es el que corresponde
% al que se quiere en mu y el sustrato que origina el mismo
% en su modelo dinámico

DatosModeloTP4

sim_hours = 50;
simConfig.StopTime = num2str(sim_hours);

s_r=0.27; % s de referencia a operar
mu_r=0.0845; % mu de referencia a operar

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.v0=v0;
modelParameters.s_r = 0.126;
modelParameters.mu_r=mu_r;

params={[s_r, mu_r]};
mus=cell(length(params));
sustrates=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)

    modelParameters.s_r = params{i}(1);
    modelParameters.mu_r=params{i}(2);

    % fprintf('Sr=%.3f,mur=%.3f\n', params{i}(1),params{i}(2));

    sim_out = sim('simulaciones/TP4_control_exp', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass = reshape(states(:,1), size(time));
    sustrates{i} = reshape(states(:,2), size(time)).*volume;
    Do = sim_out.Do.Data;
    mus{i} = sim_out.mu_s.Data;

    mu_r_vector = ones(1, length(mus{i}))*mu_r;
 
    error{i}=(mu_r_vector-mus{i});
    MSE{i} = immse(reshape(mu_r_vector, size(mus{i})), mus{i});
end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('\mu(s) (Control con alimentación exponencial)');
xlabel('Tiempo [Horas]');
ylabel('\mu(s)');
plot(time, mu_r_vector, 'k--', 'LineWidth', 2);
plot(time, mus{1}, 'LineWidth', 2);

legend('Referencia', sprintf('Sr=%.3f,mur=%.3f', params{1}(1),params{1}(2)));
savePlot(shouldSavePlot, fig, 'exp')

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo del \mu(s)');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), mu_r_vector), 'LineWidth', 3);

legend(sprintf('(Sr=%.3f,mur=%.3f) (MSE=%.4f)', MSE{1}, params{1}(1), params{1}(2)));
savePlot(shouldSavePlot, fig, 'exp_err')


%% Alimentación exponencial: variación en el parámetro x0 en 20%

% DatosModeloTP4
% 
% modelParameters.s_in=s_in;
% modelParameters.x0=x0;
% modelParameters.s_r = 0.1259;
% modelParameters.v0=v0;
% modelParameters.mu_r=mu_r;
% 
% params={x0*(1.2),x0*(0.8)}; % más/menos 20% del x0
% mus=cell(length(params));
% error=cell(length(params));
% MSE=cell(length(params));
% for i=1:length(params)
% 
%     modelParameters.x0=params{i};
% 
%     sim_out = sim('simulaciones/TP4_control_exp', simConfig);
% 
%     time = sim_out.tout;
%     volume = sim_out.volume.Data;
%     states = sim_out.states.Data;
%     biomass = reshape(states(:,1), size(time));
%     sustrates = reshape(states(:,2), size(time)).*volume;
%     Do = sim_out.Do.Data;
%     mus{i} = sim_out.mu_s.Data;
% 
%     mu_r_vector = ones(1, length(mus{i}))*mu_r;
% 
%     error{i}=(mu_r_vector-mus{i});
%     MSE{i} = immse(reshape(mu_r_vector, size(mus{i})), mus{i});
% end
% 
% fig = figure();
% set(fig,'Position',[0 0 800 600]);
% hold on; grid on;
% title('\mu(s) (Alimentación exponencial) (x0±20%)');
% xlabel('Tiempo [Horas]');
% ylabel('\mu(s)');
% plot(time, mu_r_vector, 'k--', 'LineWidth', 2);
% plot(time, mus{1}, 'LineWidth', 2);
% plot(time, mus{2}, 'LineWidth', 2);
% 
% legend('Referencia' ...
%     ,sprintf('x0=%.1f', params{1}), ...
%     sprintf('x0=%.1f', params{2}));
% savePlot(shouldSavePlot, fig, 'exp_x0')
% 
% fig = figure();
% set(fig,'Position',[0 0 800 600]);
% hold on; grid on;
% title('Error relativo del \mu(s) (x0±20%)');
% xlabel('Tiempo [Horas]');
% ylabel('Error relativo [%]');
% ylim([0 100])
% plot(time, getRelativeError(abs(error{1}), mu_r_vector), 'LineWidth', 3);
% plot(time, getRelativeError(abs(error{2}), mu_r_vector), 'LineWidth', 3);
% 
% legend(sprintf('x0=%.1f (MSE=%.4f)', params{1}, MSE{1}), ...
%     sprintf('x0=%.1f (MSE=%.4f)', params{2}, MSE{2}));
% savePlot(shouldSavePlot, fig, 'exp_err_x0')

%% Alimentación exponencial: variación en el parámetro ks1 en 20%

DatosModeloTP4

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.v0=v0;
modelParameters.s_r = 0.1259;
modelParameters.mu_r=mu_r;

params_ks={ks1*(1.2),ks1*(0.8)}; % más/menos 20% del ks1
mus_ks=cell(length(params_ks));
error_ks=cell(length(params_ks));
MSE_ks=cell(length(params_ks));
for i=1:length(params_ks)
    modelParameters.K = [1;-params_ks{i}];

    sim_out = sim('simulaciones/TP4_control_exp', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass = reshape(states(:,1), size(time));
    sustrate_ks = reshape(states(:,2), size(time)).*volume;
    Do = sim_out.Do.Data;
    mus_ks{i} = sim_out.mu_s.Data;

    mu_r_vector = ones(1, length(mus_ks{i}))*mu_r;
 
    error_ks{i}=(mu_r_vector-mus_ks{i});
    MSE_ks{i} = immse(reshape(mu_r_vector, size(mus_ks{i})), mus_ks{i});
end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('\mu(s) (Alimentación exponencial)(ks1±20%)');
xlabel('Tiempo [Horas]');
ylabel('\mu(s)');
plot(time, mu_r_vector, 'k--', 'LineWidth', 2);
plot(time, mus_ks{1}, 'LineWidth', 2);
plot(time, mus_ks{2}, 'LineWidth', 2);

legend('Referencia' ...
    ,sprintf('ks1=%.1f', params_ks{1}), ...
    sprintf('ks1=%.1f', params_ks{2}));
savePlot(shouldSavePlot, fig, 'exp_ks1')

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo del \mu(s) (ks1±20%)');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error_ks{1}), mu_r_vector), 'LineWidth', 3);
plot(time, getRelativeError(abs(error_ks{2}), mu_r_vector), 'LineWidth', 3);

legend(sprintf('ks1=%.1f (MSE=%.4f)', params_ks{1}, MSE_ks{1}), ...
    sprintf('ks1=%.1f (MSE=%.4f)', params_ks{2}, MSE_ks{2}));
savePlot(shouldSavePlot, fig, 'exp_err_ks1')


%% Control exponencial con términos kp
% Se agrega al control exponencial un término que es proporcional
% al error, es decir mur-mu
% Se prueban diferentes ganancias de kp

DatosModeloTP4

sim_hours2 = 40;
timeStep2 = 1e-2;
simConfig.StopTime = num2str(sim_hours2);
simConfig.FixedStep = num2str(timeStep2);

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.s_r = 0.1259;
modelParameters.mu_r=mu_r;
% modelParameters.kp=0.1; % factor proporcional

params={1,2,3,4};
mus=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)
    modelParameters.kp=params{i};

    sim_out = sim('simulaciones/TP4_control_kp', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass = reshape(states(:,1), size(time));
    sustrate = reshape(states(:,2), size(time)).*volume;
    Do = sim_out.Do.Data;
    mus{i} = sim_out.mu_s.Data;

    mu_r_vector = ones(1, length(mus{i}))*mu_r;
    
    error{i}=(mu_r_vector-mus{i});
    MSE{i} = immse(reshape(mu_r_vector, size(mus{i})), mus{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('\mu(s) (Control exponencial con ganancia Kp)');
xlabel('Tiempo [Horas]');
ylabel('\mu(s)');
plot(time, mu_r_vector, 'k--', 'LineWidth', 2);
plot(time, mus{1}, 'LineWidth', 2);
plot(time, mus{2}, 'LineWidth', 2);
plot(time, mus{3}, 'LineWidth', 2);
plot(time, mus{4}, 'LineWidth', 2);

legend('Referencia' ...
    ,sprintf('kp=%.1f', params{1}), ...
    sprintf('kp=%.1f', params{2}), ...
    sprintf('kp=%.1f', params{3}), ...
    sprintf('kp=%.1f', params{4}));
savePlot(shouldSavePlot, fig, 'exp_kp')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo del \mu(s)');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 200])
plot(time, getRelativeError(abs(error{1}), mu_r_vector), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{2}), mu_r_vector), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{3}), mu_r_vector), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{4}), mu_r_vector), 'LineWidth', 3);

legend(sprintf('kp=%.1f (MSE=%.4f)', params{1}, MSE{1}), ...
    sprintf('kp=%.1f (MSE=%.4f)', params{2}, MSE{2}), ...
    sprintf('kp=%.1f (MSE=%.4f)', params{3}, MSE{3}), ...
    sprintf('kp=%.1f (MSE=%.4f)', params{4}, MSE{4}));
savePlot(shouldSavePlot, fig, 'exp_err_kp')

%% Control exponencial con términos  kp y ki
% Ahora también se agrega otro término que es integrativo del error
% Se prueban diferentes ganancias de ki

DatosModeloTP4

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.s_r = 0.1259;
modelParameters.mu_r=mu_r;
modelParameters.kp=30; % factor proporcional
% modelParameters.ki=0.1; % factor integrativa
e0=mu_r*1.5;

params={10, 15, 20, 30};
mus=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)
    modelParameters.ki=params{i};

    sim_out = sim('simulaciones/TP4_control_int', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass = reshape(states(:,1), size(time));
    sustrate = reshape(states(:,2), size(time)).*volume;
    Do = sim_out.Do.Data;
    mus{i} = sim_out.mu_s.Data;

    mu_r_vector = ones(1, length(mus{i}))*mu_r;
    
    error{i}=(mu_r_vector-mus{i});
    MSE{i} = immse(reshape(mu_r_vector, size(mus{i})), mus{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('\mu(s)  (Control exponencial con integrador)');
xlabel('Tiempo [Horas]');
ylabel('\mu(s)');
plot(time, mu_r_vector, 'k--', 'LineWidth', 2);
plot(time, mus{1}, 'LineWidth', 2);
plot(time, mus{2}, 'LineWidth', 2);
plot(time, mus{3}, 'LineWidth', 2);
plot(time, mus{4}, 'LineWidth', 2);

legend('Referencia' ...
    ,sprintf('ki=%.1f', params{1}), ...
    sprintf('ki=%.1f', params{2}), ...
    sprintf('ki=%.1f', params{3}), ...
    sprintf('ki=%.1f', params{4}));
savePlot(shouldSavePlot, fig, 'exp_ki')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo del \mu(s)');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), mu_r_vector), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{2}), mu_r_vector), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{3}), mu_r_vector), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{4}), mu_r_vector), 'LineWidth', 3);

legend(sprintf('ki=%.1f (MSE=%.4f)', params{1}, MSE{1}), ...
    sprintf('ki=%.1f (MSE=%.4f)', params{2}, MSE{2}), ...
    sprintf('ki=%.1f (MSE=%.4f)', params{3}, MSE{3}), ...
    sprintf('ki=%.1f (MSE=%.4f)', params{4}, MSE{4}));
savePlot(shouldSavePlot, fig, 'exp_err_ki')

%% Alimentación exponencial: robustez (x0), sólo para kp+ki
% Se verifica el robustez haciendo una variación del parámetros x0
% 
% DatosModeloTP4
% 
% modelParameters.s_in=s_in;
% modelParameters.x0=x0;
% modelParameters.s_r = 0.1259;
% modelParameters.mu_r=mu_r;
% modelParameters.kp=30; % factor proporcional
% modelParameters.ki=30; % factor integrativo
% e0=mu_r*1.5;
% 
% params_x0={x0*(1.2),x0*(0.8)}; % más/menos 20% del x0
% mus=cell(length(params_x0));
% error=cell(length(params_x0));
% MSE=cell(length(params_x0));
% for i=1:length(params_x0)
%     modelParameters.x0=params_x0{i};
% 
%     sim_out = sim('simulaciones/TP4_control_int', simConfig);
% 
%     time = sim_out.tout;
%     volume = sim_out.volume.Data;
%     states = sim_out.states.Data;
%     biomass = reshape(states(:,1), size(time));
%     sustrate = reshape(states(:,2), size(time)).*volume;
%     Do = sim_out.Do.Data;
%     mus{i} = sim_out.mu_s.Data;
% 
%     mu_r_vector = ones(1, length(mus{i}))*mu_r;
% 
%     error{i}=(mu_r_vector-mus{i});
%     MSE{i} = immse(reshape(mu_r_vector, size(mus{i})), mus{i});
% 
% end
% 
% fig = figure();
% set(fig,'Position',[0 0 800 600]);
% hold on; grid on;
% title('\mu(s) (Control exponencial con integrador) (x0±20%)');
% xlabel('Tiempo [Horas]');
% ylabel('\mu(s)');
% plot(time, mu_r_vector, 'k--', 'LineWidth', 2);
% plot(time, mus{1}, 'LineWidth', 2);
% plot(time, mus{2}, 'LineWidth', 2);
% 
% legend('Referencia' ...
%     ,sprintf('x0=%.1f', params_x0{1}), ...
%     sprintf('x0=%.1f', params_x0{2}));
% savePlot(shouldSavePlot, fig, 'exp_rob_x0')
% 
% 
% % Error relativo
% fig = figure();
% set(fig,'Position',[0 0 800 600]);
% hold on; grid on;
% title('Error relativo del \mu(s) (x0±20%)');
% xlabel('Tiempo [Horas]');
% ylabel('Error relativo [%]');
% ylim([0 100])
% plot(time, getRelativeError(abs(error{1}), mu_r_vector), 'LineWidth', 3);
% plot(time, getRelativeError(abs(error{2}), mu_r_vector), 'LineWidth', 3);
% 
% legend(sprintf('x0=%.1f (MSE=%.4f)', params_x0{1}, MSE{1}), ...
%     sprintf('x0=%.1f (MSE=%.4f)', params_x0{2}, MSE{2}));
% savePlot(shouldSavePlot, fig, 'exp_rob_err_x0')


%% Alimentación exponencial: robustez (ks1), sólo para kp+ki
% Se verifica el robustez haciendo una variación del parámetros ks1

DatosModeloTP4

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.s_r = 0.1259;
modelParameters.mu_r=mu_r;
modelParameters.kp=30; % factor proporcional
modelParameters.ki=30; % factor integrativo
e0=mu_r*1.5;

params={ks1*(0.8), ks1*(1.2)};
mus=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)
    modelParameters.ks1=params{i};

    sim_out = sim('simulaciones/TP4_control_int', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass = reshape(states(:,1), size(time));
    sustrate = reshape(states(:,2), size(time)).*volume;
    Do = sim_out.Do.Data;
    mus{i} = sim_out.mu_s.Data;

    mu_r_vector = ones(1, length(mus{i}))*mu_r;
    
    error{i}=(mu_r_vector-mus{i});
    MSE{i} = immse(reshape(mu_r_vector, size(mus{i})), mus{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('\mu(s) (ks1±20%)');
xlabel('Tiempo [Horas]');
ylabel('\mu(s)');
plot(time, mu_r_vector, 'k--', 'LineWidth', 2);
plot(time, mus{1}, 'LineWidth', 2);
plot(time, mus{2}, 'LineWidth', 2);

legend('Referencia' ...
    ,sprintf('ks1=%.1f', params{1}), ...
    sprintf('ks1=%.1f', params{2}));
savePlot(shouldSavePlot, fig, 'exp_rob_ks1')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo del \mu(s) (ks1±20%)');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), mu_r_vector), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{2}), mu_r_vector), 'LineWidth', 3);

legend(sprintf('ks1=%.1f (MSE=%.4f)', params{1}, MSE{1}), ...
    sprintf('ks1=%.1f (MSE=%.4f)', params{2}, MSE{2}));
savePlot(shouldSavePlot, fig, 'exp_rob_err_ks1')

%% Alimentación exponencial: robustez
% Se hace una prueba de performance con una variación del 20%
% en la acción de control (D)

DatosModeloTP4

% Parámetros de la perturbación
disturbanceParameters.start = 20;
disturbanceParameters.end = 30;
disturbanceParameters.percentage = 0.2;

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.s_r = 0.1259;
modelParameters.mu_r=mu_r;
modelParameters.kp=30; % factor proporcional
modelParameters.ki=30; % factor integrativo
modelParameters.ks1=ks1;
e0=mu_r*1.5;

params={0};
mus=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)
    % modelParameters.ks1=params{i};

    sim_out = sim('simulaciones/TP4_control_int_rech', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass = reshape(states(:,1), size(time));
    sustrate = reshape(states(:,2), size(time)).*volume;
    Do = sim_out.Do.Data;
    mus{i} = sim_out.mu_s.Data;
    disturbance = sim_out.disturbance.Data;

    mu_r_vector = ones(1, length(mus{i}))*mu_r;
    
    error{i}=(mu_r_vector-mus{i});
    MSE{i} = immse(reshape(mu_r_vector, size(mus{i})), mus{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Rechazo a perturbaciones \mu(s)');
xlabel('Tiempo [Horas]');
ylabel('\mu(s)');
plot(time, mu_r_vector, 'k--', 'LineWidth', 2);
plot(time, mus{1}, 'LineWidth', 2);
plot(time, (disturbance/disturbanceParameters.percentage)*max(mus{1}), '--', 'LineWidth', 1);

legend('Referencia', 'mu', 'Perturbacion');
savePlot(shouldSavePlot, fig, 'exp_rech')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo del \mu(s)');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), mu_r_vector), 'LineWidth', 3);

legend(sprintf('(MSE=%.4f)', MSE{1}));
savePlot(shouldSavePlot, fig, 'exp_rech_err')

%% Control linealizante
% Se diseña un control que elimina la dinámica del sustrato

DatosModeloTP4

% referencia del sustrato (s*)
s_r=0.15; 

modelParameters.s_in=s_in;
modelParameters.s_r = s_r;
modelParameters.mu_r=mu_r;

params={1};
sustrates=cell(length(params));
biomass=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)

    sim_out = sim('simulaciones/TP4_control_linealizante', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass{i} = reshape(states(:,1), size(time));
    sustrates{i} = reshape(states(:,2), size(time));
    Do = sim_out.Do.Data;
    mu = sim_out.mu_s.Data;

    sustrate_vector_r = ones(length(sustrates{i}), 1)*s_r;
    
    error{i}=(sustrate_vector_r-sustrates{i});
    MSE{i} = immse(reshape(sustrate_vector_r, size(sustrates{i})), sustrates{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Control linealizante del sustrato');
xlabel('Tiempo [Horas]');
ylabel('Concentración [g/g]');
plot(time, sustrate_vector_r, 'k--', 'LineWidth', 2);
plot(time, sustrates{1}, 'LineWidth', 2);

legend('Referencia', 'Sustrato');
savePlot(shouldSavePlot, fig, 'lin')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
% ylim([0 100])
plot(time, getRelativeError(abs(error{1}), sustrate_vector_r), 'LineWidth', 3);

legend(sprintf('(MSE=%.4f)', params{1}, MSE{1}));
savePlot(shouldSavePlot, fig, 'lin_err')

%% Control linealizante: variaciones en ks1
% Se varía ks1 para el control linealizante

DatosModeloTP4

% referencia del sustrato (s*)
s_r=0.15; 

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.s_r = s_r;
modelParameters.mu_r=mu_r;

params={ks1*(0.8), ks1*(1.2)};
sustrates=cell(length(params));
biomass=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)
    modelParameters.ks1 = params{i};

    sim_out = sim('simulaciones/TP4_control_linealizante', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass{i} = reshape(states(:,1), size(time));
    sustrates{i} = reshape(states(:,2), size(time));
    Do = sim_out.Do.Data;
    mu = sim_out.mu_s.Data;

    sustrate_vector_r = ones(length(sustrates{i}), 1)*s_r;
    
    error{i}=(sustrate_vector_r-sustrates{i});
    MSE{i} = immse(reshape(sustrate_vector_r, size(sustrates{i})), sustrates{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Control linealizante del sustrato (ks1±20%)');
xlabel('Tiempo [Horas]');
ylabel('Concentración [g/g]');
plot(time, sustrate_vector_r, 'k--', 'LineWidth', 2);
plot(time, sustrates{1}, 'LineWidth', 2);
plot(time, sustrates{2}, 'LineWidth', 2);

legend('Referencia', ...
    sprintf('ks1=%.3f', params{1}), ...
    sprintf('ks1=%.3f', params{2}));
savePlot(shouldSavePlot, fig, 'lin_ks1')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo (ks1±20%)');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), sustrate_vector_r), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{2}), sustrate_vector_r), 'LineWidth', 3);

legend(sprintf('ks1=%.2f (MSE=%.4f)', params{1}, MSE{1}), ...
    sprintf('ks1=%.2f (MSE=%.4f)', params{2}, MSE{2}));
savePlot(shouldSavePlot, fig, 'lin_err_ks1')

%% Control linealizante: kp
% Al control linealizante se le agrega un término que es proporcional
% al error (sr-s)

DatosModeloTP4

% referencia del sustrato (s*)
s_r=0.15; 

modelParameters.s_in=s_in;
modelParameters.s_r = s_r;
modelParameters.mu_r=mu_r;

params={1, 5, 10};
sustrates=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)
    modelParameters.kp=params{i};

    sim_out = sim('simulaciones/TP4_control_linealizante_kp', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass = reshape(states(:,1), size(time));
    sustrates{i} = reshape(states(:,2), size(time));
    Do = sim_out.Do.Data;
    mu = sim_out.mu_s.Data;

    sustrate_vector_r = ones(length(sustrates{i}), 1)*s_r;
    
    error{i}=(sustrate_vector_r-sustrates{i});
    MSE{i} = immse(reshape(sustrate_vector_r, size(sustrates{i})), sustrates{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Control linealizante del sustrato (kp)');
xlabel('Tiempo [Horas]');
ylabel('Concentración [g/g]');
plot(time, sustrate_vector_r, 'k--', 'LineWidth', 2);
plot(time, sustrates{1}, 'LineWidth', 2);
plot(time, sustrates{2}, 'LineWidth', 2);
plot(time, sustrates{3}, 'LineWidth', 2);

legend('Referencia', ...
    sprintf('Kp=%.1f', params{1}), ...
    sprintf('Kp=%.1f', params{2}), ...
    sprintf('Kp=%.1f', params{3}));
savePlot(shouldSavePlot, fig, 'lin_kp')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), sustrate_vector_r), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{2}), sustrate_vector_r), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{3}), sustrate_vector_r), 'LineWidth', 3);

legend(sprintf('Ki=%.1f (MSE=%.4f)', params{1}, MSE{1}), ...
    sprintf('Ki=%.1f (MSE=%.4f)', params{2}, MSE{2}),...
    sprintf('Ki=%.1f (MSE=%.4f)', params{3}, MSE{3}));
savePlot(shouldSavePlot, fig, 'lin_kp_err')

%% Control linealizante: kp, variaciones en ks1
% Se varía ks1 para el control linealizante con ganancia kp

DatosModeloTP4

% referencia del sustrato (s*)
s_r=0.15; 

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.s_r = s_r;
modelParameters.mu_r=mu_r;

params={ks1*(0.8), ks1*(1.2)};
sustrates=cell(length(params));
biomass=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)
    modelParameters.ks1 = params{i};

    sim_out = sim('simulaciones/TP4_control_linealizante_kp', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass{i} = reshape(states(:,1), size(time));
    sustrates{i} = reshape(states(:,2), size(time));
    Do = sim_out.Do.Data;
    mu = sim_out.mu_s.Data;

    sustrate_vector_r = ones(length(sustrates{i}), 1)*s_r;
    
    error{i}=(sustrate_vector_r-sustrates{i});
    MSE{i} = immse(reshape(sustrate_vector_r, size(sustrates{i})), sustrates{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Control linealizante (kp) del sustrato (ks1±20%)');
xlabel('Tiempo [Horas]');
ylabel('Concentración [g/g]');
plot(time, sustrate_vector_r, 'k--', 'LineWidth', 2);
plot(time, sustrates{1}, 'LineWidth', 2);
plot(time, sustrates{2}, 'LineWidth', 2);

legend('Referencia', ...
    sprintf('ks1=%.3f', params{1}), ...
    sprintf('ks1=%.3f', params{2}));
savePlot(shouldSavePlot, fig, 'lin_kp_ks1')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo (ks1±20%)');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), sustrate_vector_r), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{2}), sustrate_vector_r), 'LineWidth', 3);

legend(sprintf('ks1=%.2f (MSE=%.4f)', params{1}, MSE{1}), ...
    sprintf('ks1=%.2f (MSE=%.4f)', params{2}, MSE{2}));
savePlot(shouldSavePlot, fig, 'lin_kp_err_ks1')

%% Control linealizante: kp+ki
% Ahora se prueba un control proporcional integrativo del error
% y se varía ks1

DatosModeloTP4

% referencia del sustrato (s*)
s_r=0.15; 

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.s_r = s_r;
modelParameters.mu_r=mu_r;
modelParameters.kp=30; % factor proporcional
modelParameters.ki=30;
e0=1.5*s_r;

params={ks1*(0.8), ks1*(1.2)};
sustrates=cell(length(params));
biomass=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)
    modelParameters.ks1 = params{i};

    sim_out = sim('simulaciones/TP4_control_linealizante_ki', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass{i} = reshape(states(:,1), size(time));
    sustrates{i} = reshape(states(:,2), size(time));
    Do = sim_out.Do.Data;
    mu = sim_out.mu_s.Data;

    sustrate_vector_r = ones(length(sustrates{i}), 1)*s_r;
    
    error{i}=(sustrate_vector_r-sustrates{i});
    MSE{i} = immse(reshape(sustrate_vector_r, size(sustrates{i})), sustrates{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Control linealizante (kp y ki) del sustrato (ks1±20%)');
xlabel('Tiempo [Horas]');
ylabel('Concentración [g/g]');
plot(time, sustrate_vector_r, 'k--', 'LineWidth', 2);
plot(time, sustrates{1}, 'LineWidth', 2);
plot(time, sustrates{2}, 'LineWidth', 2);

legend('Referencia', ...
    sprintf('ks1=%.3f', params{1}), ...
    sprintf('ks1=%.3f', params{2}));
savePlot(shouldSavePlot, fig, 'lin_ki')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo (ks1±20%)');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), sustrate_vector_r), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{2}), sustrate_vector_r), 'LineWidth', 3);

legend(sprintf('ks1=%.2f (MSE=%.4f)', params{1}, MSE{1}), ...
    sprintf('ks1=%.2f (MSE=%.4f)', params{2}, MSE{2}));
savePlot(shouldSavePlot, fig, 'lin_ki_err')

%% Control adaptivo
% Se implementa un control adaptivo considerando
% como que no se conoce mu(s)

DatosModeloTP4

mu_est0=1.5*mu_r;

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.s_r = s_r;
modelParameters.mu_r=mu_r;

params={1, 2, 3};
sustrates=cell(length(params));
biomass=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)
    modelParameters.gamma1 = params{i};

    sim_out = sim('simulaciones/TP4_control_adaptivo', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass{i} = reshape(states(:,1), size(time));
    sustrates{i} = reshape(states(:,2), size(time));
    Do = sim_out.Do.Data;
    mu = sim_out.mu_s.Data;

    sustrate_vector_r = ones(length(sustrates{i}), 1)*s_r;
    
    error{i}=(sustrate_vector_r-sustrates{i});
    MSE{i} = immse(reshape(sustrate_vector_r, size(sustrates{i})), sustrates{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Control adaptivo');
xlabel('Tiempo [Horas]');
ylabel('Concentración [g/g]');
plot(time, sustrate_vector_r, 'k--', 'LineWidth', 2);
plot(time, sustrates{1}, 'LineWidth', 2);
plot(time, sustrates{2}, 'LineWidth', 2);
plot(time, sustrates{3}, 'LineWidth', 2);

legend('Referencia', ...
    sprintf('Sutrato (gamma1=%.2f)', params{1}), ...
    sprintf('Sutrato (gamma1=%.2f)', params{2}), ...
    sprintf('Sutrato (gamma1=%.2f)', params{3}));
savePlot(shouldSavePlot, fig, 'ad')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo control adaptivo');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), sustrate_vector_r), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{2}), sustrate_vector_r), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{3}), sustrate_vector_r), 'LineWidth', 3);

legend(sprintf('gamma1=%.2f (MSE=%.4f)', params{1}, MSE{1}), ...
    sprintf('gamma1=%.2f (MSE=%.4f)', params{2}, MSE{2}),...
    sprintf('gamma1=%.2f (MSE=%.4f)', params{3}, MSE{3}));
savePlot(shouldSavePlot, fig, 'ad_err')

%% Adaptivo: variaciones de ks1

DatosModeloTP4

mu_est0=1.5*mu_r;

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.s_r = s_r;
modelParameters.mu_r=mu_r;
modelParameters.gamma1=2;

params={ks1*0.8, ks1*1.2};
sustrates=cell(length(params));
biomass=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)
    modelParameters.ks1 = params{i};

    sim_out = sim('simulaciones/TP4_control_adaptivo', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass{i} = reshape(states(:,1), size(time));
    sustrates{i} = reshape(states(:,2), size(time));
    Do = sim_out.Do.Data;
    mu = sim_out.mu_s.Data;

    sustrate_vector_r = ones(length(sustrates{i}), 1)*s_r;
    
    error{i}=(sustrate_vector_r-sustrates{i});
    MSE{i} = immse(reshape(sustrate_vector_r, size(sustrates{i})), sustrates{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Control adaptivo');
xlabel('Tiempo [Horas]');
ylabel('Concentración [g/g]');
plot(time, sustrate_vector_r, 'k--', 'LineWidth', 2);
plot(time, sustrates{1}, 'LineWidth', 2);
plot(time, sustrates{2}, 'LineWidth', 2);

legend('Referencia', ...
    sprintf('Sutrato (ks1=%.3f)', params{1}), ...
    sprintf('Sutrato (ks1=%.3f)', params{2}));
savePlot(shouldSavePlot, fig, 'ad_ks1')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo control adaptivo');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), sustrate_vector_r), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{2}), sustrate_vector_r), 'LineWidth', 3);

legend(sprintf('ks1=%.3f (MSE=%.4f)', params{1}, MSE{1}), ...
    sprintf('ks1=%.3f (MSE=%.4f)', params{2}, MSE{2}));
savePlot(shouldSavePlot, fig, 'ad_err_ks1')

%% Adpativo: Robustez
% Se varía el D en un 20% para ver que tan buen performance tiene

DatosModeloTP4

mu_est0=1.5*mu_r;

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.s_r = s_r;
modelParameters.mu_r=mu_r;

% Parámetros de la perturbación
disturbanceParameters.start = 20;
disturbanceParameters.end = 30;
disturbanceParameters.percentage = 0.2;

params={0};
sustrates=cell(length(params));
biomass=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)

    sim_out = sim('simulaciones/TP4_control_adaptivo_perturbanciones', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass{i} = reshape(states(:,1), size(time));
    sustrates{i} = reshape(states(:,2), size(time));
    Do = sim_out.Do.Data;
    mu = sim_out.mu_s.Data;
    disturbance = sim_out.disturbance.Data;

    sustrate_vector_r = ones(length(sustrates{i}), 1)*s_r;
    
    error{i}=(sustrate_vector_r-sustrates{i});
    MSE{i} = immse(reshape(sustrate_vector_r, size(sustrates{i})), sustrates{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Control adaptivo');
xlabel('Tiempo [Horas]');
ylabel('Concentración [g/g]');
plot(time, sustrate_vector_r, 'k--', 'LineWidth', 2);
plot(time, sustrates{1}, 'LineWidth', 2);
plot(time, disturbance/disturbanceParameters.percentage, '--', 'LineWidth', 1);

legend('Referencia', 'Sustrato', 'Perturbación');
savePlot(shouldSavePlot, fig, 'ad_D')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo control adaptivo');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), sustrate_vector_r), 'LineWidth', 3);

legend(sprintf('(MSE=%.4f)', MSE{1}));
savePlot(shouldSavePlot, fig, 'ad_err_D')

%% Adaptivo: Sistema completo
% se simula el control adaptivo, con variaciones de ks1 en el sistema
% completo

DatosModeloTP4

states0 = [x0;s0;0;0]*1.5;

modelParameters.K = [1 0;-ks1 -ks2; -kN 0; 0 ks2];
modelParameters.xi_in = [0;s_in;n_in;0];
modelParameters.ks1=ks1;
modelParameters.ks2=ks2;

modelParameters.mu_model.mu_max=0.46;
modelParameters.mu_model.Ks=1.2;
modelParameters.mu_model.Kis=16.728;
modelParameters.mu_model.Kn=0.254;

modelParameters.qp_model.qp_max=0.126;
modelParameters.qp_model.Kps=4.1;
modelParameters.qp_model.Kips=80;
modelParameters.qp_model.Kipn=0.262;

mu_est0=1.5*mu_r;

modelParameters.s_in=s_in;
modelParameters.x0=x0;
modelParameters.s_r = s_r;
modelParameters.mu_r=mu_r;
modelParameters.gamma1=2;

params={ks1*0.8, ks1*1.2};
sustrates=cell(length(params));
biomass=cell(length(params));
error=cell(length(params));
MSE=cell(length(params));
for i=1:length(params)
    modelParameters.ks1 = params{i};

    sim_out = sim('simulaciones/TP4_control_adaptivo_mod_completo', simConfig);

    time = sim_out.tout;
    volume = sim_out.volume.Data;
    states = sim_out.states.Data;
    biomass{i} = reshape(states(:,1), size(time));
    sustrates{i} = reshape(states(:,2), size(time));
    Do = sim_out.Do.Data;
    mu = sim_out.mu_s.Data;

    sustrate_vector_r = ones(length(sustrates{i}), 1)*s_r;
    
    error{i}=(sustrate_vector_r-sustrates{i});
    MSE{i} = immse(reshape(sustrate_vector_r, size(sustrates{i})), sustrates{i});

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Control adaptivo modelo completo');
xlabel('Tiempo [Horas]');
ylabel('Concentración [g/g]');
plot(time, sustrate_vector_r, 'k--', 'LineWidth', 2);
plot(time, sustrates{1}, 'LineWidth', 2);
plot(time, sustrates{2}, 'LineWidth', 2);

legend('Referencia', ...
    sprintf('Sutrato (ks1=%.3f)', params{1}), ...
    sprintf('Sutrato (ks1=%.3f)', params{2}));
savePlot(shouldSavePlot, fig, 'ad_completo')

% Error relativo
fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo  Control adaptivo');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), sustrate_vector_r), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{2}), sustrate_vector_r), 'LineWidth', 3);

legend(sprintf('ks1=%.3f (MSE=%.4f)', params{1}, MSE{1}), ...
    sprintf('ks1=%.3f (MSE=%.4f)', params{2}, MSE{2}));
savePlot(shouldSavePlot, fig, 'ad_completo_err')