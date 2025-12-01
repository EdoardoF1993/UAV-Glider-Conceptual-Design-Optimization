function [J_torsione,Iy_cassone,AeraMateriale,AreaCassone,PerimetroCassone,CentroElasticoCassone,CentroideCassone,boom,AltezzaMaxCassone] = ...
    MODULO_CassoneAlare(x,D_longheroni_root,D_longheroni_tip,t_rivestimento,N_longheroni,prof,c,b_SA,PosizioneFrontSpar,PosizioneRearSpar,profiloUpper,profiloLower)
% il numero dei correnti deve essere pari per avere cassone simmetrico

N_booms = N_longheroni*2 ;
%N_celle = N_longheroni - 1 ;

if (N_booms/2 - round(N_booms/2) ) ~= 0
    warning("IL NUMERO DI CORRENTI DEVE ESSERE PARI PER AVERE SEZIONE SIMMETRICA")
end

D_longheroni = D_longheroni_root - (D_longheroni_root - D_longheroni_tip)*x/b_SA ;
A_Testa_longherone = pi*(D_longheroni^2)/4 ;

altezzaFrontSpar_u = double( subs( profiloUpper,x,PosizioneFrontSpar) - subs( profiloLower,x,PosizioneFrontSpar) ) ;
altezzaRearSpar_u = double( subs( profiloUpper,x,PosizioneRearSpar) - subs( profiloLower,x,PosizioneRearSpar) ) ;
AreaCassone_u = double( int(profiloUpper,[PosizioneFrontSpar PosizioneRearSpar]) + int(profiloLower,[PosizioneFrontSpar PosizioneRearSpar]) ) ;
larghezza_u = LunghezzaProfilo(prof,1)*(PosizioneRearSpar-PosizioneFrontSpar) ; %( PosizioneRearSpar - PosizioneFrontSpar ) ;
CentroideCassone_u = PosizioneFrontSpar + ( PosizioneRearSpar - PosizioneFrontSpar )/2 ;
CentroElasticoCassone_u = PosizioneFrontSpar + ( PosizioneRearSpar - PosizioneFrontSpar )/2 ;

%DISTRIBUZIONE DELLA DIMENSIONE DEL CASSONE ALARE CON LA SEMI-APERTURA
altezzaFrontSpar = altezzaFrontSpar_u*c ;
altezzaRearSpar = altezzaRearSpar_u*c ;
altezza_rivestimento = ( altezzaFrontSpar + altezzaRearSpar )/2 ; int()
larghezza = larghezza_u*c ;
PerimetroCassone = 2*larghezza + altezzaFrontSpar + altezzaRearSpar ;
inizioCassone = PosizioneFrontSpar*c ;
fineCassone = PosizioneRearSpar*c ;
CentroideCassone = CentroideCassone_u*c ;
CentroElasticoCassone = CentroElasticoCassone_u*c ;
AreaCassone = AreaCassone_u*c^2 ;
boom = linspace(inizioCassone,fineCassone,N_booms/2) ;

J_torsione = vpa( ( 4*(AreaCassone)^2 )*t_rivestimento/PerimetroCassone , 8 ) ;
Iy_cassone = vpa( (A_Testa_longherone)*((altezzaFrontSpar/2)^2) + (A_Testa_longherone)*((altezzaRearSpar/2)^2) + t_rivestimento*larghezza*(altezza_rivestimento/2)^2 , 8 ) ;
AeraMateriale = A_Testa_longherone*N_booms + t_rivestimento*larghezza ;

AltezzaMaxCassone = (max(altezzaFrontSpar_u,altezzaRearSpar_u))*c ;

end