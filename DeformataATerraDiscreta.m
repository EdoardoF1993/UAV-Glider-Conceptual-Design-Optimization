function [wMax_terra,ThetaMax_terra] = DeformataATerraDiscreta(x,L,J,Iy,mSez,e_EG,E_young,G_taglio,grafici)

n = 1 ;
g = 9.81 ;

%DISCRETIZZAZIONE
dx = L/100 ;
VettoreX = (0:dx:L)' ; %Vettori colonna
e_EG_disc = double( subs(e_EG,x,VettoreX) ) ;
mSez_disc = double( subs(mSez,x,VettoreX) ) ;
Iy_disc = double( subs(Iy,x,VettoreX) ) ; %Vettori colonna
J_disc = double( subs(J,x,VettoreX) ) ;

%Funzioni di forma per la flessione
a4 = 1 ; a5 = 1 ; a6 = 1 ; a8 = 1 ;
fw1 = 6*a4*(L^2)*VettoreX.^2 - 4*L*a4*VettoreX.^3 + a4*VettoreX.^4 ; %Vettori colonna
fw2 = ( 6*a4 + 20*L*a5 )*(L^2)*VettoreX.^2 - L*(4*a4+10*a5*L)*VettoreX.^3 + a4*VettoreX.^4 +a5*VettoreX.^5 ;
fw3 = ( 6*a4 + 20*L*a5 + 45*(L^2)*a6 )*(L^2)*VettoreX.^2 - L*(4*a4+10*a5*L+20*a6*L^2)*VettoreX.^3 + a4*VettoreX.^4 +a5*VettoreX.^5 +a6*VettoreX.^6 ;
fw4 = (-(42/30)*L*(-112/42)*L*a8 -(56/30)*(L^2)*a8 )*VettoreX.^6 -(112/42)*L*a8*VettoreX.^7 + a8*VettoreX.^8 ;

%Funzioni di forma per la torsione
fTheta1 = VettoreX.*(VettoreX-2*L) ; %Vettori colonna
fTheta2 = (VettoreX.^2).*(VettoreX-3*L/2) ;
fTheta3 = (VettoreX.^3).*(VettoreX-4*L/3) ;
fTheta4 = (VettoreX.^4).*(VettoreX-5*L/4) ;

Nw = [fw1 fw2 fw3 fw4] ;
NTheta = [fTheta1 fTheta2 fTheta3 fTheta4] ;

Nw = Nw(:,1:n) ;
NTheta = NTheta(:,1:n) ;

% NwD1 = diff(Nw) ;
% %NwD2 = diff(Nw,2) ;
% NwD4 = diff(Nw,4) ;
% %NThetaD1 = diff(NTheta) ;
% NThetaD2 = diff(NTheta,2) ;

%NwD1 = [ 12*L^2*VettoreX - 12*L*VettoreX.^2 + 4*VettoreX.^3, 4*VettoreX.^3 + 5*VettoreX.^4 - 3*L*VettoreX.^2*(10*L + 4) + 2*L^2*VettoreX*(20*L + 6), 4*VettoreX.^3 + 5*VettoreX.^4 + 6*VettoreX.^5 - 3*L*(VettoreX.^2)*(20*L^2 + 10*L + 4) + 2*L^2*VettoreX*(45*L^2 + 20*L + 6), (56*L^2*VettoreX.^5)/5 - (56*L*VettoreX.^6)/3 + 8*VettoreX.^7] ;
NwD4 = [24*ones(size(VettoreX)) 120*VettoreX+24 360*(VettoreX.^2)+120*VettoreX+24 672*L^2*(VettoreX.^2)-2240*L*(VettoreX.^3)+1680*VettoreX.^4] ;
NThetaD2 = [2*ones(size(VettoreX)) 6*VettoreX-3*L 6*(VettoreX.^2)-6*VettoreX*((4*L)/3)-VettoreX 8*(VettoreX.^3)-12*VettoreX.^2*((5*L)/4)-VettoreX] ;

%NwD1 = NwD1(:,1:n) ;
NwD4 = NwD4(:,1:n) ;
NThetaD2 = NThetaD2(:,1:n) ;

