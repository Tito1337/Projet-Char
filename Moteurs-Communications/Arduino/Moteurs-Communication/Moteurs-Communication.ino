void setup() {
  Communications_setup();
  Moteurs_setup();

  doMove(60.0, 100.0, 255);
}

void loop() {
  Moteurs_loop();
}
