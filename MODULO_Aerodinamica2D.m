function [Cl0,Cla2D,Cd0,Cm_A,CA,AlfaLimite,Cl,Cd,Cm_p,CampioniAlfa,profiloUpper,profiloLower,PosizioneSpessoreMax] = MODULO_Aerodinamica2D(Xfoil,profiloAla,Re,Mach,CampioniAlfa_in,Alfa_a,Alfa_b,TR,x,b_SA)
%Il Re deve essere quello calcolato alla radice

PoloCm = [0.25 0] ; %Coordinate X ed Y del Polo del Cm in frazioni di corda
Re_tip = Re*TR ;
DeltaRe = ( Re - Re_tip ) ;
Reynolds = Re*( 1 - (1-TR)*x/b_SA ) ;

if Xfoil == 2
    Dir_Profili = "/home/edoardo/Scrivania/ALL IN/Progetti/GRETA2/Profili.dat/" ;
    CampioniAlfa_in = -1:0.2:13 ;
    Alfa_a = 4 ; %Incidenza in gradi dalla quale in poi voglio fare l'interpolazione
    Alfa_b = 5 ; %Ultima Incidenza dalla quale si fa l'interpolazione
    [Cl,Cd,Cm_p,Cl0,Cla2D,CampioniAlfa,AlfaLimite,Cd0,Cm_A,CA] = ProfiloFun(profiloAla,Re,Mach,CampioniAlfa_in,PoloCm,1000,Dir_Profili,Alfa_a,Alfa_b) ;
else
    DatiProfiloRe = load(profiloAla+"_Re.mat") ;
    Cl0_interpolato = DatiProfiloRe.Cl0_interpolato ;
    Cla_interpolato = DatiProfiloRe.Cla_interpolato ;
    Cd0_interpolato = DatiProfiloRe.Cd0_interpolato ;
    CA_interpolato = DatiProfiloRe.CA_interpolato ;
    AlfaLimite_interpolato = DatiProfiloRe.AlfaLimite_interpolato ;
    Cm_A_interpolato = DatiProfiloRe.Cm_A_interpolato ;
    profiloUpper = DatiProfiloRe.profiloUpper ;
    profiloLower = DatiProfiloRe.profiloLower ;
    PosizioneSpessoreMax = DatiProfiloRe.PosizioneSpessoreMax ;
    
    Cl0_Re = ( Cl0_interpolato(Re) - Cl0_interpolato(Re_tip) ) / DeltaRe ;
    Cla2D_Re = ( Cla_interpolato(Re) - Cla_interpolato(Re_tip) ) / DeltaRe ;
    Cd0_Re = ( Cd0_interpolato(Re) - Cd0_interpolato(Re_tip) ) / DeltaRe ;
    % Cm0_Re = ( Cm0_interpolato(Re_root) - Cm0_interpolato(Re_tip) ) / DeltaRe ; 
    % Cma_Re = ( Cma_interpolato(Re_root) - Cma_interpolato(Re_tip) ) / DeltaRe ;
    CA_Re = ( CA_interpolato(Re) - CA_interpolato(Re_tip) ) / DeltaRe ;
    AlfaLimite_Re = ( AlfaLimite_interpolato(Re) - AlfaLimite_interpolato(Re_tip) ) / DeltaRe ;
    Cm_A_Re = ( Cm_A_interpolato(Re) - Cm_A_interpolato(Re_tip) ) / DeltaRe ;
    
    Cl0 = Cl0_interpolato(Re) + Reynolds*Cl0_Re ;
    Cla2D = Cla_interpolato(Re) + Reynolds*Cla2D_Re ;
    Cd0 = Cd0_interpolato(Re) + Reynolds*Cd0_Re ;
    % Cm0 = Cm0_interpolato(Re) + Reynolds*Cm0_Re ;
    % Cma = Cma_interpolato(Re) + Reynolds*Cma_Re ;
    CA = CA_interpolato(Re) + Reynolds*CA_Re ;
    AlfaLimite = AlfaLimite_interpolato(Re) + Reynolds*AlfaLimite_Re ;
    Cm_A = Cm_A_interpolato(Re) + Reynolds*Cl0_Re ;
    
    Cl = 0 ;
    Cd = 0 ;
    Cm_p = 0 ;
    CampioniAlfa = 0 ;
end

end

