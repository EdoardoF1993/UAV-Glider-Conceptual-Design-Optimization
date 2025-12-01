function [Gamma_Alfa,Gamma_0,eOswald] = MODULO_Aerodinamica3D(N,b,Cla2D,Cl02D,U,x,c)
%Gamma = Gamma_Alfa*Alfa + Gamma_0. Gamma_Alfa e' stat

%Alfa = ( Peso - PresDinamica*Superficie*Cl0 )/(PresDinamica*Superficie*Cla) ; %Stima dell'incidenza
Alfa = 1 ;
b_SA = b/2 ;
Superficie = 2*int(c,[0 b/2]) ;
AR = b^2/Superficie ;

VettoreX = linspace(0,b_SA,N) ;
phi = acos(-VettoreX/b_SA) ;
Cla2D = double( subs(Cla2D,x,VettoreX) ) ; %Cla2D
Cl02D = double( subs(Cl02D,x,VettoreX) ) ; %Cl02D
Alfa0_v = - Cl02D./Cla2D ;
Alfa_v = Alfa*ones(N,1) ;
B = zeros(N,N) ;


for k = 1:N
  for h = 1:N
    B(k,h) = ( 4*b/Cla2D(k)*c(k) + h/sin(phi(k)) )*sin(h*phi(k)) ;
  end  
end

A_r = B\Alfa_v ;
A_0 = - B\Alfa0_v ;


for p = 1:N
    Gamma_disc_Alfa = 2*b*U*A_r(p)*sin(p*phi) ;
    Gamma_disc_0 = 2*b*U*A_0(p)*sin(p*phi) ;
end

Gamma_Alfa = fit(VettoreX,Gamma_disc_Alfa,'linearinterp') ;
Gamma_0 = fit(VettoreX,Gamma_disc_0,'linearinterp') ;

Gamma_disc_r = Gamma_disc_Alfa + Gamma_disc_0 ;
Gamma_r = Gamma_Alfa + Gamma_0 ;

A = A_r + A_0 ;
n = [1:N] ;
CD_indotto = pi*AR*n*A.^2 ;
CL = pi*AR*A(1) ;
%Alfa_indotto_R = n*A*sin(n*phi)
eOswald = CL^2 / (pi*AR*CD_indotto) ;

end

