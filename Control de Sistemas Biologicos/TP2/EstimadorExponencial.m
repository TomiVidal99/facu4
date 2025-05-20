% TP 2
% Estimador exponencial
close all; clear all;
savePlots=0;

%% Cargo los datos
DatosModelo

sustratePerturbance.disturbancePercentage=300;
sustratePerturbance.perturbanceStart=30;
sustratePerturbance.perturbanceStop=35;

sim_hours = 50; % la cantidad de horas que se van a simular
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

%% Estimador
omegaParams.poles = [100, -10];

omegaParams.qmax =  qp_max;
omegaParams.kips = Kips;
omegaParams.kps = Kps;

estimatedModelParameters.K = [-ks2;1];
estimatedModelParameters.rp_params = modelParameters.rp_params;
estimatedModelParameters.Kipn = modelParameters.Kipn;

paramsError = {0, 5, 10, 40};

Poles={[100, 0], [150, -0.1], [150, -0.2]};

estimated_sustrate=cell(length(paramsError), length(Poles));
error=cell(length(paramsError), length(Poles));
MSE=cell(length(paramsError), length(Poles));

% Se corren iteraciones para diferentes polos y variaciones en los
% parámetros del observador
for j=1:length(paramsError)
    for i=1:length(Poles)
    
        estimatedModelParameters.parametersError = paramsError{j};
        
        omegaParams.poles=Poles{i};
    
        sim_out = sim('TP2', simConfig);
        
        time = sim_out.tout;
        biomass = sim_out.x.Data;
        sustrate = sim_out.s.Data;
        nitrogen = sim_out.n.Data;
        plastic = sim_out.p.Data;
        mu = sim_out.mu.Data;
        qp = sim_out.qp.Data;
        volume = sim_out.v.Data;
        Do =  sim_out.Do.Data/D;
        estimated_states = sim_out.estimated_states.Data;
        
        estimated_sustrate{j, i} = reshape(estimated_states(:,1), size(time));
        error{j, i}=(estimated_sustrate{j, i}-sustrate);
        MSE{j, i} = immse(estimated_sustrate{j, i}, sustrate);
    
    end
end

% Se grafica
for j = 1:length(paramsError)
    fig = figure();
    set(fig,'Position',[0 0 800 600]);
    hold on; grid on;
    title(sprintf('Sustrato estimado \n(error de parámetros: %d%%)', paramsError{j}));
    xlabel('Tiempo [Horas]');
    ylabel('Concentración [g/g]');
    ylim([-1 5])
    
    plot(time, biomass, 'r', 'LineWidth', 2);
    plot(time, sustrate, 'b', 'LineWidth', 2);
    plot(time, plastic, 'k', 'LineWidth', 2);
    plot(time, Do, 'LineWidth', 1);
    
    for i = 1:length(Poles)
        plot(time, estimated_sustrate{j, i}, '--', 'LineWidth', 2);
    end

    legend(['Biomasa', 'Sustrato', 'Plástico', 'Dilución normalizada', ...
        arrayfun(@(i) sprintf('Sustrato estimado (Polos=[%.2f; %.2f], MSE=%.3f)', ...
        Poles{i}(1), Poles{i}(2), MSE{j, i}), 1:length(Poles), 'UniformOutput', false)]);
    if (savePlots==1)
        saveas(fig, sprintf('../Informes/Images_tp2/exponencial_%d', j), 'png');
    end

    fig = figure();
    set(fig, 'Position', [0 0 800 600]);
    hold on; grid on;
    title(sprintf('Error relativo \n(error de parámetros: %d%%)', paramsError{j}));
    xlabel('Tiempo [Horas]');
    ylabel('Error Relativo [%]');
    ylim([0 100])

    for i = 1:length(Poles)
        relErr = getRelativeError(abs(error{j, i}), sustrate);
        plot(time, relErr, 'LineWidth', 3);
    end

    legend(arrayfun(@(i) ...
        sprintf('(Polos=[%d; %.2f], MSE=%.3f)', Poles{i}(1), Poles{i}(2), MSE{j, i}), ...
        1:length(Poles), 'UniformOutput', false));

    if (savePlots==1)
        saveas(fig, sprintf('../Informes/Images_tp2/exponencial_%d_error', j), 'png');
    end

end