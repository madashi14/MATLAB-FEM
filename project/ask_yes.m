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

function x= ask_yes(s,yes,no)
    ss= sprintf('%s [%s,%s]: ',s,yes,no);
    answer=questdlg(s,'Query',yes,no,yes);
    if strcmp(answer,no)
        x=0;
    else
        x=1;
    end
end
