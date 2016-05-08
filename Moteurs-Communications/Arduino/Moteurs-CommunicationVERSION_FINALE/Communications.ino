// Configuration
#define BUFFER_SIZE 32
#define I2C_ADDRESS 8

// Debug
#define DEBUG
#ifdef DEBUG
 #define DEBUG_PRINT(x)  Serial.print (x)
 #define DEBUG_PRINTLN(x)  Serial.println (x)
#else
 #define DEBUG_PRINT(x)
#endif

#include <Wire.h>

// Variables globales
char buffer_receive[BUFFER_SIZE];
char buffer_send[BUFFER_SIZE];
int sofar;

void Communications_setup() {
  #ifdef DEBUG
    Serial.begin(9600);
    while (!Serial);
    Serial.println("Debug started");
  #endif
  
  Wire.begin(I2C_ADDRESS);
  Wire.onRequest(wireSendEvent);
  Wire.onReceive(wireReceiveEvent);
}

float parseNumber(char code,float fallback) {
  char *ptr=buffer_receive;
  while(ptr && *ptr && ptr<buffer_receive+sofar) {
    if(*ptr==code) {
      return atof(ptr+1);
    }
    ptr=strchr(ptr,' ')+1;
  }
  return fallback;
}

bool parsePresent(char code) {
  char *ptr=buffer_receive;
  while(ptr && *ptr && ptr<buffer_receive+sofar) {
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
      //doMove(parseNumber('R', 0), parseNumber('L', 0), parseNumber('S', 0));
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

void getPosition(bool R, bool L) {
  DEBUG_PRINT("You asked for position ");
  if(R) DEBUG_PRINT("right ");
  if(L) DEBUG_PRINT("left ");
  DEBUG_PRINTLN();

  wireSend("Q1 R42 L42");
}

void getSensors(bool A, bool B, bool C, bool D) {
  DEBUG_PRINT("You asked for sensors ");
  if(A) DEBUG_PRINT("A ");
  if(B) DEBUG_PRINT("B ");
  if(C) DEBUG_PRINT("C ");
  if(D) DEBUG_PRINT("D ");
  DEBUG_PRINTLN();
  
  wireSend("Q2 A1 C3");
}

void wireReceiveEvent(int howMany) {
  DEBUG_PRINT("Receiving on I2C : ");
  char c;
  if(Wire.available() > 0) {
    while(Wire.available() > 0) {
      c = Wire.read();
      if(sofar<127) buffer_receive[sofar++] = c;
      if(c=='\n') {
        buffer_receive[sofar]=0;
        DEBUG_PRINTLN(buffer_receive);
        processCommand();
        sofar = 0;
      }
    }
  }
}

void wireSend(char* str) {
  strncpy(buffer_send, str, 32);
  strncat(buffer_send, "\n", 32);
}

void wireSendEvent() {
  Wire.write(buffer_send);
}
