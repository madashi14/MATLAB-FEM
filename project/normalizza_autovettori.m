function    V= normalizza_autovettori(V,mat)
    [~,m]=size(V);
    for i=1:m
        vi= V(:,i);  vi= vi/sqrt(vi.'*mat*vi);
        V(:,i)= vi;
    end
end
