function A = assemblaggio_vettori(A,Ai,indx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASSEMBLAGGIO_VETTORI
%
%
% Federico Nanni, Samuele Tocco. 11-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n = length(indx);
    for i=1:n
        ii= indx(i);
        A(ii) = A(ii) + Ai(i);
    end
end
