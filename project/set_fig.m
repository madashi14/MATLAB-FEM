%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Libreria utilities per il corso
%  laboratorio di meccanica delle vibrazioni e sperimentazione, Universita`  degli studi di Bologna
%
%  Utilizzo riservato per i soli fini didattici agli studenti 
%  del corso laboratorio di meccanica delle vibrazioni e sperimentazione
%  Ogni altro utilizzo, in assenza di autorizzazione scritta del docente del corso, e` espressamente vietato  
%
% Giuseppe Catania, 2014-20
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fig= set_fig(fig,title)
% SET_FIG
% Incrementa il contatore delle figure, apre la figura numero fig+1
% e imposta il nome della finestra al titolo specificato,
% disabilitando il numero automatico di MATLAB ('NumberTitle','off').
%
% INPUT:
%   fig   : indice dell'ultima figura aperta
%   title : stringa con il titolo da assegnare alla nuova figura
%
% OUTPUT:
%   fig : indice della nuova figura aperta (fig_in + 1)
    fig= fig+1; figure(fig);  
    set(gcf,'Name',title,'NumberTitle','off');
end

