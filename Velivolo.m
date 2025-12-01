%------------------PSEUDO-MICRO-SATELLITE------------------

%function [J_obiettivo,Cl_velivolo,Cd_velivolo,AlfaG,MassaBatterie,MassaMotore,MassaFusolieraMuso_strutturale]  = Velivolo(SpazioProgetto,x,MassaBatterieVera,MassaMotoreVero,MassaFusolieraMuso_strutturaleVera)
 SpazioProgetto = [11 20 15 4 1 11 20 15 4 1 11 20 15 4 1]  ; %Ukmh c0 Diametro_longheroni Lh_su_b ProfiloAla ProfiloCoda percentuale
    syms x
    MassaBatterieVera = 0 ;
    MassaMotoreVero = 0 ;
    MassaFusolieraMuso_strutturaleVera = 0 ;
   cd('/home/edoardo/Scrivania/ALL IN/Progetti/GRETA 2')
   addpath('/home/edoardo/Scrivania/ALL IN/Progetti/GRETA 2')
   addpath('/home/edoardo/Scrivania/ALL IN/Progetti/GRETA 2/Profili_Re')
   addpath('/home/edoardo/Scrivania/ALL IN/Progetti/GRETA 2/Profili.dat')
%tempo = clock ;

%% SPAZIO DI PROGETTO
Ukmh = SpazioProgetto(1) ;
AR = SpazioProgetto(2) ;
TR = SpazioProgetto(3) ;
CordaMedia = SpazioProgetto(4) ;
D_longheroni_root = SpazioProgetto(5) ;
D_longheroni_tip = SpazioProgetto(6) ;
PosizioneRearSpar = SpazioProgetto(7) ;
NumeroCentine = SpazioProgetto(8) ; %Numero di centine per semi-ala
RivestimentoFusoliera = SpazioProgetto(9) ;
DiametroFusoliera = SpazioProgetto(10) ;
Lh_su_b = SpazioProgetto(11) ;
profAla_root = SpazioProgetto(12) ;
profAla_tip = SpazioProgetto(13) ;
Sezione1 = SpazioProgetto(14) ;
profCoda = SpazioProgetto(15) ;
Distribuzione_Batterie = SpazioProgetto(16) ; %Frazione di batterie che va nel muso
PosizionePayload = SpazioProgetto(17) ; %Punto del velivolo a partire dal bordo d'attacco alla radice dalla quale e' comincia il Payload

%% PENALTY FUNCTION
EfficienzaDiPenaltyFunction = 0.01 ;

%% FATTORI DI SICUREZZA
if MassaBatterieVera == 0
    FattoreSicurezzaIncidenza = 0.6 ;
    FattoreMeteo = 0.8 ; %[1 0.8 0.5 0.2] Cielo limpido - Legermente nuvoloso, - parzialmente nuvoloso, completamente nuvoloso
    FattoreDegrado = 1 ; %Fattore di degrado in un ciclo
    FattoreSicurezzaPannelli = FattoreMeteo*FattoreDegrado ;
    FattoreDiSicurezzaSnervamento = 1.5 ;
    Cm_AlfaLimite = -1 ;
    SurplusNotte = 1.5 ;
else
    FattoreSicurezzaIncidenza = 1 ;
    
end

%% ALTITUDINE & LATITUDINE
Latitudine = 0 ; %Latitudine in gradi
Quota_km = 19 - 11*abs(Latitudine)/90 ; %Quota in km della tropopausa
MeseInizio = 1 ;
MeseFine = 12 ;
[Monthly,Hourly,IrradianzaMedia,IrradianzaMax] = MODULO_Irradianza(Latitudine,Quota_km,MeseInizio,MeseFine) ;
%IrradianzaMedia = 960 ;
OreGiorno = 12 ; %Ore di sole a -+ 30° latitudine
OreNotte = 12 - OreGiorno ;
g = 9.81*(1-2*Quota_km/6.38e3) ;

%% MATERIALI
[Materiali] = MODULO_Materiali() ;
E_young = Materiali.CARBONPPEK.ModuloYoung ;
G_taglio = Materiali.CARBONPPEK.ModuloTaglio ;
rhoMateriale_SE = Materiali.CARBONPPEK.Densita ;
SigmaSnervamento = Materiali.CARBONPPEK.Snervamento ; 
rhoMateriale_SNE = Materiali.KEVLAR.Densita ;

%% BATTERIE
Batterie.SionLicerion.DensitaMassa = 640 ;
Batterie.SionLicerion.DensitaVolume = 1300 ;
Batterie.SionLicerion.Rendimento_in = 0.95 ;
Batterie.SionLicerion.Rendimento_out = 0.95 ;
DensitaBatterie = (Batterie.SionLicerion.DensitaVolume/Batterie.SionLicerion.DensitaMassa)*1e3 ; %Densita in kg/m3
RendimentoCatenaBatterie = Batterie.SionLicerion.Rendimento_out*Batterie.SionLicerion.Rendimento_in ;

Wh_kg = Batterie.SionLicerion.DensitaMassa ;
Wh_l = Batterie.SionLicerion.DensitaVolume ;

%% PROPULSIONE
RendimentoPropulsivo.RendimentoController = 0.95 ;
RendimentoPropulsivo.RendimentoMotore = 0.85 ;
RendimentoPropulsivo.RendimentoGearBox = 0.97 ;
RendimentoPropulsivo.RendimentoPropeller = 0.85 ;
RendimentoCatenaPropulsiva = RendimentoPropulsivo.RendimentoPropeller*RendimentoPropulsivo.RendimentoGearBox*RendimentoPropulsivo.RendimentoMotore*RendimentoPropulsivo.RendimentoController ;

%% PANNELLI FOTOVOLTAICI E MaximumPowerPointTracker
RendimentoPannelli = 0.3 ;
DimensioneCelle = 0.01 ; % in mq
Rendimento_MPPT = 0.97 ;

%% AERODINAMICA 2D

