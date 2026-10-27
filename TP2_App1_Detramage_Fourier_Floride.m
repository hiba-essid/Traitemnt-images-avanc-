%% TE2 - Application 1 : dé-tramage (Floride.tif)
clear; close all; clc;

I = double(imread("C:\Users\MSI\Documents\MATLAB\Vidéo et image\Jeanne\Images_Codes_Etudiants\Images_Codes_Etudiants\Floride.tif"));
if size(I,3) > 1, I = mean(I,3); end
[h, w] = size(I);

nfft   = 2^nextpow2(max(h, w));
centre = nfft/2 + 1;

%% 1. Spectre d'amplitude (log)
F = fftshift(fft2(I, nfft, nfft));
figure; 
subplot(1,2,1); imagesc(I); colormap gray; axis image; title('Image initiale');
subplot(1,2,2); imagesc(log2(1 + abs(F))); axis image; title('Spectre (log2)');
% Lignes horizontales -> énergie parasite sur l'axe vertical (colonne "centre") du spectre

%% 2-3. Masque binaire
M = ones(nfft, nfft);
M(:, centre-1:centre+1) = 0;                    % on coupe l'axe vertical
r = 10;
M(centre-r:centre+r, centre-1:centre+1) = 1;    % on garde les basses fréquences

Ib = real(ifft2(ifftshift(F .* M)));
Ib = Ib(1:h, 1:w);

figure; 
subplot(1,3,1); imagesc(M); axis image; colormap gray; title('Masque binaire');
subplot(1,3,2); imagesc(I);  axis image; title('Initiale');
subplot(1,3,3); imagesc(Ib); axis image; title('Filtrage binaire');

%% 4. Filtre gaussien
HHg = ones(nfft, nfft);
[U, V] = ndgrid(1:nfft, centre-3:centre+3);
D2  = (U - centre).^2;
HHg(:, centre-3:centre+3) = exp(-D2 / (2*20^2));
% Bande verticale de 7 colonnes autour de fx = 0 : gain 1 en (fy = 0) qui décroît
% en gaussienne avec la distance à la fréquence nulle ; ailleurs le gain vaut 1.

Ig = real(ifft2(ifftshift(F .* HHg)));
Ig = Ig(1:h, 1:w);

figure; imagesc(HHg); axis image; colormap gray; colorbar; title('HHg');

figure;
subplot(1,3,1); imagesc(I);  axis image; colormap gray; title('Initiale');
subplot(1,3,2); imagesc(Ib); axis image; title('Masque binaire');
subplot(1,3,3); imagesc(Ig); axis image; title('Masque gaussien');