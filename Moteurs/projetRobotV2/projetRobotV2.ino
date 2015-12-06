//PID asservissement
#include <PID_v1.h>
#define PIN_INPUT 0
#define PIN_OUTPUT 3
double Setpoint, Input, Output;
double Kp=2, Ki=0, Kd=0;
PID myPID(&Input, &Output, &Setpoint, Kp, Ki, Kd, DIRECT);

// Motors
int DIR1 = 8;
int PWM1 = 9; //Les PWM règlent la vitesse des moteurs
int DIR2 = 10;
int PWM2 = 11;

//Roue codeuse
int R1 = 2; //pour la pin
int compt1 [200] ={0}; // compter la totalité
unsigned int compt1_0 = 0; //compter le nombre de 0
unsigned int compt1_1 = 0; //compter le nombre de 1 de roue codeuse 1
 
//variable de vitesse
int vit; // entre 0 et 256 (0 étant la vitesse maximale, et 180 la vitesse minimale)

//choix direction
char direct ;
#define forward 'f'
#define backward 'b'
#define left  'l'
#define right 'r'
#define stopp 's'

void setup() {
  Serial.begin(9600);
  pinMode(DIR1,OUTPUT);
  pinMode(PWM1,OUTPUT);
  pinMode(DIR2,OUTPUT);
  pinMode(PWM2,OUTPUT);
  pinMode(R1, INPUT);
  //digitalWrite(R1, LOW);
  Serial.println("vitesse= ");
  Serial.println(vit);
  Serial.println("direction");
  direct = forward;
  Serial.print(direct);
  vit = 50;
  delay(100);
}

void loop() {
 Serial.println("je suis dans le loop");
 Serial.println(vit);
 Serial.println(direct);
 motorManagement (vit, direct);
 roueCodeuse ();
 if (compt1_1 > 200) {
  vit = 255;
  direct = stopp;
 }
}


void motorManagement ( int vitesse, char direct){
  switch (direct){
    case forward: // forward      
      digitalWrite(DIR1, 1);
      digitalWrite(DIR2, 1);
      analogWrite(PWM1, vitesse);
      analogWrite(PWM2, vitesse);
      break;
      
    case left: // left
      Serial.print("vitesse= ");
      Serial.print(vitesse);
      Serial.print("direction= left");
      
      digitalWrite(DIR1, 1);
      digitalWrite(DIR2, 0);
      analogWrite(PWM1, vitesse);
      analogWrite(PWM2, vitesse);
      break;
      
    case right: // right
      Serial.print("vitesse= ");
      Serial.print(vitesse);
      Serial.print("direction= right ");
      
      digitalWrite(DIR1, 0);
      digitalWrite(DIR2, 1);
      analogWrite(PWM1, vitesse);
      analogWrite(PWM2, vitesse);
      break;
      
    case backward: // backward
      Serial.print("vitesse= ");
      Serial.print(vitesse);
      Serial.print("direction= backward");
      Serial.print(direct);
      
      digitalWrite(DIR1, 0);
      digitalWrite(DIR2, 0);
      analogWrite(PWM1, vitesse);
      analogWrite(PWM2, vitesse);
      break;
      
    default: // stop if default
      Serial.print("vitesse= ");
      Serial.print(vitesse);
      Serial.print("direction= Stop");

      analogWrite(PWM1, vitesse);
      analogWrite(PWM2, vitesse);
      break;
  }
}
void roueCodeuse (){
     Serial.println("je suis dans roue codeuse");
      if (digitalRead(R1) == HIGH && compt1[-1]!= 1 ) 
      {
        compt1_1 = compt1_1 + 1;
        compt1 [-1] = 1;
        Serial.println("valeur roue = ");
        Serial.println(compt1_1);      
      }
      if (digitalRead(R1) == LOW && compt1[-1] != 0)
      {
        compt1_0 = compt1_0 + 1;
        compt1 [-1] = 0;
        Serial.println("valeur roue = ");
        Serial.println(compt1_0);
      }
}

