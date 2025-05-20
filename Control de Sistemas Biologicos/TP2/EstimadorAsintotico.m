% Observador asintótico
close all; clear all;
savePlots=0;

%% Datos
DatosModelo

sustratePerturbance.disturbancePercentage=300;
sustratePerturbance.perturbanceStart=10;
sustratePerturbance.perturbanceStop=15;

sim_hours = 20; % la cantidad de horas que se van a simular
timeStep = 0.001;

% Configuración de la simulación de Simulink
simConfig.StopTime = num2str(sim_hours);
simConfig.Solver = 'ode1';
simConfig.FixedStep = num2str(timeStep);

x0=5;
s0=1;
n0=0;
p0=0;
xi_in = [x0; s0; n0; p0];
D=0.08;
L=[0 1];


%% Observador asintótico

params.Ks2 = ks2;
params.s_in = s0;
z0=s0*1.5;

estimatedModelParameters.K = [-ks2;1];
estimatedModelParameters.rp_params = modelParameters.rp_params;
estimatedModelParameters.Kipn = modelParameters.Kipn;

paramsError = {0, 5, 10, 40};

estimated_sustrate=cell(length(paramsError));
error=cell(length(paramsError));
MSE=cell(length(paramsError));
for i=1:length(paramsError)

    params.parametersError = paramsError{i};

    sim_out = sim('TP2Asintotico', simConfig);
    
    time = sim_out.tout;
    biomass = sim_out.x.Data;
    sustrate = sim_out.s.Data;
    nitrogen = sim_out.n.Data;
    plastic = sim_out.p.Data;
    mu = sim_out.mu.Data;
    qp = sim_out.qp.Data;
    volume = sim_out.v.Data;
    Do = sim_out.Do.Data/D;
    estimated_states = sim_out.estimated_states.Data;
    % estimated_sustrate{i} = reshape(estimated_states(1,1,:), size(time));
    estimated_sustrate{i}=estimated_states;
    error{i}=(estimated_sustrate{i}-sustrate);
    MSE{i} = immse(estimated_sustrate{i}, sustrate);

end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Producción de plástico (Asintótico)');
xlabel('Tiempo [Horas]');
ylabel('Concentración [g/g]');
ylim([-1 5])
plot(time, biomass, 'r', 'LineWidth', 2);
plot(time, sustrate, 'b', 'LineWidth', 2);
plot(time, plastic, 'k', 'LineWidth', 2);
plot(time, estimated_sustrate{1}, '--', 'LineWidth', 2);
plot(time, estimated_sustrate{2}, '--', 'LineWidth', 2);
plot(time, estimated_sustrate{3}, '--', 'LineWidth', 2);
plot(time, estimated_sustrate{4}, '--', 'LineWidth', 2);
plot(time, Do, 'LineWidth', 0.5);

legend('Biomasa', 'Sustrato', 'Plástico', 'Sustrato estimado (sin error)',  'Sustrato estimado (error al 5%)',  'Sustrato estimado (error al 10%)', 'Sustrato estimado (error al 40%)', sprintf('Dilución normalizada (%.2f)', D));

if (savePlots==1)
    saveas(fig, '../Informes/Images_tp2/asintotico', 'png');
end

fig = figure();
set(fig,'Position',[0 0 800 600]);
hold on; grid on;
title('Error relativo de la estimación (concentración)');
xlabel('Tiempo [Horas]');
ylabel('Error relativo [%]');
ylim([0 100])
plot(time, getRelativeError(abs(error{1}), sustrate), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{2}), sustrate), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{3}), sustrate), 'LineWidth', 3);
plot(time, getRelativeError(abs(error{4}), sustrate), 'LineWidth', 3);

legend(sprintf('sin error (MSE=%.3f)', MSE{1}), ...
       sprintf('error al 5%% (MSE=%.3f)', MSE{2}), ...
       sprintf('error al 10%% (MSE=%.3f)', MSE{3}), ...
       sprintf('error al 40%% (MSE=%.3f)', MSE{4}));

if (savePlots==1)
    saveas(fig, '../Informes/Images_tp2/asintotico_error', 'png');
end