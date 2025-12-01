function [Cl,Cd,Cm,Cl0,Cla,Alfa_out,AlfaLimite,Cd0,Cm_A,CA,Cma,Cm0,war] = ProfiloFun(profilo,Re,Ma,Alfa_in,polo,nMax,Dir,Alfa_a,Alfa_b)

cd(Dir) ;
addpath(Dir) ;
polari = "Polari.dat" ;
comandi = "comandi.dat" ;
% mkdir DatiCp
% addpath DatiCp
delete(Dir+polari,Dir+comandi)
a = ( Alfa_a - min(Alfa_in) )/(max(Alfa_in)+abs(min(Alfa_in)) ) ;
b = (1 - ( max(Alfa_in) - Alfa_b )/(max(Alfa_in)+abs(min(Alfa_in)) ) ) ;
NumeroIterazioni = string(nMax) ;
N = length(Alfa_in);
Reynolds = convertStringsToChars( "RE " + Re ) ;
Mach = convertStringsToChars( "Mach " + Ma ) ;
poloX = string(polo(1)) ;
poloY = string(polo(2)) ;

%Comandi = {'load '+profilo 'prova' 'XYCM' poloX poloY 'MDES' 'FILT' 'EXEC' ' ' ' ' 'PANE' 'OPER' Reynolds Mach 'ITER'+NumeroIterazioni 'VISC '+Re 'pacc' 'Polari.dat' '/n' sprintf(['ALFA %.3f\n' 'CPWR cp(%d).dat\n'], [Alfa_in; 1:N]) 'QUIT' };
Comandi = {'load '+profilo 'prova' 'XYCM' poloX poloY 'PANE' 'OPER' Reynolds Mach 'ITER'+NumeroIterazioni 'VISC ON' 'pacc' 'Polari.dat' '/n' sprintf(['ALFA %.3f\n' 'CPWR cp(%d).dat\n'], [Alfa_in; 1:N]) 'QUIT' };
id = fopen('comandi.dat', 'w+');
fprintf(id, '%s\n', Comandi{:});
fclose(id);
	
%cd DatiCp

!xfoil < comandi.dat ;

Cp = zeros(160,N) ;

if round(a*N) == 0
    a2 = 1 ;
else
    a2 = 0 ;
end


for i = 1:N
    
    Dati_Cp = importdata(sprintf('cp(%d).dat', i), ' ', 1) ;
    datiCp = Dati_Cp.data ;
    X = datiCp(:,1) ;
    Cp(:,i) = datiCp(:,2) ;

end

cd ../
for i = 1:N
    Dati_Polari = str2double( table2array( readtable('Polari.dat') ) ) ;
    Dati_Polari = Dati_Polari(2:end,:) ;
    Alfa_out = Dati_Polari(:,1) ;
    Cl = Dati_Polari(:,2) ;
    Cd = Dati_Polari(:,3) ;
    Cm = Dati_Polari(:,5) ;
end

[MaxCl,IndiceMaxCl] = max(Cl) ;
Nout = size(Alfa_out,1) ;
AlfaMax = Alfa_out(IndiceMaxCl)  ; %Angolo massimo oltre il quale il Cl scende

dAlfa = (max(Alfa_in)-min(Alfa_in))/length(Alfa_in) ;
dAlfaOut = (max(Alfa_out)-min(Alfa_out))/length(Alfa_out) ;
%[Alfa0, IndiceCl0] = min(abs(Alfa_out)) ;
%Cl0 = Cl(IndiceCl0) ;
%Cla = ( Cl(round(3*N/4))-Cl(1) )/( (round(3*N/4)-1)*dAlfa*(pi/180) ) ;
Fit = polyfit(Alfa_out(round(a*Nout + a2):round(b*Nout))*pi/180,Cl(round(a*Nout + a2):round(b*Nout)),1) ;
Cla = Fit(1) ;
Cl0 = Fit(2) ;

AlfaLineare = AlfaMax - ( ( (Cl0+Cla*AlfaMax*pi/180) - MaxCl )/Cla )*180/pi ; % Angolo in gradi oltre il quale non vale piu l'approssimazione lineare
% for i = 1:3
%     IndiceAlfaLineare = floor((AlfaLineare-min(Alfa_out))/dAlfaOut) ;
%     AlfaLineare = AlfaLineare - ( ( (Cl0+Cla*Alfa_out(IndiceAlfaLineare)*pi/180) - Cl(IndiceAlfaLineare) )/Cla )*180/pi ;
% end

% Coefficiente di momento rispetto al CentroAerodinamico e CentroAerodinamico
% Cma = ( Cm(round(3*N/4))-Cm(1) )/( (round(3*N/4)-1)*dAlfa*(pi/180) ) ;
% Cm0 = Cm(IndiceCl0) ;

Fit2 = polyfit( Alfa_out( round(a*Nout + a2):round(b*Nout) )*pi/180 , Cm( round(a*Nout + a2):round(b*Nout) ) , 1 ) ;
Cma = Fit2(1) ;
Cm0 = Fit2(2) ; 
CA = polo(1) - Cma/Cla ;
Cm_A = mean( Cm + Cl*(CA-polo(1)) ) ;

Cd0 = polyfit( Alfa_out( round(a*Nout + a2):round(b*Nout) )*pi/180 , Cd( round(a*Nout + a2):round(b*Nout) ), 0 ) ;

AlfaLimite = min(AlfaLineare,AlfaMax) ;

if length(Cl) < N %Verifica che si sia andati a convergenza per tutti gli angoli
    war = N - length(Cl) ;
    warning('PER %d ALFA SU %d NON SI E'' ANDATI A CONVERGENZA !' , war, N)
else
    war = 0 ;
end

end

