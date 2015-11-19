[x, y, z] = sphere(20);
A=10; zPR = [z(1:11, :)-A/2+1; z(11:end, :)+A/2-1];
xPR1 = x+(A-1)*sign(x);
yPR1 = y+(A-1)*sign(y);
zPR1 = z+(A-1)*sign(z);
hs = surface(xPR1, yPR1, zPR1, 'FaceColor', [0, 0, 0.5], 'EdgeColor', 'none');
light('Position', [1 0 0], 'Style', 'infinite')
light('Position', [1 1 1], 'Style', 'infinite')
set(gca, 'DataAspectRatio', [1 1 1])
set(gca, 'Projection', 'perspective')
set(gca, 'Xlim', [-200 200], 'Ylim', [-200 200], 'Zlim', [-200 200])
view(119, 14)
for phid = 0:5:360;
   phi = phid*pi/180;
   Dx  = 4;
   Dy  = 10;
   Dz  = 1;
   M=-1;
   Azx = 0;
   Azy = 5;
   Azw = 0;
   X0  = 10;
   Y0  = 0;
   D   =   [M*Dx*cos(phi) -M*Dy*sin(phi)   0        X0
      Dx*sin(phi)    Dy*cos(phi)     0        Y0
      Azx            Azy             M*Dz     Azw
      0              0               0        1   ];
   [r,c] = size(xPR1);
   matXYZW=[reshape(xPR1,1,r*c); reshape(yPR1,1,r*c); reshape(zPR1,1,r*c); ones(1,r*c)];
   T = D * matXYZW;
   EndX = reshape(T(1,:), r, c);
   EndY = reshape(T(2,:), r, c);
   EndZ = reshape(T(3,:), r, c);
   set(hs, 'Xdata', EndX, 'Ydata', EndY, 'Zdata', EndZ)
   pause(0.1)
end