function [Pt1, Pt2] = diam2xyz(xf, yz1, yz2, D)
% Dans le repère de la caméra, détermination des points se trouvant à égale distance de l'origine
% dans les directions 1 et 2 et à une distance D l'un de l'autre. Ces points auront leur coordonnée x positive.
% F. Gueuning, 2013   Unité Electronique et informatique         ECAM, Bruxelles
%
% SPn 130221: Création
%
% IN:  xf        Coordonnée x du capteur donc -f (où f est distance focale entre centre optique et plan du capteur contenant les points yz)
%      yz1, yz2  Vecteurs à 2 éléments contenant les coordonnées yz (en mm) de deux points d'image déterminant les directions 1 et 2
%      D         Distance entre les 2 points
% OUT: Pt1, Pt2  Vecteurs 3x1, Points distants l'un de l'autre de D

L1 = sqrt(xf^2+yz1(1)^2+yz1(2)^2); % Longueur du vecteur 1
L2 = sqrt(xf^2+yz2(1)^2+yz2(2)^2); % Longueur du vecteur 2
k = L1/L2; % Multiplier le 2 par k pour qu'il ait la même longueur que le 1
D12 = sqrt((xf-k*xf)^2 + (yz1(1)-k*yz2(1))^2 + (yz1(2)-k*yz2(2))^2) ; % Distance entre les 2 vecteurs de longueur L1
Pt1 = -D/D12 * [xf; yz1(:)];
Pt2 = -D/D12 * k*[xf; yz2(:)];