% ALA
U = Ukmh/3.6 ; % Velocita d'avanzamento del velivolo
[TemperaturaEsterna_K,VelocitaSuono,P_statica,rhoAria] = atmosisa(Quota_km*1e3) ;
P_Dinamica = 0.5*rhoAria*(U^2) ;
TemperaturaEsterna_C = TemperaturaEsterna_K - 273.15 ; %Temperatura esterna in °C
ViscositaCinematica = 1.0e-04*( 0.0001*(Quota_km)^2 - 0.0043*Quota_km + 0.1798 ) ; %[1.79 1.76 1.63 1.46 1.42 1.42 1.45]*1e-5 0 1km 5km 10km 15km 20km 25km
Mach = U/VelocitaSuono ;
Re = double( rhoAria*CordaMedia*U/ViscositaCinematica ) ;
Xfoil = 1 ; %1 per usare i coefficienti gia interpolati, 2 per richiamare Xfoil
ProfiliAla = [["WE.DAT"] ["NACA0012H.DAT"] ["AQUILASM.DAT"] ["SC812.DAT"] ["SC512.DAT"] ["NACA1.DAT"] ["N0009SM.DAT"] ["NACA3320.DAT"] ["S1223.DAT"] ...
    ["HQ212.DAT"] ["HQ112.DAT"] ["FX79W660A.DAT"] ["AH93W480B.DAT"] ["AH94W301.DAT"] ["EPPLER864.DAT"]] ; 
profiloAla_root = ProfiliAla(profAla_root) ; % profilo NACA0012 non gira forse perche incomincia con 0 e non con 1
profiloAla_tip = ProfiliAla(profAla_tip) ;
CampioniAlfa_in = -1:0.2:13 ;
Alfa_a = 0 ; %Incidenza in gradi dalla quale in poi voglio fare l'interpolazione
Alfa_b = 1 ; %Ultima Incidenza dalla quale si fa l'interpolazione
[Cl0_root,Cla2D_root,Cd0_root,Cm_A_root,CA_root,AlfaLimite_root,Cl_root,Cd_root,Cm_p_root,CampioniAlfa_root] = MODULO_Aerodinamica2D(Xfoil,profiloAla_root,Re,Mach,CampioniAlfa_in,Alfa_a,Alfa_b) ;
[Cl0_tip,Cla2D_tip,Cd0_tip,Cm_A_tip,CA_tip,AlfaLimite_tip,Cl_tip,Cd_tip,Cm_p_tip,CampioniAlfa_tip] = MODULO_Aerodinamica2D(Xfoil,profiloAla_tip,Re,Mach,CampioniAlfa_in,Alfa_a,Alfa_b) ;
b_SA = 5 ; %%
%eOswald = FattoreDiOswald(TR,AR,0,0,0,b_SA) ;
SezioneCambioProfilo = Sezione1*b_SA ;
Cl0 = Cl0_root*rectangularPulse(0,SezioneCambioProfilo,x) + Cl0_tip*rectangularPulse(SezioneCambioProfilo,b_SA,x) ;
Cla2D = Cla2D_root*rectangularPulse(0,SezioneCambioProfilo,x) + Cla2D_tip*rectangularPulse(SezioneCambioProfilo,b_SA,x) ;
Cm_A = Cm_A_root*rectangularPulse(0,SezioneCambioProfilo,x) + Cm_A_tip*rectangularPulse(SezioneCambioProfilo,b_SA,x) ;
CA = CA_root*rectangularPulse(0,SezioneCambioProfilo,x) + CA_tip*rectangularPulse(SezioneCambioProfilo,b_SA,x) ;
AlfaLimite = AlfaLimite_root*rectangularPulse(0,SezioneCambioProfilo,x) + AlfaLimite_tip*rectangularPulse(SezioneCambioProfilo,b_SA,x) ;
%AlfaLimite = min(AlfaLimite,AlfaLimite_tip) ;
Cd0AlaMedio = (Cd0_root*Sezione1 + Cd0_tip*(b_SA-Sezione1) )/b_SA ;

% CODA
ProfiliCoda_h = [["NACA0012H.DAT"] ["NACA1.DAT"] ["N0009SM.DAT"]] ; 
profiloCoda_h = ProfiliCoda_h(2) ;
CordaMediaCoda_h = 1 ; %%
ReCoda = double( rhoAria*CordaMediaCoda_h*U/ViscositaCinematica ) ;
CampioniAlfa_in_coda = -1:0.2:13 ;
Alfa_a_coda = 0 ; %Incidenza in gradi dalla quale in poi voglio fare l'interpolazione
Alfa_b_coda = 1 ; %Ultima Incidenza dalla quale si fa l'interpolazione
[Cl0_Coda_h,ClaCoda2D_h,Cd0_Coda_h,Cm_A_Coda_h,CA_Coda_h,AlfaLimiteCoda_h,Cl_Coda_h,Cd_Coda_h,Cm_p_Coda_h,CampioniAlfa_Coda_h] = MODULO_Aerodinamica2D(Xfoil,profiloCoda_h,ReCoda,Mach,CampioniAlfa_in_coda,Alfa_a_coda,Alfa_b_coda) ;
TRcoda_h = 1 ; AR_coda_h = 10 ; bCoda = 2 ; %%
%eOswal_coda = FattoreDiOswald(TRcoda_h,AR_coda_h,0,0,0,bCoda/2) ;

profiloCoda_v = ProfiliCoda_h(1) ;
[Cl0_Coda_v,ClaCoda2D_v,Cd0_Coda_v,Cm_A_Coda_v,CA_Coda_v,AlfaLimiteCoda_v,Cl_Coda_v,Cd_Coda_v,Cm_p_Coda_v,CampioniAlfa_Coda_v] = MODULO_Aerodinamica2D(Xfoil,profiloCoda_v,ReCoda,Mach,CampioniAlfa_in_coda,Alfa_a_coda,Alfa_b_coda) ;

%% AERODINAMICA 3D
[Gamma_Alfa,Gamma_0,eOswald] = MODULO_Aerodinamica3D(50,b,Cla2D,Cl0,U,x,c) ;
Cla3DMedio = ( (Cla2D_root/(1+Cla2D_root/(pi*AR*eOswald)))*Sezione1 + (Cla2D_tip/(1+Cla2D_tip/(pi*AR*eOswald)))*(b_SA-Sezione1) )/b_SA ; %Clalfa di sezione nella teoria del filetto portante
K_Ala = 1/(pi*AR*eOswald) ;
[Gamma_Alfa_coda_h,Gamma_0_coda_h,eOswald_coda] = MODULO_Aerodinamica3D(50,bCoda_h,ClaCoda2D_h,Cl0_Coda_h,U,x,cCoda_h) ;
Cla3DCoda_h = ClaCoda2D_h/( 1 + ClaCoda2D_h/(pi*AR_coda_h*eOswald_coda) ) ;
K_coda_h = 1/(pi*AR*eOswald_coda) ;

