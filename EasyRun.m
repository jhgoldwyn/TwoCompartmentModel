% This is EasyRun.m
clear all; close all;

% Choose coupling strengths between 0 and 1 [close to 0 is weak coupling, close to 1 is strong coupling]
couple1to2 = 0.7; % Forward coupling
couple2to1 = 0.5; % Backward coupling

% Choose proportion of leak conductance to convert to dynamic KLT conductance
% [0 is passive model, 1 converts all leak conductance to dynamic KLT]
KLTfraction1 = 0.2; % KLT in compartment 1
KLTfraction2 = 0.1; % KLT in compartment 2

% Parameterize the two-compartment model
P = getParam(couple1to2, couple2to1, [KLTfraction1 KLTfraction2]);

% Choose the Na conductance
P.gNa = 1500;

% Choose the stimulus time [options are 'step', 'ramp', 'EPSG', 'EPSGpair', or 'AN']
stimType = 'EPSG';

% Set stimulus parameters depending on which stimulus you chose:
switch(stimType)
    case('step')
        startStep = 5;    % time at start of step
        stopStep  =  15;  % time at end of step
        Istep     = 2000; % current level of step
    case('ramp')
        startRamp = 5;    % time at start of ramp
        stopRamp = 7;     % slope of ramp [pA/ms]
        IrampMax  = 4000; % maximum current of ramp
    case('EPSG')
        startEPSG = 5;    % start of EPSG event
        gEPSG     = 55;   % amplitude of EPSG event [26.7 is a "unitary EPSG" in the manuscript]
    case('EPSGpair')
        startEPSG1 = 5;   % start of first EPSG event
        startEPSG2 = 5.3; % start of second EPSG event
        gEPSG      = 35;  % amplitude of EPSG event [26.7 is a "unitary EPSG" in the manuscript]
    case('AN')
        Gsyn     = 26.7;  % amplitude of unitary EPSG events
        nAN      = 5;     % Number of AN fibers (on each side)
        toneFreq = 500;   % frequency of tone
        stimdb   = 70;    % level of tone
        duration = 50;    % duration of tone
        itd      = .2;    % interaural time difference
      
end


%%% Paramters for auditory nerve model %%% 
ParamStruct.Gsyn = 26.7;
ParamStruct.stimdb = [70 70];  % 70dB used by Felicia
ParamStruct.nAN = 5;  % Number of AN fibers (on each side)
ParamStruct.CF = 500;  % characteristic freq. of neuron
ParamStruct.F0 = 500;  % Frequency of tone / carrier
ParamStruct.tEnd = 50; % ms
ParamStruct.Stim = @(t) (sin(2*pi*ParamStruct.F0*t)); % pure tone

%%% User does not need to make changes below this point %%%

% Run two-compartment model 
switch(stimType)
    case('step')
        P.step =Istep; P.startStep = startStep; P.stopStep = stopStep; tEnd = stopStep + 5; odeFile = @TwoCptODE;
    case('ramp')
        P.startRamp =startRamp; P.ramp= 1/(stopRamp-startRamp); P.I = IrampMax; tEnd = stopRamp + 5; odeFile = @TwoCptODE;
    case('EPSG')
        P.EPSG=1;P.startEPSG =startEPSG; P.I= gEPSG; tEnd = startEPSG+ 8; odeFile = @TwoCptODE;
    case('EPSGpair')
        P.EPSGpair=1;P.startEPSG1 =startEPSG1; P.td = startEPSG2-startEPSG1; P.I= gEPSG; tEnd = startEPSG2+8; odeFile = @TwoCptODE;
    case('AN')
        P.Gsyn = Gsyn; P.stimdb = [stimdb stimdb]; P.nAN = nAN; P.itd = itd; P.a12 = couple1to2; P.a21 = couple2to1; P.KLTfrac = [KLTfraction1 KLTfraction2];
        P.CF = toneFreq; P.F0 = toneFreq; P.tEnd = duration; P.Stim = @(t) (sin(2*pi*P.F0*t)); tEnd = duration; 
end

if strcmp(stimType,'AN')
    [t,x,~]=TwoCptAN_func(P);   
else
    options = odeset('abstol',1e-10,'reltol',1e-10,'maxstep',.01);
    [t,x] =ode15s(odeFile, [0 tEnd], [P.Vrest P.Vrest P.winf(P.Vrest) P.hinf(P.Vrest) P.winf(P.Vrest)],options,P);    
end

% Plot V1 and V2
V1 = x(:,1); V2 = x(:,2);
figure(1), clf, hold all; 
plot(t,[V1 V2],'linewidth',2)
set(gca,'fontsize',12); 
legend({'V1','V2'},'fontsize',8,'box','off'); 
xlabel('Time (ms)')
ylabel('Voltage (mV)');
xlim([0 tEnd])