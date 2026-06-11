close all hidden
clc
clear all
fig = 0;
mydir = './modelli';
s = [];
stit = 'Modellazione a Elementi finiti';
vs = {'Leggi modello', ...
      'Plotta Modello', ...
      'Plotta Modi propri',...
      'Verifica analitica shell',...
      'Crea Shell',...
      'Calcola Risposta Forzata',...
      'Plotta risposta forzata con chirp',...
      'Ruota Modello', ...
      'Cambia numero Gauss point',...
      'Chiudi Finestre',...
      'Esci'};
ripeti = 1;
while ripeti
    scelta = menu(stit, vs);
    switch scelta
        case 1
            s = leggi_modello(mydir);
            ng = get_Ngauss();
            s = crea_modello_fem(s,ng);
            s = calcola_modello_modale(s);
        case 2
            if isempty(s)
                error_window('Devi prima leggere il modello.', 'logo.jpg');
            else
                fig = various_plot(s,fig);
            end
        case 3
            if isempty(s)
                error_window('Devi prima leggere il modello.', 'logo.jpg');
            else
                fig = plotta_modi(s,fig);
            end
        case 4
            if isempty(s)
                error_window('Devi prima leggere il modello.', 'logo.jpg');
            elseif ~isfield(s,'file') || ~contains(lower(s.file), 'shell')
                print_window( ...
                    {'Il modello che stai esaminando non e'' uno shell.', ...
                     '', ...
                     'La verifica analitica (Blevins, Donnell)', ...
                     'e'' applicabile solo a modelli il cui nome', ...
                     'file contiene "shell".'}, ...
                    'Verifica non applicabile');
            else
                confronta_freq_shell(s, s.freq, s.file);  % s.freq = vettore frequenze FEM [Hz]
            end
        case 5
            % --- Geometria ---
            R_sh  = query_double_d('Raggio medio R [m]', 0.01, 100, 1.0);
            h_sh  = query_double_d('Spessore h [m]', 1e-4, R_sh, 0.05);
            L_sh  = query_double_d('Lunghezza L [m]', 0.01, 1000, 4.0);
            % --- Discretizzazione ---
            nc_sh = query_integer_d('N. elementi in circonferenza', 2, 200, 12);
            na_sh = query_integer_d('N. elementi in direzione assiale', 1, 200, 8);
            nt_sh = query_integer_d('N. elementi nello spessore', 1, 10, 1);
            % --- Materiale ---
            ro_sh = query_double_d('Densita'' [kg/m^3]', 1, 30000, 7800);
            ni_sh = query_double_d('Coefficiente di Poisson', 0, 0.5, 0.3);
            E_sh  = query_double_d('Modulo di Young [Pa]', 1e6, 1e13, 2.1e11);
            % --- Penalita' vincoli SS ---
            kp_sh = query_double_d('Rigidezza penalita'' k_pen [N/m^3]', 0, 1e30, 1e6*E_sh/h_sh);
            % --- Nome file ---
            nome_default = 'shell_ss.el';
            risposta = inputdlg( ...
                {'Nome file .el (deve contenere "shell" per la verifica analitica):'}, ...
                'Salva modello', 1, {nome_default});
            if isempty(risposta)
                error('!!');
            end
            nome_file_sh = char(risposta);
            if ~endsWith(nome_file_sh, '.el')
                nome_file_sh = [nome_file_sh '.el'];
            end
            if ~contains(lower(nome_file_sh), 'shell')
                print_window( ...
                    {'Attenzione: il nome file non contiene "shell".', ...
                     'La verifica analitica non sara'' disponibile.'}, ...
                    'Avviso');
            end
            % --- Genera ---
            s = crea_modello_shell(R_sh, h_sh, L_sh, nc_sh, na_sh, nt_sh, ...
                ro_sh, ni_sh, E_sh, kp_sh, nome_file_sh);
            print_window( ...
                {sprintf('Shell creato: %s', nome_file_sh), ...
                 '', ...
                 sprintf('Nodi: %d,  Elementi: %d,  Vincoli: %d', s.nd, s.nel, s.nv), ...
                 sprintf('R=%.4g  h=%.4g  L=%.4g', R_sh, h_sh, L_sh), ...
                 sprintf('Mesh: %dx%dx%d', nc_sh, na_sh, nt_sh)}, ...
                'Shell creato');
        case 6
            [risp,fig] = risposta_forzata(s,fig);
        case 7
            if isempty(risp)
                error_window('Devi prima calcolare risposta forzata.', 'logo.jpg');
            else
                verifica_chirp_frf(risp, s)
            end
        case 8
            if isempty(s)
                error_window('Devi prima leggere il modello.','logo.jpg');
            else
                s=rotate_model(s,ng);
            end
        case 9
            ng = get_Ngauss(true);
        case 10
            close all hidden
        case 11
            ripeti = 0;
        case 0
            ripeti = 0;
        otherwise
            msg = sprintf('Opzione %d non implementata', scelta);
            error_window(msg, 'logo.jpg');
    end
end