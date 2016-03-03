//#define STOP_BUTTON 8

void setup() {
  //Serial.setTimeout(5000);
  //pinMode(STOP_BUTTON, INPUT);
  Communications_setup();
  Moteurs_setup();

  doMove(42.0, 42.0, 200);
}

void loop() {
    //while(digitalRead(STOP_BUTTON) == LOW){
    Moteurs_loop();
  //}
}
