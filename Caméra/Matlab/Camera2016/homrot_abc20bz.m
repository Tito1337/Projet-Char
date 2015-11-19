function hommat = homrot_abc20bz(abc, inv)
% Matrice de rotation du vecteur abc vers le vecteur 0bz o� z positif, en coordonn�es homog�nes
% F. Gueuning, 2013   Unit� Electronique et informatique         ECAM, Bruxelles
%
% SPn 130216: Cr�ation
%
% IN:  abc    Vecteur (en principe colonne) � 3 �l�ments a,b,c (ou avec un 4e non pris en compte)
%             qui serait transform� en un vecteur 0,b,z (puis un 4e) par la matrice de
%             transformation homog�ne hommat. z est positif
%      inv    Si existe et non nul, transformation inverse
% OUT: hommat Matrice de size (4,4)
%             permettant d'effectuer la rotation autour de l'axe Y qui annule la coordonn�e x
%             avec la coordonn�e z positive
% Il existe
%   hommat = homrot_abc2x0c(abc, inv)
%   hommat = homrot_abc2xb0(abc, inv)
%   hommat = homrot_abc20yc(abc, inv)
%   hommat = homrot_abc2ay0(abc, inv)
%   hommat = homrot_abc20bz(abc, inv)
%   hommat = homrot_abc2a0z(abc, inv)
%   hommat = homtrans(abc, xyz)
R = sqrt(abc(1)^2 + abc(3)^2);
cosphi = abc(3)/R;
if nargin>1 && inv>0 % Si rotation inverse, donc de 0bz vers abc
   sinphi = -abc(1)/R;
else % Sinon rotation de abc vers 0bz
   sinphi = abc(1)/R;
end
hommat = [ cosphi  0  -sinphi  0
             0     1    0      0
           sinphi  0   cosphi  0
             0          0   0  1 ];
