function [sol,opt] = scelta_ode_solver()
% SCELTA_ODE_SOLVER
% Menu interattivo per la selezione del solutore ODE di MATLAB da usare
% nell'integrazione della risposta forzata (ode45, ode15s, ode23, ecc.).
% Chiede anche le tolleranze relative e assolute (RelTol, AbsTol).
%
% OUTPUT:
%   sol : function handle del solutore ODE scelto (es. @ode45)
%   opt : struttura opzioni ODE con RelTol e AbsTol impostati

    vsol = {'ode45','ode15s','ode23','ode113','ode23t','ode23tb','ode23s'};

    is = menu('Scelta solutore ODE',vsol);

    if is == 0
        is = 1;   % default ode45
    end

    sol = str2func(vsol{is});

    RelTol = 1e-3;
    AbsTol = 1e-6;

    vstr = {'AbsTol','RelTol'};
    xmin = [eps,eps];
    xmax = [1e10,1];
    xdef = [AbsTol,RelTol];

    out = query_multiple_exit('Ode Options',vstr,xmin,xmax,xdef);

    if isempty(out)
        out = xdef;
    end

    AbsTol = out(1);
    RelTol = out(2);

    opt = odeset('RelTol',RelTol,'AbsTol',AbsTol);

end

