%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                          %                             %
%%   Author  :  Jean-Christophe Cexus       %            STIC             %
%%              Sept. 2023.                 %         ENSTA-Bretagne      %
%%                                          %                             %
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exemples du cours 2 : Amélioration d'images (2023)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% in  = imread('bateau.bmp'); 
% in  = rgb2gray(in); % mat2gray(double(in))
% imtool(in);

% imshow('pout.tif')
% imcontrast

% taille = size(in);
% [counts,x] = imhist(uint8(in),256);
% countscum = cumsum(counts)./(taille(1)*taille(2));
 
% figure;
% subplot(121); imshow(uint8(in), []);  title(' image init ');
% subplot(122); plot(x, counts); title(' Histogramme init');

%% Inversion 
in  = imread('bateau.bmp'); 
in  = rgb2gray(in); 
out = imcomplement(uint8(in));

figure
subplot(121); imshow(uint8(in),[]); title (' image init');
subplot(122); imshow(uint8(out),[]); title (' Etirement histo');

%% Etirement
in = imread('bateau.bmp'); 
in = double(rgb2gray(in)); 

Imin = 0; Imax = 70;
m    = 0; M    = 255;
out  = ((in - Imin)./(Imax - Imin)).*(M-m) + m;
out1  = uint8(out);

out2 = imadjust(uint8(in), [Imin; Imax]/255, [m; M]/255);

figure
subplot(131); imshow(uint8(in),[]); axis off; title (' image init');
subplot(132); imshow(out1,[]);      axis off; title (' Etirement histo');
subplot(133); imshow(out2,[]);      axis off; title (' Etirement histo matlab');

%% Egalisation
in = imread('bateau.bmp'); 
in = rgb2gray(in); 

out1 = histeq(in, 256);  % Histogram equalization
out2 = adapthisteq(in);  % Contrast-limited adaptive histogram equalization (CLAHE)

figure
subplot(131); imshow(uint8(in),[]); axis off; title (' image init');
subplot(132); imshow(out1,[]);      axis off; title (' egalisation ');
subplot(133); imshow(out2,[]);      axis off; title (' CLAHE');

%% Passe bas 
A = double(imread('Lune.tif'));

H1  = fspecial('average', [11 11]);
H2  = fspecial('gaussian',[11 11], 2);

J1 = imfilter(A, H1, 'replicate'); % ou J = filter2(H, A);
J2 = imfilter(A, H2, 'replicate'); 

figure; 
subplot(131); imshow(uint8(A)); axis off;
subplot(132); imshow(uint8(J1)); axis off;
subplot(133); imshow(uint8(J2)); axis off;

%% Passe haut
A = double(imread('Lune.tif'));

H  = fspecial('gaussian',[11 11], 5);
J1 = A-imfilter(A, H, 'replicate'); % H_ph = 1-H_pb

alpha = 0.5;
J2    = A + alpha*(J1); % Masquage flou (unsharp masking)

figure; 
subplot(131); imshow(uint8(A));  axis off;
subplot(132); imshow(uint8(J1)); axis off;
subplot(133); imshow(uint8(J2)); axis off;

% ou
H3 = fspecial('unsharp'); % documentation absente
J3 = imfilter(A, H3, 'replicate');

% ou
J4 = imsharpen(A);
figure; 
subplot(131); imshow(uint8(J2)); axis off;
subplot(132); imshow(uint8(J3)); axis off;
subplot(133); imshow(uint8(J4)); axis off;

%% Detramage (exemple du cours)
close all; clear all; clc; 
A = double(imread('Arbre_moire.png'));

% Spectre
nfft      = 256;
tfd_1     = fft2(A, nfft, nfft);
tfd_log   = log2(1+abs(fftshift(tfd_1)));

