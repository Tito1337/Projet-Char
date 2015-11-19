function x = dec2x(dec, base)
% Décomposition d'entiers dans une base à différents entiers
% (c) F. Gueuning, 2011                ECAM, Belgium
%
% SPc 110731: Création de la fonction
%
% In:  dec    vecteur colonne (à r rangées) de nombres entiers à décomposer
%      base   vecteur ligne (à c colonnes) des entiers de la base
% OUT: x      matrice de dim (r, c+1) où chaque ligne est la décomposition d'un nombre
% ex:  dec = 152, base = [2 3 5 3 2 2]
%      on constate que prod(base) = 360

x = zeros(length(dec), length(base)+1);
cpb = cumprod(base);
for k = length(base):-1:1
   x(:,k+1) = floor(dec/cpb(k));
   dec = rem(dec, cpb(k));
end
x(:, 1) = dec;
