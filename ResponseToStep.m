figure();

% configurations used as 3 "extreme cases"
WEAK = [.3 .2]; FORWARD = [.8 .2]; STRONG = [.8 .7];

KLTfrac = [ .0 .0];  % fraction of leak conductance that is voltage-gated KLT

% gNa values for each configuration
gNaWeak = 6291;
gNaStrong = 2003;
gNaForward = 398;
gNa = [gNaWeak gNaForward gNaStrong];

FS = 10;

couple = [WEAK ; FORWARD ; STRONG];

IDC = [1000 2000 3000];
COLOR{1} = [0 0 1/3 ; 0 0 2/3 ; 0 0 1];
COLOR{2} = [0 1/6 0 ; 0 1/3 0 ; 0 1/2 0];
COLOR{3} = [1/3 0 0 ; 2/3 0 0 ; 1 0 0];

POS{1} = [.26  .78  .66  .15];
POS{2} = [.26  .56  .66 .15];
POS{3} = [.26  .34  .66  .15];
POS{4} = [.26  .12  .66  .15];

YMAX = [60 30 30];

Istep = @(t,y) (t>=5).*(t<20).*y;

for c=1:3
         
    ParamStruct = getParam(couple(c,1),couple(c,2), KLTfrac); 
    
    ParamStruct.gNa = gNa(c);

    for i=1:length(IDC)
        ParamStruct.step =IDC(i);

        % Initialize TwoCpt ode
        t0 = 0; tEnd = 50;
        Vrest= ParamStruct.Vrest; % Resting potential (mV)
        w1 = ParamStruct.winf(Vrest);
        w2 = ParamStruct.winf(Vrest);
        h = ParamStruct.hinf(Vrest);
        x0 = [Vrest Vrest w1 h w2];        

        % run ODE
        t = []; x = []; 
        options = odeset('abstol',1e-10,'reltol',1e-10,'maxstep',.01);
        [t,x] =ode15s(@TwoCptODE, [t0 tEnd], x0,options,ParamStruct);

        % plot
        subplot('position',POS{1}), hold all; 
            plot(t,Istep(t,IDC(i)),'linewidth',2,'color',[0 0 0]+(i-1)/3); xlim([0 25]); ylim([0 5000])
            set(gca,'xtick',[0:10:20])

        subplot('position',POS{c+1}), hold all; 
            plot(t,x(:,2),'linewidth',1,'color',COLOR{c}(i,:)); 
            set(gca,'xtick',[0:10:20],'ytick',[-60 0])
            xlim([0 25]); ylim([-65 YMAX(c)]); 
    end

end

subplot('position',POS{1}); ti=title('A','fontsize',FS+2); set(ti,'position',get(ti,'position')+[-27 -1000 0]); ylabel('I_{step} (pA)','fontsize',FS)
subplot('position',POS{2}); ti=title('B','fontsize',FS+2); set(ti,'position',get(ti,'position')+[-27 -45 0]); ylabel('V_2 (mV)','fontsize',FS); text(16,42,'weak','fontsize',FS)
subplot('position',POS{3}); ti=title('C','fontsize',FS+2); set(ti,'position',get(ti,'position')+[-27 -30 0]); ylabel('V_2 (mV)','fontsize',FS); text(16,2,'forward','fontsize',FS)
subplot('position',POS{4}), ti=title('D','fontsize',FS+2); set(ti,'position',get(ti,'position')+[-27 -30 0]); ylabel('V_2 (mV)','fontsize',FS); text(16,2,'strong','fontsize',FS)
xl= xlabel('Time (ms)','fontsize',FS); set(xl,'position',get(xl,'position')+[0 0 0])

set(gcf,'units','inches','position',[0 0 2.4 4.5])
set(gcf, 'PaperPositionMode','auto') 