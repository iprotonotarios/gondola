/*
#define M0_ENABLE_PIN       54
#define M0_STEP_PIN         55
#define M0_DIR_PIN          56

#define M1_ENABLE_PIN       57
#define M1_STEP_PIN         58
#define M1_DIR_PIN          59

#define M2_ENABLE_PIN       60
#define M2_STEP_PIN         61
#define M2_DIR_PIN          62

#define M3_ENABLE_PIN       63
#define M3_STEP_PIN         64
#define M3_DIR_PIN          65
*/

#define NUM_ANCHORS 4
#define STEP_DELAY 1

#define NUM_TIMESLOTS 200
#define LEN_TIMESLOT (1000/NUM_TIMESLOTS)

int enable_pin[] = {54, 57, 60, 63};
int step_pin[] = {55, 58, 61, 64};
int dir_pin[] = {56, 59, 62, 65};

char command[100];
long dist[NUM_ANCHORS+1];


//long steps_map[NUM_ANCHORS][NUM_TIMESLOTS];
//long steps_done[NUM_ANCHORS];


void setup() 
{ 
  Serial.begin(9600);

  for(int i=0;i<NUM_ANCHORS;i++){
    pinMode(enable_pin[i], OUTPUT);
    pinMode(step_pin[i], OUTPUT);
    pinMode(dir_pin[i], OUTPUT);
    digitalWrite(enable_pin[i], LOW);
  }

  
  pinMode(13, OUTPUT);
  digitalWrite(13, HIGH);
}


void travel(long* dist, long seconds)
{
  int step_ms[NUM_ANCHORS];
  int max_step_ms = 0;
  
  for(int i=0;i<NUM_ANCHORS;i++){
      if (dist[i] < 0) 
        digitalWrite(dir_pin[i], HIGH);
      else 
        digitalWrite(dir_pin[i], LOW);  
      dist[i] = abs(dist[i])*8;
      step_ms[i] = (int)ceil((float)dist[i]/(seconds*200));
      if (step_ms[i] > max_step_ms) 
        max_step_ms = step_ms[i];
    }
/*
  for(int a=0;a<NUM_ANCHORS;a++){
      
      if (dist[a] < 0) 
        digitalWrite(dir_pin[a], HIGH);
      else 
        digitalWrite(dir_pin[a], LOW);  
      
      dist[a] = abs(dist[a])*8;
      
      for(int t=0;t<NUM_TIMESLOTS;t++){
        steps_map[a][t] = (int)ceil((dist[a]*(t+1))/(float)NUM_TIMESLOTS);
      }

      steps_done[a]=0;
      
      //step_ms[i] = (int)ceil((float)dist[i]/(seconds*200));
      //if (step_ms[i] > max_step_ms) 
      //  max_step_ms = step_ms[i];
    }

  */  
/*
// for each millisecond, each motor make enough steps to consume its budget
  long startTime = millis()+LEN_TIMESLOT;
  
  //wait for the start of the next 10ms timeslot
  while(millis()<=startTime);
  
  for(long t=0; t<NUM_TIMESLOTS; t++)
  {
    
    boolean done = false;

//Serial.print("T");

    while(!done){

      //Serial.print("L");
      
      done = true;
      
      for(int a=0;a<NUM_ANCHORS;a++)
        if ((steps_done[a] < steps_map[a][t]) && (dist[a]>0)) {
          digitalWrite(step_pin[a], HIGH);
          }
      delayMicroseconds(STEP_DELAY);
      
      for(int a=0;a<NUM_ANCHORS;a++){

         //Serial.print(steps_done[a]); 
         //Serial.print("-");
         //Serial.print(steps_map[a][t]);
         //Serial.print(" ");
         
        if ((steps_done[a] < steps_map[a][t]) && (dist[a]>0)) {
          digitalWrite(step_pin[a], LOW);
          dist[a] = dist[a]-1;
          steps_done[a] = steps_done[a]+1;
          done = false;
          
          }
      delayMicroseconds(STEP_DELAY);
      }
    }
    //wait untile the millisecond is elapsed
    while(millis()<=startTime+((t+2)*LEN_TIMESLOT));
  }
  */


  // for each millisecond, each motor make enough steps to consume its budget
  long startTime = (millis()/LEN_TIMESLOT)+1;
  
  //wait for the start of the next 10ms timeslot
  while((millis()/LEN_TIMESLOT)<=startTime);
  
  for(long t=0; t<(seconds*NUM_TIMESLOTS); t++)
  {
    for(long s=0; s<max_step_ms; s++)
    {
      
      for(int a=0;a<NUM_ANCHORS;a++)
        if ((s < step_ms[a]) && (dist[a]>0)) {
          digitalWrite(step_pin[a], HIGH);
          }
      delayMicroseconds(STEP_DELAY);
      
      for(int a=0;a<NUM_ANCHORS;a++)
        if ((s < step_ms[a]) && (dist[a]>0)) {
          digitalWrite(step_pin[a], LOW);
          dist[a] = dist[a]-1;
          }
      delayMicroseconds(STEP_DELAY);
      
    }
    //wait untile the millisecond is elapsed
    while((millis()/LEN_TIMESLOT)<=startTime+t);
  }
  
  Serial.print("A");
}


void loop() 
{  
  if (Serial.available() > 0)
  {
    delay(1);
    Serial.readBytesUntil('\n',command,100); //need at least 30!!
    
    char* cmd = strtok(command, ":");
    for (int s=0; s<5; s++)
    {
      dist[s] =(int) 2*atof(cmd);
      cmd = strtok(NULL, ":");
    }    
    travel(dist, dist[4]/2);
  }
}
