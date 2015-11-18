function interparab(Bloc, ha)
% Pour interpolation parabolique du maximum (ou du minimum):  di = 0.5*(X(imax-1)-X(imax+1)) / (X(imax-1)-2*X(imax)+X(imax+1))
% Sur l'image, examiner les points suivant X (d�tection de verticale) dans la zone (140:240,100:120)
% D�tecter la position du minimum (ligne noire) dans chaque pixel o� minimum
% IN:  Bloc    Bloc d'image (matrice)
%      ha      Handle de axes, si fourni, pour dessin, alors fournir �galement rc
%      rcoffs  Row, column  d'offset pour ligne sur image existante
Bloc = double(Im(140:240, 100:120, 2));
[r, c] = size(Bloc);
[rMin, cMin] = find(Bloc == min(Bloc,[],2)*ones(1, c));
while any(diff(rMin)==0) % Si sur une m�me rang�e deux points (cons�cutifs) sont au minimum, ne consid�rer que le premier
   iM = find(diff(rMin)==0);
   rMin = rMin([1:iM(1) iM(1)+2:end]);
   cMin = cMin([1:iM(1) iM(1)+2:end]);
end
di =[];
for k = 1:length(rMin)
   di(k,1) = 0.5*(Bloc(rMin(k),cMin(k)-1)-Bloc(rMin(k),cMin(k)+1)) ./ (Bloc(rMin(k),cMin(k)-1)-2*Bloc(rMin(k),cMin(k))+Bloc(rMin(k),cMin(k)+1)); % Interpolation de position du minimum par rapport au centre du pixel
end
if nargin>1
   % Dessin des points de ligne
   axes(ha(strmatch('verticale', type)))
   hold on
   plot(rcoffs(2)-1+cMin+di, rcoffs(1)-1+rMin, '.Y')
   hold off
end