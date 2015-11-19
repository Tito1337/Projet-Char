% Détection de lignes dans une image
%------------------------------------
% Une ligne se distingue par un maximum local dans une zone à fortes variations
% On utilise diff soit en vertical, soit en horizontal.

[hommatall, ABC, sens, cam] = camera2013;
hgca=get(gca, 'Children');
image2objet
Im = get(hgca(2), 'CData');
detectline(Im)

% Pour interpolation parabolique du maximum (ou du minimum):  di = 0.5*(X(imax-1)-X(imax+1)) / (X(imax-1)-2*X(imax)+X(imax+1))
% Sur l'image, examiner les points suivant X (détection de verticale) dans la zone (140:240,100:120)
% Détecter la position du minimum (ligne noire) dans chaque pixel où minimum
Bloc = double(Im(140:240, 100:120, 2));
interparab(Bloc, ha(strmatch('verticale', type)), [100, 140]);
