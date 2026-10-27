%% TP5 - Application 1 : Redressement du bonhomme de neige par série de Fourier
% Une figure par étape du TP (Figure 1 = étape 1, ..., Figure 6 = étape 6).
% Les fonctions fournies (momentcentre.m, moment.m, fourier.m, ifourier.m) peuvent
% remplacer les calculs équivalents codés ici (voir les commentaires "Equivalent").
clear; close all; clc;

%% Lecture et binarisation
I = imread('snowman.bmp');
if size(I,3) == 3, I = rgb2gray(I); end
B = imbinarize(im2double(I));
if mean(B(:)) > 0.5, B = ~B; end          % l'objet doit valoir 1
B = imfill(bwareafilt(B,1), 'holes');     % silhouette principale, sans trou
[nl, nc] = size(B);

%% ===================== ETAPE 1 : orientation de l'axe principal =====================
[X, Y] = meshgrid(1:nc, 1:nl);            % X = colonne, Y = ligne (axe y vers le bas)
m00  = sum(B(:));                         % Equivalent : moment(B,0,0)
xg   = sum(X(B)) / m00;                   % Equivalent : moment(B,1,0)/moment(B,0,0)
yg   = sum(Y(B)) / m00;                   % Equivalent : moment(B,0,1)/moment(B,0,0)
mu20 = sum((X(B)-xg).^2);                 % Equivalent : momentcentre(B,2,0)
mu02 = sum((Y(B)-yg).^2);                 % Equivalent : momentcentre(B,0,2)
mu11 = sum((X(B)-xg).*(Y(B)-yg));         % Equivalent : momentcentre(B,1,1)
theta = 0.5 * atan2(2*mu11, mu20 - mu02); % angle de l'axe principal / axe des x
fprintf('Etape 1 : centre de gravité = (%.1f, %.1f), orientation = %.2f deg\n', ...
        xg, yg, theta*180/pi);

figure('Name', 'Etape 1 : orientation');
imshow(B); hold on;
L = 0.45 * max(nl, nc);
plot(xg + L*[-1 1]*cos(theta),          yg + L*[-1 1]*sin(theta),          'r-',  'LineWidth', 2);
plot(xg + L*[-1 1]*cos(theta + pi/2)/2, yg + L*[-1 1]*sin(theta + pi/2)/2, 'c--', 'LineWidth', 1.5);
plot(xg, yg, 'y+', 'MarkerSize', 14, 'LineWidth', 2);
legend('Axe principal', 'Axe secondaire', 'Centre de gravité', 'Location', 'southoutside');
title(sprintf('Etape 1 : axe principal à %.1f°', theta*180/pi));

%% ===================== ETAPE 2 : coordonnées du contour centrées =====================
% a. détection du contour
C = bwperim(B);

% b. suivi de contour dans le sens horaire à partir d'un point du contour
[r0, c0] = find(B, 1, 'first');           % pixel le plus haut de la colonne la plus à gauche
bnd = bwtraceboundary(B, [r0 c0], 'N');   % [ligne colonne] de chaque point
bnd = bnd(1:end-1, :);                    % le dernier point répète le point de départ
N   = size(bnd, 1);

