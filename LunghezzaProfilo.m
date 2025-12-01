function [length] = LunghezzaProfilo(profiloDAT,corda)
%Funzione che mi fornisce la lunghezza dell rivestimento dell'intero
%profilo. Vuole il file DAT del profilo e la corda

profilo = load(profiloDAT)*corda ;
n = size(profilo,1) ;
length = 0 ;
for i = 1:n-1
    length = length + sqrt( (profilo(i+1,1)-profilo(i,1))^2 + (profilo(i+1,2)-profilo(i,2))^2 );
end

end