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
    if nargin<2 | ~exist(icon_file)
        msgbox(msg,'Error','error');
    else
        msgbox(msg,'Error','custom',imread(icon_file));
    end
end


