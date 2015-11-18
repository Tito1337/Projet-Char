function image2objetupdate(src,eventdata)
UD = get(src, 'UserData');
cr = get(UD.ha1, 'CurrentPoint');
cr = cr(1, 1:3);
objro = pix2objro(cr(2), cr(1), UD.hommatall, UD.ABC, UD.H, UD.sens);
set(UD.htit, 'String', ['Pixel  ' num2str(round(cr(1))) ', ' num2str(round(cr(2))) ',    Position (en mm)  ' num2str(round(objro.x)) ', ' num2str(round(objro.y)) ', ' num2str(round(objro.z))]);
UD2 = get(UD.ha2, 'Userdata');
tar = struct;
tar.im.ir = cr(2);
tar.im.ic = cr(1);
tar.ro.x = objro.x;
tar.ro.y = objro.y;
tar.z = objro.z;
XY = tar.ro.x + j*tar.ro.y;
tar.ro.r = abs(XY);
tar.ro.az = angle(XY)*180/pi;
tarroxy = tar.ro.x + j*tar.ro.y;
plo = UD2.roxy + [tar.ro.x j*tar.ro.y; tarroxy+[0 0]]*exp(j*UD2.rob.az*pi/180);
set(UD2.tar.h.TraitPt(1), 'Xdata', real(plo(:,1)), 'Ydata', imag(plo(:,1))),
set(UD2.tar.h.TraitPt(2), 'Xdata', real(plo(:,2)), 'Ydata', imag(plo(:,2))),
plo = UD2.roxy + tarroxy*[1 1]*exp(j*UD2.rob.az*pi/180);
set(UD2.tar.h.TraitVertic, 'Xdata', real(plo), 'Ydata', imag(plo), 'Zdata', [0 tar.z]);
set(UD2.tar.h.TextX, 'String', ['tar.ro.x = ' num2str(tar.ro.x)]);
set(UD2.tar.h.TextY, 'String', ['tar.ro.y = ' num2str(tar.ro.y)]);
set(UD2.tar.h.TextZ, 'String', ['tar.z = ' num2str(tar.z)]);
set(UD2.tar.h.TextR, 'String', ['tar.ro.r = ' num2str(tar.ro.r)]);
set(UD2.tar.h.TextAz, 'String', ['tar.ro.az = ' num2str(tar.ro.az)]);
