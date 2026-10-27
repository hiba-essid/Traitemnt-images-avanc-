function mpq = momentcentre(Ib,p,q)

% calcul d'un moment d'ordres p et q
% Ib: image binaire code 1 pour la forme d'interet
% ou forme floue codee entre ]0;1]
 
% Auteur: Isabelle QUIDU
% Annee : 2016
% ENSTA Bretagne, France

% coordonnees du centre de gravite de la forme codee 1
xg = moment(Ib,1,0)/moment(Ib,0,0);
yg = moment(Ib,0,1)/moment(Ib,0,0);

X = [1:size(Ib,1)]'-xg;
Y = [1:size(Ib,2)]-yg;
matX = repmat(X,1,size(Ib,2));
matY = repmat(Y,size(Ib,1),1);

% calcul du moment centre d'ordre (p,q)
mpq = sum(sum((matX.^p).*(matY.^q).*Ib));