%eps = (0.05*pi/180)/(L^(n+1)) ; %Tolleranza sull'errore
%contatore = 0 ;
%Errore = 2*eps ;
%coeff = 0.2 ; % Coefficiente di rilassamento

%X_new_terra = zeros(size(Nw,2)+size(NTheta,2),1) ;

%while ( ( Errore > eps ) && (contatore < 1) )
    
    %X_terra = X_new_terra ;
    
    %Valutazione dei termini wD e Theta
    %wD = NwD1*X(1:size(Nw,2)) ;
    %Theta = NTheta*X(size(NTheta,2)+1:end) ;
    
    fwR_terra = - mSez_disc*g ;
    fThetaR_terra = - mSez_disc*g.*e_EG_disc ;
    INTfwR_terra = (Nw')*fwR_terra*dx ;
    INTfThetaR_terra = (NTheta')*fThetaR_terra*dx ;
    Fr_terra = [INTfwR_terra;INTfThetaR_terra] ;
    
    %Valutazione della matrice di rigidezza
    INTk11_terra = (Nw')*( E_young*Iy_disc.*NwD4 )*dx ;
    %INTk11 = double( int( (Nw')*( E_young*Iy*NwD4*( 1 + diff((wD^4),2)/6 ) ),[0 L] ) ) ;
    %INTk11 = double( int( (Nw')*( E_young*Iy*NwD4 ),[0 b] ) ) ;
    INTk22_terra = (NTheta')*( G_taglio*J_disc.*NThetaD2 )*dx ;
    K_terra = [INTk11_terra zeros( size(Nw,2),size(NTheta,2) );zeros( size(NTheta,2),size(Nw,2) ) INTk22_terra] ;
    
    %X = K\Fr ;
    
    %Valutazione della nuova soluzione e confronto con la vecchia
    %X_new_terra = double( (coeff*X_terra + (1-coeff)*(K_terra\Fr_terra)) ) ;
    
    %Errore = max( abs(X_terra - X_new_terra) ) ;
    
    %X_terra = X_new_terra ;
    
    %contatore = contatore + 1 ;
    
%end

X_terra = double( K_terra\Fr_terra ) ;

Xw_terra = X_terra(1:size(Nw,2)) ;
XTheta_terra = X_terra(size(NTheta,2)+1:end) ;

w_terra = Nw*Xw_terra ; %Per le equazioni positivo verso l'alto
Theta_terra = NTheta*XTheta_terra ; %Per le equazioni positivo picchiante


%bmax_terra = L(end) ;
%indice_bmax_terra = find( VettoreX == L(end) ) ;
wMax_terra = w_terra(end) ;
ThetaMax_terra = Theta_terra(end) ;
% for h = 1:3
%     wMax_terra = double( abs( w_terra(indice_bmax_terra) ) ) ; %Spostamento al tip in percentuale di semiapertura alare 
%     bmax_terra = double( sqrt(bmax_terra^2 - wMax_terra) ) ;
%     indice_bmax_terra = find( VettoreX == (round(bmax_terra/dx) ) ;
%     ThetaMax_terra = double( abs( Theta_terra(indice_bmax_terra) ) ) ; %Torsione al tip in gradi  
% end 

%"FLESSIONE MASSIMA IN PERCENTUALE DI SEMI-APERTURA ALARE "+num2str(100*round(wMax_terra/L,2))+" %"
%"TORSIONE MASSIMA IN GRADI "+num2str(round(ThetaMax_terra*180/pi,2))

if grafici == 2  
    figure(10)
    subplot(2,1,1)
    plot(VettoreX,w_terra,"LineWidth",2) ;
    title(["DEFORMAZIONE A TERRA";"Flessione w "])
    xlabel("Apertura della semi-ala [m]")
    ylabel("Spostamento a flessione [m]")
    %axis([0 bmax wMax 0.1])
    subplot(2,1,2)
    plot(VettoreX,-Theta_terra*180/pi,"LineWidth",2) % -Theta positivo cabrante
    title("Torsione -\theta ")
    xlabel("Apertura della semi-ala [m]")
    ylabel("Distribuzione della torsione [°]")
end

end