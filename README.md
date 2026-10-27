# Traitement d'images avancé

Travaux pratiques de traitement et d'analyse d'images réalisés sous MATLAB.
Le dépôt regroupe des applications de morphologie mathématique, de filtrage
fréquentiel, de restauration, de débruitage et de reconnaissance de formes.

## Prérequis

- MATLAB (version récente recommandée) ;
- Image Processing Toolbox pour les fonctions de traitement d'images ;
- Signal Processing Toolbox peut être nécessaire selon les fonctions utilisées ;
- ajouter le dossier du dépôt et ses sous-dossiers au chemin MATLAB, ou exécuter
  les scripts depuis leur dossier.

Les scripts sont autonomes lorsque les images et les fonctions auxiliaires
nécessaires sont présentes dans le même dossier ou dans un dossier ajouté au
chemin MATLAB.

## Organisation

### Applications principales

- **TP1** — Morphologie mathématique :
  - extraction de dendrites par top-hat ;
  - suppression de petites planètes dans une image couleur avec l'espace HSV.
- **TP2** — Amélioration et filtrage :
  - détramage fréquentiel de l'image de la Floride ;
  - débruitage et renforcement d'une photo de nuit.
- **TP3** — Modélisation du bruit et restauration :
  - simulation de speckle et étude de la loi de Rayleigh ;
  - restauration par filtre de Wiener ;
  - déconvolution d'une image floue par mouvement.
- **TP4** — Reconnaissance de chiffres :
  - extraction de caractéristiques de chiffres ;
  - cavités, ACP et localisation dans un code postal.
- **TP5** — Descripteurs et détection de formes :
  - descripteurs de Fourier et reconstruction de contours ;
  - template matching par corrélation de phase ;
  - détection de segments par transformée de Hough.

### Ressources

- [`TP2_Images_Cours_Amelioration/`](./TP2_Images_Cours_Amelioration/) contient
  des exemples de cours, des images et des fonctions de filtrage (Kuwahara,
  Nagao, diffusion anisotrope et filtres apparentés).
- [`TP4_Reconnaissance_Chiffres_Code_Postal/`](./TP4_Reconnaissance_Chiffres_Code_Postal/)
  contient les fonctions auxiliaires du TP4.
- [`TP5_Ressources_Fourier_Moments_Hough/`](./TP5_Ressources_Fourier_Moments_Hough/)
  contient les fonctions de moments, de Fourier et les images du TP5.

## Utilisation

1. Cloner ou télécharger le dépôt.
2. Ouvrir MATLAB et définir le dépôt comme dossier courant.
3. Ajouter les sous-dossiers au chemin si nécessaire :

   ```matlab
   addpath(genpath('chemin/vers/Traitemnt-images-avanc-'));
   ```

4. Ouvrir le script MATLAB correspondant à l'application souhaitée.
5. Vérifier que les fichiers image référencés par le script sont accessibles,
   puis exécuter le script avec **Run**.

La plupart des scripts produisent directement des figures et des mesures dans
la fenêtre MATLAB. Les fichiers suffixés `_Canevas` ou `TODO` servent de bases
de travail et peuvent nécessiter une implémentation complémentaire.

## Remarques

- Les chemins d'accès aux images peuvent devoir être adaptés selon
  l'emplacement local du dépôt.
- Le fichier `TP2_App3_Photo_Nuit_Debruitage_Bastille_copie.m` est une copie de
  travail de l'application de débruitage du TP2.
- Les fichiers `.m` sont des scripts et fonctions MATLAB ; ils ne sont pas
  destinés à être exécutés directement avec Octave sans adaptation.
