% Conversion de coordonnées du repère caméra only vers celui du robot
function objro = co2ro(objco, cam) 
% IN:  objco  structure de coordonnées de l'objet exprimé dans le repère de la caméra (caméra only)
%           .x,.y,.z  [mm] matrices de coordonnées des points de l'objet
%                          soit de memes dim, soit l'une ou l'autre scalaire
%      cam
%         .z        [mm]  hauteur du centre de l'objectif de la caméra
%         .ro  dans le système de coord du robot
%            .x,.y  [mm]  coordonnées du centre de l'objectif
%            .az    [°]   orientation azimutale (proche de 0 si la caméra regarde devant, donc suivant l'axe X)
%            .el    [°]   orientation d'élévation (négatif car la caméra regarde vers le bas)
%            .ah    [°]   angle de l'horizon avec le bas de l'image, proche de 0
%                         positif si l'horizon apparait plus haut à droite qu'à gauche sur l'image
% OUT: objro  structure de coordonnées de l'objet exprimé dans le repère du robot
%           .x,.y,.z  [mm] matrices de coordonnées des points de l'objet
%                          de memes dim

hommat1 = homrot_abc2ay0([0 cosd(cam.ro.ah) sind(cam.ro.ah)]); % Correction de ah: Rotation autour de l'axe X (A invariant) pour que A,B,C arrive dans le plan XY (Z=0)
hommat2 = homrot_abc2xb0([cosd(-cam.ro.el) 0 sind(-cam.ro.el)]); % Correction de el: Rotation autour de l'axe Y (B invariant) pour que A,B,C arrive dans le plan XY (Z=0)
hommat3 = homrot_abc2x0c([cosd(-cam.ro.az) sind(-cam.ro.az) 0]); % Correction de az: Rotation autour de l'axe Z (C invariant) pour que A,B,C arrive dans le plan XZ (Y=0)
hommat4 = homtrans([0;0;0], [cam.ro.x, cam.ro.y, cam.z]);
hommatall = hommat4*hommat3*hommat2*hommat1; % Matrice de transformation homogène pour passer du repère de la caméra vers celui du robot
[r,c] = size(objco.x);
if length(objco.y)>1
   [r,c] = size(objco.y);
elseif length(objco.z)>1
   [r,c] = size(objco.z);
end
if max(r,c)>1
   if length(objco.x)==1
      objco.x = objco.x * ones(r,c);
   end
   if length(objco.y)==1
      objco.y = objco.y * ones(r,c);
   end
   if length(objco.z)==1
      objco.z = objco.z * ones(r,c);
   end
end
if r>1
   objco.x = reshape(objco.x, 1, r*c);
   objco.y = reshape(objco.y, 1, r*c);
   objco.z = reshape(objco.z, 1, r*c);
end
xyzw = hommatall * [objco.x; objco.y; objco.z; ones(1,r*c)];
objro.x = reshape(xyzw(1,:), r, c);
objro.y = reshape(xyzw(2,:), r, c);
objro.z = reshape(xyzw(3,:), r, c);
