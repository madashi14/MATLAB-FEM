# MATLAB-FEM
 IT - Nel presente lavoro viene sviluppato un codice MATLAB per l'analisi dinamica
e vibratoria di strutture tridimensionali mediante il metodo degli elementi finiti. Il
modello numerico è basato sull'impiego di elementi solidi isoparametrici quadratici
serendipity a 20 nodi, indicati come Hexa20. Le matrici elementari di rigidezza e
massa vengono calcolate mediante integrazione numerica di Gauss e successivamente
assemblate nelle corrispondenti matrici globali del sistema. Il problema agli autovalori
generalizzato viene risolto per determinare le frequenze naturali e le forme
modali della struttura. La risposta dinamica forzata smorzata e non viene calcolata
secondo due approcci: il metodo diretto, che integra numericamente le equazioni del
moto nel dominio del tempo, e il metodo modale, che sfrutta la sovrapposizione dei
modi propri per disaccoppiare il sistema. La correttezza del codice viene valutata
attraverso una serie di verifche numeriche conservazione della massa, semidenita
positività della matrice di rigidezza, invarianza delle frequenze proprie per rotazione
del modello e verifca tramite funzione di risposta in frequenza  e mediante il
confronto con la soluzione analitica di Donnell per gusci cilindrici sottili.

EN - In the present work, a MATLAB code is developed for the dynamic and vibrational analysis of three-dimensional structures using the finite element method. The numerical model is based on the use of 20-node quadratic serendipity isoparametric solid elements, referred to as Hexa20 elements. The elemental stiffness and mass matrices are computed by means of Gauss numerical integration and are subsequently assembled into the corresponding global system matrices.

The generalised eigenvalue problem is solved in order to determine the natural frequencies and mode shapes of the structure. The damped and undamped forced dynamic response is computed using two different approaches: the direct method, which numerically integrates the equations of motion in the time domain, and the modal method, which exploits the superposition of the natural modes to decouple the system.

The correctness of the code is assessed through a series of numerical verification tests, including mass conservation, positive semidefiniteness of the stiffness matrix, invariance of the natural frequencies under model rotation, and verification through the frequency response function. Finally, the numerical results are compared with the analytical Donnell solution for thin cylindrical shells.
