function fig = plotta_risposta_forzata_animata(risp,vel,nodi,fig)
% PLOTTA_RISPOSTA_FORZATA_ANIMATA
% Anima la risposta forzata della struttura nel tempo.
% Sottocampiona la storia temporale a nframe=80 fotogrammi e per
% ogni istante disegna:
%   - la mesh originale in linea tratteggiata nera (k--)
%   - la mesh deformata scalata in rosso (r-)
% I limiti degli assi sono fissi durante l'animazione (calcolati
% con limiti_animazione prima del loop).
%
% INPUT:
%   risp : struttura risposta con risp.t (tempo), risp.x (spostamenti nt x ndof)
%   vel  : array di strutture elemento
%   nodi : array di strutture nodo
%   fig  : indice figura corrente
%
% OUTPUT:
%   fig : indice della figura usata per l'animazione
    sc = get_sc();
    L = dimensione_struttura(nodi);
    wmax = max_response_disp(risp.x);
    if wmax < eps
        scale_factor = 1;
    else
        scale_factor = sc*L/wmax;
    end
    [xlim0,ylim0,zlim0] = limiti_animazione(nodi,risp,scale_factor);
    nd = length(nodi);
    N = get_Nplot();
    nt = length(risp.t);
    nframe = 80;
    ncycle = 1;
    fig = set_fig(fig,'Risposta forzata animata');
    set(fig,'Toolbar','figure')
    set(fig,'MenuBar','figure')
    if nt > nframe
        vk = round(linspace(1,nt,nframe));
    else
        vk = 1:nt;
    end
    for c = 1:ncycle
        for iframe = 1:length(vk)
            if ~ishandle(fig)
                return
            end
            k = vk(iframe);
            xk = risp.x(k,:)' * scale_factor;
            nodi_def = nodi;
            for i = 1:nd
                ii = (i-1)*3;
                nodi_def(i).x = nodi(i).x + xk(ii+1);
                nodi_def(i).y = nodi(i).y + xk(ii+2);
                nodi_def(i).z = nodi(i).z + xk(ii+3);
            end
            cla
            hold on
            for i = 1:length(vel)
                plotta_el(vel(i), nodi, N, 'k--');
            end
            for i = 1:length(vel)
                plotta_el(vel(i), nodi_def, N, 'r-');
            end
            grid on
            view(3)
            xlim(xlim0); ylim(ylim0); zlim(zlim0);
            drawnow
        end
    end
end