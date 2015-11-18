function redressImOscillo
if findstr(computer, 'GLNX') % Si sous Linux
   Im = imread('/media/Documents/VM/VMsite/compo/diode/2013-01-15 10.12.50.jpg');
else
   Im = imread('E:\VM\VMsite\compo\diode\2013-01-15 10.12.50.jpg');
   Im = imread('E:\VM\VMsite\compo\diode\2013-01-15 10.13.05.jpg');
end
figure
image(Im)
set(gca, 'DataAspectRatio', [1 1 1])
title('Sélectionner les 4 coins du graphique de l''oscilloscope ainsi que le centre (ordre quelconque)')
if 1==1
   [X1,Y1] = ginput(5);
   XY1 = X1+j*Y1;
   d = abs(XY1-mean(XY1));
   iC = find(d == min(d));
   a = angle(XY1-XY1(iC));
   iUL = find(a<-pi/2);
   iUR = find(a>-pi/2 & a<0);
   iDR = find(a<pi/2 & a>0);
   iDL = find(a>pi/2);
   XY1 = XY1([iUL iUR iDR iDL iC]) % UpLeft, UpRight, DownRight, DownLeft, Center
else
   XY1 = [  % pour 2013-01-15 10.12.50.jpg
      0.3508 + 0.3257i
      2.0470 + 0.2881i
      2.0638 + 1.6266i
      0.3989 + 1.6664i
      1.2167 + 0.9825i
      ]*1e3;
end
% Mettre le centre en 0,0 et les 4 coins sélectionnés en  -5,4  5,4  5,-4  -5,-4

% 1. Passer des pixels aux points en mm sur le capteur (incluant correction de distorsion)
% IN:  trg.im.  Structure des pixels à traiter, les points d'objets correspondants sont appelés cibles (target)
%            .rmax  Nombre de rangées de l'image dont sont issues .ir et .ic, on suppose axe optique au centre
%            .cmax  idem pour le nombre de colonnes de l'image
%            .ir    Scalaire ou matrice d'indices des lignes (rangées) des pixels à traiter
%            .ic    Scalaire ou matrice d'indices des colonnes de dim compatibles avec celles de .ir
sens = 'samsung9000';
im5.ir = imag(XY1);
im5.ic = real(XY1);
[imyz5, sens] = pix2yz(im5, sens);

% 2. Passer des points situés dans le plan du capteur vers les points d'objet à distances connues entre eux
xf = sens.F;
kOsc = 1%0.89; %  L'oscillo Tektro a des divisions de 8.9mm et pas 10mm
L = 100*kOsc; H = 80*kOsc; D = sqrt(L^2 + H^2); % Graphique d'oscilloscope (l'oscillo Tektro a des divisions de 8.9mm)
%       ul   ur   dr   dl   OO
ref = [  0    L    D    H  D/2   % ul
         0    0    H    D  D/2   % ur
         0    0    0    L  D/2   % dr
         0    0    0    0  D/2]; % dl
objco5 = xfyz2objco(xf, imyz5, ref); % Les 5 points sont en objco5.x, .y, .z en principe dans un même plan (dans le repère co, camera only)

% 3. Déterminer le plan le plus probable auquel appartiennent ces points dans le repère co
ABC = regresplane([objco5.x objco5.y, objco5.z]); % Equation du plan : A*X + B*Y + C*Z + 1 = 0

% 4. En supposant que tous les points d'image sont issus de points d'objet situés dans ce plan,
%    déterminer les points d'objet pour tous les pixels
im.ir = (1:sens.rmax)' * ones(1,sens.cmax);
im.ic = ones(sens.rmax, 1) * (1:sens.cmax);
imyz = pix2yz(im, sens);
objcoall = xfyz2objco(xf, imyz, ABC);
objco5 = xfyz2objco(xf, imyz5, ABC)';

