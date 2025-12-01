function []  = DisegnoVelivolo(c0,b,TR,CordaMediaCoda,bCoda,DiametroFusoliera,LunghezzaFusoliera,Quota_km,Peso,BaricentroAereo,AlfaG,AlfaCodaG,CA,profilo,profiloCoda)

m2ft = 1/0.3048 ; %Passa da metri a piedi
N2lb = 0.224809 ; %Passa da kg a libre
DatiVelivolo = load("My First Plane.mat") ;
Mach = 0.2 ;
% c0 = 2 ;
% b = 18 ;
% TR = 0.4 ;
% CordaMediaCoda = 1.57 ;
% bCoda = 5 ;
% DiametroFusoliera = 0.7
% LunghezzaFusoliera = 2.583
% Mach = 0.1977
% Quota_km = 19
Peso = 2*Peso*N2lb ;
profiloChar = char(profilo) ; 

%DATI ALA
DatiVelivolo.WG.CHRDR = c0*m2ft ; %Wing.Chord Root
DatiVelivolo.WG.CHRDTP = c0*TR*m2ft ; %Wing.Chord Tip
DatiVelivolo.WG.SSPN = b*m2ft ; %Wing.semiSpan
DatiVelivolo.WG.TC = 0.12 ; %Wing.Thickness
DatiVelivolo.WG.NACA = {profiloChar profiloChar} ; %Profilo dell'ala
DatiVelivolo.WG.DATA = {load(profilo)} ;
DatiVelivolo.WG.CHSTAT = CA ; %Centro Aerodinamico dell'ala
DatiVelivolo.WG.X = 0 ; %Wing.LE's X position

%DATI PIANO DI CORDA ORIZZONTALE
DatiVelivolo.HT.CHRDR = (2*CordaMediaCoda/(1+0.36))*m2ft ; %Horizontal Tail.Chord Root
DatiVelivolo.HT.CHRDTP = (2*CordaMediaCoda/(1+0.36))*0.36*m2ft ; %Horizontal Tail.Chord Tip
DatiVelivolo.HT.SSPN = (bCoda/2)*m2ft ; %Horizontal Tail.semiSpan
DatiVelivolo.HT.TC = 0.12 ; %Horizontal Tail.Thickness
DatiVelivolo.HT.NACA = {'0012'} ; %Profilo dell'ala
%DatiVelivolo.HT.SWEEP = 0.25 ; %Centro Aerodinamico del piano di coda orizzontale
DatiVelivolo.HT.CHSTAT = 0.25 ;%Centro Aerodinamico del piano di coda orizzontale
DatiVelivolo.HT.TR = 0.45 ; %Taper Ratio Coda
DatiVelivolo.HT.AR = bCoda/CordaMediaCoda ; %Aspect Ratio Coda
DatiVelivolo.HT.S = bCoda*CordaMediaCoda*(m2ft^2) ; %Superficie piano di coda orizzontale
DatiVelivolo.HT.i = AlfaCodaG*pi/180 ; %Incidenza coda
DatiVelivolo.HT.X = (LunghezzaFusoliera-CordaMediaCoda)*m2ft ; %

%DATI PIANO DI CORDA VERTICALE
% DatiVelivolo.VT.CHRDR = *m2ft ; %Vertical Tail.Chord Root
% DatiVelivolo.VT.CHRDTP = *mt2ft ; %Vertical Tail.Chord Tip
% DatiVelivolo.VT.SSPN = *mt2ft ; %Vertical Tail.semiSpan
% w.VT.TC = 0.12 ; %Vertical Tail.Thickness
% DatiVelivolo.VT.NACA = {'0012'} ; %Vertical Tail.Profilo dell'ala
 DatiVelivolo.VT.X = (LunghezzaFusoliera-CordaMediaCoda)*m2ft ;
 DatiVelivolo.VT.Z = (-CordaMediaCoda/2)*m2ft ;

%DATI FUSOLIERA
%DatiVelivolo.BD.shape = 5*ones(1,DatiVelivolo.BD.NX) ;
DatiVelivolo.BD.NX = 7 ; %Body.number of point along X axes
DatiVelivolo.BD.X = linspace(0,LunghezzaFusoliera,DatiVelivolo.BD.NX)*m2ft ; %Body.Radius
DatiVelivolo.BD.R = (DiametroFusoliera/2)*m2ft*ones(1,DatiVelivolo.BD.NX) ; %Body.Radius
DatiVelivolo.BD.S = 2*pi*DatiVelivolo.BD.R ; %Body.Z coordinate lower
DatiVelivolo.BD.ZU = DatiVelivolo.BD.R ; %Body.Z coordinate upper
DatiVelivolo.BD.ZL = -DatiVelivolo.BD.R ; %Body.Z coordinate lower
DatiVelivolo.BD.P = 5*ones(1,DatiVelivolo.BD.NX) ; %forma della sezione della fusoliera. 5 per sezione rettangolare, 1 per circolare

%DATI AERODINAMICA
DatiVelivolo.AERO.ALSCHD = -2:0.5:12 ;
DatiVelivolo.AERO.ALT = (Quota_km*1e3)*m2ft ; %aerodinamic.altitude
DatiVelivolo.AERO.MACH = Mach ; %aerodinamic.mach
DatiVelivolo.AERO.WT =  Peso ; %aero.weight
DatiVelivolo.AERO.XCG = (c0*(1+TR)/2)*BaricentroAereo*m2ft ; %X gravity's centrer 

DatiVelivolo = struct('WG',DatiVelivolo.WG,'HT',DatiVelivolo.HT,'VT',DatiVelivolo.VT,'BD',DatiVelivolo.BD,'AERO',DatiVelivolo.AERO,'F',DatiVelivolo.F,'A',DatiVelivolo.A ...
  ,'E',DatiVelivolo.E,'R',DatiVelivolo.R,'NP',{DatiVelivolo.NP},'NB',{DatiVelivolo.NB},'unit',DatiVelivolo.unit,'plot_cmp',DatiVelivolo.plot_cmp,'cg_data',{DatiVelivolo.cg_data}) ;

save("DatiVelivolo.mat", '-struct' , 'DatiVelivolo')

addpath("/home/edoardo/MATLAB Add-Ons/Apps/AID/code")
AID

end