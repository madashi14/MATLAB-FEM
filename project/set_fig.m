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
    fig= fig+1; figure(fig);  
    set(gcf,'Name',title,'NumberTitle','off');
end

