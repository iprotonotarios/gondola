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

char command[100];
int dist[5];

void setup() 
{ 
  Serial.begin(9600);
  pinMode(M0_STEP_PIN, OUTPUT);
  pinMode(M0_DIR_PIN, OUTPUT);
  pinMode(M0_ENABLE_PIN, OUTPUT);
 
  pinMode(M1_STEP_PIN, OUTPUT);
  pinMode(M1_DIR_PIN, OUTPUT);
  pinMode(M1_ENABLE_PIN, OUTPUT);
 
  pinMode(M2_STEP_PIN, OUTPUT);
  pinMode(M2_DIR_PIN, OUTPUT);
  pinMode(M2_ENABLE_PIN, OUTPUT);
  
  pinMode(M3_STEP_PIN, OUTPUT);
  pinMode(M3_DIR_PIN, OUTPUT);
  pinMode(M3_ENABLE_PIN, OUTPUT);
 
  digitalWrite(M0_ENABLE_PIN, LOW);  
  digitalWrite(M1_ENABLE_PIN, LOW);  
  digitalWrite(M2_ENABLE_PIN, LOW);  
  digitalWrite(M3_ENABLE_PIN, LOW);
  
  pinMode(13, OUTPUT);
  digitalWrite(13, HIGH);
}

void travel(long x_dist, long y_dist, long z_dist, long e_dist, int step_delay)
{
  (x_dist < 0) ? digitalWrite(M0_DIR_PIN, HIGH):digitalWrite(M0_DIR_PIN, LOW);
  (y_dist < 0) ? digitalWrite(M1_DIR_PIN, HIGH):digitalWrite(M1_DIR_PIN, LOW);
  (z_dist < 0) ? digitalWrite(M2_DIR_PIN, HIGH):digitalWrite(M2_DIR_PIN, LOW);
  (e_dist < 0) ? digitalWrite(M3_DIR_PIN, HIGH):digitalWrite(M3_DIR_PIN, LOW);
  x_dist = abs(x_dist); y_dist = abs(y_dist); z_dist = abs(z_dist); e_dist = abs(e_dist);
  
  step_delay = (step_delay < 100) ? 100:step_delay;
  step_delay = (step_delay > 2000) ? 2000:step_delay;
  
  long steps = max(x_dist,max(y_dist,max(z_dist,e_dist)));
  steps = steps*16;
    
  for(long i=0; i<steps; i++)
  {
    if (i < x_dist*16) digitalWrite(M0_STEP_PIN    , HIGH);
    if (i < y_dist*16) digitalWrite(M1_STEP_PIN    , HIGH);
    if (i < z_dist*16) digitalWrite(M2_STEP_PIN    , HIGH);
    if (i < e_dist*16) digitalWrite(M3_STEP_PIN    , HIGH);
    delayMicroseconds(step_delay);
    if (i < x_dist*16) digitalWrite(M0_STEP_PIN    , LOW);
    if (i < y_dist*16) digitalWrite(M1_STEP_PIN    , LOW);
    if (i < z_dist*16) digitalWrite(M2_STEP_PIN    , LOW);
    if (i < e_dist*16) digitalWrite(M3_STEP_PIN    , LOW);
    delayMicroseconds(step_delay);
 }
 
  if (steps) Serial.print("A");
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
    travel(dist[0], dist[1], dist[2], dist[3], dist[4]/2);
  }
}
