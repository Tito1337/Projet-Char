% Conversion de coordonn�es du rep�re cam�ra only vers celui du robot
function objro = co2ro(objco, cam) 
% IN:  objco  structure de coordonn�es de l'objet exprim� dans le rep�re de la cam�ra (cam�ra only)
%           .x,.y,.z  [mm] matrices de coordonn�es des points de l'objet
%                          soit de memes dim, soit l'une ou l'autre scalaire
%      cam
%         .z        [mm]  hauteur du centre de l'objectif de la cam�ra
%         .ro  dans le syst�me de coord du robot
%            .x,.y  [mm]  coordonn�es du centre de l'objectif
%            .az    [�]   orientation azimutale (proche de 0 si la cam�ra regarde devant, donc suivant l'axe X)
%            .el    [�]   orientation d'�l�vation (n�gatif car la cam�ra regarde vers le bas)
%            .ah    [�]   angle de l'horizon avec le bas de l'image, proche de 0
%                         positif si l'horizon apparait plus haut � droite qu'� gauche sur l'image
% OUT: objro  structure de coordonn�es de l'objet exprim� dans le rep�re du robot
%           .x,.y,.z  [mm] matrices de coordonn�es des points de l'objet
%                          de memes dim

hommat1 = homrot_abc2ay0([0 cosd(cam.ro.ah) sind(cam.ro.ah)]); % Correction de ah: Rotation autour de l'axe X (A invariant) pour que A,B,C arrive dans le plan XY (Z=0)
hommat2 = homrot_abc2xb0([cosd(-cam.ro.el) 0 sind(-cam.ro.el)]); % Correction de el: Rotation autour de l'axe Y (B invariant) pour que A,B,C arrive dans le plan XY (Z=0)
hommat3 = homrot_abc2x0c([cosd(-cam.ro.az) sind(-cam.ro.az) 0]); % Correction de az: Rotation autour de l'axe Z (C invariant) pour que A,B,C arrive dans le plan XZ (Y=0)
hommat4 = homtrans([0;0;0], [cam.ro.x, cam.ro.y, cam.z]);
hommatall = hommat4*hommat3*hommat2*hommat1; % Matrice de transformation homog�ne pour passer du rep�re de la cam�ra vers celui du robot
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
