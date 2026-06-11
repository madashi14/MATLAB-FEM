function plotta_modello_corrente(vel,nodi,N,stile)
% PLOTTA_MODELLO_CORRENTE
% Disegna la mesh del modello FEM nella figura corrente (senza aprire
% una nuova figura). Usa hold on, quindi puo' essere chiamata piu' volte
% per sovrapporre mesh originale e deformata.
%
% INPUT:
%   vel   : array di strutture elemento (s.el)
%   nodi  : array di strutture nodo con campi .x, .y, .z
%   N     : numero di punti per spigolo
%   stile : stringa stile MATLAB per il plot (es. 'k--', 'r-')
%
% OUTPUT:
%   nessun output; disegna nella figura corrente
    hold on
    grid on
    
    view(3)
    xlabel('x')
    ylabel('y')
    zlabel('z')
    for i = 1:length(vel)
        plotta_el(vel(i),nodi,N,stile);
    end
    
    view(3)
    rotate3d(gcf,'on')
    zoom(gcf,'off')
    pan(gcf,'off')
    drawnow
end