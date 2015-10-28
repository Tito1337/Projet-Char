function detcol = detectcolor(Im, comp, cpmin, cpmax, colnum)
% Détecter plusieurs couleurs déterminées sur une image
% F. Gueuning, 2012         ECAM, Bruxelles
%
% SPc 120313: détection de plusieurs couleurs
% SPc 120218: création
% IN:  Im     image à traiter, array de dim (r,c,3) et de valeurs entre 0 et 255
%      comp   Matrice à ncol rangées (1 par couleur) indiquant pour chaque
%             couleur l'ordre de test des 3 composantes (1:R, 2:G, 3:B)
%             Ex de rangée: [2 1 3] pour tester G puis R puis B
%             Pour peu dépendre de la luminance, en chaque pixel,
%             les 2e et 3e composantes testées sont d'abord
%             *128/première testée avant comparaison à cpmin et cpmax
%      cpmin  Matrice des minima à détecter de même dim que comp
%             valeurs entre 0 et 255
%      cpmax  Matrice des maxima à détecter de même dim que comp
%             valeurs entre 0 et 255
%      colnum Vecteur colonne, numéros à attribuer aux ncol couleurs définies pour détection
%             def: leur indice de rangée dans comp
%             Ceci permet d'attribuer le même numéro à plusieurs couleurs définies pour
%             que les informations des matrices Col et To soient plus compactes
% OUT: detcol matrice de dim (r,c) contenant les numéros des couleurs détectées
%             -1 pour nomatch (= aucune couleur détectée pour le pixel)
% ex:
%   Utiliser SelectCol.m et SelectCol.fig  ou bien :
%   Im = imread('viacmucam_terrainEcam_20092010_1.jpg');
%   comp = [1 2 3]; % tester R (principale) puis G puis B
%   cpmin = [20 0 0];
%   cpmax = [255 64 64]; % La première composante est supposée virtuellement ramenée à 128, 64 indique la moitié pour les 2e et 3e par rapport à la 1ère
%   colOK = detectcolor(Im, comp, cpmin, cpmax);
% Imaginons un algorithme :
%  On teste successivement chaque composante, la première de la rangée en cours de comp est celle qui domine dans la couleur recherchée.
%  Pour chaque composante, on fournit la fourchette d'acceptation.
%  Pour la première, c'est une fourchette absolue (entre 0 et 255), mais pour les 2 autres, afin de
%  peu dépendre de la luminance, c'est en relatif par rapport à la première en chaque pixel.
%  Si la première couleur recherchée n'est pas détectée pour un pixel, on tente de détecter pour lui la couleur suivante
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
cpmax = [255 64 64]; % La première composante est supposée virtuellement ramenée à 128, 64 indique la moitié pour les 2e et 3e par rapport à la 1ère
end
if nargin<5
   colnum = (1:size(comp,1))'; % Par défaut, chaque couleur est identifiée par son indice de rangée dans comp
end
[r, c] = size(Im(:,:,1));
Imc = reshape(Im, r*c, 3);
detcol = -ones(r, c); % au départ, aucune couleur détectée
for k = 1:size(comp, 1) % Pour chaque couleur à détecter
   i = find(detcol==-1); % indices des pixels à examiner
   colOK = ones(length(i), 1); % au départ, tous les pixels sont candidats donc encore à 1
   % 1. Détection pour la première composante
   colOK = colOK & (Imc(i, comp(k,1)) >= cpmin(k,1));
   colOK = colOK & (Imc(i, comp(k,1)) <= cpmax(k,1));
   % 2. Détection pour la deuxième composante
   Im1 = Imc(i,comp(k,1));
   Im1(Im1==0) = 1; % pour éviter les divisions par zéro
   ImRel2 = uint8(uint16(Imc(i,comp(k,2))) * 128 ./ uint16(Im1)); % Valeurs relatives par rapport à 1ère composante (identique = 128)
   colOK = colOK & (ImRel2 >= cpmin(k,2));
   colOK = colOK & (ImRel2 <= cpmax(k,2));
   % 3. Détection pour la troisième composante
   ImRel3 = uint8(uint16(Imc(i,comp(k,3))) * 128 ./ uint16(Im1)); % Valeurs relatives par rapport à 1ère composante (identique = 128)
   colOK = colOK & (ImRel3 >= cpmin(k,3));
   colOK = colOK & (ImRel3 <= cpmax(k,3));
   % 4. Stockage des détectées
   detcol(i(colOK)) = colnum(k);
end
% % Affichage
% ImOut = Im;
% ImOutc = 255*ones(r, c); % pour a priori blanc où pas couleur
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
