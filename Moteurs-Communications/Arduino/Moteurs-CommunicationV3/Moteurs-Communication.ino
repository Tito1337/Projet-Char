void setup() {
  Communications_setup();
  Moteurs_setup();

  doMove(20.0, 15.0, 30); // 2 distances en cm et la vitesse de 0-255
}

void loop() {
  Moteurs_loop();
}
