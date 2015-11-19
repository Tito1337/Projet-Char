function objro = pix2objro(ir, ic, hommatall, ABC, H, sens)
% Calcul des coordonnées d'objets dans le repère du robot à partir de points d'image
% F. Gueuning, 2013   Unité Electronique et informatique         ECAM, Bruxelles
%
% IN:  ir, ic     Matrice d'indices des points d'image à transfomrmer en points d'objets
%      hommatall  Matrice homogène 4x4 de passage du repère caméra vers le repère du robot
%      ABC        Vecteur 1x3 A,B,C du plan A*X+B*Y+C*Z+1=0 du terrain dans le repère caméra
%      H          Hauteur du plan horizontal dans lequel se trouvent les points d'objet (def: 0 mm)
%      sens       Nom ou caractéristiques de la caméra (def: 'cmucam3_full')
% OUT: objro  Structure de coordonnées .x, .y, .z  des points d'objet correspondants à imyz dans le repère ro (robot)
%
% Exemple d'utilisation
%-----------------------
% 1. Utiliser camera2013 pour sélectionner une image de référence et réaliser l'étalonnage
% 2. Utiliser image2objet pour sélectionner une image de même position de caméra sur le robot
%                         et déterminer la position d'objets sur le terrain
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
objco = xfyz2objco(sens.F, imyz, ABC/(1-sqrt(H^2*(ABC*ABC')))); % Depuis points du capteur vers plan à hauteur H dans le repère de la caméra
objco_ = [reshape(objco.x, 1, r*c); reshape(objco.y, 1, r*c); reshape(objco.z, 1, r*c); ones(1, r*c)];
objro_ = hommatall*objco_; % Vers points dans le repère du robot
objro.x = reshape(objro_(1,:), r, c);
objro.y = reshape(objro_(2,:), r, c);
objro.z = reshape(objro_(3,:), r, c);
%X disp('------------------------------------------------')
%X im,imyz,objco,objro
