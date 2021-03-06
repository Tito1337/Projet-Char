% Camera - proc�dure d'�talonnage
%---------------------------------
%      Cam�ra sur Rasberry pi                            PC                
%  ������������������������������        ����������������������������������
%  Prend les images en continu    <---   Fournit nom de fichier contenant
%  Utilise zones pour d�terminer          zones et couleurs pour �talonnage (une zone par point)
%   centroides d'�talonnage              ______
%  Renvoie chaque fois im.ir      --->  |pix2yz| distances entre points
%                        .ic             ��T���  |   d'�talonnage (ref)
%                                        __V_____V_
%                                       |xfyz2objco|
%                                        �����T����positions xyz des points
%                                             V     dans le rep�re cam�ra
%                                        D�terminer position cam�ra dans le rep�re robot
%                                        D�terminer �quation du plan du terrain dans le rep�re cam�ra
%                                          |
%                                        __V__
%                                       |co2ro|
%                                        ��|��
%                                          V  coordonn�es des centroides dans le rep�re robot

im_ = rgbaread('col_detected', 3/2);
image(im_(:,:,1:3))
disp('Agrandir la figure puis cliquer sur les 4 centroides')
[im.ic, im.ir]=ginput(4) % --->  Remplacer ce choix manuel par les centroides fournis par la raspberry (picam.cpp)  <---
%              ______
[imyz, sens] = pix2yz(im, 'picam_384x256')
%              ������
D = 646; % diag (mm)
H = 646/sqrt(2);
L = H;
%       ul   ur   dr   dl
ref = [  0    L    D    H    % ul
         0    0    H    D    % ur
         0    0    0    L];  % dr
%       __________
objco = xfyz2objco(sens.F, imyz, ref);
%       ����������
figure,plot3(objco.x([1:end 1]), objco.y([1:end 1]), objco.z([1:end 1]))
set(gca,'dataAspectRatio',[1 1 1])


% Camera - Mesure de position d'objets
%--------------------------------------
%      Cam�ra sur Rasberry pi                            PC                
%  ������������������������������        ����������������������������������
%  Prend les images en continu    <---   Fournit nom de fichier contenant                               
%  Utilise zones pour d�terminer          zones et couleurs pour d�tection d'objets (une zone par objet)
%   centroides d'objets                  ______                                                         
%  Renvoie chaque fois im.ir      --->  |pix2yz| �quation du plan du terrain + hauteur de centroide  \
%                        .ic             ��T���  |                                                    |
%                                        __V_____V_                                                   | 
%                                       |xfyz2objco|                                                  |          _________
%                                        �����T����positions xyz des centroides                        >   <=>  |pix2objro|
%                                           __V__   dans le rep�re cam�ra                             |          ���������
%                                          |co2ro|                                                    |
%                                           ��|��                                                     |
%                                             V  coordonn�es des centroides dans le rep�re robot     /
