function [Pt1, Pt2] = diam2xyz(xf, yz1, yz2, D)
% Dans le rep�re de la cam�ra, d�termination des points se trouvant � �gale distance de l'origine
% dans les directions 1 et 2 et � une distance D l'un de l'autre. Ces points auront leur coordonn�e x positive.
% F. Gueuning, 2013   Unit� Electronique et informatique         ECAM, Bruxelles
%
% SPn 130221: Cr�ation
%
% IN:  xf        Coordonn�e x du capteur donc -f (o� f est distance focale entre centre optique et plan du capteur contenant les points yz)
%      yz1, yz2  Vecteurs � 2 �l�ments contenant les coordonn�es yz (en mm) de deux points d'image d�terminant les directions 1 et 2
%      D         Distance entre les 2 points
% OUT: Pt1, Pt2  Vecteurs 3x1, Points distants l'un de l'autre de D

L1 = sqrt(xf^2+yz1(1)^2+yz1(2)^2); % Longueur du vecteur 1
L2 = sqrt(xf^2+yz2(1)^2+yz2(2)^2); % Longueur du vecteur 2
k = L1/L2; % Multiplier le 2 par k pour qu'il ait la m�me longueur que le 1
D12 = sqrt((xf-k*xf)^2 + (yz1(1)-k*yz2(1))^2 + (yz1(2)-k*yz2(2))^2) ; % Distance entre les 2 vecteurs de longueur L1
Pt1 = -D/D12 * [xf; yz1(:)];
Pt2 = -D/D12 * k*[xf; yz2(:)];
