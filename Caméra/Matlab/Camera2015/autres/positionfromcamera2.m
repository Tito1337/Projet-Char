function positionfromcamera2(pix, coord, sens)
% D�tection de position par cam�ra embarqu�e
% F. Gueuning, Unit� Electronique et informatique         ECAM, Bruxelles
%
% SPn 130210: corrections orthographiques
% SPn 120323: distinction cr, ch, co plutot que ca + correction formule MAIS RESTE PROBLEME DE SOMME az ET SOMME el !
% SPn 120301: function avec pix, co, dis
% SPn 120220: Dessin des syst�mes d'axes et calcul de distorsion
% SPn 110404: Premi�res r�flexions

% IN:  pix    structure des pixels � traiter
%         .r indices des lignes (rang�es)
%      coord  structure de coordonn�es de robot et cam�ra
%      sens   structure de caract�ristiques du capteur
% On a
%  - 4 syst�mes de coordonn�es : robot (ro), cam�ra redress�e (ca), image (im), absolu ()
%  - une cible (target, tar) ou une balise (beacon, bea) visibles sur une image
%  - les coordonn�es x, y, z, r, az, el, ah
%  - indices de rang�e (ir) et de colonne (ic) d'un point sur l'image
% 
%  Cam�ra :
%  cam.z      Hauteur du centre de l'objectif de la cam�ra
%  cam.ro.x,.y  Coordonn�es du centre de l'objectif dans le syst�me de coord du robot
%        .az  Orientation azimutale (proche de 0 si la cam�ra regarde devant, donc suivant l'axe X
%        .el  Orientation d'�l�vation (n�gatif car la cam�ra regarde vers le bas)
%        .ah  Angle de l'horizon avec le bas de l'image, proche de 0�
%             Positif si l'horizon apparait plus haut � droite qu'� gauche sur l'image
%        Lors du calcul des coordonn�es de cibles et balises exprim�es dans le rep�re redress� de la
%        cam�ra (cr), on a neutralis� az, el et ah de la cam�ra. Le rep�re (cr) est donc
%        simplement une translation du rep�re (ro) valant cam.ro.x,.y,.z
%  Robot :
%  rob.x, .y   coord absolues du robot
%     .az      orientation azimutale du robot sur le terrain
% 
%  Cible (target) :
%  tar.im.ir      indice de rang�e du point d'image de la cible (target)
%        .ic                colonne
%        .y, .z   coord y et z du point au niveau de l'image apr�s correction de distortion et
%                 redressement compensant cam.ro.ah
%     .cr.az      azimut    de la cible dans le rep�re redress� de la cam�ra (donc orient� comme le robot)
%        .el      �l�vation de la cible telle que per�ue depuis le rep�re redress� de la cam�ra
%     .ro.r       distance entre cible et origine du robot
%        .az      azimut de la cible en coord du robot
%     .x          coord de la cible dans un rep�re absolu (rep�re du terrain)
%     .y
%     .z
%     
%  Balise (beacon) :
%  bea...         similaire � tar mais pour une balise (beacon)
%                 on connait les coordonn�es tar.x,.y,.z des balises
%  
% - On suppose connus les 6 param�tres de position de la cam�ra dans le syst�me de coord du robot :
%     cam.ro.x, .y, .z, .az, .el, .ah
% - A partir des coordonn�es d'un point tar.im.ir,.ic de l'image, on peut d�duire les coord
%   correspondantes tar.cr.az,.el de la cible.
%    - D'abord calculer tar.im.y et tar.im.z (� exprimer en mm en supposant nulles au centre de l'image)
%      Pour la cmucam3, si on se r�f�re aux mesures de distorsion r�alis�es en 2010, extrait de polymais.m :
%         % distorsion en barillet dans le cas o� on veut simuler le comportement de la cam�ra
%         %  521e-6 a �t� d�termin� exp�rimentalement 100328 avec les �tudiants de 4MEO:
%         %    un carreau de 32 pixels au centre devient 27 pixels � 150 pixels du centre  100328
%         %    d�riv�e au centre: 32/32,  � 150 pixels: 27/32 = 1-2*a*150 => a = 521e-6
%         PImYZ = PIm(i).Y + j*PIm(i).Z;
%         PImYZ = abs(PImYZ).*(1-521e-6*abs(PImYZ)).*exp(j*angle(PImYZ));
%         PIm(i).Y = real(PImYZ)*8.2/9; % le nombre d'unit�s en largeur est � diminuer car plus larges
%      Dans notre cas, ce sont les op�rations inverses qu'il faut faire puisqu'on doit corriger une image
%      prise par la cam�ra
%      Exemple :
       im1 = imread('distorsion en barillet.jpg');[r,c,p]=size(im1);
       XY = 2*ones(r+1,1)*(0:c)*9/8.2 + j*(0:r)'*ones(1,c+1); M=mean(mean(XY));
       k=1; PImYZ{k} = XY;
       k=2; PImYZ{k} = M + abs(XY-M).*(1+521e-6*abs(XY-M)).*exp(j*angle(XY-M));
       k=3; PImYZ{k} = M + abs(XY-M).*(1+50e-6*abs(XY-M).^1.5).*exp(j*angle(XY-M));
       k=4; PImYZ{k} = M + abs(XY-M).*(1+700e-6*abs(XY-M)).*exp(j*angle(XY-M));
       Tit = {'original' '521e-6                          ' '50e-6 et \^1.5' '                    700e-6'};
       Col = [0 0 0; 0 .5 0; 1 0 0; 0 0 1];
       for k= [1 4]
          figure
          plot([-50 450],[-50 350], '.k'), hold on
          hs = surf(real(PImYZ{k}), imag(PImYZ{k}), zeros(r+1,c+1), double(im1)/255, 'edgecolor','none');
          hold off
          title(Tit{k}, 'Color', Col(k,:))
          view(0,90)
          set(gca, 'DataAspectRatio', [1 1 1])
          pause(.5)
       end
