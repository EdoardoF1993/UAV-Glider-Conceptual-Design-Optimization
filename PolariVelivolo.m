%Coefficienti calcolati considerando la superficie in pianta della sola ala
%Polari calcolate mettendo in relazione il coefficiente di forza con l'incidenza dell'ala
contatore = 1 ;
syms x
SpazioProgetto = [ 13    44    25    16     8    8    1] ;
[J_obiettivo,Cl_v,Cd_v,AlfaG_v,MassaBatterieVera,MassaMotoreVero,MassaFusolieraMuso_strutturaleVera]  = Velivolo(SpazioProgetto,x,0,0,0) ;
%MassaBatterieVera e' Da determinare con Velivolo() mettendo la Ukm_h dell'ottimizzazione, e' la massa delle batterie per semi-velivolo
Umin = SpazioProgetto(1) - 4 ;
Umax = SpazioProgetto(1) + 4 ;
clear J_obiettivo

for Ukm_h = Umin:0.1:Umax
    
    SpazioProgetto(1) = Ukm_h ;
    [J_obiettivo] = Velivolo(SpazioProgetto,x,MassaBatterieVera,MassaMotoreVero,MassaFusolieraMuso_strutturaleVera) ;
%     Cl_v = X(2) ;
%     Cd_v = X(3) ; 
%     AlfaG_v = X(4) ;
    if J_obiettivo < 100
        [J_obiettivo, Cl_v, Cd_v, AlfaG_v, massaBatterie] = Velivolo(SpazioProgetto,x,MassaBatterieVera,MassaMotoreVero,MassaFusolieraMuso_strutturaleVera) ;
        Cl_velivolo(contatore) = Cl_v ;
        Cd_velivolo(contatore) = Cd_v ;
        AlfaG(contatore) = AlfaG_v ;
        contatore = contatore + 1 ;
    end
end

CL_info = polyfit(AlfaG*pi/180,Cl_velivolo,1) ;
CL_ALFA = CL_info(1) ;
CL0 = CL_info(2) ;
CD_info = polyfit(Cl_velivolo,Cd_velivolo,2) ;
K = CD_info(1) ;
% AR_ala = SpazioProgetto(2)*4/(0.5*(SpazioProgetto(3)/10)*(1+SpazioProgetto(4)/100)) ;
% e_oswald_velivolo = 1/(K*pi*AR_ala) 
CD1 = CD_info(2) ;
CD0 = CD_info(3) ;
AlfaLimiteUp = AlfaG(1) + (AlfaG(1) - AlfaG(2)) ;
AlfaLimiteLow = AlfaG(end) - (AlfaG(end-1) - AlfaG(end)) ;
[EFFICIENZA_MAX,ASSETTO_EMAX] = max(Cl_velivolo./Cd_velivolo) ;

syms AlfaG_Sym
CL = CL0 + CL_ALFA*AlfaG_Sym*pi/180 ;
CD = CD0 + CD1*(CL0 + CL_ALFA*AlfaG_Sym*pi/180) + K*(CL0 + CL_ALFA*AlfaG_Sym*pi/180)^2 ;
EFFICIENZA = CL/CD ;

Alfa_EfficienzaMax = AlfaG(ASSETTO_EMAX) ; %Assetto di efficienza massima
Alfa_EnduranceMax = round( double( solve(EFFICIENZA - EFFICIENZA_MAX*sqrt(3)/2) ) , 2 ) ; %Assetto di endurance massima

figure(1)
AlfaLow = AlfaLimiteLow - 2 ;
AlfaUp = AlfaLimiteUp + 2 ;
subplot(3,1,1)
fplot(AlfaG_Sym,CL,[AlfaLow AlfaUp],"LineWidth",2)
hold on
plot([AlfaLimiteUp AlfaLimiteUp],[subs(CL,AlfaG_Sym,AlfaLow) subs(CL,AlfaG_Sym,AlfaUp)],'r',"LineWidth",2)
hold on
plot([AlfaLimiteLow AlfaLimiteLow],[subs(CL,AlfaG_Sym,AlfaLow) subs(CL,AlfaG_Sym,AlfaUp)],'--r')
title(["POLARI DEL VELIVOLO","CL-{\alpha}"])
xlabel("{\alpha} [°]")
ylabel("CL")
dim = [.015 .6 .2 .2];
str = {['CL_{\alpha} = ' num2str(CL_ALFA)];['CL_{0} = ' num2str(CL0)]};
nota2 = annotation('textbox',dim,'String',str,'FitBoxToText','on');
nota2.FontSize = 15 ;
subplot(3,1,2)
fplot(AlfaG_Sym,CD,[AlfaLow AlfaUp],"LineWidth",2)
hold on
plot([AlfaLimiteUp AlfaLimiteUp],[subs(CD,AlfaG_Sym,AlfaLow) subs(CD,AlfaG_Sym,AlfaUp)],'r',"LineWidth",2)
hold on
plot([AlfaLimiteLow AlfaLimiteLow],[subs(CD,AlfaG_Sym,AlfaLow) subs(CD,AlfaG_Sym,AlfaUp)],'--r')
title("CD-{\alpha}")
xlabel("{\alpha} [°]")
ylabel("CD")
dim = [.015 .3 .2 .2];
str = {['CD_{0} = ' num2str(CD0)];['CD_{1} = ' num2str(CD1)];['K = ' num2str(K)]};
nota2 = annotation('textbox',dim,'String',str,'FitBoxToText','on');
nota2.FontSize = 15 ;
subplot(3,1,3)
fplot(AlfaG_Sym,EFFICIENZA,[AlfaLow AlfaUp],"LineWidth",2)
hold on
plot([AlfaLimiteUp AlfaLimiteUp],[min(subs(EFFICIENZA,AlfaG_Sym,AlfaLow),subs(EFFICIENZA,AlfaG_Sym,AlfaUp)) EFFICIENZA_MAX],'r',"LineWidth",2)
hold on
plot([AlfaLimiteLow AlfaLimiteLow],[min(subs(EFFICIENZA,AlfaG_Sym,AlfaLow),subs(EFFICIENZA,AlfaG_Sym,AlfaUp)) EFFICIENZA_MAX],'--r')
title("EFFICIENZA-{\alpha}")
xlabel("{\alpha} [°]")
ylabel("Efficienza")
legend("","LIMITE DEL MODELLO AERODINAMICO","LIMITE DELL'INCIDENZA DI CROCIERA")