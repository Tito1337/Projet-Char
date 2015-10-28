% Pour interpolation parabolique du maximum (ou du minimum):  di = 0.5*(X(imax-1)-X(imax+1)) / (X(imax-1)-2*X(imax)+X(imax+1))
% Sur l'image, examiner les points suivant X (détection de verticale) dans la zone (140:240,100:120)
% Détecter la position du minimum (ligne noire) dans chaque pixel où minimum
Bloc = double(Im(140:240, 100:120, 2));
Bloc = 240-10*[
   0 0 9 9 0 0 0 0 0
   0 0 7 9 2 0 0 0 0
   0 0 5 9 4 0 0 0 0
   0 0 3 9 6 0 0 0 0
   0 0 1 9 8 0 0 0 0
   0 0 0 8 9 1 0 0 0
   0 0 0 6 9 3 0 0 0
   0 0 0 4 9 5 0 0 0
   0 0 0 2 9 7 0 0 0
   0 0 0 0 9 9 0 0 0
   0 0 0 0 7 9 2 0 0
   0 0 0 0 5 9 4 0 0
   0 0 0 0 3 9 6 0 0
   0 0 0 0 1 9 8 0 0
   0 0 0 0 0 8 9 1 0
   0 0 0 0 0 6 9 3 0
   0 0 0 0 0 4 9 5 0
   0 0 0 0 0 2 9 7 0
   0 0 0 0 0 0 9 9 0
   ];
[r, c] = size(Bloc);
[rMin, cMin] = find(Bloc == min(Bloc,[],2)*ones(1, c));
while any(diff(rMin)==0) % Si sur une même rangée deux points (consécutifs) sont au minimum, ne considérer que le premier
   iM = find(diff(rMin)==0);
   rMin = rMin([1:iM(1) iM(1)+2:end]);
   cMin = cMin([1:iM(1) iM(1)+2:end]);
end
di =[];
for k = 1:length(rMin)
   di(k,1) = 0.5*(Bloc(rMin(k),cMin(k)-1)-Bloc(rMin(k),cMin(k)+1)) ./ (Bloc(rMin(k),cMin(k)-1)-2*Bloc(rMin(k),cMin(k))+Bloc(rMin(k),cMin(k)+1)); % Interpolation de position du minimum par rapport au centre du pixel
end
% Dessin des points de ligne
figure
subplot(121)
im = uint8(Bloc);
im(:,:,2) = im;
im(:,:,3) = im(:,:,1);
image(im)
hold on
plot(cMin+di, rMin, '.R')
set(gca, 'dataaspectratio',  [1 1 1])
hold off

% Avec gamma
gamma = 1/3.4;
BlocG = (Bloc/255).^gamma*255;
[rMin, cMin] = find(BlocG == min(BlocG,[],2)*ones(1, c));
while any(diff(rMin)==0) % Si sur une même rangée deux points (consécutifs) sont au minimum, ne considérer que le premier
   iM = find(diff(rMin)==0);
   rMin = rMin([1:iM(1) iM(1)+2:end]);
   cMin = cMin([1:iM(1) iM(1)+2:end]);
end
di =[];
for k = 1:length(rMin)
   di(k,1) = 0.5*(BlocG(rMin(k),cMin(k)-1)-BlocG(rMin(k),cMin(k)+1)) ./ (BlocG(rMin(k),cMin(k)-1)-2*BlocG(rMin(k),cMin(k))+BlocG(rMin(k),cMin(k)+1)); % Interpolation de position du minimum par rapport au centre du pixel
end
% Dessin des points de ligne
subplot(122)
im = uint8(BlocG);
im(:,:,2) = im;
im(:,:,3) = im(:,:,1);
image(im)
hold on
plot(cMin+di, rMin, 'B', cMin+di, rMin, '.B')
set(gca, 'dataaspectratio',  [1 1 1])
hold off
title('Avec gamma')