#include <EEPROM.h>
int i;
void setup() {
  Communications_setup();
  Moteurs_setup();

  
  doMove(212,0); //54 cm = un tour, la première variable envois une distance linéraire à parcourir, et la deuxième un angle.
}

void loop() {
  i = 0;
  doMove(212,0);
  while ( i < 30)
  {
    Moteurs_loop();
    i++;
    Serial.print("i=");
    Serial.println(i);
  }
}