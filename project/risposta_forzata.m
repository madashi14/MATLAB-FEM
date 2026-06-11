function [out,fig]= risposta_forzata(st,fig)
% RISPOSTA_FORZATA
% Menu di selezione per il calcolo della risposta forzata:
% consente di scegliere tra il metodo diretto (modello strutturale,
% integrazione dell'intero sistema) e il metodo per sovrapposizione
% modale (modello modale, integrazione in coordinate modali).
%
% INPUT:
%   st  : struttura modello FEM con K, M, C, Forza, V, freq
%   fig : indice figura corrente
%
% OUTPUT:
%   out : struttura risposta (risp) restituita dal metodo scelto
%   fig : indice dell'ultima figura aperta
switch(menu('Risposta forzata',{'via Modello strutturale','via Modello modale'}));
    case 1
        [out,fig]=risposta_forzata_strutturale(st,fig);
        
    case 2
        [out,fig]=risposta_forzata_modale(st,fig); 
   
    otherwise
        return
end

end