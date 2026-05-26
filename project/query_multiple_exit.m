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

