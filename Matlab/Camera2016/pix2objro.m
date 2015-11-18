function objro = pix2objro(ir, ic, hommatall, ABC, H, sens)
% Calcul des coordonn�es d'objets dans le rep�re du robot � partir de points d'image
% F. Gueuning, 2013   Unit� Electronique et informatique         ECAM, Bruxelles
%
% IN:  ir, ic     Matrice d'indices des points d'image � transfomrmer en points d'objets
%      hommatall  Matrice homog�ne 4x4 de passage du rep�re cam�ra vers le rep�re du robot
%      ABC        Vecteur 1x3 A,B,C du plan A*X+B*Y+C*Z+1=0 du terrain dans le rep�re cam�ra
%      H          Hauteur du plan horizontal dans lequel se trouvent les points d'objet (def: 0 mm)
%      sens       Nom ou caract�ristiques de la cam�ra (def: 'cmucam3_full')
% OUT: objro  Structure de coordonn�es .x, .y, .z  des points d'objet correspondants � imyz dans le rep�re ro (robot)
%
% Exemple d'utilisation
%-----------------------
% 1. Utiliser camera2013 pour s�lectionner une image de r�f�rence et r�aliser l'�talonnage
% 2. Utiliser image2objet pour s�lectionner une image de m�me position de cam�ra sur le robot
%                         et d�terminer la position d'objets sur le terrain
if nargin<5
   H = 0;
end
if nargin<6
   sens = 'cmucam3_full';
end
im.ir = ir;
im.ic = ic;
[r,c] = size(ir);
[imyz, sens] = pix2yz(im, sens); % Depuis pixels vers points en mm dans le plan du capteur
objco = xfyz2objco(sens.F, imyz, ABC/(1-sqrt(H^2*(ABC*ABC')))); % Depuis points du capteur vers plan � hauteur H dans le rep�re de la cam�ra
objco_ = [reshape(objco.x, 1, r*c); reshape(objco.y, 1, r*c); reshape(objco.z, 1, r*c); ones(1, r*c)];
objro_ = hommatall*objco_; % Vers points dans le rep�re du robot
objro.x = reshape(objro_(1,:), r, c);
objro.y = reshape(objro_(2,:), r, c);
objro.z = reshape(objro_(3,:), r, c);
%X disp('------------------------------------------------')
%X im,imyz,objco,objro
