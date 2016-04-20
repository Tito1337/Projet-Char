#include <EEPROM.h>

void setup() {
  Communications_setup();
  Moteurs_setup();

  doMove(100/*Left*/, 30/*Right*/, 30); // 2 distances en cm et la vitesse de 0-255 ATTENTION? IL FAUT CHANGER LE RATIO DE DISTANCE POUR LES NOUVELLES CHENILLES
}

void loop() {
  Moteurs_loop();
}
