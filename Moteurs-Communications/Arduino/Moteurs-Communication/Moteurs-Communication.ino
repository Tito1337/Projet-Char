void setup() {
  Communications_setup();
  Moteurs_setup();

  doMove(100.0, 100.0, 75);
}

void loop() {
  Moteurs_loop();
}
