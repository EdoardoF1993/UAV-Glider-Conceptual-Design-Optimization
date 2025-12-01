function [eOswald] = FattoreDiOswald(TR,AR,DiametroFusoliera_AperturaAlare,Cd0,LunghezzaWingLet,b)


f_oswald = 0.0524*(TR^4) - 0.15*(TR^3) + 0.1659*(TR^2) - 0.0706*TR + 0.0119 ;
eOswald_theo = 1/(1+f_oswald*AR) ;
KeF_oswald = 1-2*(DiametroFusoliera_AperturaAlare^2) ; %Correzione dovuta alla fusoliera
KeWL1 = 2.29 ;
KeWL_oswald = ( 1+2*LunghezzaWingLet/(KeWL1*2*b) )^2 ; %Correzione dovuta alle wing-let
KeM_oswald = 1 ; %Correzione dovuta alla compressibilita, minore di 1 solo con effetti di compressibilita, quindi solo se Mach > 0.3
Q_oswald = 1/(eOswald_theo*KeF_oswald) ;
eOswald = KeWL_oswald*KeM_oswald/(Q_oswald + 0.38*Cd0*pi*AR) ;

% figure(6)
% plot(TR2,eOswald2,[TR TR],[min(eOswald2) eOswald],'--r',[0 TR],[eOswald eOswald],'--r','LineWidth',2)
% title("FATTORE DI OSWALD 'e'")
% xlabel("Rapporto di rastremazione TR")
% ylabel("Fattore di Oswald")
% grid on
% dim = [.015 .78 .2 .2];
% str = {['Allungamento Alare = ' num2str(round(AR,2))];['Resistenza parassita = ' num2str(round(Cd0,3))]};
% nota1 = annotation('textbox',dim,'String',str,'FitBoxToText','on') ;
% nota1.FontSize = 15 ;


end

