#include <EEPROM.h>

void setup() {
  Communications_setup();
  Moteurs_setup();

  //doMove2(19/*Left*/, 19/*Right*/, 30); // 2 distances en cm et la vitesse de 0-255 ATTENTION? IL FAUT CHANGER LE RATIO DE DISTANCE POUR LES NOUVELLES CHENILLES
  doMove(0,52);
  //shoot();
}

void loop() {
  Moteurs_loop();
}
