% This is getParam.m
% User defines coupling parameters, values should >0 and <1, larger values are for stronger coupling
% User defines fraction of leak current in each compartment that is
% voltage-gated KLT current.  KLTfrac is a vector 1x2 vector with values between 0 and 1.  KLTfrac(1) is KLT fraction in cpt1, KLTfrac(2) is KLT fraction in cpt2
%
% Parameters that represent MSO-like values are set below (not as inputs) these are: areaRatio, input resistance, membrane time constant, and resting potential
%
% output is P, a structure containing parameter values

function P = getParam(couple12,couple21,KLTfrac)

    if nargin<2;
        error('coupling parameters not defined')
    elseif nargin==2;
        KLTfrac= [0 0];  % frozen KLT
    elseif nargin>3; 
        error('too many inputs')
    end
        
    % Fixed parameters %
    areaRatio = 0.01; % CPT1 to CPT2 area ratio
    R1      = 8.5 * 1e-3;    % Input resistance to CPT1 [10^9 Ohm]
    tauEst  = .34;     % "estimated time constant" [ms]
    Vrest   = -58;    % resting membrane potential [mV]
    Elk     = -58;    % leak reversal potential [mV]
    
    % Passive parameters %
    gC    = (1/R1) * couple21 / (1-couple12*couple21); % coupling conductance [nS]
    glk1  = gC * (1/couple21 - 1); % CPT1 leak conductance [nS]
    glk2  = gC * (1/couple12 - 1); % CPT2 leak conductance [nS]

    % Passive parameters that require separation of time scales assumption %
    tau1  = tauEst * (1-couple12*couple21);          % CPT1 time constant [ms]
    tau2  = tau1 * areaRatio * (couple12/couple21);  % CPT2 time constant [ms]
    cap1  = tau1 * (glk1 + gC); % CPT1 capacitance [pF]
    cap2  = tau2 * (glk2 + gC); % CPT2 capacitance [pF]

    %%%%% PARAMETER STRUCTURE %%%%
    P.couple12 = couple12;
    P.couple21 = couple21;
    P.areaRatio= areaRatio;
    P.R1    = R1;
    P.tauEst= tauEst;
    P.tau1  = tau1;
    P.tau2  = tau2;
    P.cap1  = cap1;
    P.cap2  = cap2; 
    P.glk1  = glk1;
    P.glk2  = glk2;
    P.gC    = gC;
    P.Vrest = Vrest;
    P.Elk   = Elk; 
    
    %%% KLT CONDUCTANCE %%%
    P.EK = -106;
    P.winf = @(V)  (1. + exp(-(V+57.3)/11.7) )^-1; 
    P.zinf = @(V) (1.-.22) / (1.+exp((V+57.)/5.44)) + .22;
    P.tauw = @(V) .46*(100. / (6.*exp((V+75.)/12.15) + 24.*exp(-(V+75.)/25.) + .55));
    P.tauz = @(V) .24*(1000. / (exp((V+60.)/20.) + exp(-(V+60.)/8.)) + 50.);
    
    P.gKLT1 = (KLTfrac(1)*P.glk1) / (P.winf(P.Vrest)^4*P.zinf(Vrest));
    P.glk1 = (1-KLTfrac(1))*P.glk1;

    P.gKLT2 = (KLTfrac(2)*P.glk2) / (P.winf(P.Vrest)^4*P.zinf(Vrest));
    P.glk2 = (1-KLTfrac(2))*P.glk2;

    % Na gating Rothman Manis with 35C temp adjustment
    P.minf = @(V)(1.+exp(-(V+38.)/7.)).^-1.;
    P.hinf = @(V)(1.+exp((V+65.)/6.)).^-1.;
    P.tauh = @(V) .24* (100. / (7.*exp((V+60)/11.) + 10.*exp(-(V+60.)/25.)) + 0.6);
    P.ENa     = 55;     % Na reversal potential [mV]

    P.gSyn = 26.7; % 6mV EPSP in V1 with Franken EPSG waveform
    
    
