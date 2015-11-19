% image2objet
%-------------
% - S�lection d'une image compatible avec les variables hommatall, ABC, et sens
%   pr�alablement issues de camera2013
% - d�termination de la position d'objets sur le terrain sur base de leurs points d'image
% F. Gueuning, 2013   Unit� Electronique et informatique         ECAM, Bruxelles
%
% IN:  hommatall  Matrice homog�ne 4x4 de passage du rep�re cam�ra vers le rep�re du robot
%      ABC        Vecteur 1x3 A,B,C du plan A*X+B*Y+C*Z+1=0 du terrain dans le rep�re cam�ra
%      sens       Nom ou caract�ristiques de la cam�ra (def: 'cmucam3_full')
% OUT: objro  Structure de coordonn�es .x, .y, .z  des points d'objet correspondants � imyz dans le rep�re ro (robot)
%
% Charger image contenant objet � situer
[fname1,pname1]=uigetfile('*.jpg;*.bmp;*.JPG;*.BMP','Photo d''objet � situer');
Im = imread([pname1 fname1]);

H = input('Hauteur des points � situer (en mm) : ');
hf = figure('Position', [432 674 1027 420]);

% 
UD = struct; % UD pour pouvoir ouvrir simultan�ment plusieurs figures ind�pendantes
UD.hommatall = hommatall;
UD.ABC = ABC;
UD.H = H;
UD.sens = sens;
subplot(121)
image(Im)
set(gca, 'DataAspectRatio', [1 1 1])
UD.htit = title('Position (en mm)  ');
UD.ha1 = gca;
% set(hf, 'WindowButtonMotionFcn', ...
% ['UD = get(' num2str(hf) ', ''UserData''); ' ...
% 'cr = get(UD.ha1, ''CurrentPoint''); ' ...
% 'cr = cr(1, 1:3); ' ...
% 'objro = pix2objro(cr(2), cr(1), UD.hommatall, UD.ABC, UD.H, UD.sens); ' ...
% 'set(UD.htit, ''String'', [''Pixel  '' num2str(round(cr(1))) '', '' num2str(round(cr(2))) '',    Position (en mm)  ''' ...
% ' num2str(round(objro.x)) '', '' num2str(round(objro.y)) '', '' num2str(round(objro.z))]);' ...
% ... % Coordonn�es de la cible (sur le robot)
% 'UD2 = get(UD.ha2, ''Userdata'');' ...
% 'tarroxy = tar.ro.x + j*tar.ro.y;' ...
% 'plo = UD2.roxy + [tar.ro.x j*tar.ro.y; tarroxy+[0 0]]*exp(j*UD2.rob.az*pi/180);' ...
% 'set(UD2.tar.h.TraitPt, ''Xdata'', real(plo), ''Ydata'', imag(plo), ''Zdata'', [0 0; 0 0]),' ...
% 'plo = UD2.roxy + tarroxy*[1 1]*exp(j*UD2.rob.az*pi/180);' ...
% 'set(UD2.tar.h.TraitVertic, ''Xdata'', real(plo), ''Ydata'', imag(plo), ''Zdata'', [0 tar.z]);' ...
% 'set(UD2.tar.h.TextX, ''String'', [''tar.ro.x = '' num2str(tar.ro.x)]);' ...
% 'set(UD2.tar.h.TextY, ''String'', [''tar.ro.y = '' num2str(tar.ro.y)]);' ...
% 'set(UD2.tar.h.TextZ, ''String'', [''tar.z = '' num2str(tar.z)]);' ...
% ])
set(hf, 'WindowButtonMotionFcn', @image2objetupdate)
subplot(122)
cr = [sens.cmax/2, sens.rmax/2]; % initialisation (un peu bidon)
objro = pix2objro(cr(2), cr(1), UD.hommatall, UD.ABC, UD.H, UD.sens);
%      tar  Cible (target)
%         .im.ir      indice de rang�e du point d'image de la cible (target)
%            .ic                colonne
%         .ro.r       distance entre cible et origine du robot
%            .az      azimut de la cible en coord du robot
%            .x       coord de la cible dans le rep�re du robot
%            .y
%         .x          coord de la cible dans un rep�re absolu (rep�re du terrain)
%         .y
%         .z
tar = struct;
tar.im.ir = cr(2);
tar.im.ic = cr(1);
tar.ro.x = objro.x;
tar.ro.y = objro.y;
tar.z = objro.z;
XY = tar.ro.x + j*tar.ro.y;
tar.ro.r = abs(XY);
tar.ro.az = angle(XY)*180/pi;
UD.ha2 = plotsystem3d(tar, cam, sens); % ha2 est handle de axes o� dessin des syst�mes de coordonn�es
set(gcf, 'UserData', UD)
