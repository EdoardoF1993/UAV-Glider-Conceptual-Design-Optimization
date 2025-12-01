function [] = GraficiCarichi(L_sez,mSez,Taglio,MomentoAero_E_sez,MomentoPeso_E_sez,MomentoTorcente_E,b,x)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    g = 9.74 ;
    DistribuzioneEllittica = subs(L_sez,x,0)*sqrt(1-(x/b)^2) ;
    MeshDensity = 50 ;
    figure(2)
    subplot(2,1,1)
    fplot(L_sez,[0 b],"b","LineWidth",2)
    hold on
	fplot(DistribuzioneEllittica,[0 b],"--b","LineWidth",2)
    hold on
    fplot(-mSez*g,[0 b],"r","LineWidth",2,"MeshDensity",MeshDensity)
    hold on
    fplot(Taglio,[0 b],"y","LineWidth",2,"MeshDensity",MeshDensity)
    hold on
    fplot(0*x,[0 b],"k","LineWidth",4)
    title(["CARICHI DI TAGLIO"])
    xlabel("Apertura della semi-ala [m]")
    ylabel("[N]")
    legend("Distribuzione di portanza","Distribuzione ideale","Peso","Carico distribuito netto","Semi-ala")
    grid on

    subplot(2,1,2)
    fplot(MomentoAero_E_sez,[0 b],"b","LineWidth",2)
    hold on
    fplot(MomentoPeso_E_sez,[0 b],"r","LineWidth",2,"MeshDensity",MeshDensity)
    hold on
    fplot(MomentoTorcente_E,[0 b],"y","LineWidth",2,"MeshDensity",MeshDensity)
    hold on
    fplot(0*x,[0 b],"k","LineWidth",4)
    title(["MOMENTO TORCENTE DISTRIBUITO RISPETTO ALL'ASSE ELASTICO"])
    xlabel("Apertura della semi-ala [m]")
    ylabel("[Nm]")
    legend("Aerodinamica","Peso","Carico distribuito totale","Ala")
    grid on

end

