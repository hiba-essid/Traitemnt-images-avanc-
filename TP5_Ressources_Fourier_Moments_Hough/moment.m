function mpq = moment(Ib,p,q)

% calcul d'un moment d'ordres p et q
% Ib: image binaire code 1 pour la forme d'interet
% ou forme floue codee entre ]0;1]

% Auteur: Isabelle QUIDU
% Annee : 2016
% ENSTA Bretagne, France

X = [1:size(Ib,1)]';
Y = 1:size(Ib,2);
matX = repmat(X,1,size(Ib,2));
matY = repmat(Y,size(Ib,1),1);

mpq = sum(sum((matX.^p).*(matY.^q).*Ib));