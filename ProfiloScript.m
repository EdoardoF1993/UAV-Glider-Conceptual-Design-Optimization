%PROFILO

for j = 15:15
    Profili = [["WE.DAT"] ["NACA0012H.DAT"] ["AQUILASM.DAT"] ["SC812.DAT"] ["SC512.DAT"] ["NACA1.DAT"] ["N0009SM.DAT"] ["NACA3320.DAT"] ["S1223.DAT"] ...
        ["HQ212.DAT"] ["HQ112.DAT"] ["FX79W660A.DAT"] ["AH93W480B.DAT"] ["AH94W301.DAT"] ["EPPLER864.DAT"] ["f.DAT"]] ;
    profilo = Profili(j) ;
    
    Dir_Profili = "/home/edoardo/Scrivania/ALL IN/Università/Magistrale Aeronautica/Corsi/Progettazione Aeronautiica/Progetto/Profili.dat/" ;
    cd(Dir_Profili) ;
    addpath(Dir_Profili) ;
    
    Alfa_in = -0.5:0.2:10 ;
    Alfa_a = 0 ;
    Alfa_b = 6 ;
    Ma = 0.15 ; %Mach
    PoloCm = [0.25 0] ; %Coordinate X ed Y del Polo del Cm in frazioni di corda
    
    nMax = 1000 ; %Numero max di iterazioni da far fare ad xfoil
	NumeroCicli = 50 ; %Numero di iterazioni del ciclo for
    
    ReMin = 5e4 ;
    ReMax = 3.5e6 ;
    DeltaRe = (ReMax-ReMin)/(NumeroCicli-1) ;
    
%     Cl_k = zeros(NumeroCicli,size(Alfa_in,2)) ;
%     Cd_k = zeros(NumeroCicli,size(Alfa_in,2)) ;
%     Cm_polo_k = zeros(NumeroCicli,size(Alfa_in,2)) ;
    Cl0_k = zeros(NumeroCicli,1) ;
    Cla_k = zeros(NumeroCicli,1) ;
    Cd0_k = zeros(NumeroCicli,1) ;
    Cm0_k = zeros(NumeroCicli,1) ;
    Cma_k = zeros(NumeroCicli,1) ;
    CA_k = zeros(NumeroCicli,1) ;
    AlfaLimite_k = zeros(NumeroCicli,1) ;
    Cm_A_k = zeros(NumeroCicli,1) ;
    war_k = zeros(NumeroCicli,1) ;
    
	contatore = 1 ;
    
    for Re = ReMin:DeltaRe:ReMax
        
        [Cl,Cd,Cm_polo,Cl0,Cla,Alfa_out,AlfaLimite,Cd0,Cm_A,CA,Cma,Cm0,war] = ProfiloFun(profilo,Re,Ma,Alfa_in,PoloCm,nMax,Dir_Profili,Alfa_a,Alfa_b) ;
        
        %SALVATAGGIO DELLE CARATTERIESTICHE DEL PROFILO AL RE CONSIDERATO
%         Cl_k(contatore,:) = Cl' ; %Ogni colonna e' relativa ad un Alfa, ogni riga ad un Reynolds
%         Cd_k(contatore,:) = Cd' ;
%         Cm_polo_k(contatore,:) = Cm_polo' ;
        Cl0_k(contatore) = Cl0 ;
        Cla_k(contatore) = Cla ;
        Cd0_k(contatore) = Cd0 ;
        Cm0_k(contatore) = Cm0 ;
        Cma_k(contatore) = Cma ;
        CA_k(contatore) = CA ;
        AlfaLimite_k(contatore) = AlfaLimite ;
        Cm_A_k(contatore) = Cm_A ;
        war_k(contatore) = war ;
        contatore = contatore + 1 ;
        
    end
    
    %% INTERPOLAZIONE e SALVATAGGIO COME FILE .DAT E .MAT
    Re = (ReMin:DeltaRe:ReMax)' ;
%     Cl_k = Cl_k(:,1:size(Alfa_out,2)) ;
%     Cd_k = Cd_k(:,1:size(Alfa_out,2)) ;
%     Cm_polo_k = Cm_polo_k(:,1:size(Alfa_out,2)) ;
    
    ProfiloVsRe = profilo+"_Re.DAT" ;
    id1 = fopen(ProfiloVsRe, 'w+') ;
    Dati_Interpolati_Re = [Re Cl0_k Cla_k Cd0_k Cm0_k Cma_k CA_k AlfaLimite_k Cm_A_k] ;
    fprintf(id1,'%.15g %.15g %.15g %.15g %.15g %.15g %.15g %.15g %.15g\n',Dati_Interpolati_Re') ;
    fclose(id1) ;
    
    %DatiProfilo = importdata(ProfiloVsRe) ;
    Cl0_interpolato = fit(Re,Cl0_k, 'smoothingspline' ) ;
    Cla_interpolato = fit(Re,Cla_k, 'smoothingspline' ) ;
    Cd0_interpolato = fit(Re,Cd0_k, 'smoothingspline' ) ;
    %Cm0_interpolato = fit(DatiProfilo(:,1),DatiProfilo(:,5), 'smoothingspline' ) ;
    %Cma_interpolato = fit(DatiProfilo(:,1),DatiProfilo(:,6), 'smoothingspline' ) ;
    CA_interpolato = fit(Re,CA_k, 'smoothingspline' ) ;
    AlfaLimite_interpolato = fit(Re,AlfaLimite_k, 'smoothingspline' ) ;
    Cm_A_interpolato = fit(Re,Cm_A_k, 'smoothingspline' ) ;

    %InterpolazioneCurvaProfilo
    [~,indiceUpperLower] = max(profilo(:,1) == 0) ;
    profiloUpper_disc = profilo(1:indiceUpperLower,:) ;
    profiloLower_disc = profilo(indiceUpperLower:end,:) ;
    profiloUpper = fit(profiloUpper_disc(:,1),profiloUpper_disc(:,2),'linearinterp') ;
    profiloLower = fit(profiloLower_disc(:,1),profiloLower_disc(:,2),'linearinterp') ;
    dx = 0.02 ;
    [MaxSpessore,indiceMaxSpessore] = max( profiloUpper([0:dx:1]) - profiloLower([0:dx:1]) ) ;
    PosizioneSpessoreMax = (indiceMaxSpessore-1)*dx ;
    
    save(profilo+"_Re.mat",'Cl0_interpolato','Cla_interpolato','Cd0_interpolato','CA_interpolato','AlfaLimite_interpolato','Cm_A_interpolato','profiloUpper','profiloLower','PosizioneSpessoreMax')
    
    % 	ProfiloCl = profilo+"_Cl.DAT" ;
%     id2 = fopen(ProfiloCl, 'w+') ;
%     fprintf(id2,'%.15g %.15g %.15g %.15g %.15g %.15g %.15g %.15g %.15g\n',Cl_k') ;
%     fclose(id2) ;
%     
% 	ProfiloCd = profilo+"_Cd.DAT" ;
%     id3 = fopen(ProfiloCd, 'w+') ;
%     fprintf(id3,'%.15g %.15g %.15g %.15g %.15g %.15g %.15g %.15g %.15g\n',Cd_k') ;
%     fclose(id3) ;
%     
%     ProfiloCm = profilo+"_Cm.DAT" ;
%     id4 = fopen(ProfiloCm, 'w+') ;
%     fprintf(id4,'%.15g %.15g %.15g %.15g %.15g %.15g %.15g %.15g %.15g\n',Cm_polo_k') ;
%     fclose(id4) ;
    
    clear all
    clc
end

