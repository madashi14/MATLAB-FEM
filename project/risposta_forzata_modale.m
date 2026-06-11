function [risp,fig] = risposta_forzata_modale(s,fig)
% RISPOSTA_FORZATA_MODALE
% Calcola la risposta forzata per sovrapposizione modale.
% Proietta il sistema su n_modi autovettori, integra le equazioni
% disaccoppiate in coordinate modali e ritorna alle coordinate fisiche.
%
% Vantaggi rispetto al metodo diretto: dimensione del sistema integrato
% 2*n_modi << 2*ndof, quindi molto piu' veloce per strutture con molti gdl.
%
% Scarta automaticamente i modi rigidi (freq < 0.1 Hz).
% Chiede all'utente: smorzamento modale zeta, forzante temporale, solver ODE.
%
% INPUT:
%   s   : struttura con s.V, s.freq, s.K, s.M, s.Forza
%   fig : indice figura corrente
%
% OUTPUT:
%   risp : struttura con risp.t, risp.x, risp.dx, risp.F0, risp.ft
%   fig  : indice dell'ultima figura aperta (animazione)

    vel  = s.el;
    nodi = s.p;

    if ~s.nf
        risp = [];
        error_window('No Forces !!!','logo.jpg');
        return
    end

    % --- Dati modali ----------------------------------------------------
    V     = s.V;                         % ndof x n_modi
    freq  = s.freq(:);                   % n_modi x 1  [Hz]
    ndof  = size(V,1);

    % scarta modi rigidi (freq == 0)
    idx_flex = find(freq > 0.1);
    V_flex   = V(:, idx_flex);
    omega    = 2*pi*freq(idx_flex);      % pulsazioni [rad/s]
    nmodi    = length(omega);

    % matrici modali diagonali (vettori)
    mm = diag(V_flex' * s.M * V_flex);   % ~1 se M-normalizzati
    km = diag(V_flex' * s.K * V_flex);   % ~omega_i^2

    % --- Smorzamento modale ---------------------------------------------
    zeta = query_double_d('Smorzamento modale zeta', 0, 1, 0.01);
    cm   = 2*zeta*omega(:) .* mm;

    % --- Forza modale ---------------------------------------------------
    F0   = s.Forza(:);
    Fm   = V_flex' * F0;                 % nmodi x 1

    % --- Forzante temporale (stessa scelta della versione diretta) ------
    ft = scegli_forzante_temporale();
    T  = ft.t(:);

    % --- Condizioni iniziali modali (partenza da fermo) -----------------
    q0 = zeros(2*nmodi, 1);

    % --- Scelta solver ODE ----------------------------------------------
    [odesol, options] = scelta_ode_solver();

    % --- Integrazione in coordinate modali ------------------------------
    [t, yq] = odesol(@(t,y) ode_modale(t, y, mm, cm, km, Fm, ft), ...
                      T, q0, options);

    % --- Ritorno alle coordinate fisiche --------------------------------
    q  = yq(:, 1:nmodi);                % nt x nmodi
    dq = yq(:, nmodi+1:2*nmodi);

    x  = q  * V_flex';                  % nt x ndof
    dx = dq * V_flex';

    % --- Output (identico a risposta_forzata_strutturale) ---------------
    risp.t  = t;
    risp.y  = [x dx];
    risp.x  = x;
    risp.dx = dx;
    risp.F0 = F0;
    risp.ft = ft;

    % --- Animazione -----------------------------------------------------
    fig = plotta_risposta_forzata_animata(risp, vel, nodi, fig);

end

% ========================================================================
function dydt = ode_modale(t, y, mm, cm, km, Fm, ft)
%
%   q_i'' + (cm_i/mm_i)*q_i' + (km_i/mm_i)*q_i = (Fm_i/mm_i)*alpha(t)
%
    n  = length(mm);
    q  = y(1:n);
    dq = y(n+1:2*n);

    alpha = interp1(ft.t, ft.x, t, 'linear', 0);

    ddq = (Fm*alpha - cm.*dq - km.*q) ./ mm;

    dydt = [dq; ddq];
end