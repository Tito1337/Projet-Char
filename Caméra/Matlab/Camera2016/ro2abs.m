% Conversion de coordonnées du repère du robot vers celui du terrain
function objabs = ro2abs(objro, rob) 
% IN:  objro  structure de coordonnées de l'objet exprimé dans le repère du robot
%           .x,.y,.z  [mm] matrices de coordonnées des points de l'objet
%                          soit de memes dim, soit l'une ou l'autre scalaire
%      rob
%            .x,.y  [mm]  coordonnées du point de référence du robot dans le repère du terrain
%            .az    [°]   orientation azimutale du robot
% OUT: objabs  structure de coordonnées de l'objet exprimé dans le repère du terrain
%           .x,.y,.z  [mm] matrices de coordonnées des points de l'objet
%                          de memes dim

hommat1 = homrot_abc2x0c([cosd(-rob.az) sind(-rob.az) 0]); % Correction de az: Rotation autour de l'axe Z (C invariant) pour que A,B,C arrive dans le plan XZ (Y=0)
hommat2 = homtrans([0;0;0], [rob.x, rob.y, 0]);
hommatall = hommat2*hommat1; % Matrice de transformation homogène pour passer du repère de la caméra vers celui du robot
[r,c] = size(objro.x);
if length(objro.y)>1
   [r,c] = size(objro.y);
elseif length(objro.z)>1
   [r,c] = size(objro.z);
end
if max(r,c)>1
   if length(objro.x)==1
      objro.x = objro.x * ones(r,c);
   end
   if length(objro.y)==1
      objro.y = objro.y * ones(r,c);
   end
   if length(objro.z)==1
      objro.z = objro.z * ones(r,c);
   end
end
if r>1
   objro.x = reshape(objro.x, 1, r*c);
   objro.y = reshape(objro.y, 1, r*c);
   objro.z = reshape(objro.z, 1, r*c);
end
xyzw = hommatall * [objro.x; objro.y; objro.z; ones(1,r*c)];
objabs.x = reshape(xyzw(1,:), r, c);
objabs.y = reshape(xyzw(2,:), r, c);
objabs.z = reshape(xyzw(3,:), r, c);
