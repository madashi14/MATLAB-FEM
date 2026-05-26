function s = analisi_modale(s)

[Vs,D] = eig(s.K,s.M);
lambda = diag(D);
omega = sqrt(lambda);
freqs = omega/(2*pi);
s.freq=freqs;
[s.freq,idx]=sort(s.freq);
s.V=Vs(:,idx);
vs='Quante frequenze vuoi stampare?';
ancora=1;
xmax=100;
xmin=1;
xdef=10;
while ancora
    n=query_integer_d(vs,xmin,xmax,xdef);
    ancora=0;
end

stit=sprintf('Prime %d Frequenze Proprie',n);
for i=1:n
    str{i}=sprintf('%d Freq Propria: %f [Hz]', i, s.freq(i));
end
print_window(str,stit);

end