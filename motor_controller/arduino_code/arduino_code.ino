#define NUM_ANCHORS 4
#define STEP_DELAY 1

//#define NUM_TIMESLOTS 200
//#define LEN_TIMESLOT (1000/NUM_TIMESLOTS)

int enable_pin[] = {54, 57, 60, 63};
int step_pin[] = {55, 58, 61, 64};
int dir_pin[] = {56, 59, 62, 65};

char command[100];
long dist[NUM_ANCHORS+1];


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

void travel(long* dist, long ms)
{

  
  float step_us[NUM_ANCHORS];
  float next_step[NUM_ANCHORS];
  long startTime;
  
  for(int a=0;a<NUM_ANCHORS;a++){
      if (dist[a] < 0) 
        digitalWrite(dir_pin[a], HIGH);
      else 
        digitalWrite(dir_pin[a], LOW);  
      dist[a] = abs(dist[a])*8; //adapt mm distance to steps
      step_us[a] = ((ms*1000.0)/(float)dist[a]); // computes how frequently each stepper need to perform a step (a step event)
      next_step[a] = 0.0;
    }
    
  startTime = micros();
  
  //until the time is elapsed
  while(micros()<=startTime+(ms*1000)){
    
    for(int a=0;a<NUM_ANCHORS;a++){
      // if we have passed a step event and we still have steps to do
      if((micros()>startTime+(long)round(next_step[a])) && (dist[a]>0)){ 
          digitalWrite(step_pin[a], HIGH); // start step trigger
      }
    }
    delayMicroseconds(STEP_DELAY); //leave the pins up for abit in order to be detected
    for(int a=0;a<NUM_ANCHORS;a++){
      if((micros()>startTime+(long)round(next_step[a])) && (dist[a]>0)){
          digitalWrite(step_pin[a], LOW); // stop step trigger
          next_step[a]+=step_us[a]; // store when the next step will be
          dist[a] = dist[a]-1; // remove 1 step from our counter
      }
    }
    
  }
  //TODO: check if we performed all steps
  Serial.print("A");
}
/*
void travel_old(long* dist, long seconds)
{


// TODO: for each stepp add to a float counter the slot budget (also float)
// at each step, round the counter with floor() and execute the resulting amount of steps
// remove the integer part from the counter and from the global number


  
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

*/
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
