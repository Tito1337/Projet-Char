#include <EEPROM.h>

void setup() {
  Communications_setup();
  Moteurs_setup();

  
  doMove(212,0); //54 cm = un tour, la première variable envois une distance linéraire à parcourir, et la deuxième un angle.
}

void loop() {
    Moteurs_loop();
}
