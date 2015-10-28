function hommat = homrot_abc20yc(abc, inv)
% Matrice de rotation du vecteur abc vers le vecteur 0yc où y positif, en coordonnées homogènes
% F. Gueuning, 2013   Unité Electronique et informatique         ECAM, Bruxelles
%
% SPn 130216: Création
%
% IN:  abc    Vecteur (en principe colonne) à 3 éléments a,b,c (ou avec un 4e non pris en compte)
%             qui serait transformé en un vecteur 0,y,c (puis un 4e) par la matrice de
%             transformation homogène hommat. y est positif
%      inv    Si existe et non nul, transformation inverse
% OUT: hommat Matrice de size (4,4)
%             permettant d'effectuer la rotation autour de l'axe Z qui annule la coordonnée x
%             avec la coordonnée y positive
% Il existe
%   hommat = homrot_abc2x0c(abc, inv)
%   hommat = homrot_abc2xb0(abc, inv)
%   hommat = homrot_abc20yc(abc, inv)
%   hommat = homrot_abc2ay0(abc, inv)
%   hommat = homrot_abc20bz(abc, inv)
%   hommat = homrot_abc2a0z(abc, inv)
%   hommat = homtrans(abc, xyz)
R = sqrt(abc(1)^2 + abc(2)^2);
cosphi = abc(2)/R;
if nargin>1 && inv>0 % Si rotation inverse, donc de 0yc vers abc
   sinphi = -abc(1)/R;
else % Sinon rotation de abc vers 0yc
   sinphi = abc(1)/R;
end
hommat = [ cosphi  -sinphi  0  0
           sinphi   cosphi  0  0
             0          0   1  0
             0          0   0  1 ];
