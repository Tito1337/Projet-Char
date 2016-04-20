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
#define CM_TO_COUNT_RATIO 0.44 // Nombre de centimètres par compte des roues codeuses
#define FORWARD 1
#define BACKWARD 0
#define SPEEDSOUND 340 // Vitesse du son en m/s
// Variables globales
long comptL = 0;
long comptR = 0;
bool lastComptL = LOW;
bool lastComptR = LOW;
long comptTargetL = 0;
long comptTargetR = 0;

int directionL = FORWARD;
int directionR = FORWARD;
int speedL;
int speedR ;


float distUS;

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

}

// Moteurs_loop doit être appelé dans le loop() de l'Arduino pour gérer le module moteurs
void Moteurs_loop() {
  roueCodeuse();
  motorManagement();
  ultrasons();
}

// regulateMotors se charge de réguler la vitesse des moteurs pour atteindre l'objectif de distance fixé
void motorManagement() {
  DEBUG_PRINT("LEFT : ");
  DEBUG_PRINT(comptL);
  DEBUG_PRINT(" / ");
  DEBUG_PRINT(comptTargetL);
  DEBUG_PRINT(" @ ");
  DEBUG_PRINTLN(speedL);
  if (distUS > 15){
  
  //analogWrite(PIN_PWM_L, speedMotorManagementL);
  
  
  if(comptTargetL > comptL) {
    if(directionL == FORWARD) {
      digitalWrite(PIN_DIR_L1, 1);
       analogWrite(PIN_PWM_L, speedL);
    } else {
      digitalWrite(PIN_DIR_L1, 0);
      analogWrite(PIN_PWM_L, speedL);     
    }
    } else {
      analogWrite(PIN_PWM_L, 0);
      Serial.println("distance atteinte L ");
  }
 

  DEBUG_PRINT("RIGHT : ");
  DEBUG_PRINT(comptR);
  DEBUG_PRINT(" / ");
  DEBUG_PRINT(comptTargetR);
  DEBUG_PRINT(" @ ");
  DEBUG_PRINTLN(speedR);
  
  //analogWrite(PIN_PWM_R, speedMotorManagementR);
  if(comptTargetR > comptR) {
    if(directionR == FORWARD) {
      analogWrite(PIN_PWM_R, speedR);
      digitalWrite(PIN_DIR_R1, 1);
    } else {
      digitalWrite(PIN_DIR_R1, 0);
      analogWrite(PIN_PWM_R, speedR);    
    }
  } else {
     analogWrite(PIN_PWM_R, 0);
     Serial.println("distance atteinte R ");      
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
    comptL += 1;
    lastComptL = !lastComptL;
    Serial.println("je compte le gauche");
  }

  if (digitalRead(PIN_COUNTER_R) != lastComptR) {
    comptR += 1;
    lastComptR = !lastComptR;
    Serial.println("je compte le droit");
  }
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
  Serial.print("la vitesse du debug est de ");
  Serial.println(speedL);
}
//Fonction calculant la distance entre un objet et le robot pour ainsi arrêter le robot en urgence avant la percution. 
void ultrasons()
{
  digitalWrite(PIN_ULTRASONS_TRIG, HIGH);
  
  // délais de 10 µs
  delayMicroseconds (10); 
  digitalWrite(PIN_ULTRASONS_TRIG, LOW);
  
  // Calcul de la durée de l'état haut sur la broche ECHO
  unsigned long duration = pulseIn(PIN_ULTRASONS_ECHO, HIGH); 

  //Calcul de la distance
  duration = duration/2;
  float temps = duration/10000.0; 
  distUS = temps*SPEEDSOUND; //en cm
  Serial.print("DistanceUltrasons = ");
  Serial.println(distUS); //affiche la distance mesurée (en mètres)
  delay(250);
}