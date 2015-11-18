function hommat = homrot_abc2a0z(abc, inv)
% Matrice de rotation du vecteur abc vers le vecteur a0z o� z positif, en coordonn�es homog�nes
% F. Gueuning, 2013   Unit� Electronique et informatique         ECAM, Bruxelles
%
% SPn 130216: Cr�ation
%
% IN:  abc    Vecteur (en principe colonne) � 3 �l�ments a,b,c (ou avec un 4e non pris en compte)
%             qui serait transform� en un vecteur a,0,z (puis un 4e) par la matrice de
%             transformation homog�ne hommat. y est positif
%      inv    Si existe et non nul, transformation inverse
% OUT: hommat Matrice de size (4,4)
%             permettant d'effectuer la rotation autour de l'axe X qui annule la coordonn�e y
%             avec la coordonn�e z positive
% Il existe
%   hommat = homrot_abc2x0c(abc, inv)
%   hommat = homrot_abc2xb0(abc, inv)
%   hommat = homrot_abc20yc(abc, inv)
%   hommat = homrot_abc2ay0(abc, inv)
%   hommat = homrot_abc20bz(abc, inv)
%   hommat = homrot_abc2a0z(abc, inv)
%   hommat = homtrans(abc, xyz)
R = sqrt(abc(3)^2 + abc(2)^2);
cosphi = abc(3)/R;
if nargin>1 && inv>0 % Si rotation inverse, donc de a0z vers abc
   sinphi = -abc(2)/R;
else % Sinon rotation de abc vers a0z
   sinphi = abc(2)/R;
end
hommat = [ 1     0       0     0
           0   cosphi -sinphi  0
           0   sinphi  cosphi  0
           0     0       0     1 ];
