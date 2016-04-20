#include <PID_v1.h>
#include <Time.h>
// PID myPID(&Input, &Output, &Setpoint, Kp, Ki, Kd, DIRECT);
// Set point sera un distance à atteindre, la consigne.
// Input la distance à laquelle on se trouve
// Output la valeur de PWM


// Définition des pins Arduino
#define PIN_DIR_L1 4 // Sélecteur de direction 1 du moteur L
#define PIN_PWM_L 10 // PWM pour régler la vitesse du moteur L
#define PIN_DIR_R1 6 // Sélecteur de direction 1 du moteur R
#define PIN_PWM_R 11 // PWM pour régler la vitesse du moteur R
#define PIN_COUNTER_L 2 // Roue codeuse du moteur L
#define PIN_COUNTER_R 3 // Roue codeuse du moteur R
#define PIN_ULTRASONS_TRIG 8 // Capteur ultrasons 
#define PIN_ULTRASONS_ECHO 9 // Capteur ultrasons 

// Autres constantes
#define CM_TO_COUNT_RATIO 0.1 // Nombre de centimètres par compte des roues codeuses
#define SPEEDSOUND 340 // Vitesse du son en m/s
#define FORWARD 1
#define BACKWARD 0

// Variables globales
//Roue codeuse
long comptL = 0;
long comptR = 0;
bool lastComptL = LOW;
bool lastComptR = LOW;
long comptTargetL = 0;
long comptTargetR = 0;
//Moteurs
int directionL = FORWARD;
int directionR = FORWARD;
int speedL;
int speedR;
//Ultra-sons
float distUS;
//PID
double SetpointLin, InputLin, OutputLin,SetpointAng, InputAng, OutputAng;
double OutputR,OutputL;
//Specify the links and initial tuning parameters
PID PIDlineaire(&InputLin, &OutputLin, &SetpointLin,2,5,0, DIRECT);
PID PIDangulaire(&InputAng, &OutputAng, &SetpointAng,2,1,0, DIRECT);


// Moteurs_setup doit être appelé dans le setup() de l'Arduino pour configurer le module moteurs
void Moteurs_setup() {
  pinMode(PIN_DIR_L1, OUTPUT);
  pinMode(PIN_PWM_L, OUTPUT);
  
  pinMode(PIN_DIR_R1, OUTPUT);
  pinMode(PIN_PWM_R, OUTPUT);
  
  pinMode(PIN_COUNTER_L, INPUT);
  pinMode(PIN_COUNTER_R, INPUT);

  pinMode(PIN_ULTRASONS_TRIG,OUTPUT);
  pinMode(PIN_ULTRASONS_ECHO, INPUT);

  PIDlineaire.SetMode(AUTOMATIC); //turn on the PID 
  PIDangulaire.SetMode(AUTOMATIC);
  InputLin=0;
  //Gestion des interruptions.Dans l'arduino UNO il existe deux pins dédiées à l'intérruption la 2 et la 3
  attachInterrupt(0, roueCodeuse, CHANGE); // le 0 correspond à la pin 2
  attachInterrupt(1, roueCodeuse, CHANGE); //le 1 correspond à la pin 3
  SetpointAng = 500; 
}

// Moteurs_loop doit être appelé dans le loop() de l'Arduino pour gérer le module moteurs
void Moteurs_loop() {
  motorManagement();
  ultrasons();
  Serial.print("SetpointLin----");
  Serial.println(SetpointLin);
  Serial.print("SetpointAng----");
  Serial.println(SetpointAng);
  Serial.print("outputLin----");
  Serial.println(OutputLin);
  Serial.print("outputAng----");
  Serial.println(OutputAng);
  Serial.print("InputLin----");
  Serial.println(InputLin);
  Serial.print("InputAng----");
  Serial.println(InputAng);
}

// regulateMotors se charge de réguler la vitesse des moteurs pour atteindre l'objectif de distance fixé
void motorManagement() {
  DEBUG_PRINT("LEFT : ");
  DEBUG_PRINT(comptL);
  DEBUG_PRINT(" / ");
  DEBUG_PRINT(comptTargetL);
  DEBUG_PRINT(" @ ");
  DEBUG_PRINTLN(OutputL);


  DEBUG_PRINT("RIGHT : ");
  DEBUG_PRINT(comptR);
  DEBUG_PRINT(" / ");
  DEBUG_PRINT(comptTargetR);
  DEBUG_PRINT(" @ ");
  DEBUG_PRINTLN(OutputR);
  if (distUS > 15){
    if(directionL == FORWARD) {
      digitalWrite(PIN_DIR_L1, 1);
       analogWrite(PIN_PWM_L, OutputL);
    } else {
      digitalWrite(PIN_DIR_L1, 0);
      analogWrite(PIN_PWM_L, OutputL);     
    }

    if(directionR == FORWARD) {     
      analogWrite(PIN_PWM_R, OutputR);
      digitalWrite(PIN_DIR_R1, 1);
    } else {
      digitalWrite(PIN_DIR_R1, 0);
      analogWrite(PIN_PWM_R, OutputR);    
    }
  }
 else {
   Serial.println("La distance est moins de 15cm ");
   analogWrite(PIN_PWM_L, 0);
   analogWrite(PIN_PWM_R, 0);
  }
}

// updateCodingWheels met à jour comptL et comptR si les roues codeuses respectives ont tourné
void roueCodeuse() {
  // Compter uniquement si la mesure est différente de la dernière
  
  if (digitalRead(PIN_COUNTER_L) != lastComptL) {
    comptL++;
    lastComptL = !lastComptL;
  }

  if (digitalRead(PIN_COUNTER_R) != lastComptR) {
    comptR++;
    lastComptR = !lastComptR;
  }
  //Voir image du PID régulation dans la documentation
  InputLin=(comptR+comptL)/2;
  InputAng=(comptR-comptL);
  OutputR = OutputLin + OutputAng;
  OutputL = OutputLin - OutputAng;
  PIDangulaire.Compute();
  PIDlineaire.Compute();
}

// Fonction recevant l'ordre de se déplacer. right et left en cm (positif = en avant, négatif = en arrière). speed en pourcents (0 à 100)
void doMove(float left, float right, float speed) {
  float absRight = abs(right);
  float absLeft = abs(left);
  
  // On ajoute le nombre de count des roues codeuses au target
  comptTargetR += absRight/CM_TO_COUNT_RATIO;
  comptTargetL += absLeft/CM_TO_COUNT_RATIO;
  SetpointLin = comptTargetR;
  // On choisit la bonne direction pour chaque roue
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
  Serial.print("la vitesse du debug est de ");
  Serial.println(speedL);
}

//Fonction calculant la distance entre un objet et le robot pour ainsi arrêter le robot en urgence avant la percution. 
void ultrasons()
{
  digitalWrite(PIN_ULTRASONS_TRIG, HIGH);
  delayMicroseconds (10); 
  digitalWrite(PIN_ULTRASONS_TRIG, LOW);
  
  // Calcul de la durée de l'état haut sur la broche ECHO
  unsigned long duration = pulseIn(PIN_ULTRASONS_ECHO, HIGH); 

  //Calcul de la distance
  duration = duration/2;
  float temps = duration/10000.0; 
  distUS = temps*SPEEDSOUND; //en cm
  delay(250);
  Serial.print("distance ultrasons---- ");
  Serial.println(distUS);
}


