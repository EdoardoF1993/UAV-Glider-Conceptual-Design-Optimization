function [MassaBatterie] = MODULO_Batterie(OreGiorno,PotenzaConsumata,Rendimento_propulsivo,Batterie,FattoreSicurezzaBatterie)

Wh_kg = Batterie.SionLicerion.DensitaMassa ; % valori delle batterie sion licerion
Wh_l = Batterie.SionLicerion.DensitaVolume ;
Rendimento_in = Batterie.SionLicerion.Rendimento_in ;
Rendimento_out = Batterie.SionLicerion.Rendimento_out ;

EnergiaMassa_Batterie = Wh_kg*3600 ; %Energia in J/kg
%EnergiaVolume_Batterie = Wh_l*3600 ; %Energia in J/Litro 
%rho_batterie = 1e3*(EnergiaVolume_Batterie/EnergiaMassa_Batterie) ; %in kg/m3

OreNotte = 24 - OreGiorno ;

EnergiaConsumata_notte = PotenzaConsumata*OreNotte*3600 ; %Energia consumata durante la fase di notte
EnergiaBatterie = EnergiaConsumata_notte/(Rendimento_in*Rendimento_out*Rendimento_propulsivo) ;
MassaBatterie = FattoreSicurezzaBatterie*EnergiaBatterie/EnergiaMassa_Batterie ;

end
