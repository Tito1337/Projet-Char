% Camera - proc�dure d'�talonnage
%---------------------------------
%
%      Cam�ra sur Rasberry pi                                     PC                
%  ������������������������������������            ����������������������������������
%  Pourrait prend les images en continu    <---    Pourrait fournir nom de fichier contenant
%  Utilise zones pour d�terminer                   zones et couleurs pour �talonnage (une zone par point)
%   centroides d'�talonnage                        ______
%  Renvoie chaque fois im.ir               --->   |pix2yz| distances entre points
%                        .ic                       ��T���  |   d'�talonnage (ref)
%                                                  __V_____V_
%                                                 |xfyz2objco|
%                                                  �����T����positions xyz des points
%                                                       V     dans le rep�re cam�ra
%                                                  D�terminer �quation du plan du terrain dans le rep�re cam�ra
%                                                  D�terminer position cam�ra dans le rep�re robot
%                                                    |
%                                                  __V__
%                                                 |co2ro|
%                                                  ��|��
%                                                    V  coordonn�es des points dans le rep�re robot

% Attention! Il faut peut-�tre un effet miroir sur les ir !

%SPLAN 151028: �talon test A4
% SP4 151028:  correction et ajout dessin �talon et rep�re cam�ra dans rep�re robot

im4_ = rgbaread('col_detected', 3/2);
figure
image(im4_(:,:,1:3))
disp('Agrandir la figure puis cliquer sur les 4 centroides')
[im4.ic, im4.ir]=ginput(4) % --->  Remplacer ce choix manuel par les centroides fournis par la raspberry (picam.cpp)  <---
% Les remettre dans l'ordre rmax, cmax, rmin, cmin
%X151028 irmax = find(im4.ir==max(im4.ir));
%X151028 icmax = find(im4.ic==max(im4.ic));
%X151028 irmin = find(im4.ir==min(im4.ir));
%X151028 icmin = find(im4.ic==min(im4.ic));
%X151028 inew = [irmax; icmax; irmin; icmin];


%rechercher ordre  ul   ur   dr   dl   151028 LANGAU
iul = find((im4.ir<mean(im4.ir))& (im4.ic<mean(im4.ic)));
iur = find((im4.ir<mean(im4.ir))& (im4.ic>mean(im4.ic)));
idr = find((im4.ir>mean(im4.ir))& (im4.ic>mean(im4.ic)));
idl = find((im4.ir>mean(im4.ir))& (im4.ic<mean(im4.ic)));
inew = [iul; iur; idr; idl];

if (mean(inew)~=mean(1:4)) || std(inew)~=std(1:4), brol, end % Provoquer erreur si on n'a pas 1 2 3 4 (dans un ordre quelconque)
im4.ic = im4.ic(inew);
im4.ir = im4.ir(inew);

%              ______
[imyz4, sens] = pix2yz(im4, 'picam_384x256')
%              ������
%X151028 D = 646; % diag (mm)
%X151028 H = 646/sqrt(2);
%X151028 L = H;
%X151028gng H = 95/sqrt(2);
H = 95;
L = 120;
D = sqrt(H^2+L^2); % diag (mm)

%       ul   ur   dr   dl
ref = [  0    L    D    H    % ul
         0    0    H    D    % ur
         0    0    0    L];  % dr
%X151028gng XY1ref = [D/2 0]; % coord X,Y du point principal de r�f�rence dans le rep�re du robot
XY1ref = [262, 56]; % coord X,Y du point principal de r�f�rence (up left) dans le rep�re du robot
iPtRef = 1; % 1er (up left)
%         __________
objco4_ = xfyz2objco(sens.F, imyz4, ref); % Positions des points dans le rep�re cam�ra
%         ����������
figure,plot3(objco4_.x([1:end 1]), objco4_.y([1:end 1]), objco4_.z([1:end 1]))
set(gca,'dataAspectRatio',[1 1 1])


