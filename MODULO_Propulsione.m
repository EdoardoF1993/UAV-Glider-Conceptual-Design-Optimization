function [MassaMotore,DiametroElica] = MODULO_Propulsione(PotenzaCrociera,U)

CoeffMassaMotore = ( 0.0033 + 0.0012 + 0.0008 + 0.007 )/4 ;
MassaMotore = CoeffMassaMotore*PotenzaCrociera ;
DiametroElica = sqrt(PotenzaCrociera/PresDinamica*U)

end