% c. centrage sur le centre de gravité (PAS d'imshow ici : coordonnées négatives)
x = bnd(:,2) - xg;
y = bnd(:,1) - yg;
fprintf('Etape 2 : %d points de contour\n', N);

figure('Name', 'Etape 2 : contour');
subplot(1,3,1); imshow(C); title('2a. Contour détecté');
subplot(1,3,2); imshow(B); hold on;
plot(bnd(:,2), bnd(:,1), 'g-', 'LineWidth', 1.5);
plot(c0, r0, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
pas = max(1, round(N/12));                % flèches pour montrer le sens horaire
quiver(bnd(1:pas:end-1,2), bnd(1:pas:end-1,1), ...
       bnd(2:pas:end,2) - bnd(1:pas:end-1,2), bnd(2:pas:end,1) - bnd(1:pas:end-1,1), ...
       3, 'y', 'LineWidth', 1.5);
title('2b. Suivi (sens horaire)');
subplot(1,3,3);
plot(x, y, 'b-', 'LineWidth', 1.5); hold on;
plot(0, 0, 'r+', 'MarkerSize', 12, 'LineWidth', 2);
axis equal ij; grid on; xlabel('x - x_g'); ylabel('y - y_g');
title('2c. Coordonnées centrées');

%% ===================== ETAPE 3 : descripteurs de Fourier =====================
[Ax, Ay] = fourierDesc(x, y);             % Equivalent : fonction fournie fourier.m
f = (-floor(N/2):ceil(N/2)-1)';           % fréquences centrées

figure('Name', 'Etape 3 : descripteurs');
subplot(2,1,1);
stem(f, fftshift(abs(Ax)), 'b.'); hold on;
stem(f, fftshift(abs(Ay)), 'r.');
set(gca, 'YScale', 'log'); xlim([-50 50]); grid on;
legend('|A_x(k)|', '|A_y(k)|'); xlabel('harmonique k'); ylabel('module');
title('Etape 3 : module des descripteurs (zoom sur |k| \leq 50)');
subplot(2,1,2);
plot(f, fftshift(angle(Ax)), 'b.', f, fftshift(angle(Ay)), 'r.');
xlim([-50 50]); grid on; xlabel('harmonique k'); ylabel('phase (rad)');
legend('arg A_x(k)', 'arg A_y(k)'); title('Phase des descripteurs');

%% ===================== ETAPE 4 : rotation des descripteurs =====================
% La tête est du côté le plus éloigné du centre de gravité le long de l'axe principal :
% on choisit la rotation qui l'amène en haut de l'image.
p = x*cos(theta) + y*sin(theta);          % projection sur l'axe principal
if max(p) > -min(p)
    phi = -pi/2 - theta;
else
    phi =  pi/2 - theta;
end
fprintf('Etape 4 : rotation appliquée = %.2f deg\n', phi*180/pi);

% La rotation est linéaire : elle s'applique directement aux coefficients
Axr = cos(phi)*Ax - sin(phi)*Ay;
Ayr = sin(phi)*Ax + cos(phi)*Ay;

% Contrôle : reconstruction complète avant / après rotation
[xc0, yc0] = ifourierDesc(Ax,  Ay,  Inf);
[xc1, yc1] = ifourierDesc(Axr, Ayr, Inf);

figure('Name', 'Etape 4 : rotation');
subplot(1,2,1);
stem(f, fftshift(abs(Ax)),  'b.'); hold on;
stem(f, fftshift(abs(Axr)), 'm.');
set(gca, 'YScale', 'log'); xlim([-30 30]); grid on;
legend('|A_x| avant', '|A_x| après rotation'); xlabel('harmonique k');
title('Descripteurs avant / après rotation');
subplot(1,2,2);
plot(real(xc0), real(yc0), 'b-', real(xc1), real(yc1), 'm-', 'LineWidth', 1.5); hold on;
plot(0, 0, 'k+', 'MarkerSize', 12, 'LineWidth', 2);
axis equal ij; grid on;
legend('Contour initial', 'Contour tourné', 'Centre de gravité', 'Location', 'southoutside');
title(sprintf('Etape 4 : rotation de %.1f° autour de G', phi*180/pi));

%% ===================== ETAPE 5 : reconstruction + translation =====================
Kliste = [1 2 5 10 30 floor((N-1)/2)];
figure('Name', 'Etape 5 : reconstruction');
for k = 1:numel(Kliste)
    [xk, yk] = ifourierDesc(Axr, Ayr, Kliste(k));   % Equivalent : ifourier.m
    xk = real(xk) + xg;                  % coordonnées éventuellement complexes -> partie réelle
    yk = real(yk) + yg;                  % translation vers le repère d'origine
    subplot(2, 3, k);
    plot(xk, yk, 'b-', 'LineWidth', 1.5); hold on;
    plot(xg, yg, 'r+');
    axis equal ij; axis([1 nc 1 nl]); grid on;
    title(sprintf('%d harmonique(s)', Kliste(k)));
end
sgtitle('Etape 5 : contour reconstruit selon le niveau de détail');

K = 30;                                   % niveau de détail retenu
[xr, yr] = ifourierDesc(Axr, Ayr, K);
xr = real(xr) + xg;
yr = real(yr) + yg;

%% ===================== ETAPE 6 : synthèse de la nouvelle image =====================
% a. image vide de même taille que l'image de départ
J0 = false(nl, nc);

% b. pixels de contour à 1 avec sub2ind (contour densifié pour être fermé)
t  = (0:N)';
tt = (0:0.1:N)';
xd = interp1(t, [xr; xr(1)], tt);
yd = interp1(t, [yr; yr(1)], tt);
col = round(xd);  lig = round(yd);
ok  = col >= 1 & col <= nc & lig >= 1 & lig <= nl;
J1 = J0;
J1(sub2ind([nl nc], lig(ok), col(ok))) = true;
J1 = imclose(J1, strel('square', 2));     % fermeture du contour par sécurité

% c. remplissage de la silhouette
J2 = imfill(J1, 'holes');

figure('Name', 'Etape 6 : synthèse');
subplot(2,2,1); imshow(J0); title('6a. Image initialisée');
subplot(2,2,2); imshow(J1); title(sprintf('6b. Contour (K = %d)', K));
subplot(2,2,3); imshow(J2); title('6c. Silhouette remplie');
subplot(2,2,4); imshowpair(B, J2, 'falsecolor');
title('Origine (magenta) / redressé (vert)');
sgtitle('Etape 6 : bonhomme de neige remis dans l''axe');

%% ---------------- Fonctions locales ----------------
function [Ax, Ay] = fourierDesc(x, y)
% Descripteurs de Fourier (TFD) des deux signaux de coordonnées x(t) et y(t)
Ax = fft(x(:));
Ay = fft(y(:));
end

function [x, y] = ifourierDesc(Ax, Ay, K)
% Reconstruction en ne gardant que les harmoniques -K..K
N = numel(Ax);
K = min(K, floor((N-1)/2));
masque = false(N, 1);
masque(1:K+1)   = true;                   % fréquences 0..K
masque(N-K+1:N) = true;                   % fréquences -K..-1
x = ifft(Ax .* masque);
y = ifft(Ay .* masque);
end