% -- PROGETTO SATELLITE A BASSA QUOTA --
clear; clc; close all ;
syms z
Profili = [["WE.DAT"] ["NACA0012H.DAT"] ["AQUILASM.DAT"] ["SC812.DAT"] ["SC512.DAT"] ["NACA1.DAT"] ["N0009SM.DAT"] ["NACA3320.DAT"] ["S1223.DAT"] ...
    ["HQ212.DAT"] ["HQ112.DAT"] ["FX79W660A.DAT"] ["AH93W480B.DAT"] ["AH94W301.DAT"] ["EPPLER864.DAT"]] ;

J_obiettivo = @(SpazioProgetto) Velivolo(SpazioProgetto,z,0,0,0) ;

%VINCOLI DI BOX
lb = [14 30 1 6 1 0 10] ;
ub = [30 50 70 12 13 20 20] ;
%Ukmh,c0,DiametroLongheroni,Lh/b,profiloAla,profiloCoda,DistribuzioneBatterie,Vh
Variabili_Intere = [1,2,3,4,5,6,7] ;

DimensioneSpazioProgetto = size(ub,2) ;

%VINCOLI
A = []; % linear inequality constraints
b = []; % linear inequality constraints
Aeq = []; % linear equality constraints
beq = []; % linear equality constraints
nlconstr= []; % non linear inequality constraints

NumeroGenerazioni = 300 ;
StalloGenerazioni = 50 ;
options = optimoptions('ga','MaxGenerations',NumeroGenerazioni,'MaxStallGenerations',StalloGenerazioni,'PlotFcn',@gaplotbestf) ;
options.PopulationSize = 10*DimensioneSpazioProgetto ;

tempo = clock ;
[ProgettoOttimo,fval] = ga(J_obiettivo,DimensioneSpazioProgetto,[],[],[],[],lb,ub,[],Variabili_Intere,options) ;

tempoImpiegato = clock-tempo ;

minJ = Velivolo(ProgettoOttimo,z,0,0,0) ;
EfficienzaOttima = 1/minJ ;

"----------- CARATTERISTICHE VELIVOLO -----------"

"VELOCITA DI CROCIERA = "+10*ProgettoOttimo(1)+" km/h"
%"ASPECT RATIO = "+ProgettoOttimo(2)+" m"
"CORDA ALLA RADICE = "+ProgettoOttimo(2)/20+" m"
"DIAMETRO EQUIVALENTE DEI LONGHERONI = "+ProgettoOttimo(4)+" mm"
"PROFILO DELL'ALA "+Profili(ProgettoOttimo(6))
"PROFILO DELLA CODA "+Profili(ProgettoOttimo(7))

tempoPerGirata = (tempoImpiegato(4)*3600 + tempoImpiegato(5)*60 + tempoImpiegato(6))/(options.PopulationSize*(NumeroGenerazioni+1))

%[13 55 66 16 7 6 6] ProgettoOttimo Efficienza
%[15 50 61 41 6 1 1] ProgettoOttimo2 Efficienza
%[7 60 70 12 6 9 1] ProgettoOttimo2 Endurance
%[ 13    43    25    16     8    8    10]
%[ 12    34    21     8     8     7]
%[14    40    17    16     8     6 8]
%[24    48    16     9    10     3    16    15] %Eff 54 Alfa ok deflessione 8%
%[27    50    15     8    10     1     3    16]
%[30    48    27    10     5    16    12]