%% VINCOLO CL_ALFA
% if ( Cla <= 0 )
%     Efficienza = EfficienzaDiPenaltyFunction ;
%     J_obiettivo = 1/Efficienza ;
%     warning("RUN SOSPESO -- CL_{ALFA} NEGATIVO! ") ;
%     return
% end
% 
% if (AlfaLimite <= 0 || AlfaLimiteCoda <= 0)
%     AlfaLimite = abs(AlfaLimite) ;
%     AlfaLimiteCoda = abs(AlfaLimiteCoda) ;
% end

%% GEOMETRIA VELIVOLO

% GEOMETRIA ALA
b_SA = AR*CordaMedia/2 ; %SEMI-APERTURA ALARE
b = 2*b_SA ; %APERTURA ALARE
DistribuzioneCorda = ( 1 - (1-TR)*x/b_SA ) ;
c0 = 2*CordaMedia/(1+TR) ;
c = c0*DistribuzioneCorda ; % Corda della sezione
%CordaMedia = c0*(1+TR)/2 ;
SuperficieAla = CordaMedia*b ; % Superficie in pianta della ala trapezoidale
SuperficieBagnata_Ala = ( LunghezzaProfilo(profiloAla_root,CordaMedia)*Sezione1 + LunghezzaProfilo(profiloAla_tip,CordaMedia)*(1-Sezione1) )*b ;
%AltezzaWingLet = 0.3 ;

% GEOMETRIA CODA
Vh =  0.5 ; %( 0.35 + 0.5 + 0.464 + 0.6 + 0.3 )/5 ; %Volume di coda orizontale per Aliante
Vv = ( 0.014 + 0.02 )/2 ; %Volume di coda verticale per Aliante
Lh = b*Lh_su_b ; %Distanza fra il Centro Aerodinamico dell'ala e il piano di coda orizzontale
Lv = Lh ; %Distanza fra il Centro Aerodinamico dell'ala e il piano di coda verticale
SuperficieCoda_h = Vh*SuperficieAla*CordaMedia/Lh ; %Lh distanza orizontale fra centro aerodinamico ala e la coda
SuperficieCoda_v = Vv*SuperficieAla*b/Lv ; %Lv distanza verticale fra centro aerodinamico ala e la coda
AR_coda_h = 10 ; %Da Rhymer
bCoda_h = sqrt(AR_coda_h*SuperficieCoda_h) ;
CordaMediaCoda_h = SuperficieCoda_h/bCoda_h ;
SuperficieBagnata_Coda_h = LunghezzaProfilo(profiloCoda_h,CordaMediaCoda_h)*bCoda_h ;
TRcoda_h = 0.36 ;
c0Coda_h = CordaMediaCoda_h*2/(1+TRcoda_h) ;
cCoda_h = c0Coda_h*( 1 - (1-TRcoda_h)*x/bCoda_h/2 ) ;
AR_coda_v = 1.5 ; %Da Rhymer
bCoda_v = sqrt(AR_coda_v*SuperficieCoda_v) ;
CordaMediaCoda_v = SuperficieCoda_v/bCoda_v ;
TRcoda_v = 0.6 ;
c0Coda_v = CordaMediaCoda_v*2/(1+TRcoda_v) ;

% GEOMETRIA FUSOLIERA
SezioneFusoliera = 0.25*pi*DiametroFusoliera^2 ;
LunghezzaFusoliera = Lh + c0*CA_root ; %La fusoliera comincia al bordo d'attacco dell'ala alla radice
VolumeFusoliera = SezioneFusoliera*LunghezzaFusoliera ;
SuperficieBagnata_Fusoliera = pi*DiametroFusoliera*LunghezzaFusoliera ;
SuperficieFusoliera = DiametroFusoliera*LunghezzaFusoliera ;

% GEOMETRIA CARRELLO
AltezzaCarrello = 0.5 ;
LarghezzaCarrello = 0.2 ;
PosizioneCarrelloAla = b_SA*0.7 ; %Posizione del carrelo sulla semiala dalla radice
PosizioneCarrelloFusoliera = LunghezzaFusoliera*0.75 ;
NumeroCarrelli = 3 ;

%GEOMETRIA MOTORE
LarghezzaMotore = c0/10 ; %Larghezza del motore. Serve per calcolare il carico distribuito associato al motore
PosizioneMotore = b_SA*0.5 ; %Posizione del motore lungo x dalla radice

%GEOMETRIA PANNELLI
PercentualePanneli = 0.95 ;
SuperficiePannelli = PercentualePanneli*(SuperficieBagnata_Coda_h + SuperficieBagnata_Fusoliera + SuperficieBagnata_Ala ) ;

%GEOMETRIA PAYLOAD
DimensionePayload = 0.7 ;

%% CASSONE ALARE
Spessore_rivestimento = 0.0005 ;
N_longheroni = 2 ;
PosizioneFrontSpar = Max_Spessore(profiloAla_root) ;

[J,Iy,AreaMaterialeCassone,AreaCassone,PerimetroCassone,CentroElastico,CentroideCassone,boom,AltezzaMaxCassone] = MODULO_CassoneAlare(x,D_longheroni_root, ...
    D_longheroni_tip,Spessore_rivestimento,N_longheroni,profiloAla_tip,c,b_SA,PosizioneFrontSpar,PosizioneRearSpar,profiloUpper,profiloLower) ;

larghezzaCassoneMedio = (PosizioneRearSpar - PosizioneFrontSpar)*CordaMedia ;

%OFFSET AERODINAMICO
%e_EQuartoDiCorda = vpa( CentroElastico(1) - 0.25*c ) ; %Distanza in segno fra il centro elastico e il quarto di corda del profilo -- ci passo c0 perche l'ala e' dritta e quindi la linea dei quarti di corda e' allineata
e_EA = vpa( CentroElastico(1) - CA_root*c ,3) ; % Off-set aerodinamico, positivo se centro Aerodinamico avanti a quello Elastico

