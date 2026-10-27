function [param, X, map] = calc_cavites(I)
% I : imagette binaire (chiffre = 1) avec cadre noir
% param : surfaces relatives des cavites, ordre [E W S N C]

I = logical(I);

% points du fond depuis lesquels on rencontre le trace en allant vers E/W/S/N
% (equivalent a la dilatation par une demi-droite)
Ie = fliplr(cumsum(fliplr(I),2)) > 0;
Iw = cumsum(I,2) > 0;
Is = flipud(cumsum(flipud(I),1)) > 0;
In = cumsum(I,1) > 0;
bg = ~I;

CW = bg & Ie & ~Iw & In & Is;
CE = bg & Iw & ~Ie & In & Is;
CN = bg & Is & ~In & Ie & Iw;
CS = bg & In & ~Is & Ie & Iw;
CC = bg & Ie & Iw & In & Is;

A = [nnz(CE) nnz(CW) nnz(CS) nnz(CN) nnz(CC)];
param = A / max(sum(A),1);

% image indexee : 0 fond, 1 trace, 2 W, 3 E, 4 C, 5 N, 6 S
X = zeros(size(I),'uint8');
X(I)  = 1;
X(CW) = 2;
X(CE) = 3;
X(CC) = 4;
X(CN) = 5;
X(CS) = 6;
map = [0 0 0; 0.5 0.5 0.5; 0 1 0; 1 0 0; 1 0 1; 1 1 0; 0 0 1];
end