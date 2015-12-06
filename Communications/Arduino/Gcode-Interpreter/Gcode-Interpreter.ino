#include <Wire.h>

// Variables globales
char rpiBuffer[128];
int sofar;

// Définition de fonctions
float parseNumber(char, float);
void processCommand();
void doMove(float, float, float);
void getPosition(bool, bool);
void getSensors(bool, bool, bool, bool);

void setup() {
  Serial.begin(9600);
  while (!Serial);
  Serial.println("Started");
  Wire.begin(8);                // join i2c bus with address #8
  Wire.onRequest(wireSend);
  Wire.onReceive(wireReceive);
}

void loop() {
}

float parseNumber(char code,float fallback) {
  char *ptr=rpiBuffer;
  while(ptr && *ptr && ptr<rpiBuffer+sofar) {
    if(*ptr==code) {
      return atof(ptr+1);
    }
    ptr=strchr(ptr,' ')+1;
  }
  return fallback;
}

bool parsePresent(char code) {
  char *ptr=rpiBuffer;
  while(ptr && *ptr && ptr<rpiBuffer+sofar) {
    if(*ptr==code) {
      return 1;
    }
    ptr=strchr(ptr,' ')+1;
  }
  return 0;
}

void processCommand() {
  long cmd;
  
  // Commandes F
  cmd = parseNumber('F',-1);
  switch(cmd) {
    case  1: { // F1 : se déplacer
      // Ex : F1 R999999.99 L999999.99 S999
      doMove(parseNumber('R', 0), parseNumber('L', 0), parseNumber('S', 0));
      break;
      }
    default:  break;
  }

  // Commandes Q
  cmd = parseNumber('Q',-1);
  switch(cmd) {
    case 1: { // Q1 : Demande de position
      getPosition(parsePresent('R'), parsePresent('L'));
      break;
    }
    case 2: { // Q2 : Demande d'information des capteurs
      getSensors(parsePresent('A'), parsePresent('B'), parsePresent('C'), parsePresent('D'));
      break;
    }
    default:  break;
  }
}

void doMove(float right, float left, float speed) {
  Serial.print("I will move right=");
  Serial.print(right);
  Serial.print(", left=");
  Serial.print(left);
  Serial.print(", speed=");
  Serial.println(speed);
}

void getPosition(bool R, bool L) {
  Serial.print("You asked for position ");
  if(R) Serial.print("right ");
  if(L) Serial.print("left ");
  Serial.println();
}

void getSensors(bool A, bool B, bool C, bool D) {
  Serial.print("You asked for sensor ");
  if(A) Serial.print("A ");
  if(B) Serial.print("B ");
  if(C) Serial.print("C ");
  if(D) Serial.print("D ");
  Serial.println();
  Wire.write("Q2 A1 B2 C3 D4");
}

void wireReceive(int howMany) {
  Serial.println("Wire receive...");
  char c;
  if(Wire.available() > 0) {
    while(Wire.available() > 0) {
      c = Wire.read();
      Serial.print(c);
      if(sofar<127) rpiBuffer[sofar++] = c;
      if(c=='\n') {
        rpiBuffer[sofar]=0;
        Serial.print("Received : ");
        Serial.print(rpiBuffer);
        processCommand();
        sofar = 0;
      }
    }
  }
}

void wireSend() {
  Serial.println("Wire send...");
  Wire.write("Coucou!");
}
