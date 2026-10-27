%% TE2 - Application 3 : photo de nuit (bastille_lune.JPG)
clear; close all; clc;

I = imread("C:\Users\MSI\Documents\MATLAB\Vidéo et image\Jeanne\Images_Codes_Etudiants\Images_Codes_Etudiants\bastille_lune.JPG");
I = I(1:2:end, 1:2:end, :);              % sous-échantillonnage x2
hsv = rgb2hsv(I);
H = hsv(:,:,1); S = hsv(:,:,2); V = hsv(:,:,3);

figure; montage({hsv2rgb(cat(3,V,V,V)), S, H}, 'Size', [1 3]); title('V | S | H');

%% Débruitage
% Chrominance : le bruit y est fort -> filtrage médian + gaussien
S_f = imgaussfilt(medfilt2(S, [5 5]), 1.5);
H_f = H;                                 % teinte : circulaire, on ne touche pas

% Luminance : médian puis gaussien
V_med = medfilt2(V, [3 3]);
V_dn  = imgaussfilt(V_med, 1.2);

%% Renforcement des contours (masque flou), uniquement sur les zones à contours
gx = imfilter(V_dn, fspecial('sobel')', 'replicate');
gy = imfilter(V_dn, fspecial('sobel'),  'replicate');
G  = hypot(gx, gy);
seuil = prctile(G(:), 90);
E = imgaussfilt(double(G > seuil), 1);   % masque de contours adouci

V_sharp = V_dn + 1.2 * (V_dn - imgaussfilt(V_dn, 2));
V_out   = E .* V_sharp + (1 - E) * 1 .* V_dn;   % lissage dans les zones plates
V_out   = min(max(V_out, 0), 1);

out = hsv2rgb(cat(3, H_f, S_f, V_out));

%% Affichage
figure; montage({I, im2uint8(out)}, 'Size', [1 2]); title('Originale | Améliorée');
figure;
subplot(1,2,1); imshow(I(end/2:end, 1:end/2, :));       title('Zoom original');
o8 = im2uint8(out);
subplot(1,2,2); imshow(o8(end/2:end, 1:end/2, :));      title('Zoom amélioré');
imwrite(o8, "C:\Users\MSI\Documents\MATLAB\Vidéo et image\Jeanne\Images_Codes_Etudiants\Images_Codes_Etudiants\bastille_lune.JPG"');