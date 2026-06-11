function sig = scegli_forzante_temporale()
% SCEGLI_FORZANTE_TEMPORALE
% Menu interattivo per la scelta e la generazione della forzante temporale
% da usare nell'integrazione della risposta forzata.
%
% Tipi di forzante disponibili:
%   1. Random (segnale casuale uniforme)
%   2. Armonica (seno a frequenza e ampiezza specificate)
%   3. Serie di armoniche (somma di sinusoidi random)
%   4. Serie di armoniche smorzate (con decadimento esponenziale)
%   5. Chirp (sweep di frequenza lineare)
%   6. Pseudo impulso (rettangolo di area unitaria)
%
% OUTPUT:
%   sig : struttura con sig.t (vettore tempi), sig.x (vettore segnale),
%         sig.N (numero campioni), sig.fc (frequenza campionamento [Hz])

    v = {'Random', ...
         'Armonica', ...
         'Serie armoniche', ...
         'Serie armoniche smorzate', ...
         'Chirp', ...
         'Pseudo impulso', ...
         'Esci'};

    scelta = menu('Scegli forzante temporale',v);

    switch scelta
        case 1
            sig = genera_segnale_casuale();

        case 2
            sig = genera_segnale_armonico();

        case 3
            sig = genera_serie_armoniche();

        case 4
            sig = genera_serie_armoniche_smorzate();

        case 5
            sig = genera_segnale_chirp();

        case 6
            sig = genera_segnale_pseudo_impulso_area();

        otherwise
            error('Scelta forzante annullata.');
    end

    sig.t = (0:sig.N-1)/sig.fc;

end

function    s=genera_segnale_casuale()
    stitle= 'Genera segnale random';
    vs= {'N','fc [Hz]','Amin', 'Amax'};
    ancora= 1;
    xmin= [2,1e-6,-1e6,-1.e6];
    xmax= [100000000,1e6,1e6,1.e6];
    xdef= [1024,1000.,-100,100.];
    while ancora
        out= query_multiple_exit(stitle,vs,xmin,xmax,xdef);
        s.N= out(1); s.fc= out(2); Amin= out(3); Amax= out(4);
        if Amax>Amin  ancora=0; end
    end
    tmax= (s.N-1)/s.fc; t= linspace(0,tmax,s.N);
    s.x= Amin+(Amax-Amin)*rand(size(t));
    
end


function    s=genera_segnale_armonico()
    stitle= 'Genera segnale armonico';
    vs= {'N','fc [Hz]','Amplitude', 'Frequency [Hz]', 'Phase [deg]'};
    xmin= [2,1e-6,1e-6,1.e-6,0.];
    xmax= [100000000,1e6,1e10,1.e5,360.];
    xdef= [1024,1000.,10.,100.,30.];
    out= query_multiple_exit(stitle,vs,xmin,xmax,xdef);
    s.N= out(1); s.fc= out(2); A= out(3); w= 2*pi*out(4); ph= pi*out(5)/180;
    tmax= (s.N-1)/s.fc; t= linspace(0,tmax,s.N);
    s.x= A*sin(w*t+ph);
  
end

function    s=genera_serie_armoniche()
    stitle= 'Genera segnale serie armoniche';
    vs= {'N','fc [Hz]','Numero componenti','Amin','Amax',...
        'fmin [Hz]', 'fmax [Hz]'};
    ancora= 1;
    xmin= [2,1e-6,1,1e-6,1e-6,1e-6,1e-6];
    xmax= [100000000,1e6,1000,1e6,1e6,1e5,1e5];
    xdef= [1024,1000.,10,1.,10.,1,400.];
    while ancora
        out= query_multiple_exit(stitle,vs,xmin,xmax,xdef);
        s.N= out(1); s.fc= out(2); n= out(3);
        Amin= out(4); Amax= out(5);
        wmin= 2*pi*out(6); wmax= 2*pi*out(7);
        if Amax>Amin & wmax>wmin
            ancora=0;
        end
    end
    
    tmax= (s.N-1)/s.fc; t= linspace(0,tmax,s.N);
    vA= Amin+(Amax-Amin)*rand(n,1);
    vw= wmin+(wmax-wmin)*rand(n,1);
    vph= -pi+2*pi*rand(n,1);
    s.x= zeros(size(t));
    for i=1:n
        s.x= s.x+vA(i)*sin(vw(i)*t+vph(i));
    end
 
