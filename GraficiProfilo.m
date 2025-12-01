 function [] = GraficiProfilo(c,CampioniAlfa,Cl,Cl0,Cla2D,profilo,Mach,Re,Cd,Cd0,Cm_p,Cm_A,PoloCm,CA,c0,Dir_Profili,inizioCassone, ...
     larghezzaCassone,fineCassone,Upper,Lower,boom,e_EG,CentroElastico,e_EA,Posizione,CampioniAlfaCoda,CdCoda, ...
     CACoda,Cm_pCoda,profiloCoda,ReCoda,Cd0Coda,ClCoda,ClaCoda2D,Cl0Coda,Cm_ACoda)

syms x
inizioCassone = double( subs(inizioCassone,x,Posizione) ) ;
larghezzaCassone = double( subs(larghezzaCassone,x,Posizione) ) ;
fineCassone = double( subs(fineCassone,x,Posizione) ) ;
Upper = double( subs(Upper,x,Posizione) ) ;
Lower = double( subs(Lower,x,Posizione) ) ;
e_EG = double( subs(e_EG,x,Posizione) ) ;
CentroElastico = double( subs(CentroElastico,x,Posizione) ) ;
e_EA = double( subs(e_EA,x,Posizione) ) ;
c = double( subs(c,x,Posizione) ) ;
boom = double( subs(boom,x,Posizione) ) ;

    figure(3)
    plot(CampioniAlfa,Cl,"b",CampioniAlfa,(Cl0 + Cla2D*CampioniAlfa*pi/180),"--r","LineWidth",2) ;
    title(["Coefficiente di portanza di sezione"])
    xlabel("Incidenza \alpha [°]")
    legend("Cl","Modello Linearizzato")
    grid on
    dim = [.015 .78 .2 .2];
    str = {['Profilo = ' num2str(profilo)];['Mach = ' num2str(Mach)];['Reynolds = ' num2str(round(Re)/1e6) ' 10^6 '];['Cl_{, \alpha} = ' num2str(Cla2D)];['Cl_{0} = ' num2str(Cl0)]};
    nota1 = annotation('textbox',dim,'String',str,'FitBoxToText','on') ;
    nota1.FontSize = 15 ;

    figure(4)
    subplot(2,1,1)
    plot(CampioniAlfa,Cd,CampioniAlfa,Cd0*ones(size(CampioniAlfa)),'--r',"LineWidth",2) ;
    title(["Coefficiente di resistenza di sezione"])
    xlabel("Incidenza \alpha [°]")
    grid on
    dim = [.015 .78 .2 .2];
    str = {['Profilo = ' num2str(profilo)];['Mach = ' num2str(Mach)];['Reynolds = ' num2str(round(Re)/1e6) ' 10^6 ']};
    nota1 = annotation('textbox',dim,'String',str,'FitBoxToText','on') ;
    nota1.FontSize = 15 ;
    legend("Andamento reale", "Modello costante")
    subplot(2,1,2)
    plot(CampioniAlfa,Cm_p,CampioniAlfa,Cm_A*ones(size(CampioniAlfa)),'--r',"LineWidth",2) ;
    legend( ["Rispetto al polo scelto: "+num2str(PoloCm(1)), "Rispetto al Centro Aerodinamico:  "+num2str(round(CA,4))] )
    title(["Coefficiente di momento di sezione rispetto a " num2str(PoloCm*100) " % di corda"])
    xlabel("Incidenza \alpha [°]")
    axis([min(CampioniAlfa) max(CampioniAlfa) -0.5 0.5])
    grid on

    figure(5)
    Geometria_profilo = c*load(Dir_Profili+profilo) ;
    plot(Geometria_profilo(:,1),Geometria_profilo(:,2),"LineWidth",2)
    axis equal
    hold on

    N_celle = length(boom) - 1 ;
    
    if N_celle == 1
        plot([inizioCassone fineCassone],[Upper Upper],'--r',[inizioCassone fineCassone],[Lower Lower],'--r', ... 
        [inizioCassone inizioCassone],[Lower Upper],'--r',[fineCassone fineCassone],[Lower Upper],'--r',"LineWidth",2)
        hold on
    elseif N_celle == 2
        
        cella12 = inizioCassone + larghezzaCassone*c/2 ;
        
        plot([inizioCassone fineCassone],[Upper Upper],'--r',[inizioCassone fineCassone],[Lower Lower],'--r', ... 
        [inizioCassone inizioCassone],[Lower Upper],'--r',[fineCassone fineCassone],[Lower Upper],'--r', ... 
        [cella12 cella12],[Lower Upper],'--r',"LineWidth",2)
        hold on
    else
        
        cella12 = inizioCassone + larghezzaCassone*c/3 ;
        cella23 = cella12 + larghezzaCassone*c/3 ;
        
        plot([inizioCassone fineCassone],[Upper Upper],'--r',[inizioCassone fineCassone],[Lower Lower],'--r', ...
        [inizioCassone inizioCassone],[Lower Upper],'--r',[fineCassone fineCassone],[Lower Upper],'--r', ... 
        [cella12 cella12],[Lower Upper],'--r',[cella23 cella23],[Lower Upper],'--r',"LineWidth",2)
        hold on
    end

    scatter(CentroElastico(1),CentroElastico(2),'m','LineWidth',2)
    hold on
    scatter(CA*c,CentroElastico(2),'g','LineWidth',2)
    hold on
    scatter(CentroElastico(1)+e_EG,CentroElastico(2),'c','LineWidth',2)
    hold on

    scatter(boom,Upper*ones(size(boom)),'r','LineWidth',2)
    hold on
    scatter(boom,Lower*ones(size(boom)),'r','LineWidth',2)

    title(["PROFILO A "+num2str(Posizione)+" m DALLA RADICE DELL'ALA",profilo])
    legend("Profilo","Cassone alare")
    xlabel("[m]")
    ylabel("[m]")
    grid on
    dim = [.015 .78 .2 .2];
    str = {['Magenta -> CENTRO ELASTICO'];['Verde -> CENTRO AERODINAMICO'];['Ciano -> CENTRO INERZIALE'] ...
        ;[' '];['Off-set aerodinamico = ' num2str(round(e_EA,2)) ' m'];['Off-set inerziale = ' num2str(round(e_EG,2)) ' m ']};
    nota1 = annotation('textbox',dim,'String',str,'FitBoxToText','on') ;
    nota1.FontSize = 15 ;
    
    if N_celle > 3
        warning("IL NUMERO DI CELLE DEVE ESSERE AL PIU' 3")
    end
    
    PoloCmCoda = PoloCm ;
    
    figure(6) %Grafici polari coda
    plot(CampioniAlfaCoda,ClCoda,"b",CampioniAlfaCoda,(Cl0Coda + ClaCoda2D*CampioniAlfaCoda*pi/180),"--r","LineWidth",2) ;
    title(["COEFFICIENTE DI PORTANZA DI SEZIONE DELLA CODA"])
    xlabel("Incidenza \alpha [°]")
    legend("Cl","Modello Linearizzato")
    grid on
    dim = [.015 .78 .2 .2];
    str = {['Profilo = ' num2str(profiloCoda)];['Mach = ' num2str(Mach)];['Reynolds = ' num2str(round(ReCoda)/1e6) ' 10^6 '];['Cl_{, \alpha} = ' num2str(ClaCoda2D)];['Cl_{0} = ' num2str(Cl0Coda)]};
    nota1 = annotation('textbox',dim,'String',str,'FitBoxToText','on') ;
    nota1.FontSize = 15 ;

    figure(7)
    subplot(2,1,1)
    plot(CampioniAlfaCoda,CdCoda,CampioniAlfaCoda,Cd0Coda*ones(size(CampioniAlfaCoda)),'--r',"LineWidth",2) ;
    title(["COEFFICIENTE DI RESISTENZA DI SEZIONE DELLA CODA"])
    xlabel("Incidenza \alpha [°]")
    grid on
    dim = [.015 .78 .2 .2];
    str = {['Profilo = ' num2str(profiloCoda)];['Mach = ' num2str(Mach)];['Reynolds = ' num2str(round(ReCoda)/1e6) ' 10^6 ']};
    nota1 = annotation('textbox',dim,'String',str,'FitBoxToText','on') ;
    nota1.FontSize = 15 ;
    legend("Andamento reale", "Modello costante")
    subplot(2,1,2)
    plot(CampioniAlfaCoda,Cm_pCoda,CampioniAlfaCoda,Cm_ACoda*ones(size(CampioniAlfaCoda)),'--r',"LineWidth",2) ;
    legend( ["Rispetto al polo scelto: "+num2str(PoloCmCoda(1)), "Rispetto al Centro Aerodinamico:  "+num2str(round(CACoda,4))] )
    title(["COEFFICIENTE DI MOMMENTO DELLA CODA RISPETTO AL " num2str(PoloCmCoda*100) " % DI CORDA "])
    xlabel("Incidenza \alpha [°]")
    axis([min(CampioniAlfaCoda) max(CampioniAlfaCoda) -0.5 0.5])
    grid on
    
    
end

