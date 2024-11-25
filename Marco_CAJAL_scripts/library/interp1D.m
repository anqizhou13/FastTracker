%interp1D.m

%la funzione utilizza la trasformata di Fourier per calcolare la matrice
%interpolata ad n punti; l'algoritmo, al fine di rendere più regolare il
%segnale opera all'inizio e alla fine del vettore un processo di zero
%padding costruendo, per ogni colonna della matrice d'ingresso un vettore
%di dimensione tripla rispetto all'originale che nei campioni centrali
%contiene i valori del vettore di partenza

function Mint=interp1D(M,n)

r=size(M,1);
c=size(M,2);

%per avere un corretto funzionamento della funzione interpft è necessario
%che il numero di campioni d'ingresso e di uscita non siano coincidenti
if n==r
    Mint=M;
else 
    for i=1:1:c
        x=zeros(3*r,1);
        x(r+1:2*r,1)=M(:,i);
        y=interpft(x,3*n);
        Mint(:,i)=y(n+1:2*n,1);
    end
end

Mint=kalm2ord(Mint);
