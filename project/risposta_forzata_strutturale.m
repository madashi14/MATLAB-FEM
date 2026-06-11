function [risp,fig] = risposta_forzata_strutturale(s,fig)
% RISPOSTA_FORZATA_STRUTTURALE
% Calcola la risposta forzata integrando direttamente il sistema
% di equazioni differenziali del secondo ordine:
%   M*x'' + C*x' + K*x = F0 * alpha(t)
% convertito nel sistema del primo ordine di stato y = [x; dx].
%
% Chiede all'utente la forzante temporale e il solver ODE da usare.
% Se non e' presente la matrice C, usa smorzamento nullo.
%
% INPUT:
%   s   : struttura con s.M, s.K, s.C (opzionale), s.Forza, s.el, s.p
%   fig : indice figura corrente
%
% OUTPUT:
%   risp : struttura con risp.t, risp.y, risp.x, risp.dx, risp.F0, risp.ft
%   fig  : indice dell'ultima figura aperta (animazione)
    vel=s.el;
    nodi=s.p;
    if ~s.nf
        risp = [];
        error_window('No Forces !!!','logo.jpg');
        return
    end

    % Matrici strutturali
    M = s.M;
    K = s.K;

    if isfield(s,'C') && ~isempty(s.C)
        C = s.C;
    else
        C = zeros(size(M));
    end

    n = size(M,1);

    % Vettore spaziale globale della forza
    F0 = s.Forza(:);

    if length(F0) ~= n
        error('Dimensione errata: s.Forza deve avere dimensione ndof x 1.');
    end

    % Scelta forzante temporale
    ft = scegli_forzante_temporale();

    % Tempo di integrazione
    T = ft.t(:);

    % Condizioni iniziali
    x0  = zeros(n,1);
    dx0 = zeros(n,1);
    y0  = [x0; dx0];

    % Scelta solver ODE
    [odesol,options] = scelta_ode_solver();

    % Integrazione
    [t,y] = odesol(@(t,y) ode_forzata_strutturale(t,y,M,C,K,F0,ft), ...
                   T,y0,options);

    % Salvataggio risultati
    risp.t  = t;
    risp.y  = y;
    risp.x  = y(:,1:n);
    risp.dx = y(:,n+1:2*n);
    risp.F0 = F0;
    risp.ft = ft;

    % Animazione risposta dell'intero sistema
    fig = plotta_risposta_forzata_animata(risp,vel,nodi,fig);

end
function dydt = ode_forzata_strutturale(t,y,M,C,K,F0,ft)

    n = size(M,1);

    x  = y(1:n);
    dx = y(n+1:2*n);

    % Valore della forzante temporale al tempo t
    alfa = interp1(ft.t,ft.x,t,'linear',0);

    % Forza globale al tempo t
    Ft = F0 * alfa;

    % Equazione dinamica
    ddx = M \ (Ft - C*dx - K*x);

    % Derivata del vettore di stato
    dydt = [dx; ddx];

end