%% POTENZA PAYLOAD
PotenzaPayload = 50 ; %PotenzaPersa dal Payload per semi-velivolo %Per micro-satelliti -> satelliti con payload inferiore ai 100 kg %( 2*1e3 + 4.8*1e3 + 42 + 520 )/4 ; %1kW
PotenzaAvionica = 0 ; %Percentuale di potenza persa per i controlli rispetto alla potenza persa per l'avanzamento

%% MASSE E DISTRIBUZIONE DEI PESI

CoeffMassaCarrello = 0.046 ; %MassaCarrelli 2.5 - 5 % del totale
coeffMassaAvionica = 0.015 ; %Da Rhymer 1-3% del totale
CoeffMassaMotore = ( 0.0033 + 0.0012 + 0.0008 + 0.007 )/4 ;

DensitaSuperficiale_celle = 0.170 ; %AltaDevics Kg/mq

%MASSA ALA
SpessoreCentina = 0.01 ;
AltezzaCentina = 0.02 ;
AreaCentine = PerimetroCassone*AltezzaCentina*SpessoreCentina*dirac( x - linspace(0,b_SA,NumeroCentine) ) ;
MSez_strutturalmenteEfficace = vpa( AreaMaterialeCassone + AreaCentine , 4 )*rhoMateriale_SE ;
MSez_strutturalmenteInefficaceAla = Spessore_rivestimento*c*( LunghezzaProfilo(profiloAla_root,1)*(1-(PosizioneRearSpar-PosizioneFrontSpar))*Sezione1 + LunghezzaProfilo(profiloAla_tip,1)*(1-(PosizioneRearSpar-PosizioneFrontSpar))*(1-Sezione1) )*rhoMateriale_SNE ;
MassaCelleAla = (DensitaSuperficiale_celle*SuperficieBagnata_Ala/2)*PercentualePanneli ; % kg/m
MSez_CelleAla = MassaCelleAla/c ;
MassaStrutturalmenteEfficaceAla = 2*double( int( MSez_strutturalmenteEfficace , [0 b_SA] ) ) ;
MassaStrutturalmenteInefficaceAla = 2*double( int( MSez_strutturalmenteInefficaceAla , [0 b_SA] ) ) ;
MassaAla = MassaStrutturalmenteInefficaceAla + MassaStrutturalmenteEfficaceAla + MassaCelleAla ;

%MASSA PAYLOAD
Payload = 50 ;

%MASSA FUSOLIERA
MassaStrutturaleFusoliera = RivestimentoFusoliera*SuperficieBagnata_Fusoliera*rhoMateriale_SE ;
McelleFusoliera = DensitaSuperficiale_celle*(SuperficieBagnata_Fusoliera/2)*PercentualePanneli ;
MassaFusoliera = MassaStrutturaleFusoliera + McelleFusoliera ;
MSezFusoliera = MassaStrutturaleFusoliera/LunghezzaFusoliera ;

%MASSA PIANI DI CODA
McelleCoda = DensitaSuperficiale_celle*(SuperficieBagnata_Coda_h/2)*PercentualePanneli ;
MassaCoda_h = MassaStrutturalmenteInefficaceAla*SuperficieCoda_h/SuperficieAla + MassaStrutturalmenteEfficaceAla*AR_coda_h/AR + McelleCoda ;
MassaCoda_v = MassaStrutturalmenteInefficaceAla*SuperficieCoda_v/SuperficieAla + MassaStrutturalmenteEfficaceAla*AR_coda_v/AR ;
MassaCoda = MassaCoda_h + MassaCoda_v ;
%Da dati per alianti la coda pesa per il 6.7 % sulla massa totale

%MAXIMUM POWER POINT TRACKER MASS
CoefMassaMPPT = 0.00042 ;
Massa_MPPTM = CoefMassaMPPT*IrradianzaMax*RendimentoPannelli*Rendimento_MPPT*SuperficiePannelli ;

%MASSA CELLE SOLARI
MassaCelle = SuperficiePannelli*DensitaSuperficiale_celle ; %Massa delle celle per semi-velivolo
NumeroTotCelle = SuperficiePannelli/DimensioneCelle ;

%MASSA STIMATA
beta = ( SurplusNotte*OreNotte/(RendimentoCatenaBatterie*RendimentoCatenaPropulsiva) )/(Batterie.SionLicerion.DensitaMassa) ;
A = K_Ala*g*beta/(P_Dinamica*SuperficieAla*(1-CoeffMassaMotore-CoeffMassaCarrello-coeffMassaAvionica)) ;
B = -1 ;
C = (MassaFusoliera + MassaAla + MassaCoda + Massa_MPPTM + ( PotenzaPayload + PotenzaAvionica + P_Dinamica*( SuperficieAla*Cd0AlaMedio + ...
    SuperficieCoda_h*Cd0_Coda_h + SuperficieCoda_v*Cd0_Coda_v) )*beta )/(1-CoeffMassaMotore-CoeffMassaCarrello-coeffMassaAvionica) ;
MassaStimata = (-B + sqrt(B^2 - 4*A*C) )/(2*A) ;

D_rigido = P_Dinamica*( SuperficieAla*Cd0AlaMedio + SuperficieCoda_h*Cd0_Coda_h + SuperficieCoda_v*Cd0_Coda_v) + K_Ala*(MassaStimata*g/(P_Dinamica*SuperficieAla))^2 ;
PotenzaCruise_rigido = D_rigido*U ;
PotenzaConsumata = PotenzaPayload + PotenzaAvionica + PotenzaCruise_rigido/(RendimentoCatenaBatterie*RendimentoCatenaPropulsiva) ;

%MASSA BATTERIE
[MassaBatterie] = MODULO_Batterie(OreGiorno,PotenzaConsumata,RendimentoCatenaBatterie,Batterie,SurplusNotte) ;

%MASSA MUSO
MassaMusoBatterie = MassaBatterie*Distribuzione_Batterie ;
if PosizionePayload < 0
    LunghezzaMuso = 4*(( (DiametroFusoliera^2)*pi/4 )/DensitaBatterie ) + PosizionePayload*DimensionePayload ;
else
    LunghezzaMuso = 4*(( (DiametroFusoliera^2)*pi/4 )/DensitaBatterie ) ;