% Extraction du centre du spectre (information basse fréquence propre à
% l'image utile)
taille_centre = 5;
centre        = ones (taille_centre, taille_centre);
tfd_centre    = zeros(nfft,nfft);
indice_centre = round((nfft-taille_centre)/2):round((nfft+taille_centre)/2-1); 
tfd_centre(indice_centre, indice_centre) = -inf.*centre;
tfd_no_centre = tfd_log+tfd_centre; 

% Recherche des max dans le spectre (sans le centre)
N    = 4;
inds = zeros(N,1);
tmpX = tfd_no_centre(:);
for i=1:N
  [~, inds(i)]  = max(tmpX);
  tmpX(inds(i)) = -inf;
end
[rows, cols] = ind2sub(size(tfd_no_centre), inds);

% Construction du masque fréquentiel sur [-1/2,1/2]x[-1/2,1/2]
Masque = ones(nfft,nfft);
for i=1:N
    Masque(rows(i), cols(i)) = 0;
end

% Filtrage fréquentiel à l'aide du masque sur [-1/2,1/2]x[-1/2,1/2]
tfd_filter = fftshift(tfd_1).*Masque;
A_filter   = real(ifft2(ifftshift(tfd_filter)));

% Affichage
figure; 
subplot(221); imagesc(uint8(A));     axis off; colormap('gray'); impixelinfo;
subplot(222); mesh(1:nfft, 1:nfft, tfd_log); xlabel('u'); ylabel('v');
subplot(223); imagesc(1:nfft, 1:nfft, tfd_no_centre);
subplot(224); imagesc(1:nfft, 1:nfft, log2(1+abs(tfd_filter)));

figure; 
subplot(121); imagesc(uint8(A));        axis off; colormap('gray');
subplot(122); imagesc(uint8(A_filter)); axis off; colormap('gray');

%% Filtrage homomorphique
A = double(imread('PET.tif'));

B    = log(A+1);
H    = fspecial('gaussian',[17 17], 3);
J_pb = imfilter(B, H, 'replicate'); % H_pb
J_ph = B-J_pb;                      % H_ph 

alpha = 0.2;
J2 = alpha*J_pb; % J_pb -0.8*J_pb ;     
J3 = mat2gray(exp(J2)-1)*255;
figure; 
subplot(121); imshow(uint8(A),[]); axis off; 
subplot(122); imshow(uint8(J3),[]); axis off; 

J2bis = 0.8*J_ph;
J4 = mat2gray(exp(J2bis)-1)*255;
figure; 
subplot(131); imshow(uint8(A),[]); axis off; 
subplot(132); imshow(uint8(J4),[]); axis off; 
subplot(133); imshow(uint8(abs(A-J4)),[]); axis off; 

%{
H    = fspecial('gaussian',[21 21], 5); % H_pb
J_pb = imfilter(B, H, 'replicate'); 
J3   = mat2gray(exp(0.1*J_pb)-1)*255;

H    = 1-H; %H=H./sum(H(:)); % H_ph
J_ph = imfilter(B, 0.01+1.5*H, 'replicate'); 
J4   = mat2gray(exp(J_ph)-1)*255;
figure; 
subplot(131); imshow(uint8(A),[]); axis off; 
subplot(132); imshow(uint8(J3),[]); axis off; 
subplot(133); imshow(uint8(J4),[]); axis off; 
%}
%% filtrage anisotrope
A = double(imread('chien_bruit_PS.png'));
J = anisodiff(A, 9, 160, 0.2, 2);
figure; 
subplot(121); imshow(uint8(A)); axis off; 
subplot(122); imshow(uint8(J)); axis off; 

%% filtrage de rang (median) et bitonic
A = double(imread('chien_bruit_PS.png'));
J1 = medfilt2(A, [5 5]);
J2 = ordfilt2(A, 13,ones(5)); % median
J3 = ordfilt2(A, 1, ones(2)); % erosion (filtre min)
J4 = ordfilt2(A, 4, ones(2)); % dilatation (filre max)

figure; 
subplot(231); imshow(uint8(A)); axis off; 
subplot(232); imshow(uint8(J1)); axis off; 
subplot(233); imshow(uint8(J2)); axis off; 
subplot(234); imshow(uint8(J3)); axis off; 
subplot(233); imshow(uint8(J4)); axis off; 

%% filtrage median et bitonic
close all; clear all; clc; 
% A = imread('Barbara.tif');
% A = imnoise(A,'salt & pepper',0.05);
% A = double(imnoise(A,'gaussian',0,0.05));
A  = double(imread('Barbara_Noise.png'));
J1 = medfilt2(A, [5 5]);
J2 = bitonic(A, 5, 15);
figure; 
subplot(131); imshow(uint8(A)); axis off; 
subplot(132); imshow(uint8(J1)); axis off; 
subplot(133); imshow(uint8(J2)); axis off; 

%% filtrage Nagao / median / Kawahara
close all; clear all; clc; 
A  = double(imread('Image_epave.png'));
J2 = Nagao(A);  %fcnHomogeneousMaskAreaFilter(A);
J3 = medfilt2(A, [5 5]);
%J3 = Kuwahara(A, 5); 
figure; 
subplot(131); imshow(uint8(A));  axis off; 
subplot(132); imshow(uint8(J2)); axis off; 
subplot(133); imshow(uint8(J3)); axis off; 

%% Principe non local mean denoising
close all; clear all; clc; 
A = imread('Barbara.tif');
[Ny, Nx] = size(A);

Nbr_rea = 30;
I_rea   = zeros(Ny, Nx, Nbr_rea);
figure;
for ind=1:16
    tmp = imnoise(A, 'gaussian', 0, 0.01);
    I_rea(:,:,ind) = double(tmp);
    
    subplot(4,4,ind);
    imshow(tmp); axis off; 
end

J = mean(I_rea,3);

figure; 
subplot(131); imshow(A); axis off; 
subplot(132); imshow(uint8(I_rea(:,:,1))); axis off; 
subplot(133); imshow(uint8(J)); axis off; 

A2 = I_rea(:,:,1);
J2 = imnlmfilt(A2);
figure; 
subplot(131); imshow(uint8(A)); axis off; 
subplot(132); imshow(uint8(A2)); axis off; 
subplot(133); imshow(uint8(J2)); axis off; 
