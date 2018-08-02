% TwoCpt model with WITH CARNEY MODEL AN INput
function [t,y,ANforMSO,Sipsi,Scontra] = TwoCptAN_func(ParamStruct)

    % Outputs
    % t - time (ms)
    % y - V1, V2, and gating variables
    % ANforMSO - spike times (ms) and number of occurences
    % Sipsi, Scontra - Sound waveform, input to AN model

    % Simulation time (ms)
    t0 =0;
    ANstruct.tEnd = ParamStruct.tEnd; tEnd = ParamStruct.tEnd;

    % Stimulus
    ANstruct.Stim = ParamStruct.Stim;

    % Number of AN fibers
    ANstruct.nAN = ParamStruct.nAN;

    % Generate AN spikes (Ipsi Ear)
    ANstruct.F0 = ParamStruct.F0;
    ANstruct.stimdb =ParamStruct.stimdb(1);
    ANstruct.CF = ParamStruct.CF;
    [Sipsi,a] = CarneyModel(ANstruct,0);
    ANipsi(1,:) = a(1,:)*1E3;  % switch to ms
    ANipsi(2,:) = a(2,:);

    % Generate AN spikes (Contra Ear)
    ANstruct.stimdb = ParamStruct.stimdb(2);   
    [Scontra,a] = CarneyModel(ANstruct,ParamStruct.itd);
    ANcontra(1,:) =  a(1,:)*1E3;  % switch to ms
    ANcontra(2,:) =  a(2,:);

    ANforMSO = [ANipsi ANcontra];   

    % Get Parameters
    P = getParam(ParamStruct.a12, ParamStruct.a21,ParamStruct.KLTfrac);
    P.gNa = ParamStruct.gNa;
    P.Gsyn = ParamStruct.Gsyn;

    % Initialize MSO ode
    Vrest= P.Vrest; % Resting potential (mV)
    w1 = P.winf(Vrest);
    w2 = P.winf(Vrest);
    h = P.hinf(Vrest);
    x0 = [Vrest Vrest w1 h w2];
    
    ANforMSOstruct.P = P;
    ANforMSOstruct.ANforMSO = ANforMSO;

    %Solve MSO ode
    options = odeset('MaxStep',.1);
    [t,y] = ode15s(@TwoCptANode, t0:.01:tEnd, x0,options,ANforMSOstruct);