end

function    s=genera_serie_armoniche_smorzate()
    stitle= 'Genera segnale serie armoniche smorzate';
    vs= {'N','fc [Hz]','Numero componenti','Amin','Amax',...
        'fmin [Hz]', 'fmax [Hz]', 'zita min [%]', 'zita max [%]'};
    ancora= 1;
    xmin= [2,1e-6,1,1e-6,1e-6,1e-6,1e-6,1e-3,1e-3];
    xmax= [100000000,1e6,1000,1e6,1e6,1e5,1e5,100.,100.];
    xdef= [1024,1000.,10,1.,10.,1,400.,1.e-3,1.e-2];
    while ancora
        out= query_multiple_exit(stitle,vs,xmin,xmax,xdef);
        s.N= out(1); s.fc= out(2); n= out(3);
        Amin= out(4); Amax= out(5);
        wmin= 2*pi*out(6); wmax= 2*pi*out(7);
        zmin= out(8); zmax= out(9);
        if Amax>Amin & wmax>wmin & zmax>zmin &wmax<pi*s.fc
            ancora=0;
        end
    end
    
    tmax= (s.N-1)/s.fc; t= linspace(0,tmax,s.N);
    vA= Amin+(Amax-Amin)*rand(n,1);
    vw= wmin+(wmax-wmin)*rand(n,1);
    vzita= zmin+(zmax-zmin)*rand(n,1);
    vph= -pi+2*pi*rand(n,1);
    s.x= zeros(size(t));
    for i=1:n
        s.x= s.x+vA(i)*exp(-vzita(i)*vw(i)*t).*sin(vw(i)*t+vph(i));
    end
   
end

function s=genera_segnale_chirp()
    stitle= 'Genera segnale chirp';
    vs= {'N','fc [Hz]','f0 [Hz}','f1 [Hz]'};
    ancora= 1;
    xmin= [2,1e-6,0.,1e-6];
    xmax= [100000000,1e6,1e6,1e6];
    xdef= [1024,1000.,0.,100.];
    while ancora
        out= query_multiple_exit(stitle,vs,xmin,xmax,xdef);
        s.N= out(1); s.fc= out(2); f0= out(3); f1= out(4);
        fmax= 0.5*s.fc;
        if f1<fmax & f0<f1
            ancora=0;
        end
    end
    time= linspace(0,(s.N-1)/s.fc,s.N);
    s.x= chirp(time,f0,time(end),f1);
    s.X= fft(s.x);
    s.tipo='chirp';
    s.f0   = f0;
    s.f1   = f1;

end
function s = genera_segnale_pseudo_impulso_area()

stitle = 'Genera segnale pseudo impulso';

vs = {'N','fc [Hz]','Impulso I','t0 [s]','dt impulso [s]'};

xmin = [2, 1e-6, -1e10, 0, 1e-12];
xmax = [100000000, 1e6, 1e10, 1e10, 1e10];
xdef = [1024, 1000., 1., 0.01, 0.001];

ancora = 1;

while ancora

    out = query_multiple_exit(stitle,vs,xmin,xmax,xdef);

    if isempty(out)
        out = xdef;
    end

    s.N  = round(out(1));
    s.fc = out(2);
    Iimp = out(3);
    t0   = out(4);
    dt   = out(5);

    tmax = (s.N-1)/s.fc;

    if t0 >= 0 && t0 < tmax && dt > 0 && t0+dt <= tmax
        ancora = 0;
    else
        error_window('Pseudo impulso fuori dal range temporale','logo.jpg');
    end

end

tmax = (s.N-1)/s.fc;
t = linspace(0,tmax,s.N);

A = Iimp/dt;

s.x = zeros(size(t));
indx = t >= t0 & t <= t0+dt;
s.x(indx) = A;

s.t = t;


end