% 5. Changements de repères
% On a créé les fonctions suivantes où hommat est une matrice de transformation homogène, abc est un vecteur tel que [A, B, C] et inv~=0 pour inverser rotation
%   hommat = homrot_abc2x0c(abc, inv)
%   hommat = homrot_abc2xb0(abc, inv)
%   hommat = homrot_abc20yc(abc, inv)
%   hommat = homrot_abc2ay0(abc, inv)
%   hommat = homrot_abc20bz(abc, inv)
%   hommat = homrot_abc2a0z(abc, inv)
%   hommat = homtrans(abc, xyz)
% Le vecteur A,B,C est perpendiculaire au plan
% On va déterminer 2 rotations pour amener ce vecteur sur l'axe X (notre plan sera donc parallèle au plan YZ)
% puis une troisième rotation pour qu'une horizontale du graphique soit parallèle à l'axe Y.
hommat1 = homrot_abc2x0c(ABC); %  - Rotation autour de l'axe Z (C invariant) pour que A,B,C arrive dans le plan XZ (Y=0)
hommat2 = homrot_abc2xb0(hommat1*[ABC 1]'); %  - Rotation autour de l'axe Y (B invariant) pour que A',0,C se confonde avec l'axe X (Z=0)
hommat12 = hommat2*hommat1;
%  - Rotation autour de l'axe X
% D'abord rotation hommat12 pour les 4 coins (ul ur dr dl) du graphique
Pt4YZ = hommat12 * [objco5.x(1:4)'; objco5.y(1:4)'; objco5.z(1:4)'; [1 1 1 1]];
% Utiliser ces points pour définir une droite qui devra devenir horizontale (sur l'axe Y)
D = mean(Pt4YZ(:,[2 3]), 2) - mean(Pt4YZ(:,[1 4]), 2);
hommat3 = homrot_abc2ay0(D); %  - Rotation autour de l'axe X (A invariant) pour que 0,B,C se confonde avec l'axe Y (Z=0)
hommat123 = hommat3*hommat12;

% 6. Translation pour ramener le centre du graphique en 0,0,0
Pt0 = hommat123 * [objco5.x(5); objco5.y(5); objco5.z(5); 1];
hommatT = homtrans(Pt0, [0 0 0]);
hommatall = hommatT*hommat123;

% 7. Transformation ramenant tous les pixels dans le plan YZ
r = sens.rmax;
c = sens.cmax;
objYZ = hommatall * [reshape(objcoall.x, 1, r*c); reshape(objcoall.y, 1, r*c); reshape(objcoall.z, 1, r*c); ones(1, r*c)];

% 8. Affichage de la photo d'écran d'oscillo
figure
%hs = surf(reshape(objYZ(1,:), r, c), reshape(objYZ(2,:), r, c), reshape(objYZ(3,:), r, c), double(Im)/255, 'edgecolor','none');
% Afficher (-5:10, -5:35)
xx = reshape(objYZ(1,:), r, c);
yy = reshape(objYZ(2,:), r, c);
zz = reshape(objYZ(3,:), r, c);
[iyr, iyc] = find(yy<-5);
iymin = max(iyc)
[iyr, iyc] = find(yy>20);
iymax = min(iyc)
[izr, izc] = find(zz<-5);
izmax = min(izr)
[izr, izc] = find(zz>35);
izmin = max(izr)
hs = surf(xx(izmin:izmax, iymin:iymax), ...
   yy(izmin:izmax, iymin:iymax), ...
   zz(izmin:izmax, iymin:iymax), double(Im(izmin:izmax, iymin:iymax, :))/255, 'edgecolor','none');
set(gca, 'DataAspectRatio', [1 1 1])
view(89.99, 0)

UD.h = []; % Contiendra handles de points et texte ajoutés sur l'image
UD.VI = []; % Contiendra positionsou clicks
set(gcf, 'UserData', UD)
set(gcf, 'WindowButtonMotionFcn', @displayposition, 'KeyPressFcn', @selectpointforcoord)
%#################################################################################################
function selectpointforcoord(varargin)  % KeyPressFcn
% Lorsqu'on exécute commande : sélection d'un point avec souris et affichage de x y
% Attention! Erreur java sérieuse sous Windows si on utilise la touche avant d'avoir cliqué une fois au moins
% Erreur grave (fermeture de Matlab) sous Linux lors du click après sélection de touche
UD=get(gcf,'UserData');
cr = get(gca, 'CurrentPoint');
cr = cr(1, 1:3);
VI = [cr(2)*0.2-cr(3)*2e-3 cr(3)*2e-3];
UD.VI = [UD.VI; VI];
set(gcf, 'UserData', UD)
% On trouve en cliquant
% UD.VI  pour  2013-01-15 10.12.50.jpg
% ans =  V         A
%     0.0054    0.0001
%     0.3802   -0.0000
%     0.5965    0.0015
%     0.6799    0.0053
%     0.7188    0.0099
%     0.7479    0.0158
%     0.7785    0.0199
%     0.7942    0.0304
%     0.8269    0.0413
%     0.8339    0.0517
%     0.8431    0.0599
%     0.8569    0.0636
% UD.VI   pour  2013-01-15 10.13.05.jpg
% ans =  
%    -0.3259    0.0002
%     0.0140    0.0002
%     0.2402    0.0006
%     0.3069    0.0036
%     0.3454    0.0086
%     0.3539    0.0176
%     0.4129    0.0283
%     0.4300    0.0373
%     0.4518    0.0503
%     0.4769    0.0601
%     0.4551    0.0645
%#################################################################################################
function displayposition(varargin)  % WindowButtonMotionFcn
% Lorsque l'on passe sur le graphique, indiquer la position
UD=get(gcf,'UserData');
cr = get(gca, 'CurrentPoint');
cr = cr(1, 1:3);
%X title(sprintf('x= %3.2f  y= %3.2f', cr(2), cr(3)));
title([num2eng(cr(2)*0.2, 'V') ', ' num2eng(cr(3)*2e-3, 'A') ',  corrigé :  ' num2eng(cr(2)*0.2-cr(3)*2e-3, 'V') ', ' num2eng(cr(3)*2e-3, 'A')]);
