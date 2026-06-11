function fig = plotta_modello(vel,nodi,fig,stile)
% PLOTTA_MODELLO
% Apre (o aggiorna) una figura e disegna la mesh del modello FEM.
% Ogni elemento viene disegnato con plotta_el usando lo stile specificato.
% Abilita toolbar, menu, rotazione 3D e grid.
%
% INPUT:
%   vel   : array di strutture elemento (s.el)
%   nodi  : array di strutture nodo con campi .x, .y, .z
%   fig   : indice della figura corrente (viene incrementato internamente)
%   stile : stringa stile MATLAB per il plot (es. 'k-')
%
% OUTPUT:
%   fig : indice della nuova figura aperta
    
    
        N = get_Nplot();

    fig = set_fig(fig,'Plot mesh');

    hold on
    grid on
    axis equal
    view(3)

    set(fig,'Toolbar','figure')
    set(fig,'MenuBar','figure')

    xlabel('x')
    ylabel('y')
    zlabel('z')

    for i = 1:length(vel)
        plotta_el(vel(i),nodi,N,stile);    
    end

    axis equal
    view(3)

    rotate3d(fig,'on')
    zoom(fig,'off')
    pan(fig,'off')

    drawnow



    hold off

end



