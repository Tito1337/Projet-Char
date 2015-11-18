function detcol = detectcolor(Im, comp, cpmin, cpmax, colnum)
% D�tecter plusieurs couleurs d�termin�es sur une image
% F. Gueuning, 2012         ECAM, Bruxelles
%
% SPc 120313: d�tection de plusieurs couleurs
% SPc 120218: cr�ation
% IN:  Im     image � traiter, array de dim (r,c,3) et de valeurs entre 0 et 255
%      comp   Matrice � ncol rang�es (1 par couleur) indiquant pour chaque
%             couleur l'ordre de test des 3 composantes (1:R, 2:G, 3:B)
%             Ex de rang�e: [2 1 3] pour tester G puis R puis B
%             Pour peu d�pendre de la luminance, en chaque pixel,
%             les 2e et 3e composantes test�es sont d'abord
%             *128/premi�re test�e avant comparaison � cpmin et cpmax
%      cpmin  Matrice des minima � d�tecter de m�me dim que comp
%             valeurs entre 0 et 255
%      cpmax  Matrice des maxima � d�tecter de m�me dim que comp
%             valeurs entre 0 et 255
%      colnum Vecteur colonne, num�ros � attribuer aux ncol couleurs d�finies pour d�tection
%             def: leur indice de rang�e dans comp
%             Ceci permet d'attribuer le m�me num�ro � plusieurs couleurs d�finies pour
%             que les informations des matrices Col et To soient plus compactes
% OUT: detcol matrice de dim (r,c) contenant les num�ros des couleurs d�tect�es
%             -1 pour nomatch (= aucune couleur d�tect�e pour le pixel)
% ex:
%   Utiliser SelectCol.m et SelectCol.fig  ou bien :
%   Im = imread('viacmucam_terrainEcam_20092010_1.jpg');
%   comp = [1 2 3]; % tester R (principale) puis G puis B
%   cpmin = [20 0 0];
%   cpmax = [255 64 64]; % La premi�re composante est suppos�e virtuellement ramen�e � 128, 64 indique la moiti� pour les 2e et 3e par rapport � la 1�re
%   colOK = detectcolor(Im, comp, cpmin, cpmax);
% Imaginons un algorithme :
%  On teste successivement chaque composante, la premi�re de la rang�e en cours de comp est celle qui domine dans la couleur recherch�e.
%  Pour chaque composante, on fournit la fourchette d'acceptation.
%  Pour la premi�re, c'est une fourchette absolue (entre 0 et 255), mais pour les 2 autres, afin de
%  peu d�pendre de la luminance, c'est en relatif par rapport � la premi�re en chaque pixel.
%  Si la premi�re couleur recherch�e n'est pas d�tect�e pour un pixel, on tente de d�tecter pour lui la couleur suivante
if nargin<1
   Im = imread('viacmucam_terrainEcam_20092010_1.jpg');
end
if nargin<2
comp = [1 2 3]; % tester R (principale) puis G puis B
end
if nargin<3
cpmin = [20 0 0];
end
if nargin<4
cpmax = [255 64 64]; % La premi�re composante est suppos�e virtuellement ramen�e � 128, 64 indique la moiti� pour les 2e et 3e par rapport � la 1�re
end
if nargin<5
   colnum = (1:size(comp,1))'; % Par d�faut, chaque couleur est identifi�e par son indice de rang�e dans comp
end
[r, c] = size(Im(:,:,1));
Imc = reshape(Im, r*c, 3);
detcol = -ones(r, c); % au d�part, aucune couleur d�tect�e
for k = 1:size(comp, 1) % Pour chaque couleur � d�tecter
   i = find(detcol==-1); % indices des pixels � examiner
   colOK = ones(length(i), 1); % au d�part, tous les pixels sont candidats donc encore � 1
   % 1. D�tection pour la premi�re composante
   colOK = colOK & (Imc(i, comp(k,1)) >= cpmin(k,1));
   colOK = colOK & (Imc(i, comp(k,1)) <= cpmax(k,1));
   % 2. D�tection pour la deuxi�me composante
   Im1 = Imc(i,comp(k,1));
   Im1(Im1==0) = 1; % pour �viter les divisions par z�ro
   ImRel2 = uint8(uint16(Imc(i,comp(k,2))) * 128 ./ uint16(Im1)); % Valeurs relatives par rapport � 1�re composante (identique = 128)
   colOK = colOK & (ImRel2 >= cpmin(k,2));
   colOK = colOK & (ImRel2 <= cpmax(k,2));
   % 3. D�tection pour la troisi�me composante
   ImRel3 = uint8(uint16(Imc(i,comp(k,3))) * 128 ./ uint16(Im1)); % Valeurs relatives par rapport � 1�re composante (identique = 128)
   colOK = colOK & (ImRel3 >= cpmin(k,3));
   colOK = colOK & (ImRel3 <= cpmax(k,3));
   % 4. Stockage des d�tect�es
   detcol(i(colOK)) = colnum(k);
end
% % Affichage
% ImOut = Im;
% ImOutc = 255*ones(r, c); % pour a priori blanc o� pas couleur
% for k=1:3
%    ImOutk = Im(:,:,k);
%    ImOutc(colOK) = ImOutk(colOK);
%    ImOut(:,:,k) = ImOutc;
% end
% figure
% subplot(2,1,1);
% image(Im)
% set(gca, 'dataaspectratio', [1 1 1])
% subplot(2,1,2);
% image(ImOut)
% set(gca, 'dataaspectratio', [1 1 1])
