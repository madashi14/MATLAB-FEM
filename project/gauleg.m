%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Libreria utilities per il corso
%  laboratorio di meccanica delle vibrazioni e sperimentazione, Universita`  degli studi di Bologna
%
%  Utilizzo riservato per i soli fini didattici agli studenti 
%  del corso laboratorio di meccanica delle vibrazioni e sperimentazione
%  Ogni altro utilizzo, in assenza di autorizzazione scritta del docente del corso, e` espressamente vietato  
%
% Giuseppe Catania, 2014-19
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x,w]= gauleg(x1,x2,n)
% GAULEG
% Calcola i nodi (x) e i pesi (w) della quadratura di Gauss-Legendre
% su un intervallo [x1, x2] con n punti.
%
% Usa il metodo iterativo di Newton per trovare le radici del polinomio
% di Legendre di grado n, con precisione pari alla precisione macchina.
% I pesi sono calcolati dalla formula analitica.
%
% La quadratura di Gauss-Legendre integra esattamente polinomi fino
% al grado (2n-1).
%
% INPUT:
%   x1, x2 : estremi dell'intervallo di integrazione
%   n      : numero di punti di Gauss
%
% OUTPUT:
%   x : vettore (1xn) dei nodi di quadratura
%   w : vettore (1xn) dei pesi di quadratura

	DMACHEPS= 1.0e-16;
	m=(n+1)/2;
	xm=0.5*(x2+x1);
	xl=0.5*(x2-x1);
	for i=1:m  
      z=cos(pi*(i-0.25)/(n+0.5));
      ancora= 1;
	 while ancora
		p1=1.0;
			p2=0.0;
			for j=1:n 
				p3=p2;
				p2=p1;
            		p1=((2.0*j-1.0)*z*p2-(j-1.0)*p3)/j;
         		end
			pp=n*(z*p1-p2)/(z*z-1.0);
			z1=z;
			z=z1-p1/pp;
      	if abs(z-z1) <= DMACHEPS
           	ancora= 0;
         	end
     	end
	x(i)=xm-xl*z;
	x(n+1-i)=xm+xl*z;
	w(i)=2.0*xl/((1.0-z*z)*pp*pp);
	w(n+1-i)=w(i);
end
