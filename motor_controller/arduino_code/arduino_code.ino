#define NUM_ANCHORS 4
#define STEP_DELAY 1

int enable_pin[] = {54, 57, 60, 63};
int step_pin[] = {55, 58, 61, 64};
int dir_pin[] = {56, 59, 62, 65};

char command[255];
long dist[NUM_ANCHORS];
long time_budget;

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
  long startTime;
  long sum_dist = 0;
  long step_goal[NUM_ANCHORS];
  long step_done[NUM_ANCHORS];

  for(int a=0;a<NUM_ANCHORS;a++){
      if (dist[a] < 0) 
        digitalWrite(dir_pin[a], HIGH);
      else 
        digitalWrite(dir_pin[a], LOW);  
      dist[a] = abs(dist[a])*8; //adapt mm distance to steps
      sum_dist += dist[a];
      step_done[a] = 0;  
    }
  startTime = millis();

  while ((millis() < (startTime+ms)) || (sum_dist>0)){
    for(int a=0;a<NUM_ANCHORS;a++){
      step_goal[a] = ceil(((float)((millis()-startTime)*dist[a]))/((float)ms));
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
  Serial.println("A"); //send an ACK to the system controller
}

void loop() 
{  
  if (Serial.available() > 0)
  {
    delay(1);
    Serial.readBytesUntil('\n',command,255); //NOTE THAT FOR A PROPER PARSING OUR STRING NEEDS TO TERMINATE WITH ':'
    char* cmd = strtok(command, ":");
    for (int a=0;a<NUM_ANCHORS;a++)
    {
      dist[a] =(long)round(2*atof(cmd)); //distance can be provided with a precision up to 0.5mm. If we multiply by 2, we can use integer
      cmd = strtok(NULL, ":");
    }    
    time_budget =(long)atol(cmd);
    cmd = strtok(NULL, ":");
    travel(dist,time_budget);
  }
}
