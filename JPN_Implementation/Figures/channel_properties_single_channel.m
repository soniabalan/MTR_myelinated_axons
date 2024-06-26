clear all
close all
clc

par = Cullen2018CortexAxonJPNlocalized_MTR(0);
nd= 15;

par.sim.dt.value = 1;
par.sim.tmax.value = 10;
par.sim.temp = 20;
[MEMBRANE_POTENTIAL, ~ , TIME_VECTOR] = ModelJPN_MTR(par);

dt = unitsabs(par.sim.dt.units) * par.sim.dt.value;


%% FIGURES (faster without the simulation above)
par = Cullen2018CortexAxonJPNlocalized_KILT(0);

figure(1)
subplot(211)
hold on
plot(TIME_VECTOR,MEMBRANE_POTENTIAL(:,nd), 'k', 'LineWidth',1.5);
title('voltage')
xlabel('time (ms)')
ylabel('voltage')
hold off

V = MEMBRANE_POTENTIAL(:,nd);

vrest = simunits(par.elec.pas.vrest.units)*par.elec.pas.vrest.value.ref;

gates=cell(1,length(par.channels));

for i=1:length(par.channels)
    gates{i}=cell(1,par.channels(i).gates.number);
    for j=1:par.channels(i).gates.number
        for v=1:length(V)
            a = rateequation(V(v), par.sim.temp, par.channels(i).gates.temp, par.channels(i).gates.alpha.q10(j), par.channels(i).gates.alpha.equ{j});
            b = rateequation(V(v), par.sim.temp, par.channels(i).gates.temp, par.channels(i).gates.beta.q10(j), par.channels(i).gates.beta.equ{j});
            gates{i}{j}((v), 1) = a/(a+b);
        end
        figure(1)
        subplot(212)
        hold on
        plot(TIME_VECTOR,gates{i}{j},'DisplayName', par.channels(i).channame, 'LineWidth', 1.5)
    end
end
hold off
legend
title('gating var')
xlabel('time (ms)')

%% K+ gates specifically
V = linspace(-100,100,length(TIME_VECTOR));

i = 4;
g4 = nan(length(V),2);
inf = nan(length(V), 1);
tau = nan(length(V), 1);


for j=1:par.channels(i).gates.number
    for v=1:length(V)
        inf(v) = rateequation(V(v), par.sim.temp, par.channels(i).gates.temp, par.channels(i).gates.alpha.q10(j), par.channels(i).gates.inf.equ{j});
        tau(v) = rateequation(V(v), par.sim.temp, par.channels(i).gates.temp, par.channels(i).gates.beta.q10(j), par.channels(i).gates.tau.equ{j});
        g4(v,j)= inf(v)/(inf(v)+tau(v));
    end


    if j<2
        figure(1)
        subplot(321)
        hold on
        plot(V,inf, 'DisplayName', par.channels(i).channame,'LineWidth',1.1)
        hold off
        % set(gca, 'XTick', []);
        % leg = legend('show'); % Just one output here
        % leg.Location = 'southeast';
        % title(leg,'Channel')
        title('m_{inf}')
        inf1=inf;

        figure(1)
        subplot(323)
        hold on
        plot(V,tau, 'DisplayName', par.channels(i).channame,'LineWidth',1.1)
        hold off
        % set(gca, 'XTick', []);
        title('\tau_m (ms)')

    else
        figure(1)
        subplot(322)
        hold on
        plot(V,inf, 'DisplayName', par.channels(i).channame,'LineWidth',1.1)
        hold off
        % set(gca, 'XTick', []);
        title('h_{inf}')

        figure(1)
        subplot(3,2,5:6)
        hold on
        plot(V,inf1.*inf, 'DisplayName', par.channels(i).channame,'LineWidth',1.1)
        xlabel('mV')
        title('m_{inf}*h_{inf}')
        hold off

        figure(1)
        subplot(324)
        hold on
        plot(V, tau, 'DisplayName', par.channels(i).channame,'LineWidth',1.1)
        hold off
        xlabel('mV')
        title('\tau_h (ms)')
        %
    end

end

