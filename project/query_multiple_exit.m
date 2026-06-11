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

function x= query_multiple_exit(stitle,s,xmin,xmax,xdef)
% QUERY_MULTIPLE_EXIT
% Mostra una finestra di dialogo con piu' campi di input numerici,
% ciascuno con il proprio range [xmin(i), xmax(i)] e valore default xdef(i).
% Ripete la richiesta finche' tutti i valori non sono nell'intervallo.
% Restituisce un array vuoto se l'utente preme Annulla.
%
% INPUT:
%   stitle : titolo della finestra di dialogo
%   s      : cell array di stringhe (una per campo)
%   xmin   : vettore dei valori minimi accettabili
%   xmax   : vettore dei valori massimi accettabili
%   xdef   : vettore dei valori di default
%
% OUTPUT:
%   x : vettore dei valori numerici inseriti dall'utente ([] se annullato)

    lineNo= 1;
    n= length(xmin);
    for i=1:n
        if isfinite(xdef(i))
            def(i)= cellstr(sprintf('%f',xdef(i)));
        else
            def(i)= cellstr(sprintf(''));
        end
        ss(i)= cellstr(sprintf('%s [%f,%f]: ',char(s(i)),xmin(i),xmax(i)));
    end

    again= 1;
    while again
        again= 0;
        answer= char(inputdlg(ss,stitle,lineNo,def));
        if(isempty(answer))
            x=[];  break
        end
        x= str2num(answer);
        for i=1:n
            if x(i)>xmax(i) | x(i)<xmin(i)
                again= 1;
                break
            end
        end
    end
end

