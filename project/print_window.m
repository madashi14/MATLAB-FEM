%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Libreria utilities per il corso
%  laboratorio di meccanica delle vibrazioni e sperimentazione, Universita`  degli studi di Bologna
%
%  Utilizzo riservato per i soli fini didattici agli studenti 
%  del corso laboratorio di meccanica delle vibrazioni e sperimentazione
%  Ogni altro utilizzo, in assenza di autorizzazione scritta del docente del corso, e` espressamente vietato  
%
% Giuseppe Catania, 2014-19
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_window(str,stit)
% PRINT_WINDOW
% Mostra una finestra di messaggio (msgbox) con il testo specificato
% e il titolo fornito.
%
% INPUT:
%   str  : cell array di stringhe con il testo da visualizzare
%   stit : stringa con il titolo della finestra
%
% OUTPUT:
%   nessun output; apre una finestra msgbox
   msgbox(str,stit);
return