end
SuperficieBagnata_Muso = pi*DiametroFusoliera*LunghezzaMuso ;
SuperficieMuso = DiametroFusoliera*LunghezzaMuso ;
MassaCelleMuso = SuperficieBagnata_Muso*DensitaSuperficiale_celle*PercentualePanneli ;
MassaMuso_strutturale = MassaStrutturaleFusoliera*LunghezzaMuso/LunghezzaFusoliera ;
MassaMuso = MassaMusoBatterie + MassaCelleMuso + MassaMuso_strutturale ;

%MASSA MOTORE
[MassaMotore,DiametroElica] = MODULO_Propulsione(PotenzaCruise_rigido,U) ;
if MassaMotoreVero > 0
    MassaMotore = MassaMotoreVero ;
end
NumeroMotori = ceil( 2*DiametroElica/(DiametroFusoliera + AltezzaCarrello) ) ;
MSez_motore = (MassaMotore/LarghezzaMotore)*rectangularPulse(PosizioneMotore-LarghezzaMotore/2,PosizioneMotore+LarghezzaMotore/2, x ) ;

%MASSA CARRELLO
MassaCarrello = CoeffMassaCarrello*MassaStimata/NumeroCarrelli ;
MsezAla_carrello = (MassaCarrello/LarghezzaCarrello)*rectangularPulse(PosizioneCarrelloAla-LarghezzaCarrello/2,PosizioneCarrelloAla+LarghezzaCarrello/2, x ) ;
MsezFusoliera_carrello = (MassaCarrello/LarghezzaCarrello)*rectangularPulse(PosizioneCarrelloFusoliera-LarghezzaCarrello/2,PosizioneCarrelloFusoliera+LarghezzaCarrello/2, x ) ;

%MASSA AVIONICA
MassaAvionica = MassaStimata*coeffMassaAvionica ; %Da Rhymer 1-3% del totale

VolumeBatterieAla = 4*(MassaAla_batterie/DensitaBatterie) ;
VolumeBatterieFusoliera = 4*(MassaFusoliera_batterie/DensitaBatterie) ;
AperturaSemiAlareOccupataBatterie = 0.5*double( subs(VolumeBatterieAla/AreaCassone,x,b_SA/2 ) ) ; %Apertura della semi-ala occupata da meta batterie in m
LunghezzaFusolieraOccupataBatterie = VolumeBatterieFusoliera/SezioneFusoliera ;

%MASSA MATERIALE ISOLANTE
rhoIsolante = 1.9 ; %Densita Aerogel
CunducibilitaTermicaIsolante = 0.013 ; %Conducibilita termica aerogel
T_Batterie = 35 ; %Temperatura ottimale di funzionamento delle batterie
DeltaT_batterie = abs(TemperaturaEsterna_C-T_Batterie) ;
CaloreBatterie = (1-RendimentoCatenaBatterie)*MassaBatterie*(Wh_kg)/12 ;
CaloreBatterieFusoliera = 0 ;
CaloreBatterieMuso = CaloreBatterie*Distribuzione_Batterie ;
CaloreBatterieSemiAla = CaloreBatterie*(1-Distribuzione_Batterie) ;
SuperficieIsolanteAla = double( 2*AperturaSemiAlareOccupataBatterie*( subs(PerimetroCassone,x,AperturaSemiAlareOccupataBatterie) ) + 2*subs(AreaCassone,x,AperturaSemiAlareOccupataBatterie) ) ;
SuperficieIsolanteFusoliera = LunghezzaFusolieraOccupataBatterie*DiametroFusoliera*pi + 2*0.25*pi*(DiametroFusoliera^2) ;
SuperficieIsolanteMuso = LunghezzaMuso*DiametroFusoliera*pi + 2*0.25*pi*(DiametroFusoliera^2) ;
Spessore_IsolanteAla = (DeltaT_batterie*SuperficieIsolanteAla*CunducibilitaTermicaIsolante)/(2*CaloreBatterieSemiAla) ;
Spessore_IsolanteMuso = (DeltaT_batterie*SuperficieIsolanteMuso*CunducibilitaTermicaIsolante)/CaloreBatterieMuso ;
MassaIsolanteAla = rhoIsolante*SuperficieIsolanteAla*Spessore_IsolanteAla ;
MassaIsolanteFusoliera = 0 ;
MassaIsolanteMuso = rhoIsolante*SuperficieIsolanteMuso*Spessore_IsolanteMuso ;
MassaIsolante = MassaIsolanteAla + MassaIsolanteFusoliera + MassaIsolanteMuso ;

%---------- AGGIORNAMENTO MASSA ALA ------------
MassaAla_batterie = MassaBatterie*(1-Distribuzione_Batterie) ;
MSezSemiAla_batterie = round( 0.5*MassaAla_batterie/AperturaSemiAlareOccupataBatterie , 3 )*rectangularPulse(0,AperturaSemiAlareOccupataBatterie, x ) ;
mSezSemiAla = vpa( MSez_strutturalmenteEfficace + MSez_strutturalmenteInefficaceAla + MsezAla_carrello + MSezSemiAla_batterie + MSez_motore + MSez_CelleAla, 4) ;
MassaAla = 2*double( int(mSezSemiAla,[0 b_SA]) ) + MassaIsolanteAla ;

%---------- AGGIORNAMENTO MASSA FUSOLIERA ------------
MassaFusoliera_batterie = 0 ;
MSezFusoliera = MSezFusoliera + MsezFusoliera_carrello ;
MassaFusoliera = MassaFusoliera + MassaFusoliera_batterie + MassaIsolanteFusoliera ;

%---------- AGGIORNAMENTO MASSA MUSO ------------
MassaMuso = MassaMuso + MassaIsolanteMuso ;

% MASSA DEL VELIVOLO
MassaVelivolo = double( MassaAla + MassaFusoliera + MassaCoda + MassaMuso + MassaCarrello + Payload + MassaAvionica + Massa_MPPTM ) ;
"MASSA DEL VELIVOLO = "+num2str( round(MassaVelivolo,1) )+" kg"

% DEFINIZIONE DEI PESI
PesoAla = MassaAla*g ; % Peso della semi-ala
PesoFusoliera = MassaFusoliera*g ;
PesoCoda = MassaCoda*g ; %peso Piani di coda totali
PesoMuso = MassaMuso*g ;
PesoCarrelli = MassaCarrello*NumeroCarrelli*g ;
PesoPayload = Payload*g ;
PesoAvionica = MassaAvionica*g ;
PesoMPPT = Massa_MPPTM*g ;
Peso = MassaVelivolo*g ; %Peso che deve sostenere una semiala, ho aggiunto il carrello sulla fusoliera

