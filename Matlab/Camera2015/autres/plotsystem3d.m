function ha = plotsystem3d(tar, cam, sens, rob)
% Dessin des systèmes de coordonnées dans l'axes courant
% F. Gueuning, 2010-2013   Unité Electronique et informatique         ECAM, Bruxelles
%
% SPn 130224: création depuis positionfromcamera3
%
% IN:  tar  Cible (target)
%         .im.ir      indice de rangée du point d'image de la cible (target)
%            .ic                colonne
%            .y, .z   coord y et z du point au niveau de l'image après correction de distortion et
%         .cr.az      azimut    de la cible dans le repère redressé de la caméra (donc orienté comme le robot)
%            .el      élévation de la cible telle que perçue depuis le repère redressé de la caméra
%         .ro.r       distance entre cible et origine du robot
%            .az      azimut de la cible en coord du robot
%         .x          coord de la cible dans un repère absolu (repère du terrain)
%         .y
%         .z
%      cam  Caméra 
%         .z      Hauteur du centre de l'objectif de la caméra
%         .ro.x,.y  Coordonnées du centre de l'objectif dans le système de coord du robot
%            .az  Orientation azimutale (proche de 0 si la caméra regarde devant, donc suivant l'axe X
%            .el  Orientation d'élévation (négatif car la caméra regarde vers le bas)
%            .ah  Angle de l'horizon avec le bas de l'image, proche de 0°
%                 Positif si l'horizon apparait plus haut à droite qu'à gauche sur l'image
%                         .-------------------------.
%                  Image  |           |  /          |
%                         |           ' /           |
%                         |           |/ \ ah>0     |
%                         |_._._._._._/_._._._._._._|
%                         |          /|             |
%                         |  Horizon/ '             |
%                         |        /  |             |
%                         '-------------------------'
%      sens  Capteur (sensor)
%          .W   Largeur (col) d'un pixel [mm]
%          .H   hauteur (row) d'un pixel [mm]
%          .F   distance focale (négative) [mm]
%          .k2  coefficient pour correction de distortion, 0 pour aucune correction
%               Calcul: abs.*(1+k2*abs)
%          .rmax  Nombre de rangées de l'image, on suppose axe optique au centre
%          .cmax  idem pour le nombre de colonnes de l'image
%      rob  Robot (si fourni sinon valeurs par défaut)
%         .x, .y   coord absolues du robot
%         .az      orientation azimutale du robot sur le terrain
% OUT: ha  handle de l'axes qui contient le dessin. Afin de pouvoir modifier celui-ci,
%          le UserData de l'axes est une structure contenant les fields suivants :
%          .tar
%          .cam   + .h :  handles des lines et texts pour caméra
%          .sens
%          .rob   + .h :  handles des lines et texts pour robot
%           
rob.x = 150;
rob.y = 250; % [mm] coord absolues du robot
rob.az = 40; % [°] orientation azimutale du robot sur le terrain
roxy = rob.x + j*rob.y; % robot

% Axes principaux
plot3([0 0 0; 600 0 0], [0 0 0; 0 600 0], [0 0 0; 0 0 400], 'k'), set(gca, 'DataAspectRatio', [1 1 1])
view(-10.5, 26)
hold on
% Coordonnées du robot
cosraz = cos(rob.az*pi/180);
sinraz = sin(rob.az*pi/180);
rob.h.TraitCont = plot3([0 0; rob.x 0], [0 0; 0 rob.y], [0 0; 0 0], 'Color', [0 .5 0], 'linewidth', 2); % Lignes sur axes
rob.h.TraitPt = plot3(rob.x*[0 1; 2 1], rob.y*[1 0; 1 1], [0 0; 0 0], ':', 'Color', [0 .5 0]); % pointillés ...
rob.h.TraitAxe = plot3(rob.x+[0; 500*cosraz], rob.y+[0; 500*sinraz], [0; 0], '-.', 'Color', [0 .5 0], 'linewidth', 2); % trait d'axe .-.-.
rob.h.TextX = text(rob.x, -180, 0, ['rob.x = ' num2str(rob.x)],'HorizontalAlignment', 'Center', 'Color', [0 .5 0], 'FontWeight', 'Bold');
rob.h.TextY = text(-120, rob.y, 0, ['rob.y = ' num2str(rob.y)],'HorizontalAlignment', 'Center', 'Color', [0 .5 0], 'FontWeight', 'Bold');
plo = roxy + .7*rob.x*rot((0:abs(rob.az))*sign(rob.az)); % pour dessin d'angle rob.az
rob.h.Az = plot3(real(plo), imag(plo), zeros(size(plo)), 'Color', [0 .5 0]);
rob.h.TextAz = text(2.6*rob.x, 1.6*rob.y, 0, ['rob.az = ' num2str(rob.az) '°'], 'Color', [0 .5 0], 'FontWeight', 'Bold');
% Coordonnées de la caméra (sur le robot)
camroxy = cam.ro.x + j*cam.ro.y;
camxy = camroxy*rot(rob.az);
plo = roxy + [0 0 camroxy; cam.ro.x j*cam.ro.y camroxy]*rot(rob.az); % Pour lignes sur axes
cam.h.TraitCont = plot3(real(plo), imag(plo), [0 0 0; 0 0 cam.z], 'B', 'linewidth', 2);
plo = roxy + [cam.ro.x j*cam.ro.y camroxy; camroxy+[0 0 300]]*rot(rob.az); % Pour pointillés ...
cam.h.TraitPt = plot3(real(plo), imag(plo), [0 0 cam.z; 0 0 cam.z], ':B');
plo = roxy + camxy + [0; 300*rot(rob.az+cam.ro.az)]; % Pour  trait d'axe .-.-.
cam.h.TraitAxe = plot3(real(plo), imag(plo), ones(size(plo))*cam.z, 'B-.');
plo = roxy -80j; % Pour texte cam.ro.x
cam.h.TextX = text(real(plo), imag(plo), 0, ['cam.ro.x = ' num2str(cam.ro.x)], 'Color', 'B', 'FontWeight', 'Bold');
plo = roxy +80j; % Pour texte cam.ro.y
cam.h.TextY = text(real(plo), imag(plo), 0, ['cam.ro.y = ' num2str(cam.ro.y)], 'Color', 'B', 'FontWeight', 'Bold');
plo = roxy+camxy + 10; % Pour texte cam.z
cam.h.TextZ = text(real(plo), imag(plo), .7*cam.z, ['cam.z = ' num2str(cam.z)], 'Color', 'B', 'FontWeight', 'Bold');
plo = roxy+camxy + 200*rot(rob.az+((0:abs(cam.ro.az))*sign(cam.ro.az))); % pour dessin d'angle cam.ro.az
cam.h.Az = plot3(real(plo), imag(plo), ones(size(plo))*cam.z, 'B');
plo = roxy+camxy + 260*rot(rob.az+cam.ro.az/2); % pour texte cam.ro.az
cam.h.TextAz = text(real(plo), imag(plo), cam.z, ['cam.ro.az = ' num2str(cam.ro.az) '°'], 'Color', 'B', 'FontWeight', 'Bold');
LenAxCam = abs(1/cam.ABC(1));
plo = roxy + camxy + [0; LenAxCam*rot(rob.az+cam.ro.az)]*cosd(cam.ro.el); % Pour  trait d'axe optique .-.-.
cam.h.TraitAxeOpt = plot3(real(plo), imag(plo), cam.z+[0; LenAxCam*sind(cam.ro.el)], 'R-.', 'linewidth', 2);
plo = roxy+camxy + 200*rot(rob.az+cam.ro.az)*cosd(0:abs(cam.ro.el)); % pour dessin d'angle cam.ro.el
cam.h.El = plot3(real(plo), imag(plo), cam.z+200*sind(0:abs(cam.ro.el))*sign(cam.ro.el), 'R');
plo = roxy+camxy + 260*rot(rob.az+cam.ro.az)*cosd(cam.ro.el/2); % pour texte cam.ro.el
cam.h.TextEl = text(real(plo), imag(plo), cam.z+200*sind(cam.ro.el/2)-10, ['cam.ro.el = ' num2str(cam.ro.el) '°'], 'Color', 'R', 'FontWeight', 'Bold');

% Coordonnées de la cible (sur le robot)
tarroxy = tar.ro.x + j*tar.ro.y;
tarxy = tarroxy*rot(rob.az);
plo = roxy + [tar.ro.x j*tar.ro.y; tarroxy+[0 0]]*rot(rob.az); % Pour pointillés ...
UD.tar.h.TraitPt = plot3(real(plo), imag(plo), [0 0; 0 0], ':K');
plo = roxy + (tar.ro.x+j*tar.ro.y)*[1 1]*rot(rob.az); % Verticale
UD.tar.h.TraitVertic = plot3(real(plo), imag(plo), [0 tar.z], 'K', 'Marker', '.');
plo = roxy +250+60j; % Pour texte tar.ro.x
UD.tar.h.TextX = text(real(plo), imag(plo), 0, ['tar.ro.x = ' num2str(tar.ro.x)], 'Color', 'K', 'FontWeight', 'Bold');
plo = roxy +250-0j; % Pour texte tar.ro.y
UD.tar.h.TextY = text(real(plo), imag(plo), 0, ['tar.ro.y = ' num2str(tar.ro.y)], 'Color', 'K', 'FontWeight', 'Bold');
plo = roxy+250-60j; % Pour texte tar.z
UD.tar.h.TextZ = text(real(plo), imag(plo), .7*tar.z, ['tar.z = ' num2str(tar.z)], 'Color', 'K', 'FontWeight', 'Bold');
plo = roxy +250-120j; % Pour texte tar.ro.y
UD.tar.h.TextR = text(real(plo), imag(plo), 0, ['tar.ro.r = ' num2str(tar.ro.r)], 'Color', 'K', 'FontWeight', 'Bold');
plo = roxy +250-180j; % Pour texte tar.ro.y
UD.tar.h.TextAz = text(real(plo), imag(plo), 0, ['tar.ro.az = ' num2str(tar.ro.az)], 'Color', 'K', 'FontWeight', 'Bold');
hold off
ha = gca;
UD.roxy = roxy;
UD.rob = rob;
set(gca, 'UserData', UD)

function expangdeg = rot(angdeg)
expangdeg = exp(j*angdeg*pi/180);
