function hommat = homtrans(abc, xyz)
% Matrice de translation du point abc vers le point xyz, en coordonnées homogènes
% F. Gueuning, 2013   Unité Electronique et informatique         ECAM, Bruxelles
%
% SPn 130216: Création
%
% IN:  abc    Vecteur (en principe colonne) à 3 éléments a,b,c (ou avec un 4e non pris en compte)
%             qui serait transformé en un point x,y,z (puis un 4e) par la matrice de
%             transformation homogène hommat.
%      xyz    Vecteur (en principe colonne) à 3 éléments x,y,z (ou avec un 4e non pris en compte)
%             vers lequel la matrice hommat devrait translater le point a,b,c
% OUT: hommat Matrice de size (4,4)
%             permettant d'effectuer la translation du point a,b,c vers le point x,y,z
% Il existe
%   hommat = homrot_abc2x0c(abc, inv)
%   hommat = homrot_abc2xb0(abc, inv)
%   hommat = homrot_abc20yc(abc, inv)
%   hommat = homrot_abc2ay0(abc, inv)
%   hommat = homrot_abc20bz(abc, inv)
%   hommat = homrot_abc2a0z(abc, inv)
%   hommat = homtrans(abc, xyz)
hommat = [ 1     0     0     xyz(1)-abc(1)
           0     1     0     xyz(2)-abc(2)
           0     0     1     xyz(3)-abc(3)
           0     0     0     1            ];