%      Ne pas oublier de neutraliser l'effet de cam.ro.ah
%      
%    - Puis tenir compte de cam.F (distance focale de la cam�ra) pour calculer tar.cr.az et tar.cr.el
%      tar.cr.az = atan(tar.im.y/cam.F)+cam.ro.az;  % cam.F n�gatif RELATION INCORRECTE, SOMME VALABLE UNIQUEMENT SI AXE OPTIQUE HORIZONTAL
%      tar.cr.el = atan(tar.im.z/(cam.F/cos(tar.cr.az)))+cam.ro.el; % correction 120323  SOMME INCORRECTE

% - Comment d�duire tar.ro.r,.az � partir de tar.cr.az,.el et tar.z ?
%   Si cam.ro.x=0 et cam.ro.y=0  alors on a directement  tar.ro.az=tar.cr.az
%   Sinon il faut par exemple que tar.cr.el soit non nulle pour d�duire  tar.ro.r,.az
%   ce qui n�cessite que cam�ra et cible ne soient pas � la m�me hauteur :
%      tar.cr.r = (cam.z-tar.z)*tan(tar.cr.el)
%   Autre possibilit� : se baser sur la taille de l'image de la cible (fonction de son �loignement).
% - Comment d�terminer l'orientation rob.az et la position rob.x,.y du robot sur le terrain ?
%   CECI EST EN GESTATION, IL FAUDRAIT VOIR DES IMAGES POUR SE FAIRE UNE IDEE
%   Pour une balise, si on peut d�duire bea.ro.r,.az comme pour une cible, 2 balises suffisent pour
%   connaitre la position (ainsi que l'orientation) du robot, sinon il faut 3 balises.
%   On peut aussi se baser sur 2 images � des positions diff�rentes et se contenter de 2 balises : si on
%   sait qu'on a avanc� en ligne droite d'une distance D entre les 2 images, avec les 2 azimuts, on a une
%   information similaire � bea.ro.r,.az
%   Autre possibilit� : tenir compte de l'orientation du bord du terrain sur l'image

% Dessin des syst�mes de coordonn�es
%------------------------------------
cam.z = 300; % [mm] hauteur du centre de l'objectif de la cam�ra
cam.ro.x = -50;
cam.ro.y = 100; % [mm] coordonn�es du centre de l'objectif dans le syst�me de coord du robot
cam.ro.az = 15; % [�] orientation azimutale (proche de 0 si la cam�ra regarde devant, donc suivant l'axe X
cam.ro.el = -30; % [�] orientation d'�l�vation (n�gatif car la cam�ra regarde vers le bas)
cam.ro.ah = 0; % [�] angle de l'horizon avec le bas de l'image, proche de 0
               % positif si l'horizon apparait plus haut � droite qu'� gauche sur l'image
rob.x = 240;
rob.y = 250; % [mm] coord absolues du robot
rob.az = 40; % [�] orientation azimutale du robot sur le terrain
roxy = rob.x + j*rob.y; % robot
figure
% Axes principaux
plot3([0 0 0; 600 0 0], [0 0 0; 0 600 0], [0 0 0; 0 0 400], 'k'), set(gca, 'DataAspectRatio', [1 1 1])
view(-10.5, 26)
hold on
% Coordonn�es du robot
cosraz = cos(rob.az*pi/180);
sinraz = sin(rob.az*pi/180);
plot3([0 0; rob.x 0], [0 0; 0 rob.y], [0 0; 0 0], 'Color', [0 .5 0], 'linewidth', 2) % Lignes sur axes
plot3(rob.x*[0 1; 2 1], rob.y*[1 0; 1 1], [0 0; 0 0], ':', 'Color', [0 .5 0]) % pointill�s ...
plot3(rob.x+[0; 300*cosraz], rob.y+[0; 300*sinraz], [0; 0], '-.', 'Color', [0 .5 0], 'linewidth', 2) % trait d'axe .-.-.
text(rob.x, -110, 0, ['rob.x = ' num2str(rob.x)],'HorizontalAlignment', 'Center', 'Color', [0 .5 0], 'FontWeight', 'Bold')
text(-80, rob.y, 0, ['rob.y = ' num2str(rob.y)],'HorizontalAlignment', 'Center', 'Color', [0 .5 0], 'FontWeight', 'Bold')
plo = roxy + .7*rob.x*rot((0:abs(rob.az))*sign(rob.az)); % pour dessin d'angle rob.az
plot3(real(plo), imag(plo), zeros(size(plo)), 'Color', [0 .5 0])
text(1.7*rob.x, 1.3*rob.y, 0, ['rob.az = ' num2str(rob.az) '�'], 'Color', [0 .5 0], 'FontWeight', 'Bold')
% Coordonn�es de la cam�ra (sur le robot)
camroxy = cam.ro.x + j*cam.ro.y;
camxy = camroxy*rot(rob.az);
plo = roxy + [0 0 camroxy; cam.ro.x j*cam.ro.y camroxy]*rot(rob.az); % Pour lignes sur axes
plot3(real(plo), imag(plo), [0 0 0; 0 0 cam.z], 'B', 'linewidth', 2)
plo = roxy + [cam.ro.x j*cam.ro.y camroxy; camroxy+[0 0 300]]*rot(rob.az); % Pour pointill�s ...
plot3(real(plo), imag(plo), [0 0 cam.z; 0 0 cam.z], ':B')
plo = roxy + camxy + [0; 300*rot(rob.az+cam.ro.az)]; % Pour  trait d'axe .-.-.
plot3(real(plo), imag(plo), ones(size(plo))*cam.z, 'B-.')
plo = roxy -80j; % Pour texte cam.ro.x
text(real(plo), imag(plo), 0, ['cam.ro.x = ' num2str(cam.ro.x)], 'Color', 'B', 'FontWeight', 'Bold')
plo = roxy +80j; % Pour texte cam.ro.y
text(real(plo), imag(plo), 0, ['cam.ro.y = ' num2str(cam.ro.y)], 'Color', 'B', 'FontWeight', 'Bold')
plo = roxy+camxy + 10; % Pour texte cam.z
text(real(plo), imag(plo), .7*cam.z, ['cam.z = ' num2str(cam.z)], 'Color', 'B', 'FontWeight', 'Bold')
plo = roxy+camxy + 200*rot(rob.az+((0:abs(cam.ro.az))*sign(cam.ro.az))); % pour dessin d'angle cam.ro.az
plot3(real(plo), imag(plo), ones(size(plo))*cam.z, 'B')
plo = roxy+camxy + 260*rot(rob.az+cam.ro.az/2); % pour texte cam.ro.az
text(real(plo), imag(plo), cam.z, ['cam.ro.az = ' num2str(cam.ro.az) '�'], 'Color', 'B', 'FontWeight', 'Bold')
plo = roxy + camxy + [0; 300*rot(rob.az+cam.ro.az)]*cosd(cam.ro.el); % Pour  trait d'axe optique .-.-.
plot3(real(plo), imag(plo), cam.z+[0; 300*sind(cam.ro.el)], 'R-.', 'linewidth', 2)
plo = roxy+camxy + 200*rot(rob.az+cam.ro.az)*cosd(0:abs(cam.ro.el)); % pour dessin d'angle cam.ro.el
plot3(real(plo), imag(plo), cam.z+200*sind(0:abs(cam.ro.el))*sign(cam.ro.el), 'R')
plo = roxy+camxy + 260*rot(rob.az+cam.ro.az)*cosd(cam.ro.el/2); % pour texte cam.ro.el
text(real(plo), imag(plo), cam.z+200*sind(cam.ro.el/2)-10, ['cam.ro.el = ' num2str(cam.ro.el) '�'], 'Color', 'R', 'FontWeight', 'Bold')

function expangdeg = rot(angdeg)
expangdeg = exp(j*angdeg*pi/180);
