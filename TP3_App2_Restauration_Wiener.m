clear; close all; clc; rng(1)

%% 1. Image degradee
I = im2double(imread('cameraman.tif'));
h = fspecial('motion', 15, 30);  
sigma = 0.01;
Ib = degrade(I, h, sigma); %dégradation convolutive

%% 2-3. Wiener de reference (h connu, bruit connu)
Sx = abs(fft2(I)).^2/numel(I);          % periodogramme de l'image
Ir = wiener(Ib, h, sigma^2, Sx, 1);

figure
subplot(1,3,1); imshow(I);  title('Originale')
subplot(1,3,2); imshow(Ib); title(sprintf('Degradee (PSNR %.1f dB)', psnr(Ib,I)))
subplot(1,3,3); imshow(Ir); title(sprintf('Wiener (PSNR %.1f dB)', psnr(Ir,I)))

%% Variante A : degradation h~ proche mais differente
ht = fspecial('motion', 17, 30);
IA = wiener(Ib, ht, sigma^2, Sx, 1);

%% Variante B : puissance du bruit differente (sigma = 0.05)
sigB = 0.05;
IbB = degrade(I, h, sigB);
IB1 = wiener(IbB, h, sigB^2, Sx, 1);        % bruit connu
IB2 = wiener(IbB, h, sigma^2, Sx, 1);       % bruit sous-estime

%% Variante C : bruit inconnu -> pseudo-inverse
H = psf2otf(h, size(I));
R = zeros(size(H)); k = abs(H) > 1e-2; R(k) = 1./H(k);
IC = real(ifft2(R.*fft2(Ib)));
R = 1./(H + eps);                           % inverse brut
IC0 = real(ifft2(R.*fft2(Ib)));

%% Variante D : Wiener parametrique
ID1 = wiener(Ib, h, sigma^2, Sx, 0.1);
ID2 = wiener(Ib, h, sigma^2, Sx, 5);

%% Affichage
im  = {IA, IB1, IB2, IC0, IC, ID1, ID2};
tit = {'h~ (17 au lieu de 15)', 'sigma=0.05 connu', 'sigma=0.05 sous-estime', ...
    'inverse brut', 'pseudo-inverse', 'parametrique \gamma=0.1', 'parametrique \gamma=5'};
figure
for k = 1:numel(im)
    subplot(2,4,k); imshow(im{k}, []);
    title(sprintf('%s\n%.1f dB', tit{k}, psnr(im2double(mat2gray(im{k})), I)), 'FontSize', 8)
end

%% fonctions locales
function Ib = degrade(I, h, sigma)
Ib = imfilter(I, h, 'circular') + sigma*randn(size(I));
end

function Ir = wiener(Ib, h, Sn, Sx, gamma)
H = psf2otf(h, size(Ib));
R = conj(H)./(abs(H).^2 + gamma*Sn./(Sx + eps));
Ir = real(ifft2(R.*fft2(Ib)));
end