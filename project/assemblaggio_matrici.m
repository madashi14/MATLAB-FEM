function A = assemblaggio_matrici(A,Ai,indx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASSEMBLAGGIO_MATRICI
%
%
% Federico Nanni, Samuele Tocco. 11-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n = length(indx);
    for i=1:n
        ii= indx(i);
        for j=1:n
            jj= indx(j);
            A(ii,jj) = A(ii,jj) + Ai(i,j);
        end
    end
end



