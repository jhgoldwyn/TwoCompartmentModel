% This is ResponseToAN
% It simulates TwoCpt model to 500 Hz inputs and creates figures
% Top row: simulations have no Sodium current (passive model)
% Bottom row: simulations have gNa set to reference value (spiking model)

close all
clear all

seed = 1804; % initial random number generator

figure()
FS = 10;

POS{1,1} = [.1 .83 .18 .1] + [.02 0 0 0];
POS{1,2} = [.41 .83 .18 .1]+ [.02 0 0 0];
POS{1,3} = [.72 .83 .18 .1]+ [.02 0 0 0];
POS{2,1} = [.08 .51 .22 .23]+ [.02 0 0 0];
POS{2,2} = [.39 .51 .22 .23]+ [.02 0 0 0];
POS{2,3} = [.70 .51 .22 .23]+ [.02 0 0 0];
POS{3,1} = [.08 .11 .22 .23]+ [.02 0 0 0];
POS{3,2} = [.39 .11 .22 .23]+ [.02 0 0 0];
POS{3,3} = [.7 .11 .22 .23]+ [.02 0 0 0];

% coupling parameter configurations for three "extreme case" models of weak, forward, and strong coupling
WEAK = [.3 .2]; FORWARD = [.8 .2]; STRONG = [.8 .7];

KLTfrac = [ 0 0];  % fraction of leak conductance that is voltage-gated KLT

% gNa values for each configuration
gNaWeak = 6291;
gNaStrong = 2003;
gNaForward = 398;

%%% CARTOONS to illustrate coupling configurations %%%
subplot('position',POS{1,1}), hold all
    th = linspace(0,2*pi,501);
    plot(cos(th),sin(th),'color',[0 0 .5],'linewidth',1)
    plot(3.+.6*cos(th),.6*sin(th),'color',[.25 .5 1],'linewidth',1)
    text(-.25,0,'V_1','fontsize',FS-1)
    text(3-.25,0,'V_2','fontsize',FS-1)
    text(1.15,.65,num2str(WEAK(1)),'fontsize',FS-2)
    text(1.65,-.65,num2str(WEAK(2)),'fontsize',FS-2)
    plot([1,2.15],[.2,.2],'k','linewidth',1); plot(2.15,.2,'>','markerfacecolor','k','markeredge','none','markersize',5)
    plot([2.4 1.3],-[.2,.2],'k','linewidth',1); plot(1.3,-.2,'<','markerfacecolor','k','markeredge','none','markersize',5)
    title('Weakly-coupled','fontsize',FS,'fontweight','normal')
    set(gca,'fontsize',FS)
    axis tight; axis off; box off
    text(-3.15,1.5,'A','fontsize',FS,'fontweight','bold')

subplot('position',POS{1,2}), hold all
    th = linspace(0,2*pi,501);
    plot(cos(th),sin(th),'color',[0 .4 0 ],'linewidth',3)
    plot(3.+.6*cos(th),.6*sin(th),'color',[.2 .8 .2],'linewidth',1)
    text(-.25,0,'V_1','fontsize',FS-1,'fontweight','bold')
    text(3-.25,0,'V_2','fontsize',FS-1)
    text(1.15,.65,num2str(FORWARD(1)),'fontsize',FS-2)
    text(1.65,-.65,num2str(FORWARD(2)),'fontsize',FS-2)
    plot([1,2.1],[.2,.2],'k','linewidth',2); plot(2.1,.2,'>','markerfacecolor','k','markeredge','none','markersize',8)
    plot([2.4 1.3],-[.2,.2],'k','linewidth',1); plot(1.3,-.2,'<','markerfacecolor','k','markeredge','none','markersize',5)
    title('Forward-coupled','fontsize',FS,'fontweight','normal')
    set(gca,'fontsize',FS)
    axis tight; axis off; box off

subplot('position',POS{1,3}), hold all
    th = linspace(0,2*pi,501);
    plot(cos(th),sin(th),'color',[.5 0 0],'linewidth',3)
    plot(3.+.6*cos(th),.6*sin(th),'color',[1 .5 0],'linewidth',3)
    text(-.25,0,'V_1','fontsize',FS-1,'fontweight','bold')
    text(3-.25,0,'V_2','fontsize',FS-1,'fontweight','bold')
    text(1.15,.65,num2str(STRONG(1)),'fontsize',FS-2)
    text(1.65,-.65,num2str(STRONG(2)),'fontsize',FS-2)
    plot([1,2.1],[.2,.2],'k','linewidth',2); plot(2.1,.2,'>','markerfacecolor','k','markeredge','none','markersize',8)
    plot([2.4 1.35],-[.2,.2],'k','linewidth',2); plot(1.35,-.2,'<','markerfacecolor','k','markeredge','none','markersize',8)
    title('Strongly-coupled','fontsize',FS,'fontweight','normal')
    set(gca,'fontsize',FS)
    axis tight; axis off; box off


%%% Paramters for auditory nerve model %%% 
ParamStruct.Gsyn = 26.7;
ParamStruct.stimdb = [70 70];  % 70dB used by Felicia
ParamStruct.nAN = 5;  % Number of AN fibers (on each side)
ParamStruct.CF = 500;  % characteristic freq. of neuron
ParamStruct.F0 = 500;  % Frequency of tone / carrier
ParamStruct.tEnd = 40; % ms
ParamStruct.Stim = @(t) (sin(2*pi*ParamStruct.F0*t)); % pure tone

