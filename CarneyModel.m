% Carney AN model    
function [pin,ANOut] = CarneyModel(ANstruct,itd)

% NOTE: mex code for Zilany-Carney 2009 model must be compiled in path for matlab

% Read parameters from input structure
tEnd = ANstruct.tEnd;
stimdb = ANstruct.stimdb;

% model fiber parameters
CF    = ANstruct.CF; % CF in Hz;   
cohc  = 1.0;   % normal ohc function
cihc  = 1.0;   % normal ihc function
fiberType = 2; % spontaneous rate (in spikes/s) of the fiber BEFORE refractory effects; "1" = Low; "2" = Medium; "3" = High
implnt = 0;    % "0" for approximate or "1" for actual implementation of the power-law functions in the Synapse

% stimulus parameters
Fs = 100e3;   % sampling rate in Hz (must be 100, 200 or 500 kHz)
T = tEnd*1E-3;% stimulus duration
rt = 1e-3;    % rise/fall time in seconds

% PSTH parameters
nrep = ANstruct.nAN;% number of AN fibers

t = 0:1/Fs:T-1/Fs; % time vector (s)
mxpts = length(t);
irpts = rt*Fs;  % Ramping parameter

% Stimulus
r = ANstruct.Stim;
pin = sqrt(2)*20e-6*10^(stimdb/20)*r(t);

% Ramp
pin(1:irpts)=pin(1:irpts).*(0:(irpts-1))/irpts; 
pin((mxpts-irpts):mxpts)=pin((mxpts-irpts):mxpts).*(irpts:-1:0)/irpts;

% Shift by ITD amount
itdShift = max(find(t<itd*1E-3));
pin(itdShift+1:end) = pin(1:end-itdShift);
pin(1:itdShift) = 0;

species = 1; % cat
vihc = model_IHC(pin,CF,nrep,1/Fs,T*2,cohc,cihc,species); 

noiseType = 1;  % 1 for variable fGn (0 for fixed fGn)
[~,~,psth] = model_Synapse(vihc,CF,nrep,1/Fs,fiberType,noiseType,implnt); 

timeout = (1:length(psth))*1/Fs;

% For spike input to MSO model
FindSpike = find(psth>0);
ANOut(1,:) = timeout(FindSpike);
ANOut(2,:) = psth(FindSpike);

[~,s2] = sort(ANOut(1,:));
if ~isempty(s2)
    ANOut(1,:) = ANOut(1,s2);
    ANOut(2,:) = ANOut(2,s2);
end
