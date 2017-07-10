

/**
 * 
 *   GONDOLA CONTROLLER FOR ARDUINO 
 *   
 *   self-contained code. just program the arduino and send positions via serial
 * 
 * 
 **/

// CONSTANTS 
#define NUM_ANCHORS 3
#define STEP_DELAY 90 //delay for stepper in microseconds (computer for 32 microsteps, using calculator https://www.allaboutcircuits.com/tools/stepper-motor-calculator/ and 42BYGHW811 Wantai stepper motor)
#define TOKENS ":, \n"
#define DEBUG 1
// the difference between the old distance and the new one is then reduced in precision (0.05 cm = MIN_PRECISION = 1step = 1.8', 1 cm = 20steps = 36', 10 cm = 200steps = 360')
#define STEP_CM 20.0
#define MIN_PRECISION (1/STEP_CM) //precision of 1 step in cm
#define MICROSTEPS 16L

// MACROS
#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

struct coordinate
{
  float x;
  float y;
  float z;
};

struct pins
{
  int en;
  int stp;
  int dir;
};

float euclidean_distance(coordinate p1, coordinate p2){
  return sqrt(pow(p1.x-p2.x,2)+pow(p1.y-p2.y,2)+pow(p1.z-p2.z,2));
}

float round_precision(float number, float min_precision){
  return round(number*(1.0/min_precision))/(1.0/min_precision);
  }

class Anchor
{
  coordinate anchor_position;
  pins pin;
  
  // state
  float spooled_distance;
  long steps_todo,steps_done,steps_goal;

  public:
  Anchor(int id)
  {
     Serial.print("Creating anchor ");
     Serial.println(id);
  }


  long missing_steps(){
    return steps_todo-steps_done;
    }
  void set_pins(int _enable, int _step, int _direction)
  {
    pin = {_enable,_step,_direction};
    pinMode(pin.en, OUTPUT);
    pinMode(pin.stp, OUTPUT);
    pinMode(pin.dir, OUTPUT);
    digitalWrite(pin.en, LOW);
  }
  
  void set_position(float _x, float _y, float _z, float _spooled)
  {
    anchor_position = {_x,_y,_z};
    spooled_distance = _spooled;
  }

  void prepare_to_spool(coordinate new_position){

    float cm_todo,cm_todo_rounded,new_spooled_distance,precision_distance;

    new_spooled_distance = euclidean_distance(anchor_position,new_position);

    
    cm_todo = new_spooled_distance - spooled_distance; //in cm
    if (cm_todo > 0){
      //direction_todo = 1;
      digitalWrite(pin.dir, HIGH); 
    } else {
      //direction_todo = -1;
      digitalWrite(pin.dir, LOW);
      }

    spooled_distance += round_precision(cm_todo,MIN_PRECISION); // save new anchor spooled distance
    //spooled_distance += cm_todo; // save new anchor spooled distance
    cm_todo = abs(cm_todo);
    cm_todo_rounded = round_precision(cm_todo,MIN_PRECISION);
    steps_todo = (long)(cm_todo_rounded*STEP_CM); //here we do not make sure the number is not round!!!
    
    if(DEBUG){
        Serial.print("Spooled ");
        Serial.print(spooled_distance);
        Serial.print("cm, Delta ");
        Serial.print(cm_todo);
        Serial.print("cm, Rounded to MIN_PRECISION (0.05) ");
        Serial.print(cm_todo_rounded);
        Serial.print("cm, steps ");
        Serial.print(steps_todo); //200 steps per cm
        Serial.print(", microsteps ");
        Serial.println(steps_todo*MICROSTEPS);    
        }

    steps_todo *= MICROSTEPS; //we need to account for all microsteps
    steps_done = 0;
    steps_goal = 0;
  }
 
  void start_step(long start_time, float budget){
      steps_goal = ceil(((float)((millis()-start_time)*steps_todo))/budget);
      if (steps_goal>steps_todo) steps_goal = steps_todo;
      if ((steps_goal>steps_done)&&(steps_done<steps_todo)){
        digitalWrite(pin.stp, HIGH);
      }
  }

