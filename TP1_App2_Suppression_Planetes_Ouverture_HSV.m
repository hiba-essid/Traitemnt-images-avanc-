%% TP1 - Application 2 : suppression des petites planetes (image couleur)
%  Ouverture par un disque ; morphologie appliquee au seul canal V (HSV)
%  pour ne pas alterer teinte et saturation.

clear; close all; clc;

%% Lecture
RGB = imread("C:\Users\MSI\Downloads\fichiersTE1_2023\1200px-BH_LMC.png");
if size(RGB,3) == 4, RGB = RGB(:,:,1:3); end
RGB = im2double(RGB);

R  = 3;
se = strel('disk', R);

%% Methode A : canal par canal en RGB
A_open = zeros(size(RGB));
A_rec  = zeros(size(RGB));
for c = 1:3
    A_open(:,:,c) = imopen(RGB(:,:,c), se);
    A_rec(:,:,c)  = imreconstruct(imerode(RGB(:,:,c), se), RGB(:,:,c));
end

%% Methode B : HSV, canal V uniquement
HSV = rgb2hsv(RGB);
H = HSV(:,:,1);  S = HSV(:,:,2);  V = HSV(:,:,3);

Vopen  = imopen(V, se);
B_open = hsv2rgb(cat(3, H, S, Vopen));

Vrec  = imreconstruct(imerode(V, se), V);
B_rec = hsv2rgb(cat(3, H, S, Vrec));

%% Affichage
figure('Name','Application 2','Color','w');
subplot(2,3,1), imshow(RGB),    title('Originale');
subplot(2,3,2), imshow(A_open), title('RGB canal/canal - ouverture');
subplot(2,3,3), imshow(A_rec),  title('RGB canal/canal - reconstruction');
subplot(2,3,4), imshow(RGB),    title('Originale');
subplot(2,3,5), imshow(B_open), title('HSV (V) - ouverture');
subplot(2,3,6), imshow(B_rec),  title('HSV (V) - reconstruction');

z1 = round(size(RGB,1)*0.30):round(size(RGB,1)*0.55);
z2 = round(size(RGB,2)*0.30):round(size(RGB,2)*0.55);
figure('Name','Zoom','Color','w');
subplot(1,3,1), imshow(RGB(z1,z2,:)),    title('Originale');
subplot(1,3,2), imshow(B_open(z1,z2,:)), title('Ouverture classique');
subplot(1,3,3), imshow(B_rec(z1,z2,:)),  title('Ouverture par reconstruction');

%% Comparaison quantitative sur les zones a conserver
masque = (V - Vrec) < 0.02;
M3  = repmat(masque, [1 1 3]);
err = @(X) mean(abs(RGB(M3) - X(M3)));

fprintf('Erreur moyenne sur les zones a conserver :\n');
fprintf('  RGB canal/canal ouverture : %.5f\n', err(A_open));
fprintf('  RGB canal/canal reconstr. : %.5f\n', err(A_rec));
fprintf('  HSV(V) ouverture          : %.5f\n', err(B_open));
fprintf('  HSV(V) reconstruction     : %.5f\n', err(B_rec));

Ha = rgb2hsv(A_open); Ha = Ha(:,:,1);
Hb = rgb2hsv(B_rec);  Hb = Hb(:,:,1);
fprintf('Derive de teinte : RGB = %.5f | HSV = %.5f\n', ...
    mean(abs(H(masque)-Ha(masque))), mean(abs(H(masque)-Hb(masque))));

figure('Name','Objets supprimes','Color','w');
imshow(V - Vrec, []); title('Residu'); colorbar;