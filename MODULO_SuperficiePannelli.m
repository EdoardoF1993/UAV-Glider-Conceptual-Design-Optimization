function [SuperficieNecessaria,Etot] = MODULO_SuperficiePannelli(U,Resist,irradianza_media,OreGiorno,PotenzaPersaRiscaldamento,rend_pannelli,RendimentoCatenaBatterie ...
    ,PotenzaPersaAvionica,RendimentoCatenaPropulsiva,FattoreSicurezzaPannelli,SurplusNotte)

RendimentoDi = RendimentoCatenaPropulsiva ;
RendimentoNotte = RendimentoCatenaBatterie*RendimentoDi ;

En_volo_giorno = (Resist*U + PotenzaPersaRiscaldamento + PotenzaPersaAvionica)*3600*OreGiorno ; %Energia richiesta per volare 12h diurne, Potenza*12h
En_volo_notte = (Resist*U + PotenzaPersaRiscaldamento + PotenzaPersaAvionica)*3600*(24-OreGiorno) ;

SuperficieNecessariaIdeale = (En_volo_giorno/RendimentoDi + SurplusNotte*En_volo_notte/RendimentoNotte)/(rend_pannelli*irradianza_media*3600*OreGiorno) ;
SuperficieNecessaria = ceil( SuperficieNecessariaIdeale )/FattoreSicurezzaPannelli ;

Etot = En_volo_notte + En_volo_giorno ;

end