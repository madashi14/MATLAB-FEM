function fig = various_plot(s,fig)
% VARIOUS_PLOT
% Menu interattivo per la scelta del tipo di visualizzazione del modello FEM.
% Consente di scegliere tra:
%   1. Mesh semplice
%   2. Mesh con numerazione nodi
%   3. Mesh con numerazione nodi e elementi
%   4. Cambio del numero di punti per il plot
%   5. Chiusura delle figure
% Dopo ogni plot mesh aggiunge automaticamente le facce vincolate.
%
% INPUT:
%   s   : struttura modello FEM con s.el, s.p, s.nv
%   fig : indice figura corrente
%
% OUTPUT:
%   fig : indice dell'ultima figura aperta
    stit = 'Tipologia Plot';
    
    vs = {'Mesh', ...
          'Mesh + nodi', ...
          'Mesh + nodi + Numerazione Elementi', ...
          'Cambia numero punti plottati',...
          'Chiudi Finestre',...
          'Esci'};
    
    ripeti = 1;

    while ripeti
    
        scelta = menu(stit, vs);
    
        switch scelta
    
            case 1
                if isempty(s)
                    error_window('Devi prima leggere il modello.', 'logo.jpg');
                else
                    fig = plotta_modello(s.el,s.p,fig,'k-');
                    hold on
                    plotta_facce_vincolate_e_caricate(s);
                end
    
    
            case 2
                if isempty(s)
                    error_window('Devi prima leggere il modello.', 'logo.jpg');
                else
                    fig = plotta_modello_nodi(s.el,s.p,fig);
                    hold on
                    plotta_facce_vincolate_e_caricate(s);
                end
    
            case 3
                if isempty(s)
                    error_window('Devi prima leggere il modello.', 'logo.jpg');
                else
                    fig = plotta_modello_nodi_elementi(s.el,s.p,fig);
                    hold on
                   plotta_facce_vincolate_e_caricate(s);
                end

            case 4
                get_Nplot(true);

            case 5
                close all hidden

            case 6
                ripeti=0;
        end
    end
end