%BARICENTRO DELLA SEZIONE, OFF-SET INERZIALE E BARICENTRO AEREO
BaricentroProfiloAlare = vpa( ( sum(load(profiloAla_root),1)/size(load(profiloAla_root),1) )*[1;0]*c + (c0-c)*CA , 4) ; %Coordinata lungo la corda del Baricentro del profilo
BaricentroCassone = e_EA + c0*CA ; %Valutato a partire dal bordo d'attacco della sezione x
BaricentroCarrelloAli = double( subs( c,x,PosizioneCarrelloAla )/2 ) + c0*CA_root - double( subs( c,x,PosizioneCarrelloAla ))*CA ;
BaricentroAla = double( int(( MSez_strutturalmenteEfficace*BaricentroCassone + MSezSemiAla_batterie*BaricentroCassone + BaricentroCarrelloAli*MsezAla_carrello + MSez_strutturalmenteInefficaceAla*BaricentroProfiloAlare ),[0 b_SA])/MassaSemiAla ) ;
BaricentroFusoliera = LunghezzaFusoliera/2 ; % (LunghezzaFusoliera/2 + CordaMedia) ; Supponendo che la fusoliera cominci al Bordo d'attacco dell'ala
BaricentroCoda = Lh + CA_root*c0 ;
BaricentroMuso = -LunghezzaMuso*0.5  ;
BaricentroPayload = PosizionePayload*DimensionePayload/2 ;
BaricentroMPPT = c0/5 ;
BaricentroAvionica = c0/3 ;
BaricentroAereo = ( BaricentroAla*MassaAla + BaricentroFusoliera*MassaFusoliera + BaricentroCoda*MassaCoda + BaricentroMuso*MassaMuso + Payload*BaricentroPayload + MassaCarrello*PosizioneCarrelloFusoliera + BaricentroMPPT*Massa_MPPTM + BaricentroAvionica*MassaAvionica )/MassaVelivolo ;

%OFFSET INERZIALE
e_EG = vpa( BaricentroAla - CentroElastico(1) ,3) ; % Off-set inerziale, positivo se Baricentro della sezione dietro al centro Elastico

%% FATTORE DI CARICO VERTICLE
FattoreCaricoVerticale = 2.1 + (24000/(Peso + 10000)) ;

%% VINCOLO SUL PESO
%     if ( 2*Peso/g > 700 )
%         Efficienza = EfficienzaDiPenaltyFunction ;
%     	J_obiettivo = EfficienzaDiPenaltyFunction ;
%         warning("RUN SOSPESO -- PESA TROPPO! ") ;
%         return
%     end

%% EQUILIBRIO ROTAZIONE
MomentoAeroAla_A = 2*round( int(Cm_A*P_Dinamica*(c^2),[0 b_SA]) ) ; %Momento Aerodinamico dell'ala rispetto al CentroAerodinamico dell'ala
MomentoAeroCoda_A = round( Cm_A_Coda_h*P_Dinamica*CordaMediaCoda_h*SuperficieCoda_h ) ; %Momento Aerodinamico della coda rispetto al CentroAerodinamico della coda
%BraccioCoda = (Lh + CA*c0) - BaricentroAereo ; %Distanza fra quarto di corda della coda e il baricentro del velivolo
BraccioPortanza = (BaricentroAereo - CA_root*c0) ; %Distanza fra CA dell'ala e il baricentro del velivolo
Segno = BraccioPortanza/abs(BraccioPortanza) ; %Segno del momento concentrato, devono essere positivi se la portanza si trova dietro al CA, e negativi viceversa
AlfaCoda = double( (Peso*BraccioPortanza - (MomentoAeroAla_A + MomentoAeroCoda_A)*Segno - SuperficieCoda_h*P_Dinamica*Cl0_Coda_h*Lh )/( SuperficieCoda_h*P_Dinamica*Cla3DCoda_h*Lh ) ) ;
AlfaCodaG = AlfaCoda*180/pi ;
L_coda = P_Dinamica*SuperficieCoda_h*( Cl0_Coda_h + Cla3DCoda_h*AlfaCoda ) ;
PesoCorretto = double( Peso - L_coda ) ;
D_coda = P_Dinamica*SuperficieCoda_h*Cd0_Coda_h + K_coda_h*(L_coda^2) + P_Dinamica*SuperficieCoda_v*Cd0_Coda_v ;

%% VINCOLO INCIDENZA DELLA CODA
if ( (AlfaCodaG > AlfaLimiteCoda_h*FattoreSicurezzaIncidenza) || (AlfaCodaG < -2.5 ) )
    Efficienza = EfficienzaDiPenaltyFunction ;
    J_obiettivo = 1/Efficienza ;
    warning("VELIVOLO NON VOLANTE -- INCIDENZA CODA ELEVATA: "+num2str(AlfaCodaG)+" °")
    return
end

%% STABILITA STATICA LONGITUDINALE
eta = 0.995 ; % (1+0.99)/2
Deps = 2*Cla/(pi*AR*eOswald) ; %ClaCoda
Cla_velivolo = Cla3DMedio + (SuperficieCoda_h/SuperficieAla)*eta*( 1 - Deps )*Cla3DCoda_h ;
Cm_G_Alfa = Cla_velivolo*( (BaricentroAereo - CA_root*c0)/CordaMedia ) - Cla3DCoda_h*( 1 - Deps )*eta*Vh ; %Dell'intero velivolo
PuntoNeutro = CA_root*c0/CordaMedia + eta*Vh*(Cla3DCoda_h/Cla_velivolo)*( 1 - Deps ) ;
MargineStatico = PuntoNeutro - BaricentroAereo/CordaMedia ; %Deve essere positivo
%Cm_G_Alfa = Cla_velivolo*(-MargineStatico) ;

%VERIFICA SULLA STABILITA
if Cm_G_Alfa > Cm_AlfaLimite
    J_obiettivo = 1/EfficienzaDiPenaltyFunction ;
    warning("VELIVOLO NON VOLANTE -- INSTABILE: "+num2str(Cm_G_Alfa))
    return
end

