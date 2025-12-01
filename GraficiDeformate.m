function [] = GraficiDeformate(w,Theta,b)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    figure(1)
    subplot(2,1,1)
    fplot(w,[0 b],"LineWidth",2) ;
    title(["MODELLO DI TRAVE INCASTRATA-LIBERA";"Flessione w "])
    xlabel("Apertura della semi-ala [m]")
    ylabel("Spostamento a flessione [m]")
    axis equal
    subplot(2,1,2)
    fplot(-Theta*180/pi,[0 b],"LineWidth",2) % -Theta positivo cabrante
    title("Torsione -\theta ")
    xlabel("Apertura della semi-ala [m]")
    ylabel("Distribuzione della torsione [°]")
end

