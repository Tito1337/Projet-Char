// Librairie PID d'arduino
#include <PID_v1.h>
#include <Time.h>
// Premier test de PID sur la vitesse du moteur de droite
// PID myPID(&Input, &Output, &Setpoint, Kp, Ki, Kd, DIRECT);
// Set point sera p/ex int speedR
// Input la vitesse de rotation de la roue
// Output la valeur de PWM
// Définition des pins Arduino
//Define Variables we'll be connecting to
double Setpoint, Input, Output;

//Specify the links and initial tuning parameters
PID myPID(&Input, &Output, &Setpoint,2,5,1, DIRECT);

#define PIN_DIR_L1 4 // Sélecteur de direction 1 du moteur L
#define PIN_DIR_L2 5 // Sélecteur de direction 2 du moteur L
#define PIN_PWM_L 10 // PWM pour régler la vitesse du moteur L
#define PIN_DIR_R1 6 // Sélecteur de direction 1 du moteur R
#define PIN_DIR_R2 7 // Sélecteur de direction 2 du moteur R
#define PIN_PWM_R 11 // PWM pour régler la vitesse du moteur R
#define PIN_COUNTER_L 2 // Roue codeuse du moteur L
#define PIN_COUNTER_R 3 // Roue codeuse du moteur R

// Autres constantes
#define CM_TO_COUNT_RATIO 0.44 // Nombre de centimètres par compte des roues codeuses
#define FORWARD 1
#define BACKWARD 0

// Variables globales
long comptL = 0;
long comptR = 0;
bool lastComptL = LOW;
bool lastComptR = LOW;
long comptTargetL = 0;
long comptTargetR = 0;
long CM_R = 0;
long CM_L = 0;

int directionL = FORWARD;
int directionR = FORWARD;
int speedL = 255;
int speedR = 255;

// Moteurs_setup doit être appelé dans le setup() de l'Arduino pour configurer le module moteurs
void Moteurs_setup() {
  pinMode(PIN_DIR_L1, OUTPUT);
  pinMode(PIN_DIR_L2, OUTPUT);
  pinMode(PIN_PWM_L, OUTPUT);
  
  pinMode(PIN_DIR_R1, OUTPUT);
  pinMode(PIN_DIR_R2, OUTPUT);
  pinMode(PIN_PWM_R, OUTPUT);
  
  pinMode(PIN_COUNTER_L, INPUT);
  pinMode(PIN_COUNTER_R, INPUT);
  ///////////////////////////////////////////////////////////////////////
  // Ajout setup PID
  // En input, 
  Input = CM_R;
  Setpoint = 42;
  //turn the PID on
  myPID.SetMode(AUTOMATIC);
}

// Moteurs_loop doit être appelé dans le loop() de l'Arduino pour gérer le module moteurs
void Moteurs_loop() {
  roueCodeuse();
  motorManagement();
  ///////////////////////////////////////////////////////////////////////
  //Input = CM_R;
  //myPID.Compute();
  //analogWrite(PIN_PWM_R,Output);
}

// regulateMotors se charge de réguler la vitesse des moteurs pour atteindre l'objectif de distance fixé
void motorManagement() {
  // Ajout débug pour voir le temps que ça prend
  DEBUG_PRINT("  ");
  DEBUG_PRINT(minute());
  DEBUG_PRINT(" min ");
  DEBUG_PRINT(second());
  DEBUG_PRINT(" sec \n");
  //
  DEBUG_PRINT("LEFT : ");
  DEBUG_PRINT(comptL);
  DEBUG_PRINT(" / ");
  DEBUG_PRINT(comptTargetL);
  DEBUG_PRINT(" @ ");
  DEBUG_PRINTLN(speedL);
  
  analogWrite(PIN_PWM_L, speedL);
  if(comptTargetL > comptL) {
    if(directionL == FORWARD) {
      digitalWrite(PIN_DIR_L1, 1);
      digitalWrite(PIN_DIR_L2, 0);
    } else {
      digitalWrite(PIN_DIR_L1, 0);
      digitalWrite(PIN_DIR_L2, 1);      
    }
  } else {
      digitalWrite(PIN_DIR_L1, 0);
      digitalWrite(PIN_DIR_L2, 0);
  }

  DEBUG_PRINT("RIGHT : ");
  DEBUG_PRINT(comptR);
  DEBUG_PRINT(" / ");
  DEBUG_PRINT(comptTargetR);
  DEBUG_PRINT(" @ ");
  DEBUG_PRINTLN(speedR);
  
  analogWrite(PIN_PWM_R, speedR);
  if(comptTargetR > comptR) {
    if(directionR == FORWARD) {
      digitalWrite(PIN_DIR_R1, 1);
      digitalWrite(PIN_DIR_R2, 0);
    } else {
      digitalWrite(PIN_DIR_R1, 0);
      digitalWrite(PIN_DIR_R2, 1);      
    }
  } else {
      digitalWrite(PIN_DIR_R1, 0);
      digitalWrite(PIN_DIR_R2, 0);      
  }
}

// updateCodingWheels met à jour comptL et comptR si les roues codeuses respectives ont tourné
void roueCodeuse() {
  // Compter uniquement si la mesure est différente de la dernière
  if (digitalRead(PIN_COUNTER_L) != lastComptL) {
    comptL += 1;
    lastComptL = !lastComptL;
    // On incrémente aussi la distance en centimètres
    CM_L = comptL*CM_TO_COUNT_RATIO;
  }

  if (digitalRead(PIN_COUNTER_R) != lastComptR) {
    comptR += 1;
    lastComptR = !lastComptR;
    CM_R = comptR*CM_TO_COUNT_RATIO;
  }
//////////////////////////////////////////////////////
// Parametre pid, l'input en cm
  Input = CM_R;
  myPID.Compute();
  analogWrite(PIN_PWM_R,Output);
}

// Fonction recevant l'ordre de se déplacer. right et left en cm (positif = en avant, négatif = en arrière). speed en pourcents (0 à 100)
void doMove(float right, float left, float speed) {
  float absRight = abs(right);
  float absLeft = abs(left);
  
  // On ajoute le nombre de count des roues codeuses au target
  comptTargetR += absRight/CM_TO_COUNT_RATIO;
  comptTargetL += absLeft/CM_TO_COUNT_RATIO;

  // On chosit la bonne direction pour chaque roue
  if(right<0) {
    directionR = BACKWARD;
  } else {
    directionR = FORWARD;
  }
  if(left<0) {
    directionL = BACKWARD;
  } else {
    directionL = FORWARD;
  }
 
  // Adaptation basique de la vitesse 
  if(absRight>absLeft) {
    speedR = 2.55*speed;
    speedL = 2.55*speed/(absRight/absLeft);
  } else {
    speedL = 2.55*speed;
    speedR = 2.55*speed/(absLeft/absRight);
  }
}

