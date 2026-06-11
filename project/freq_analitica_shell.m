function [freq_tab, f_min, ij_min] = freq_analitica_shell(R, h, L, ro, ni, E, i_max, j_max)
% FREQ_ANALITICA_SHELL
% Calcola le frequenze naturali analitiche di un guscio cilindrico
% semplicemente appoggiato (simply supported) con la teoria di Donnell.
%
% Per ogni coppia (i, j) con i = numero di mezze onde assiali e
% j = numero di onde circonferenziali, risolve l'equazione caratteristica
% della teoria di Donnell per gusci cilindrici sottili.
%
% INPUT:
%   R, h, L  : raggio medio, spessore, lunghezza [m]
%   ro, ni, E: densita', Poisson, Young [SI]
%   i_max    : numero massimo di mezze onde assiali
%   j_max    : numero massimo di onde circonferenziali
%
% OUTPUT:
%   freq_tab : matrice (i_max+1) x j_max delle frequenze [Hz]
%   f_min    : frequenza fondamentale [Hz]
%   ij_min   : [i, j] corrispondenti alla frequenza fondamentale

    if nargin < 7 || isempty(i_max),  i_max = 20;  end
    if nargin < 8 || isempty(j_max),  j_max = 5;   end

    k = h^2 / (12*R^2);
    c_freq = 1/(2*pi*R) * sqrt(E / (ro*(1-ni^2)));

    freq_tab = zeros(i_max+1, j_max);
    f_min    = Inf;
    ij_min   = [0, 1];

    for j = 1:j_max
        xi = j*pi*R / L;
        for i = 0:i_max
            s = i^2 + xi^2;

            K2 = 1 + 0.5*(3 - ni)*s + k*s^2;
            K1 = 0.5*(1 - ni) * ( (3 + 2*ni)*xi^2 + i^2 + s^2 ...
                 + (3 - ni)/(1 - ni) * k * s^3 );
            K0 = 0.5*(1 - ni) * ( (1 - ni^2)*xi^4 + k*s^4 );

            p   = [1, -K2, K1, -K0];
            rad = roots(p);
            rad = real(rad(abs(imag(rad)) < 1e-12*max(abs(rad)+1)));
            rad = rad(rad > 0);

            if isempty(rad)
                freq_tab(i+1, j) = NaN;
                continue
            end

            lambda_min = sqrt(min(rad));
            f_ij       = lambda_min * c_freq;

            freq_tab(i+1, j) = f_ij;

            if f_ij < f_min
                f_min  = f_ij;
                ij_min = [i, j];
            end
        end
    end

    % --- Stampa risultati con print_window ------------------------------
    str = {};
    str{end+1} = 'Frequenze analitiche - Donnell shell theory';
    str{end+1} = '';
    str{end+1} = sprintf('R = %.4g m,  h = %.4g m,  L = %.4g m', R, h, L);
    str{end+1} = sprintf('h/R = %.4g,  L/R = %.4g,  k = %.4e', h/R, L/R, k);
    str{end+1} = sprintf('ro = %.4g kg/m3,  ni = %.4g,  E = %.4g Pa', ro, ni, E);
    str{end+1} = '';

    % intestazione
    riga = '  i\j  ';
    for j = 1:j_max
        riga = [riga, sprintf('   j=%-5d', j)];
    end
    str{end+1} = riga;

    sep = '  -----';
    for j = 1:j_max
        sep = [sep, '----------'];
    end
    str{end+1} = sep;

    % corpo tabella
    for i = 0:i_max
        riga = sprintf('  i=%2d ', i);
        for j = 1:j_max
            f = freq_tab(i+1, j);
            if isnan(f)
                riga = [riga, sprintf('   %8s', '---')];
            else
                riga = [riga, sprintf('  %8.2f', f)];
            end
        end
        str{end+1} = riga;
    end

    str{end+1} = '';
    str{end+1} = sprintf('Frequenza fondamentale:  f_min = %.4f Hz   (i=%d, j=%d)', ...
                          f_min, ij_min(1), ij_min(2));

    print_window(str, 'Frequenze analitiche shell');
end
