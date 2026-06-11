function confronta_freq_shell(st, freq_fem, nome_file)
% CONFRONTA_FREQ_SHELL
% Confronta le frequenze proprie calcolate dal modello FEM con quelle
% analitiche di un guscio cilindrico (teoria di Donnell/Blevins).
%
% Funzionamento:
%   1. Verifica che il nome file contenga 'shell'.
%   2. Estrae R, h, L, materiale dalla struttura FEM.
%   3. Calcola le frequenze analitiche con freq_analitica_shell.
%   4. Raddoppia le frequenze con numero ondulatorio i>=1 (degenerazione
%      cos/sin dovuta alla simmetria cilindrica).
%   5. Mostra una tabella comparativa FEM vs analitico con errore percentuale.
%
% INPUT:
%   st        : struttura modello FEM (nodi, elementi, materiale)
%   freq_fem  : vettore frequenze proprie FEM [Hz]
%   nome_file : nome del file .el caricato
%
% OUTPUT:
%   nessun output; apre una finestra con la tabella di confronto

    % --- 1. Check sul nome file -----------------------------------------
    if ~contains(lower(nome_file), 'shell')
        print_window( ...
            {'Il modello che stai esaminando non e'' uno shell.', ...
             '', ...
             sprintf('File caricato: %s', nome_file), ...
             '', ...
             'La verifica analitica (Blevins, Donnell)', ...
             'e'' applicabile solo a modelli il cui nome', ...
             'file contiene "shell".'}, ...
            'Verifica non applicabile');
        return
    end

    % --- 2. Estrai geometria dai nodi -----------------------------------
    nd = st.nd;
    x  = zeros(nd,1);
    y  = zeros(nd,1);
    z  = zeros(nd,1);
    for i = 1:nd
        x(i) = st.p(i).x;
        y(i) = st.p(i).y;
        z(i) = st.p(i).z;
    end

    r_all = sqrt(x.^2 + y.^2);
    R     = (max(r_all) + min(r_all)) / 2;
    h     = max(r_all) - min(r_all);
    L     = max(z) - min(z);

    ro = st.el(1).ro;
    ni = st.el(1).ni;
    E  = st.el(1).E;

    % --- 3. Frequenze analitiche ----------------------------------------
    i_max = 20;
    j_max = 5;
    [freq_tab, f_min, ij_min] = freq_analitica_shell(R, h, L, ro, ni, E, i_max, j_max);

    % --- 4. Raddoppia le freq con i>=1 (degenerazione cos/sin) ----------
    %   Riga 1 di freq_tab -> i=0 : modi assisimmetrici, NON degeneri
    %   Righe 2.. di freq_tab -> i>=1 : ogni modo ha coppia cos/sin
    f_an = [];
    % i = 0: una sola copia
    for j = 1:j_max
        if ~isnan(freq_tab(1,j))
            f_an(end+1) = freq_tab(1,j);
        end
    end
    % i >= 1: doppia copia
    for i = 1:i_max
        for j = 1:j_max
            if ~isnan(freq_tab(i+1,j))
                f_an(end+1) = freq_tab(i+1,j);
                f_an(end+1) = freq_tab(i+1,j);
            end
        end
    end
    f_an = sort(f_an(:));

    % --- 5. Confronto ---------------------------------------------------
    toll_zero = 1e-2;
    freq_fem  = freq_fem(freq_fem > toll_zero);
    freq_fem  = sort(freq_fem(:));

    n_confronto = min([length(freq_fem), length(f_an), 20]);

    str = {};
    str{end+1} = 'Confronto frequenze: FEM vs Donnell (analitico)';
    str{end+1} = '';
    str{end+1} = sprintf('File: %s', nome_file);
    str{end+1} = sprintf('R = %.4g m,  h = %.4g m,  L = %.4g m', R, h, L);
    str{end+1} = sprintf('h/R = %.4g,  L/R = %.4g', h/R, L/R);
    str{end+1} = sprintf('ro = %.4g,  ni = %.4g,  E = %.4g', ro, ni, E);
    str{end+1} = sprintf('Fondamentale analitica: %.4f Hz  (i=%d, j=%d)', ...
                          f_min, ij_min(1), ij_min(2));
    str{end+1} = '';
    str{end+1} = 'Nota: ogni modo analitico con i>=1 e'' doppio (cos/sin)';
    str{end+1} = '';
    str{end+1} = '  Modo     f_FEM [Hz]   f_anal [Hz]   err [%]';
    str{end+1} = '  ----     ----------   -----------   -------';

    err_vec = zeros(n_confronto, 1);
    for im = 1:n_confronto
        err = (freq_fem(im) - f_an(im)) / f_an(im) * 100;
        err_vec(im) = abs(err);
        str{end+1} = sprintf('  %4d     %10.3f   %11.3f   %+7.2f', ...
                              im, freq_fem(im), f_an(im), err);
    end

    str{end+1} = '';
    str{end+1} = sprintf('Errore medio: %.2f %%', mean(err_vec));

    print_window(str, 'Verifica analitica shell');
end