XL = [9 31];

% WEAK COUPLE
rng(seed)
ParamStruct.a12 = WEAK(1); ParamStruct.a21 = WEAK(2);  ParamStruct.KLTfrac = KLTfrac;
ParamStruct.itd = 0; % ITD (ms) coincident
ParamStruct.gNa = 0;  % 200 spikes 
[t,y,~]=TwoCptAN_func(ParamStruct); 
subplot('position',POS{2,1}), hold all
    plot(t,y(:,2),'color',[.25 .5 1],'linewidth',1)
    plot(t,y(:,1),'color',[0 0 .5],'linewidth',1)
    set(gca,'xtick',0:10:1000,'ytick',[-50 -30])
    axis([XL -60 -28]) 
    xlabel('Time (ms)','fontsize',FS)
    ylabel('V (mV)','fontsize',FS)
    set(gca,'fontsize',FS)
    text(2.5,-26,'B','fontsize',FS,'fontweight','bold')
    text(10,-31,'g_{Na}=0')

rng(seed)
ParamStruct.gNa = gNaWeak;
[t,y,~]=TwoCptAN_func(ParamStruct); 
subplot('position',POS{3,1}), hold all
    plot(t,y(:,2),'color',[.25 .5 1],'linewidth',1)
    plot(t,y(:,1),'color',[0 0 .5],'linewidth',1)
    set(gca,'xtick',0:10:1000,'ytick',[-50 0 40])
    axis([XL -60 52]) 
    xlabel('Time (ms)','fontsize',FS)
    ylabel('V (mV)','fontsize',FS)
    set(gca,'fontsize',FS)
    text(2.5,63,'C','fontsize',FS,'fontweight','bold')
    text(10,57,['g_{Na}=',num2str(ParamStruct.gNa)])

% FORWARD COUPLE
rng(seed)
ParamStruct.a12 = FORWARD(1); ParamStruct.a21 = FORWARD(2);  ParamStruct.KLTfrac = KLTfrac;
ParamStruct.gNa = 0; 
ParamStruct.itd = 0; % ITD (ms) coincident
[t,y,~]=TwoCptAN_func(ParamStruct); 
subplot('position',POS{2,2}), hold all
    plot(t,y(:,2),'color',[.2 .8 .2],'linewidth',1)
    plot(t,y(:,1),'color',[0 .4 .0],'linewidth',1)
    set(gca,'xtick',0:10:1000,'ytick',[-50 -30])
    axis([XL -60 -28]) 
    xlabel('Time (ms)','fontsize',FS)
%         ylabel('V (mV)','fontsize',FS)
    set(gca,'fontsize',FS)
    text(10,-31,'g_{Na}=0')


rng(seed)
ParamStruct.gNa = gNaForward;
[t,y,a]=TwoCptAN_func(ParamStruct); 
subplot('position',POS{3,2}), hold all
    plot(t,y(:,2),'color',[.2 .8 .2],'linewidth',1)
    plot(t,y(:,1),'color',[0 .4 0],'linewidth',1)
    set(gca,'xtick',0:10:1000,'ytick',[-50 0 50])
    axis([XL -60 10]) 
    xlabel('Time (ms)','fontsize',FS)
    set(gca,'fontsize',FS)
    text(10,10,['g_{Na}=',num2str(ParamStruct.gNa)],'fontsize',FS)


% STRONG COUPLE
rng(seed)
ParamStruct.a12 = STRONG(1); ParamStruct.a21 = STRONG(2);  ParamStruct.KLTfrac = KLTfrac;
ParamStruct.gNa = 0; 
ParamStruct.itd = 0; % ITD (ms) coincident 
[t,y,~]=TwoCptAN_func(ParamStruct); 
subplot('position',POS{2,3}), hold all
    plot(t,y(:,2),'color',[1 .5 0],'linewidth',1)
    plot(t,y(:,1),'color',[.5 0 .0],'linewidth',1)
    set(gca,'xtick',0:10:1000,'ytick',[-50 -30])
    axis([XL -60 -28]) 
    xlabel('Time (ms)','fontsize',FS)
    set(gca,'fontsize',FS)
    text(10,-31,'g_{Na}=0')


rng(seed)
ParamStruct.gNa = gNaStrong;
[t,y,~]=TwoCptAN_func(ParamStruct); 
subplot('position',POS{3,3}), hold all
    plot(t,y(:,2),'color',[1 .5 0],'linewidth',1)
    plot(t,y(:,1),'color',[.5 0 0],'linewidth',1)
    set(gca,'xtick',0:10:1000,'ytick',[-50 0 50])
    axis([XL -60 10]) 
    xlabel('Time (ms)','fontsize',FS)
    set(gca,'fontsize',FS)
    text(10,10,['g_{Na}=',num2str(ParamStruct.gNa)],'fontsize',FS)

set(gcf,'units','inches','position',[1 1 11 10])
set(gcf, 'PaperPositionMode','auto') 
