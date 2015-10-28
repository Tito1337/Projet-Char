function ha = detectline(Im)
% Détection de lignes dans une image
%------------------------------------
% F. Gueuning, 2013   Unité Electronique et informatique         ECAM, Bruxelles
%
% IN:  Im  Image telle que chargée par imread
% Une ligne se distingue par un minimum local dans une zone à fortes variations
% On utilise diff soit en vertical, soit en horizontal.

DiffX = diff(Im(:,:,2), 1, 2);
DiffY = diff(Im(:,:,2));
SDiffX = abs(DiffX(:,1:end-1)) + abs(DiffX(:,2:end));
SDiffY = abs(DiffY(1:end-1,:)) + abs(DiffY(2:end,:));
SDiff_{1} = Im(:,:,2); % Sera pour diff suivant X, donc pour détection des lignes verticales
SDiff_{1}(:,2:end-1) = SDiffX;
SDiff_{2} = Im(:,:,2); % Sera pour diff suivant Y, donc pour détection des lignes verticales
SDiff_{2}(2:end-1,:) = SDiffY;

th = 15;
type = {'verticale' 'horizontale'};
type2 = {'X' 'Y'};
for k=1:length(SDiff_)
   SDiff = SDiff_{k}>th;
   disp([num2str(length(find(SDiff))) ' pixels où ligne ' type{k} ' possible (détection suivant coordonnée ' type2{k} ')'])
   % Elargir dans chaque direction la zone des pixels d'intérêt (où ligne)
   SDiff = SDiff | circshift(SDiff, 1) | circshift(SDiff, -1) | circshift(SDiff, -2) | circshift(SDiff, -3);
   SDiff = ~(SDiff | circshift(SDiff, [0 1]) | circshift(SDiff, [0 -1]) | circshift(SDiff, [0 -2]) | circshift(SDiff, [0 -3]));
   Im3 = Im;
   Im2 = Im(:,:,1);
   Im2(SDiff) = 0;
   Im3(:,:,1) = Im2;
   Im2 = Im(:,:,2);
   Im2(SDiff) = 0;
   Im3(:,:,2) = Im2;
   Im2 = Im(:,:,3);
   Im2(SDiff) = 0;
   Im3(:,:,3) = Im2;
   figure, image(Im3)
   set(gca,'dataaspectratio', [1 1 1])
   ha(k) = gca;
end
