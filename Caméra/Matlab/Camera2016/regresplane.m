function ABC = regresplane(XYZ)
% Plan obtenu par régression en disposant de n points
% Référence : http://fr.scribd.com/doc/31477970/Regressions-et-trajectoires-3D
%             p. 22 solution exacte au problème de régression plane en 3D
% F. Gueuning, 2013         ECAM - Bruxelles
%
% SPn130210: Création
%
% IN:  XYZ  Matrice à n lignes dont chacune contient les coord X, Y et Z d'un point
%           Il faut minimum 3 points
% OUT: ABC  Vecteur ligne des coefficients A, B, C du plan minimisant la somme des
%           carrés des distances des points par rapport au plan
%           L'équation du plan est  A*X + B*Y + C*Z + 1 = 0
% ex:
% XYZ = [
% 1.72 2.3 -2.94
% -0.69 2.5 -3.94
% -2.43 1.35 -3.05
% -2.19 -0.29 -0.95
% -0.15 -1.18 0.88
% 2.16 -0.66 1.03
% 2.99 0.89 -0.73
% 1.72 2.29 -2.97
% -0.69 2.5 -4.02
% -2.43 1.35 -3.11];
% ABC = regressplane3d(XYZ)
% donne  ABC =
%  -0.580617   2.258106   1.764963

% On calcule ici simplement les équations de la référence sans démonstration.
n = size(XYZ, 1);
xyz = XYZ - ones(n,1)*mean(XYZ); % Coordonnées réduites
x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);
Sxx = sum(x.^2);
Syy = sum(y.^2);
Szz = sum(z.^2);
Sxy = sum(x.*y);
Sxz = sum(x.*z);
Syz = sum(y.*z);
c0 = Syz*(Sxy^2-Sxz^2) + Sxy*Sxz*(Szz-Syy);
c1 = Sxy^3 + Sxy*(Sxz^2-2*Syz^2-Szz^2) + Sxy*(Sxx*Szz + Syy*Szz - Sxx*Syy) + Sxz*Syz*(Syy+Szz-2*Sxx);
c2 = Syz^3 + Syz*(Sxz^2-2*Sxy^2-Sxx^2) + Syz*(Sxx*Szz + Sxx*Syy - Syy*Szz) + Sxy*Sxz*(Sxx+Syy-2*Szz);
c3 = Sxy*(Syz^2-Sxz^2) + Sxz*Syz*(Sxx-Syy);
r = c2/c3;
s = c1/c3;
t = c0/c3;
p = s - r^2/3;
q = 2*r^3/27 - r*s/3 + t;
R = q^2/4 + p^3/27;
if R>0
   a = -r/3 + (-q/2 + sqrt(R))^(1/3) + (-q/2 - sqrt(R))^(1/3);
elseif R<0
   rho = sqrt(-p^3/27);
   phi = acos(-q/(2*rho));
   a(1) = -r/3+2*(rho)^(1/3)*cos(phi/3);
   a(2) = -r/3+2*(rho)^(1/3)*cos((phi+2*pi)/3);
   a(3) = -r/3+2*(rho)^(1/3)*cos((phi+4*pi)/3);
   a = a(imag(a)==0); % Ne conserver que les réels
end
b = (Sxy*Syz*a.^2 + (Syz^2 - Sxy^2).*a - Sxy*Syz) ./ ((Syz*(Sxx-Syy) - Sxy*Sxz) .* a + Sxy*(Syy-Szz) + Sxz*Syz);
Sd2 = 1 ./ (a.^2 + b.^2 + 1) .* sum((x*a + y*b + z*ones(size(a))).^2);
i = find(Sd2 == min(Sd2));
a = a(i);
b = b(i);
lambda = mean(XYZ)*[a;b;1];
ABC = -[a b 1]/lambda;