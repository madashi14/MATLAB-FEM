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

function x= query_integer_d(s,xmin,xmax,xdef)
% QUERY_INTEGER_D
% Mostra una finestra di dialogo e chiede all'utente di inserire un
% numero intero compreso nell'intervallo [xmin, xmax].
% Ripete la richiesta finche' il valore non e' valido.
% Termina con errore se l'utente preme Annulla.
%
% INPUT:
%   s    : stringa con la descrizione della variabile
%   xmin : valore minimo accettabile (intero)
%   xmax : valore massimo accettabile (intero)
%   xdef : valore di default proposto (intero)
%
% OUTPUT:
%   x : intero inserito dall'utente

ss= sprintf('%s [%d,%d]: ',s,xmin,xmax);

while(1)
	answer= char(inputdlg(ss,'Query',1,cellstr(sprintf('%d',xdef))));
	if(length(answer)==0)
	   x = []; return;
	end
   x= sscanf(answer,'%d');
   if x<=xmax & x>=xmin
   	break
   end
end
return