% D�terminer �quation du plan le plus probable auquel appartiennent ces points dans le rep�re co
%-----------------------------
ABC = regresplane([objco4_.x objco4_.y, objco4_.z]); % Equation du plan : A*X + B*Y + C*Z + 1 = 0
% Puis ajuster les points objco pour qu'ils appartiennent � ce plan
objco4 = xfyz2objco(sens.F, imyz4, ABC);

% Changement de rep�res
%X151028gng hommat1 = homrot_abc2a0z(ABC); % Correction de ah: Rotation autour de l'axe Y (B invariant) pour que A,B,C arrive dans le plan YZ (X=0)
hommat1 = homrot_abc2a0z(ABC); % Correction de ah: Rotation autour de l'axe X (A invariant) pour que A,B,C arrive dans le plan XZ (Y=0)
%X151028gng hommat2 = homrot_abc20bz(hommat1*[ABC 1]'); % Correction de el: Rotation autour de l'axe X (X invariant) pour que 0,B,C' se confonde avec l'axe Z (Y=0)
hommat2 = homrot_abc20bz(hommat1*[ABC 1]'); % Correction de el: Rotation autour de l'axe Y (B invariant) pour que A,0,C' se confonde avec l'axe Z (X=0)
hommat12 = hommat2*hommat1;
Pt4XY = hommat12 * [objco4.x'; objco4.y'; objco4.z'; [1 1 1 1]];

% Utiliser deux points pour d�finir une droite qui devra devenir horizontale (sur l'axe Y)
%---------------------------------------------------------------------------
% ATTENTION! est-ce que les points choisis sont compatibles avec vos points d'�talonnage ?
D =  mean(Pt4XY(:,[1 4]), 2) - mean(Pt4XY(:,[2 3]), 2);

hommat3 = homrot_abc20yc(D); % Correction de az - Rotation autour de l'axe Z (C invariant) pour que A,B,0 se confonde avec l'axe Y (X=0)
hommat123 = hommat3*hommat12;
%X151028 XYZ2 = [objco4.x(1)  objco4.y(1)  objco4.z(1)]; % Point de r�f�rence XYZ: (1er, le plus proche de la cam�ra)
XYZ2 = [objco4.x(iPtRef)  objco4.y(iPtRef)  objco4.z(iPtRef) 1]'; % Point de r�f�rence XYZ: (up left)
XY0 = hommat123*XYZ2; % Faisons d'abord subir les trois rotations � ce point pour le ramener dans le plan XY du robot
hommatT = homtrans(XY0, [XY1ref 0]); % Translation du point XY0 vers le point [XY1ref 0]
hommatall = hommatT*hommat123; % Matrice de transformation homog�ne pour passer du rep�re de la cam�ra vers celui du robot


% D�terminer position cam�ra dans le rep�re robot
%-------------------------------------------------
%      cam  Cam�ra 
%         .z      Hauteur du centre de l'objectif de la cam�ra
%         .ro.x,.y  Coordonn�es du centre de l'objectif dans le syst�me de coord du robot
%            .az  Orientation azimutale (proche de 0 si la cam�ra regarde devant, donc suivant l'axe X
%            .el  Orientation d'�l�vation (n�gatif car la cam�ra regarde vers le bas)
%            .ah  Angle de l'horizon avec le bas de l'image, proche de 0�
cam0 = hommatall*[0;0;0;1]; % coord de la cam�ra dans le rep�re du robot
cam.z = cam0(3);
cam.ro.x = cam0(1);
cam.ro.y = cam0(2);
cam.ro.az = angle(hommat3(1,1)-j*hommat3(1,2))*180/pi;
cam.ro.el = angle(hommat2(1,1)-j*hommat2(1,3))*180/pi;
cam.ro.ah = angle(hommat1(2,2)+j*hommat1(2,3))*180/pi;
cam.ABC = ABC; % Equation du plan : A*X + B*Y + C*Z + 1 = 0
cam.hommatall = hommatall;

% Out: hommatall  Matrice homog�ne 4x4 de passage du rep�re cam�ra vers le rep�re du robot
%      ABC        Vecteur 1x3 A,B,C du plan A*X+B*Y+C*Z+1=0 du terrain dans le rep�re cam�ra
% Ces variables, sont � fournir � la fonction  pix2objro  qui calcule les coordonn�es d'objets dans le rep�re du robot
% � partir de points d'image.

% Note: Pour calcul d'erreur compl�mentaire, voir camera2013


% Dessin des axes principaux
figure
plot3([0 0 0; 300 0 0], [0 0 0; 0 300 0], [0 0 0; 0 0 200], 'k'), set(gca, 'DataAspectRatio', [1 1 1])
view(-10.5, 26)
view(36.5, 24)
hold on

% Dessin des coordonn�es de la cam�ra (sur le robot)
camroxy = cam.ro.x + j*cam.ro.y;
camxy = camroxy;
plo = [0 0 camroxy; cam.ro.x j*cam.ro.y camroxy]; % Pour lignes sur axes
plot3(real(plo), imag(plo), [0 0 0; 0 0 cam.z], 'Color', 'B', 'linewidth', 2)
plo = [cam.ro.x j*cam.ro.y camroxy; camroxy+[0 0 300]]; % Pour pointill�s ...
plot3(real(plo), imag(plo), [0 0 cam.z; 0 0 cam.z], 'Color', 'B',  'LineStyle', ':')
plo = camxy + [0; 300*rot(cam.ro.az)]; % Pour  trait d'axe .-.-.
plot3(real(plo), imag(plo), ones(size(plo))*cam.z, 'Color', 'B',  'LineStyle', '-')
plo =  -80j; % Pour texte cam.ro.x
text(real(plo), imag(plo), 0, ['cam.ro.x = ' num2str(cam.ro.x)], 'Color', 'B', 'FontWeight', 'Bold')
plo =  +80j; % Pour texte cam.ro.y
text(real(plo), imag(plo), 0, ['cam.ro.y = ' num2str(cam.ro.y)], 'Color', 'B', 'FontWeight', 'Bold')
plo = camxy + 10; % Pour texte cam.z
text(real(plo), imag(plo), .7*cam.z, ['cam.z = ' num2str(cam.z)], 'Color', 'B', 'FontWeight', 'Bold')
plo = camxy + 200*rot(((0:abs(cam.ro.az))*sign(cam.ro.az))); % pour dessin d'angle cam.ro.az
plot3(real(plo), imag(plo), ones(size(plo))*cam.z, 'Color', 'B')
plo = camxy + 260*rot(cam.ro.az/2); % pour texte cam.ro.az
text(real(plo), imag(plo), cam.z, ['cam.ro.az = ' num2str(cam.ro.az) '�'], 'Color', 'B', 'FontWeight', 'Bold')
plo = camxy + [-80; 300]*rot(cam.ro.az)*cosd(cam.ro.el); % Pour  trait d'axe optique .-.-.
plot3(real(plo), imag(plo), cam.z+[-80; 300]*sind(cam.ro.el), 'Color', 'R',  'LineStyle', '-.', 'linewidth', 2)
plo = camxy + 200*rot(cam.ro.az)*cosd(0:abs(cam.ro.el)); % pour dessin d'angle cam.ro.el
plot3(real(plo), imag(plo), cam.z+200*sind(0:abs(cam.ro.el))*sign(cam.ro.el), 'Color', 'R')
plo = camxy + 260*rot(cam.ro.az)*cosd(cam.ro.el/2); % pour texte cam.ro.el
text(real(plo), imag(plo), cam.z+200*sind(cam.ro.el/2)-10, ['cam.ro.el = ' num2str(cam.ro.el) '�'], 'Color', 'R', 'FontWeight', 'Bold')

% Dessin de l'objet
obj = cam.hommatall * [objco4.x'; objco4.y'; objco4.z'; ones(size(objco4.x'))];
%X151028 plot3(objco4_.x([1:end 1]), objco4_.y([1:end 1]), objco4_.z([1:end 1]))
plot3(obj(1,[1:end 1]), obj(2,[1:end 1]), obj(3,[1:end 1]))
plot3(obj(1,iPtRef), obj(2,iPtRef), obj(3,iPtRef), '.')

hold off
grid
