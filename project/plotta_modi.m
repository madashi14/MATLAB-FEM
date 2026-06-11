function fig = plotta_modi(s,fig)
% PLOTTA_MODI
% Menu interattivo per la visualizzazione dei modi propri.
% Chiede quanti modi stampare, li elenca in una finestra, poi entra
% in un loop interattivo che consente di:
%   - Plottare la massima deformazione di un modo scelto
%   - Animare un modo scelto
%   - Cambiare il numero di punti per il plot
%   - Cambiare lo scale factor
%   - Chiudere le figure
%
% INPUT:
%   s   : struttura modello con s.freq, s.V, s.el, s.p
%   fig : indice figura corrente
%
% OUTPUT:
%   fig : indice dell'ultima figura aperta

    vs='Quante frequenze vuoi stampare?';
    ancora=1;
    xmax=min(100,length(s.freq));
    xmin=1;
    xdef=10;
    while ancora
        n=query_integer_d(vs,xmin,xmax,xdef);
        ancora=0;
    end
    if isempty(n)
        return
    end
    stit=sprintf('Prime %d Frequenze Proprie',n);
    for i=1:n
        str{i}=sprintf('%d Freq Propria: %.4e [Hz]', i, s.freq(i));
    end
    print_window(str,stit);
    fig = 0;

    while ask_yes('Vuoi plottare un modo proprio?','si','no')
        ripeti=1;
        while ripeti
            scelta=menu('Che tipo di plot vuoi?', 'Massima deformazione', ...
                'Animato','Cambia numero punti plottati', ...
                'Cambia scale factor',...
                'Chiudi Finestre','Esci');
            switch scelta
                case 1
                    imodo = query_integer_d('Quale modo vuoi plottare?',1,length(s.freq),1);
                    if isempty(imodo)
                        return
                    end
                    modo=s.V(:,imodo);
                    vel=s.el;
                    nodi=s.p;
                    freq=s.freq(imodo);
                    fig=plotta_modo_max_def(modo,vel,nodi,freq,imodo,fig);
                case 2
                    imodo = query_integer_d('Quale modo vuoi animare?',1,length(s.freq),1);
                    if isempty(imodo)
                        return
                    end
                    modo=s.V(:,imodo);
                    vel=s.el;
                    nodi=s.p;
                    freq=s.freq(imodo);
                    fig=plotta_modo_animato(modo,vel,nodi,freq,imodo,fig);
                    
           
                case 3
                    get_Nplot(true);
                case 4
                     get_sc(true);
                case 5
                    close all hidden
                case 6
                    ripeti=0;

            end
        end
                    
    end
end
