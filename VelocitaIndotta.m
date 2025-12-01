%function [Alfa_ind] = VelocitaIndotta(w,Theta,e_aero,Alfa_Geo,c,Cla,U,rho,g,massa)

e_EA = double( subs(e_EA,x,b/2) ) ;
Gamma0 = 0.5*c0*U*( Cl0 + Cla2D*Alfa ) ;
dx = 0.01 ;
X = 0:dx:b ;
w_d = double( subs(w,x,X) ) ;
Theta_d = double( subs(Theta,x,X) ) ;
c_d = double( subs(c,x,X) ) ;
DThetac = diff(Theta) ;
DTheta = double( subs(DThetac,x,X) ) ;
DGamma_e = 0.5*U*c_d.*Cla2D.*DTheta ;
Gamma_r = Gamma0*sqrt(1-(x/b)^2)/DistribuzioneCorda ;
DGamma_r = diff(Gamma_r) ;
DGamma_r = 0 ;%double( subs(DGamma_r,x,X) ) ;

contatore = 1 ;

for x0 = 0:dx:b
    w0 = double( subs(w,x,x0) ) ;
    Theta0 = double( subs(Theta,x,x0) ) ;
    Dw0 = double( subs(w,x,x0) ) ;
    %V_indotta(contatore) = trapz( ( (x0-X).*(w0-e_EA*Theta0-w_d+e_EA*Theta_d)*Dw0./( (x0-X).^2 + (w0-e_EA*Theta0-w_d+e_EA*Theta_d).^2 ) ) )*dx/(4*pi) ;
    %V_indotta(contatore) = - trapz( ( (x0-X).*(w0-e_EA*Theta0-w_d+e_EA*Theta_d)*Dw0./( (x0-X).^2 + (w0-e_EA*Theta0-w_d+e_EA*Theta_d).^2 ) ).*( DGamma_e - 4*Gamma0*X./(4*(b^2)*sqrt(1-(X/b).^2)) ) )*dx/(4*pi) ;
    V_indotta(contatore) = - trapz( ( (x0-X).*(w0-e_EA*Theta0-w_d+e_EA*Theta_d)*Dw0./( (x0-X).^2 + (w0-e_EA*Theta0-w_d+e_EA*Theta_d).^2 ) ).*( DGamma_e + DGamma_r ) )*dx/(4*pi) ;
    contatore = contatore + 1 ;
end


%end
