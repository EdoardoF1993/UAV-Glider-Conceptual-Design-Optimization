function [w_c,Theta_c,w,Theta,wMax,ThetaMax] = MODULO_Aeroelasticita(x,b_SA,Cm_A,e_EA,e_EG,mSez,E_young,G_taglio,Iy,J,g,Gamma_Alfa,Gamma_0,AlfaR)
%La funzione restituisce flessione w(x) positiva verso l'alto, torsione Theta(x) positiva
%picchiante e l'angolo di assetto del velivolo in gradi.
%La funzione richiede in ordine Lunghezza L della trave, Cl0, Clalfa, Cm
%rispetto al centro aerodinamico e Alfa di stallo (AlfaMax) del profilo.
%Offset aerodinamico e inerziale (e_EA ed e_EG) il primo positivo se avanti
%al centro elastico ed il secondo se dietro. La corda c(x) del profilo, il
%Peso che deve sostenere la sola semiala, la massa mSez(x) della sezione,
%il modulo di Young E e di taglio G del materiale, il momento d'inerzia Iy
%rispetto all'asse y (asse longidutinale al velivolo per il centro elastico) e la rigidetta
%a torsione J. La densita rho, la velocita U e la funzione Psi sulla quale si
%vuole proiettare la portanza di sezione. n e' il numero di funzioni di
%forma che si vogliono utilizzare. n per la flessione ed n per la torsione.
%AlfaR deve essere in gradi

%DISCRETIZZAZIONE
dx = b_SA/400 ;
VettoreX = (0:dx:b_SA)' ; %Vettori colonna
e_EA_disc = double( subs(e_EA,x,VettoreX) ) ;
e_EG_disc = double( subs(e_EG,x,VettoreX) ) ;
%c_disc = double( subs(c,x,VettoreX) ) ;
mSez_disc = double( subs(mSez,x,VettoreX) ) ;
Iy_disc = double( subs(Iy,x,VettoreX) ) ; %Vettori colonna
J_disc = double( subs(J,x,VettoreX) ) ;
Gamma_Alfa_disc = double( Gamma_Alfa(VettoreX) ) ;
Gamma_0_disc = double( Gamma_0(VettoreX) ) ;
Gamma_disc = Gamma_Alfa_disc*AlfaR + Gamma_0_disc ;

fz = rho*U*Gamma_disc - mSez_disc*g ;
mx = Cm_A + rho*U*e_EA_disc.*Gamma_disc - mSez_disc*g.*e_EG_disc ;

w1 = trapz(fz)*dx ;
Const_w1 = - w1(end) ;
w1 = w1 + Const_w1 ;
w2 = trapz(w1)*dx ;
Const_w2 = - w2(end) ;
w2 = w2 + Const_w2 ;
w3 = trapz( w2./(E_young*Iy_disc) )*dx ;
Const_w3 = - w3(0) ;
w3 = w3 + Const_w3 ;
w = trapz(w3)*dx ;
Const_w4 = - w(0) ;
w = w + Const_w4 ;

Theta1 = - trapz(mx)*dx ;
Const_Theta1 = - Theta1(end) ;
Theta1 = Theta1 + Const_Theta1 ;
Theta = trapz(Theta1./(G_taglio*J_disc))*dx ;
Const_Theta2 = - Theta(end) ;
Theta = Theta + Const_Theta2 ;

LunghezzaAla(1) = 0 ;
k = 1 ;
while LunghezzaAla(k) < b_SA
    LunghezzaAla(k) = LunghezzaAla(k-1) + sqrt( (w(k)-w(k-1))^2 + dx^2) ;
    k = k + 1 ;
end

w = w(1:k) ;
Theta = Theta(1:k) ;

wMax = w(end) ;
ThetaMax = Theta(end) ;

end