  void end_step(){
      if ((steps_goal>steps_done)&&(steps_done<steps_todo)){
          digitalWrite(pin.stp, LOW); // stop step trigger
          steps_done += 1;
      }
  }

  void end_spooling(){
    
    }
  
};

class Gondola
{
  
  coordinate current_position;

  public:
  Gondola(coordinate start_position){ 
    current_position = start_position;
  }

  coordinate get_position(){
    return current_position;
  }

  void set_position(coordinate new_position){
    current_position.x = new_position.x;
    current_position.y = new_position.y;
    current_position.z = new_position.z;
  }
  
};

Anchor* anchors[NUM_ANCHORS];
Gondola* gondola; 

// ARDUINO SETTINGS
int enable_pin[] = {54, 57, 60, 63};
int step_pin[] = {55, 58, 61, 64};
int dir_pin[] = {56, 59, 62, 65};
// ANCHORS POSITION
float x[] = {0.0, 0.0, 0.0};
float y[] = {0.0, 0.0, 0.0};
float z[] = {0.0, 0.0, 0.0};
float spooled[] = {0.0, 0.0, 0.0};


long time_budget;


void setup() 
{ 

  Serial.begin(115200);
 
  for(int a=0;a<NUM_ANCHORS;a++){
    anchors[a] = new Anchor(a);
    anchors[a]->set_pins(enable_pin[a],step_pin[a],dir_pin[a]);
    anchors[a]->set_position(x[a],y[a],z[a],spooled[a]);
  }

  gondola = new Gondola((coordinate){0.0,0.0,0.0});
  
  pinMode(13, OUTPUT);
  digitalWrite(13, HIGH);
}



void loop() 
{  

  if (Serial.available() > 0)
  {
    char command[255];
    coordinate new_position;
    float travel_speed,travel_distance,travel_time;
    long start_time;
    
    // read a line from serial
    Serial.readBytesUntil('\n',command,255); 
    // parse string on serial (later change it with command interpreter)
    // we expect 4 float: x, y, z, speed in cm/s
    char* cmd = strtok(command,TOKENS);

    new_position.x = atof(cmd);
    cmd = strtok(NULL,TOKENS); // in cm
    new_position.y = atof(cmd);
    cmd = strtok(NULL,TOKENS); // in cm
    new_position.z = atof(cmd);
    cmd = strtok(NULL,TOKENS); // in cm
    travel_speed = atof(cmd); //in cm/s
    cmd = strtok(NULL,TOKENS);

    travel_distance = euclidean_distance(gondola->get_position(),new_position);
    travel_time = travel_distance/travel_speed;
  
    if (travel_distance == 0){
      Serial.println("Travel distance = 0. Nothing to do");
      return;
    }


    // ACTUATE THE STEPPER MOTORS

  long max_steps = 0;
  
  for(int a=0;a<NUM_ANCHORS;a++){
      anchors[a]->prepare_to_spool(new_position);
      max_steps = MAX(anchors[a]->missing_steps(),max_steps);
    }

  if (DEBUG) {
    Serial.print("Budget ");
    Serial.print(travel_time);
    Serial.print("s, Minimum ");
    Serial.print(max_steps/2000.0); //each microsteps takes 0.5 ms 
    Serial.println("s");
  }

  travel_time = MAX(travel_time,max_steps/2000.0); 
    
  start_time = millis();
  travel_time *= 1000; //convert budget time in milliseconds

  boolean steps_left = 1;
  
  while ((millis() < (start_time+travel_time)) || steps_left>0){
    steps_left = 0;
    for(int a=0;a<NUM_ANCHORS;a++){
      anchors[a]->start_step(start_time,travel_time);
    }
    delayMicroseconds(STEP_DELAY); //leave the pins up for abit in order to be detected
    for(int a=0;a<NUM_ANCHORS;a++){
      anchors[a]->end_step();
      steps_left += anchors[a]->missing_steps();
    }
  }

  gondola->set_position(new_position);
  
    if (DEBUG) {
    Serial.print("Spooling time ");
    Serial.print((millis()-start_time)/1000.0);
    Serial.print(", missing steps ");
    Serial.println(steps_left);
    }


  }

  
}
