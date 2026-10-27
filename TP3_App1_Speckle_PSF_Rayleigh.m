clear; close all; clc; rng(1)

%% 1. PSF gaussienne 39x39
N = 39; c = (N+1)/2; sx = 1; sy = 3;
[X,Y] = meshgrid(1:N,1:N);
G = exp(-((X-c).^2/(2*sx^2) + (Y-c).^2/(2*sy^2)));
G = G/sum(G(:));
figure; mesh(X,Y,G); xlabel('x'); ylabel('y'); title('PSF gaussienne') %visualiser en 3D fonction mesh

%% 2. FWHM : résolution en pixels 
FWHMx = fwhm(G(c,:));      % profil horizontal
FWHMy = fwhm(G(:,c));      % profil vertical
fprintf('FWHMx = %.2f px, FWHMy = %.2f px (theorie : %.2f et %.2f)\n', ...
    FWHMx, FWHMy, 2.355*sx, 2.355*sy);

%% 3. Image complexe et speckle
M = 512;
Ie1 = rand(M).*exp(1i*(2*pi*rand(M)-pi)); %bruit blanc complexe
Is1 = imfilter(Ie1, G, 'circular');    %image cohérente Is1 avec un bruit de speckle homogène sur toute l'image

%% 4. Image et histogramme
A = abs(Is1);
figure; imagesc(A); colormap gray; axis image; colorbar; title('|Is1|') % histogramme normalisé
figure; histogram(A(:), 100, 'Normalization', 'pdf'); hold on

%% 5. Loi de Rayleigh (EMV)
alpha2 = sum(A(:).^2)/(2*numel(A));
x = linspace(0, max(A(:)), 300);
plot(x, x/alpha2.*exp(-x.^2/(2*alpha2)), 'r', 'LineWidth', 2)
legend('Histogramme', 'Rayleigh theorique'); title('Distribution de |Is1|')

%% 6. Pouvoir de resolution
amp = 10*max(abs(Ie1(:)));
l0 = 256; c0 = 200;
cas = {'horizontal d=1 (<FWHMx)', 0, 1; ...
    'horizontal d=4 (>FWHMx)', 0, 4; ...
    'vertical d=4 (<FWHMy)',   4, 0; ...
    'vertical d=9 (>FWHMy)',   9, 0};
figure
for k = 1:size(cas,1)
    Ie = Ie1;
    Ie(l0, c0) = amp;
    Ie(l0+cas{k,2}, c0+cas{k,3}) = amp;
    Is = imfilter(Ie, G, 'circular');
    subplot(2,2,k)
    imagesc(abs(Is(l0-20:l0+20+cas{k,2}, c0-20:c0+20+cas{k,3}))); 
    axis image; colormap gray; title(cas{k,1})
end

%% 7. Quatre regions de niveaux moyens differents
gain = ones(M);
h = M/2;
gain(1:h,1:h) = 1;   gain(1:h,h+1:end) = 2;
gain(h+1:end,1:h) = 3; gain(h+1:end,h+1:end) = 4;
Ie2 = Ie1.*gain;
Is2 = imfilter(Ie2, G, 'circular');  %nouvelle image cohérente simulée
A2 = abs(Is2);
figure; imagesc(A2); colormap gray; axis image; colorbar; title('|Is2|')

%% 8. Histogrammes par region
m = 20;                                   % marge pour eviter les bords
reg = {A2(m:h-m, m:h-m), A2(m:h-m, h+m:end-m), ...
    A2(h+m:end-m, m:h-m), A2(h+m:end-m, h+m:end-m)};
ctr = linspace(0, max(A2(:)), 150);
figure; hold on
for k = 1:4
    n = hist(reg{k}(:), ctr);
    plot(ctr, n/sum(n), 'LineWidth', 1.5);
end
n = hist(A2(:), ctr); plot(ctr, n/sum(n), 'k--', 'LineWidth', 2);
legend('Reg 1','Reg 2','Reg 3','Reg 4','Image entiere'); xlabel('Amplitude')
title('Histogrammes (distributions recouvrantes : seuillage difficile)')

%% 9. Coefficient de variation
for k = 1:4
    v = reg{k}(:);
    fprintf('Region %d : CV = %.3f\n', k, std(v)/mean(v));
end
fprintf('Theorie : sqrt(4/pi-1) = %.3f\n', sqrt(4/pi-1));

%% fonction locale
function w = fwhm(p)
p = p(:)'/max(p);
xi = linspace(1, numel(p), 20000);
pi_ = interp1(1:numel(p), p, xi, 'spline');
w = sum(pi_ >= 0.5)*(xi(2)-xi(1));
end