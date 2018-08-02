%%% function called by ode solver
function dx = TwoCptANode(t,x,Q)

	% Parameter Values
    P = Q.P;
    
    % AN input
    ANin = Q.ANforMSO;
    
    % synaptic parameters
	G = P.Gsyn; 
    Esyn =0.; 

    %%%% votage variables %%%% 
	V1  = x(1); 
    V2  = x(2);  
    
    %%%%% gating variables %%%% 
    w1  = x(3);
    z1  = P.zinf(V1);
    m   = P.minf(V2);
    h   = x(4);
    w2  = x(5);
    z2  = P.zinf(V2);

    % Synapses
    epsg = @(t,G) (G/0.21317) .* ones(size(t)) .* (t>0) .* (exp(-t/.18) - exp(-t/.1) ); % unitary epsg waveform
    fan = find(ANin(1,:)<t);
    ANspike = ANin(1,fan);
    ANweight = ANin(2,fan);
    Isyn = sum(epsg(t-ANspike, G*ANweight)) * (V1-Esyn);

    %%%%% Cpt1 currents %%%%%
    Ilk1   = P.glk1 * (V1 - P.Elk);
    IKLT0  = P.gKLT1 * P.winf(P.Vrest)^4*P.zinf(P.Vrest)*(P.Vrest-P.EK);
    IKLT1  = P.gKLT1 * w1^4*z1*(V1-P.EK) - IKLT0;

    %%%%% Cpt2 currents %%%%%
    Ilk2  = P.glk2  * (V2 - P.Elk);
    INa0  = P.gNa * ( P.minf(P.Vrest)^3*P.hinf(P.Vrest)*(P.Vrest-P.ENa)); % to make Ispike=0 at rest
    INa   = P.gNa * (P.minf(V2)^3*h*(V2-P.ENa)) - INa0;
    IKLT0  = P.gKLT2 * P.winf(P.Vrest)^4*P.zinf(P.Vrest)*(P.Vrest-P.EK);
    IKLT2  = P.gKLT2 * w2^4*z2*(V2-P.EK) - IKLT0;

    %%%%% Coupling current %%%%%
    IC = P.gC*(V1-V2);
    
    %%%%% Update V using Current Balance Equation %%%%%
    dV1 =  ( -Ilk1 - IKLT1 - IC - Isyn)/ P.cap1 ;
    dV2 =  ( -Ilk2 - IKLT2 + IC - INa  )/ P.cap2 ; 
    
    %%%%% Update Gating Vars %%%%%
    dw1  = (P.winf(V1) -w1) / P.tauw(V1);
    dw2  = (P.winf(V2) -w2) / P.tauw(V2);
    dh  = (P.hinf(V2) -h) / P.tauh(V2);
    
    %%%%% output %%%%%
    dx = [dV1 ; dV2 ; dw1 ; dh ; dw2 ];

    