%% POTENZA PERSA PER RISCALDAMENTO
if MassaIsolanteAla ~= 0
    PotenzaPersaRiscaldamentoSemiAla = round( CunducibilitaTermicaIsolante*(DeltaT_batterie/Spessore_IsolanteAla)*SuperficieIsolanteAla - CaloreBatterieSemiAla ) ;
else
    PotenzaPersaRiscaldamentoSemiAla = 0 ;
end
if MassaIsolanteFusoliera ~= 0
    PotenzaPersaRiscaldamentoFusoliera = round( rhoIsolante*CunducibilitaTermicaIsolante*DeltaT_batterie*( SuperficieIsolanteFusoliera/MassaIsolanteFusoliera ) - CaloreBatterieFusoliera ) ;
else
    PotenzaPersaRiscaldamentoFusoliera = 0 ;
end
if MassaIsolanteMuso ~= 0
    PotenzaPersaRiscaldamentoMuso = round( CunducibilitaTermicaIsolante*(DeltaT_batterie/Spessore_IsolanteMuso)*SuperficieIsolanteMuso - CaloreBatterieMuso ) ;
else
    PotenzaPersaRiscaldamentoMuso = 0 ;
end

PotenzaPersaRiscaldamento = PotenzaPersaRiscaldamentoSemiAla + PotenzaPersaRiscaldamentoFusoliera/2 + PotenzaPersaRiscaldamentoMuso/2 ;

% syms tiso
% fplot(CunducibilitaTermicaIsolante*(DeltaT_batterie/tiso)*SuperficieIsolanteAla/2 - CaloreBatterieSemiAla,[0 0.05])
% xlabel("Spessore isolante [m]")
% ylabel("Flusso di calore netto scambiato [W]")

%% TRIM RIGIDO
AlfaR = ( PesoCorretto - P_Dinamica*SuperficieAla*Cl0 )/( P_Dinamica*SuperficieAla*Cla3DMedio ) ;
AlfaRG = AlfaR*180/pi ;

%% VERIFICA SUL VELIVOLO RIGIDO

%VERIFICA SULLA INCIDENZA
if AlfaRG > 1.5*AlfaLimite*FattoreSicurezzaIncidenza
    Efficienza = EfficienzaDiPenaltyFunction ;
    J_obiettivo = 1/Efficienza ;
    warning("VELIVOLO NON VOLANTE -- INCIDENZA RIGIDA ALTA: "+num2str(AlfaR*180/pi)+" °")
    return
end

%% AEROELASTICITA 3D
[w,Theta,wDisc,ThetaDisc,wMax,ThetaMax] = MODULO_Aeroelasticita(x,b_SA,Cm_A,e_EA,e_EG,mSezSemiAla,E_young,G_taglio,Iy,J,g,Gamma_Alfa,Gamma_0,AlfaR) ;
%"INCIDENZA DEL VELIVOLO = "+num2str( round(AlfaG,2) )+" °"

%% CARICHI SULL'ALA
L_sez = rhoAria*U*( Gamma_0 + Gamma_Alfa*( AlfaR - (1 + ((1-tan(AlfaR))/(1+(tan(AlfaR))^2))*(tan(AlfaR)/2)*diff(w)^2 )*Theta ) ) ; %carico aerodinamico lungo z di
L_Ala = 2*double( int( L_sez,[0 b_SA]) )  ;
L_velivolo = L_Ala + round(L_coda) ;

%D_sez = P_Dinamica*c*(Cd0_root + ((Cl0_root+Cla*(Alfa-Theta))^2)/(pi*AR*eOswald)) ; %Resistenza di sezione
D_ala = P_Dinamica*SuperficieAla*Cd0AlaMedio + K_Ala*(L_Ala)^2 ; %Resistenza ala
SnellezzaFusoliera = (LunghezzaFusoliera+LunghezzaMuso)/DiametroFusoliera ;
Cd0F = 0.01256*(1+60*((SnellezzaFusoliera)^-3)+(SnellezzaFusoliera)/400)*(SnellezzaFusoliera)*(DiametroFusoliera^2)/SuperficieAla ;
Kf = 0.004*(SnellezzaFusoliera)*DiametroFusoliera/SuperficieAla ;
D_fusoliera = (Cd0F + Kf*L_Ala/(P_Dinamica*Superficie))*SuperficieAla ;
D_velivolo = ( D_ala + D_coda + D_fusoliera )/(1-(NumeroCarrelli/2)/30) ;
D_carrelli = NumeroCarrelli*(1/30)*D_velivolo ;

MomentoAero_E_sez = Cm_A*P_Dinamica*(c^2) + L_sez*e_EA ;
MomentoPeso_E_sez = mSez*g*e_EG ;

"VERIFICA: PORTANZA - PESO = "+num2str( round(L_velivolo-Peso) )+" N" % Verifica L = Peso

Efficienza_ala = round(L_Ala/D_ala ,2 ) ; %Efficienza dell'ala
Efficienza_coda = round(L_coda/D_coda ,2 ) ; %Efficienza della coda
Efficienza = round(L_velivolo/D_velivolo ,2) ; %Efficienza dell'intero velivolo

Taglio = FattoreCaricoVerticale*(L_sez - mSezSemiAla*g) ;
RisultanteTaglio = round( int(Taglio,[0 b_SA])) ;
BraccioTaglio = double( int(Taglio*x,[0 b_SA])/RisultanteTaglio ) ;
MomentoFlettente = round( RisultanteTaglio*BraccioTaglio ) ; %Momento flettente alla radice
%MomentoTorcente_E = MomentoPeso_E_sez + MomentoAero_E_sez ;

%CaricoAlare = L_semiala/Superficie ;

%% COEFFICIENTI DI PORTANZA E RESISTENZA DEL VELIVOLO
Cl_velivolo = L_velivolo/(P_Dinamica*SuperficieAla) ;
Cd_velivolo = D_velivolo/(P_Dinamica*SuperficieAla) ;
Cm0_velivolo_G = -Cm_G_Alfa/Alfa  ;

