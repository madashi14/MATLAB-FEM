function verifica_chirp_frf(risp, s)
% VERIFICA_CHIRP_FRF
% Visualizza la FRF (risposta in frequenza) per un nodo scelto,
% calcolata dalla risposta al chirp.
%
% INPUT:
%   risp : struttura risposta (risp.x, risp.t, risp.ft)
%   s    : struttura modello (s.el, s.p, s.freq, s.nv, s.nf ...)

    if isempty(risp) || isempty(risp.x)
        error_window('Nessuna risposta disponibile.', 'logo.jpg');
        return
    end

    if ~isfield(risp, 'ft') || ~isfield(risp.ft, 'tipo') || ~strcmp(risp.ft.tipo, 'chirp')
        print_window({'La verifica FRF richiede la forzante di tipo chirp.', ...
                      'Selezionare prima il chirp come forzante temporale.'}, ...
                     'Tipo forzante non valido');
        return
    end

    ndof   = size(risp.x, 2);
    n_nodi = ndof / 3;

    while 1
        switch menu('FRF Chirp', {'Seleziona nodo e plotta FRF', 'Esci'})
            case 0
                break
            case 1
                % modello SEMPRE su fig 1 (set_fig(0,...) → fig 0+1 = 1)
                fig_nodi = plotta_modello_nodi(s.el, s.p, 0);
                hold on
                plotta_facce_vincolate_e_caricate(s);
                hold off

                print_window( ...
                    {'Il modello e'' stato plottato con la', ...
                     'numerazione dei nodi.', '', ...
                     'Ruota la figura per identificare', ...
                     'il nodo su cui eseguire la FRF,', ...
                     'poi premi OK per continuare.'}, ...
                    'Scegli nodo');

                
                    nodo = query_integer_d('Numero nodo per la FRF', 1, n_nodi, 1);
              
                if isempty(nodo), continue; end

                dir = menu('Direzione spostamento', ...
                           'x (dof 1)', 'y (dof 2)', 'z (dof 3)');
                if dir == 0, continue; end

                % FRF SEMPRE su fig_nodi+1 = fig 2  →  nessun conflitto
                frf_plot(risp, s, nodo, dir, fig_nodi);

            case 2
                break
        end
    end
end

% -------------------------------------------------------------------------
function frf_plot(risp, s, nodo, dir, fig)
% FRF_PLOT  Calcola e visualizza la FRF per il nodo/direzione scelti.
%   fig ricevuto = fig_nodi (es. 1).
%   set_fig lo incrementa → FRF su fig 2. Nessuna collisione col modello.

    dirs  = {'x', 'y', 'z'};
    idof  = (nodo - 1)*3 + dir;

    % --- FFT ---------------------------------------------------------------
    dt   = 1 / risp.ft.fc;
    N    = risp.ft.N;
    fc   = risp.ft.fc;
    
    X    = fft(risp.x(:, idof)) / N;
    F    = fft(risp.ft.x)       / N;
    freq = (0:N-1) * fc / N;
    H    = X ./ F;

    f_max_plot = min(risp.ft.f1 * 1.1, fc / 2);
    idx        = freq > 0 & freq <= f_max_plot;

    fn = s.freq;   % frequenze proprie [Hz]

    % --- set_fig PRIMA, subplot subito dopo --------------------------------
    fig_title = sprintf('FRF - Nodo %d, dir. %s', nodo, dirs{dir});
    fig = set_fig(fig, fig_title);   % apre fig_nodi+1, sempre la stessa

    subplot(2, 1, 1)
    semilogy(freq(idx), abs(H(idx)), 'b-', 'LineWidth', 1.2)
    hold on
    for k = 1:length(fn)
        if fn(k) <= f_max_plot
            xline(fn(k), 'r--', 'LineWidth', 0.8);
        end
    end
    hold off
    xlabel('Frequenza [Hz]')
    ylabel('|H(f)|  [m / N norm.]')
    legend('FRF  |X/F|', 'Frequenze proprie', 'Location', 'northeast')
    grid on

    subplot(2, 1, 2)
    plot(freq(idx), abs(F(idx)), 'k-', 'LineWidth', 1.2)
    xlabel('Frequenza [Hz]')
    ylabel('|F(f)|  [N norm.]')
    title('Spettro della forzante (chirp)')
    grid on

    drawnow
end