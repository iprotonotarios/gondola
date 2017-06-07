
#define NUM_ANCHORS 3
#define STEP_DELAY 90 //delay for stepper in microseconds (computer for 32 microsteps, using calculator https://www.allaboutcircuits.com/tools/stepper-motor-calculator/ and 42BYGHW811 Wantai stepper motor)
#define TOKENS ":, \n"
#define DEBUG 1
#define MIN_PRECISION 0.5 //precision of 1 step in mm
#define MICROSTEPS 16L
#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))


int enable_pin[] = {54, 57, 60, 63};
int step_pin[] = {55, 58, 61, 64};
int dir_pin[] = {56, 59, 62, 65};

float spooled_float[NUM_ANCHORS];

long dist_long[NUM_ANCHORS];
float dist_float[NUM_ANCHORS];
long time_budget;


void setup() 
{ 
  Serial.begin(115200);
  
  for(int a=0;a<NUM_ANCHORS;a++){
    pinMode(enable_pin[a], OUTPUT);
    pinMode(step_pin[a], OUTPUT);
    pinMode(dir_pin[a], OUTPUT);
    digitalWrite(enable_pin[a], LOW);
    spooled_float[a] = 0.0;
  }
  
  pinMode(13, OUTPUT);
  digitalWrite(13, HIGH);
}

void travel(long* dist, long ms)
{
  long startTime;
  long sum_dist = 0;
  long max_dist = 0;
  long step_goal[NUM_ANCHORS];
  long step_done[NUM_ANCHORS];
  long budget;

  for(int a=0;a<NUM_ANCHORS;a++){
      if (dist[a] < 0) 
        digitalWrite(dir_pin[a], LOW);
      else 
        digitalWrite(dir_pin[a], HIGH);  
      dist[a] = abs(dist[a])*MICROSTEPS; //multiply the step by the number of microsteps
      sum_dist += dist[a];
      max_dist = MAX(dist[a],max_dist);
      step_done[a] = 0;  
    }

  if (DEBUG) {
    Serial.print("Budget ");
    Serial.print(ms);
    Serial.print(" Minimum ");
    Serial.println(max_dist/2); //each microsteps takes 0.5 ms 
  }

  budget = MAX(ms,max_dist/2); 

    
  startTime = millis();

  while ((millis() < (startTime+budget)) || (sum_dist>0)){
    for(int a=0;a<NUM_ANCHORS;a++){
      step_goal[a] = ceil(((float)((millis()-startTime)*dist[a]))/((float)budget));
      if (step_goal[a]>dist[a]) step_goal[a]=dist[a];
      if ((step_goal[a]>step_done[a])&&(step_done[a]<dist[a])){
        digitalWrite(step_pin[a], HIGH);
      }
    }
    delayMicroseconds(STEP_DELAY); //leave the pins up for abit in order to be detected
    for(int a=0;a<NUM_ANCHORS;a++){
      if ((step_goal[a]>step_done[a])&&(step_done[a]<dist[a])){
          digitalWrite(step_pin[a], LOW); // stop step trigger
          sum_dist = sum_dist -1;
          step_done[a] = step_done[a]+1;
      }
    }
  }
  if(!DEBUG) Serial.println("A"); //send an ACK to the system controller
}

void loop() 
{  
// SENSYS VERSION
  if (Serial.available() > 0)
  {
    char command[255];
    //we expect NUM ANCHOR floating distances in mm + a budget time in ms
    Serial.readBytesUntil('\n',command,255); 
    char* cmd = strtok(command,TOKENS);
    
    for (int a=0;a<NUM_ANCHORS;a++)
    {
      // we keep the quantity of spooled wire in floating point for precision
      float old_spool = spooled_float[a];
      dist_float[a] =atof(cmd);
      cmd = strtok(NULL,TOKENS);
      spooled_float[a] += dist_float[a];
      // the difference between the old distance and the new one is then reduced in precision (0.5mm = 1step = 1.8' - 100mm = 200steps = 360')
      dist_long[a] = (long)(((round(spooled_float[a]*(1/MIN_PRECISION))/(1/MIN_PRECISION)) - (round(old_spool*(1/MIN_PRECISION))/(1/MIN_PRECISION)))*2);
   
      if(DEBUG){
        Serial.print("Spooled ");
        Serial.print(spooled_float[a]);
        Serial.print(" mm, Delta ");
        Serial.print(dist_float[a]);
        Serial.print(" mm, ");
        Serial.print(dist_long[a]);
        Serial.println(" steps");
      }
    }    
    time_budget =(long)atol(cmd);
    cmd = strtok(NULL,TOKENS);
    
    if(DEBUG) {
      Serial.print("Start ");
      Serial.println(millis());
    }
    travel(dist_long,time_budget);
    if(DEBUG) {
      Serial.print("Stop ");
      Serial.println(millis());
    }
    
}

  
}