%% STIMA ANGOLO DIEDRO
%B = 5.5 ;
%Diedro = B*2*b*Cl_velivolo/Lv ; %Blaine Rawdon, from Douglas Aircraft
%% AGGIORNAMENTO DELLA MASSA DELLE BATTERIE CON LA RESISTENZA AGGIORNATA DEL VELIVOLO
% DeltaBatterie = ( (D_velivolo - D_rigido)*U*24/Wh_kg ) ; %Massa di batterie per l'intero velivolo aggiornata alla resistenza corretta, se negative possiamo togliere delle batterie
% MassaBatterie
% MassaBatterieNEW = MassaBatterie + DeltaBatterie ;  %Massa delle batterie per semi-velivolo
% while abs(MassaBatterie - MassaBatterieNEW) > 0.1
%     DeltaBatterie = (DeltaBatterie*g/Efficienza)*U*24/Wh_kg ;
%     MassaBatterie = MassaBatterieNEW ;
%     MassaBatterieNEW = MassaBatterie + DeltaBatterie ;
% end

%SurplusNotte = ( -DeltaBatterie + MassaBatterie/3 )/(MassaBatterie*2/3) ; %Surplus complessivo di batterie, posso volare per 1 notte + 1notte*SurplusNotte

%% VERIFICA PORTANZA-PESO
if ( abs(L_velivolo-Peso) > Peso*0.1 )
    Efficienza = EfficienzaDiPenaltyFunction ;
    J_obiettivo = 1/Efficienza ;
    warning("VELIVOLO NON VOLANTE -- PORTANZA TROPPO DIVERSA DAL PESO")
    return
end

if ( abs(D_rigido-D_velivolo) > max(D_velivolo,D_rigido)*0.25 )
    Efficienza = EfficienzaDiPenaltyFunction ;
    J_obiettivo = 1/Efficienza ;
    warning("VELIVOLO NON VOLANTE -- RESISTENZA RIGIDA TROPPO DIVERSA DA QUELLA ELASTICA")
    return
end

%% VINCOLI

%VINCOLO ENERGETICO
[SuperficieMin] = MODULO_SuperficiePannelli(U,D_velivolo,IrradianzaMedia,OreGiorno,PotenzaPersaRiscaldamento,RendimentoPannelli,RendimentoCatenaBatterie, ...
    PotenzaPayload,RendimentoCatenaPropulsiva,FattoreSicurezzaPannelli,SurplusNotte) ;
ProiezioneStrutturale = bMax/b ;
ProiezioneAssetto = cos(Alfa) ;
SuperficieEfficacePannelli = (SuperficieAla + SuperficieCoda_h + SuperficieFusoliera + SuperficieMuso)*PercentualePanneli*ProiezioneAssetto*ProiezioneStrutturale ;
if ( SuperficieEfficacePannelli < SuperficieMin )
    Efficienza = EfficienzaDiPenaltyFunction ;
    warning(" %d > %d SUPERFICIE ALARA NON SUFFICIENTE AD OSPITARE I PANNELLI FOTOVOLTAICI! ", round(SuperficieMin*2,2), round(SuperficieAla*2),2) ;
end

%VINCOLO DI ASSETTO
if abs(AlfaRG) > FattoreSicurezzaIncidenza*AlfaLimite
    Efficienza = EfficienzaDiPenaltyFunction ;
    warning(" %d > %d ALFA MAGGIORE DI ALFA LIMITE. MODELLO LINEARE NON PiU' VALIDO! ", round(AlfaG,2), round(AlfaLimite),2) ;
end

%VINCOLO SFORZO MASSIMO
Sigma = double( MomentoFlettente*(subs(AltezzaMaxCassone,x,0)/2)/subs(Iy,x,0) ) ;
if ( abs(FattoreDiSicurezzaSnervamento*Sigma) > SigmaSnervamento )
    Efficienza = EfficienzaDiPenaltyFunction ;
    warning(" %d > %d SFORZO MASSIMO TROPPO GRANDE! ") ;
end

%VINCOLO DI BUCKLING
SegmentoLongherone = b_SA/NumeroCentine ;
K_buckling = 0.5 ; %Trave incastrata-incastrata
AreaLongherone = 0.25*pi*D_longheroni_root^2 ;
F_buckling = pi*E_young*Iy/(K_buckling*SegmentoLongherone)^2 ;
if ( abs(Sigma*A) > F_buckling )
    Efficienza = EfficienzaDiPenaltyFunction ;
    warning(" %d > %d LONGHERONE IN BUCKLING! ") ;
end

%VINCOLO SULLA DEFLESSIONE MASSIMA
if ( wMax > 0.05*b_SA )
    Efficienza = EfficienzaDiPenaltyFunction ;
    warning(" DELFESSIONE MASSIMA SUPERATA! ") ;
end

%VINCOLO SULLA TORSIONE MASSIMA
if ( -ThetaMax*180/pi + AlfaRG > AlfaLimite ) %Theta e' positivo verso il basso, se picchiante
    Efficienza = EfficienzaDiPenaltyFunction ;
    warning(" TORSIONE MASSIMA SUPERATA! ") ;
end

%% FUNZIONE OBIETTIVO
if Efficienza == 0
    Efficienza = EfficienzaDiPenaltyFunction ;
end

J_obiettivo = 1/Efficienza ;

"EFFICIENZA = "+num2str( Efficienza )

%% TEMPO GIRATA
%tempo = clock-tempo ;
%"IL TEMPO PER UNA GIRATA E' = "+num2str( round(tempo(6),3) )+" s"

%% GRAFICI
%
% % GRAFICI DEFORMATE
%GraficiDeformate(w,Theta,bMax)
%DeformataATerra(x,b,J,Iy,mSez,e_EG,E_young,G_taglio,PosizioneCarrelloAla,AltezzaCarrello,DiametroFusoliera)
%
% % GRAFICI CARICHI
% GraficiCarichi(L_sez,mSez,Taglio,MomentoAero_E_sez,MomentoPeso_E_sez,MomentoTorcente_E,b,x)
%
% % GRAFICI PROFILO
if Xfoil == 2
    GraficiProfilo(c,CampioniAlfa_root,Cl,Cl0_root,Cla2D_root,profiloAla_root,Mach,Re,Cd_root,Cd0_root,Cm_p_root,Cm_A_root,PoloCm,CA_root,CordaMedia,Dir_Profili,inizioCassone, ...
    larghezzaCassone,fineCassone,Upper,Lower,boom,e_EG,CentroElastico,e_EA,b_SA/2,CampioniAlfaCoda,CdCoda,CACoda, ...
    Cm_pCoda,profiloCoda_h,ReCoda,Cd0Coda,ClCoda,ClaCoda2D_h,Cl0Coda,Cm_ACoda)
end
%end