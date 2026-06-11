%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Libreria utilities per il corso
%  laboratorio di meccanica delle vibrazioni e sperimentazione, Universita`  degli studi di Bologna
%
%  Utilizzo riservato per i soli fini didattici agli studenti 
%  del corso laboratorio di meccanica delle vibrazioni e sperimentazione
%  Ogni altro utilizzo, in assenza di autorizzazione scritta del docente del corso, e` espressamente vietato  
%
% Giuseppe Catania, 2014-22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function error_window(msg,icon_file)
% ERROR_WINDOW
% Mostra una finestra di errore con il messaggio specificato.
% Se viene fornito un file icona valido, lo usa come immagine nella finestra;
% altrimenti usa l'icona di errore standard di MATLAB.
%
% INPUT:
%   msg       : stringa o cell array di stringhe con il messaggio di errore
%   icon_file : (opzionale) percorso di un file immagine da usare come icona
%
% OUTPUT:
%   nessun output; apre una finestra msgbox modale
    if nargin<2 | ~exist(icon_file)
        msgbox(msg,'Error','error');
    else
        msgbox(msg,'Error','custom',imread(icon_file));
    end
end


