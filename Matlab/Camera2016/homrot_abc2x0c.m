function hommat = homrot_abc2x0c(abc, inv)
% Matrice de rotation du vecteur abc vers le vecteur x0c où x positif, en coordonnées homogènes
% F. Gueuning, 2013   Unité Electronique et informatique         ECAM, Bruxelles
%
% SPn 130216: Création
%
% IN:  abc    Vecteur (en principe colonne) à 3 éléments a,b,c (ou avec un 4e non pris en compte)
%             qui serait transformé en un vecteur x,0,c (puis un 4e) par la matrice de
%             transformation homogène hommat. x est positif
%      inv    Si existe et non nul, transformation inverse
% OUT: hommat Matrice de size (4,4)
%             permettant d'effectuer la rotation autour de l'axe Z qui annule la coordonnée y
%             avec la coordonnée x positive
% Il existe
%   hommat = homrot_abc2x0c(abc, inv)
%   hommat = homrot_abc2xb0(abc, inv)
%   hommat = homrot_abc20yc(abc, inv)
%   hommat = homrot_abc2ay0(abc, inv)
%   hommat = homrot_abc20bz(abc, inv)
%   hommat = homrot_abc2a0z(abc, inv)
%   hommat = homtrans(abc, xyz)
R = sqrt(abc(1)^2 + abc(2)^2);
cosphi = abc(1)/R;
if nargin>1 && inv>0 % Si rotation inverse, donc de x0c vers abc
   sinphi = abc(2)/R;
else % Sinon rotation de abc vers x0c
   sinphi = -abc(2)/R;
end
hommat = [ cosphi  -sinphi  0  0
           sinphi   cosphi  0  0
             0          0   1  0
             0          0   0  1 ];
