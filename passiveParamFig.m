% This is passiveParamFig
% creates a figure relating leak conductance in cpt1, leak conductance in cpt2, and axial conductance to values of the coupling parameters

% Coupling parameters used as 3 "extreme cases"
WEAK = [.3 .2]; FORWARD = [.8 .2]; STRONG = [.8 .7];

figure(); clf;
FS = 10;
POS{1} = [0.11    0.24    0.25    0.62];
POS{2} = [0.42    0.24    0.25    0.62];
POS{3} = [0.73    0.24    0.25    0.62];

stoa = linspace(.1,.9);
atos = linspace(.1,.9);
[XStoA,XAtoS] = meshgrid(stoa, atos);
allow = zeros(size(XStoA)); allow(XStoA>=XAtoS)=1;allow(XStoA<XAtoS)=nan;

for i=1:length(stoa)
    for j=1:i
        P = getParam(stoa(i),atos(j));
        TAU1(j,i) = P.tau1;
        TAU2(j,i) = P.tau2;
        CAP1(j,i) = P.cap1;
        CAP2(j,i) = P.cap2;
        G1(j,i) = P.glk1;
        G2(j,i) = P.glk2;
        GC(j,i) = P.gC;
    end 
end

subplot('position',POS{1}), hold all
    contour(XStoA,XAtoS,G1.*allow,[5:5:65 75:5:85 95:5:105 115:5:200],'color','k','linewidth',1);
    [c,h] = contour(XStoA,XAtoS,G1.*allow,[50:20:110],'k','linewidth',2);
    plot3(WEAK(1),WEAK(2),300,'p','markersize',16,'markeredge','none','markerfacecolor','b')
    plot3(FORWARD(1),FORWARD(2),300,'p','markersize',16,'markeredge','none','markerfacecolor',[0 .5 0])
    plot3(STRONG(1),STRONG(2),300,'p','markersize',16,'markeredge','none','markerfacecolor','r')
    clabel(c,h,[50:20:110],'fontsize',FS)
    grid off
    axis([min(stoa),max(stoa),min(atos),max(atos)])
    set(gca,'fontsize',FS,'xtick',.1:.1:.9,'xticklabel',{'0.1','','','','0.5','','','','0.9'},'ytick',.1:.1:.9,'yticklabel',{'0.1','','','','0.5','','','','0.9'})
    ti = title('    Compartment 1 leak','fontweight','normal','fontsize',FS); set(ti,'position',get(ti,'position')+[0 .018 0 ]);
    text(.19,.85,'g_1 (nS)','fontsize',FS)
    text(.04,1,'A','fontsize',FS+2,'fontweight','bold')
    ylabel({'Backward Coupling \kappa_{2\rightarrow1}'},'fontsize',FS)
subplot('position',POS{2}), hold all
    contour(XStoA,XAtoS,G2.*allow,[ 20 30 50 60 80 90],'color','k','linewidth',1);
    [c,h] = contour(XStoA,XAtoS,G2.*allow,[10 40 70],'k','linewidth',2);
    clabel(c,h,[10 40 70],'fontsize',FS)
    plot3(WEAK(1),WEAK(2),300,'p','markersize',16,'markeredge','none','markerfacecolor','b')
    plot3(FORWARD(1),FORWARD(2),300,'p','markersize',16,'markeredge','none','markerfacecolor',[0 .5 0])
    plot3(STRONG(1),STRONG(2),300,'p','markersize',16,'markeredge','none','markerfacecolor','r')
    grid off
    axis([min(stoa),max(stoa),min(atos),max(atos)])
    set(gca,'fontsize',FS,'xtick',.1:.1:.9,'xticklabel',{'0.1','','','','0.5','','','','0.9'},'ytick',.1:.1:.9,'yticklabel',{})
    ti = title('      Compartment 2 leak','fontweight','normal','fontsize',FS); set(ti,'position',get(ti,'position')+[0 .018 0 ]);
    text(.19,.85,'g_2 (nS)','fontsize',FS)
    text(.06,1,'B','fontsize',FS+2,'fontweight','bold')
    xlabel({'Forward Coupling \kappa_{1\rightarrow2}'},'fontsize',FS)
subplot('position',POS{3}), hold all
    contour(XStoA,XAtoS,GC.*allow,[20 60 80 120 140 180 200 240 260 300 320 360 380],'color','k','linewidth',1);
    [c,h] = contour(XStoA,XAtoS,GC.*allow,[40 340],'k','linewidth',2);
    clabel(c,h,[40 340],'fontsize',FS);
    [c,h] = contour(XStoA,XAtoS,GC.*allow,[ 100 160 220 280],'k','linewidth',2);
    clabel(c,h,[100 160 ],'fontsize',FS-1);
    plot3(WEAK(1),WEAK(2),300,'p','markersize',16,'markeredge','none','markerfacecolor','b')
    plot3(FORWARD(1),FORWARD(2),300,'p','markersize',16,'markeredge','none','markerfacecolor',[0 .5 0])
    plot3(STRONG(1),STRONG(2),300,'p','markersize',16,'markeredge','none','markerfacecolor','r')
    grid off
    axis([min(stoa),max(stoa),min(atos),max(atos)])
    set(gca,'fontsize',FS,'xtick',.1:.1:.9,'xticklabel',{'0.1','','','','0.5','','','','0.9'},'ytick',.1:.1:.9,'yticklabel',{})
    ti = title('   Axial conductance','fontweight','normal','fontsize',FS); set(ti,'position',get(ti,'position')+[0 .018 0 ]);
    text(.19,.85,'g_C (nS) ','fontsize',FS)
    text(.06,1,'C','fontsize',FS+2,'fontweight','bold')

set(gcf,'units','inches','position',[1 1 5.2 2.2])
set(gcf, 'PaperPositionMode','auto') 


