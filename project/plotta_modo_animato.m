function fig=plotta_modo_animato(modo,vel,nodi,f,m,fig)
% PLOTTA_MODO_ANIMATO
% Anima il modo proprio numero m alla frequenza f [Hz] per ncycle cicli
% completi con nframe fotogrammi per ciclo.
%
% Ad ogni fotogramma calcola alpha = sin(theta) e disegna:
%   - la mesh non deformata in linea tratteggiata nera (k--)
%   - la mesh deformata di alpha * modo_scalato in rosso (r-)
% Lo scale factor e' recuperato con get_sc() e la dimensione
% caratteristica con dimensione_struttura().
%
% INPUT:
%   modo : vettore autovettore (ndof x 1)
%   vel  : array di strutture elemento
%   nodi : array di strutture nodo
%   f    : frequenza propria [Hz]
%   m    : numero del modo
%   fig  : indice figura corrente
%
% OUTPUT:
%   fig : indice della figura usata per l'animazione

sc = get_sc();
L= dimensione_struttura(nodi);  scale_factor= sc*L;
wmax=max_mode_disp(modo);
modo= modo*scale_factor/wmax;
nd= length(nodi);
N = get_Nplot();
nframe=40;
fig = set_fig(fig, sprintf('Modo #%d - f=%f [Hz]',m,f));
set(fig,'Toolbar','figure')
set(fig,'MenuBar','figure')
xn = [nodi.x]; yn = [nodi.y]; zn = [nodi.z];
max_def = max_mode_disp(modo) ;
margine = 0.1 * L;
xlim0 = [min(xn)-max_def-margine, max(xn)+max_def+margine];
ylim0 = [min(yn)-max_def-margine, max(yn)+max_def+margine];
zlim0 = [min(zn)-max_def-margine, max(zn)+max_def+margine];
ncycle=5;
ncycle = 5;
for c = 1:ncycle
    for iframe = 1:nframe
        if ~ishandle(fig)
            return
        end
        theta = 2*pi*(iframe-1)/nframe;
        alpha = sin(theta);
        nodi_def = nodi;
        for i = 1:nd
            ii = (i-1)*3;
            nodi_def(i).x = nodi(i).x + alpha*modo(ii+1);
            nodi_def(i).y = nodi(i).y + alpha*modo(ii+2);
            nodi_def(i).z = nodi(i).z + alpha*modo(ii+3);
        end
        cla
        hold on
        for i = 1:length(vel)
            plotta_el(vel(i), nodi, N, 'k--');
        end
        for i = 1:length(vel)
            plotta_el(vel(i), nodi_def, N, 'r-');
        end
        grid on
        view(3)
        xlim(xlim0); ylim(ylim0); zlim(zlim0);
        drawnow
    end
end

end


