// MACROS
#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

// CONSTANTS 
#define DEBUG 1

// SERIAL SETTINGS
#define TOKENS ":, \n"
#define BAUDRATE 115200

// ARDUINO SETTINGS (wemos D1 mini based on esp8266)
// data from https://github.com/esp8266/Arduino/blob/master/variants/d1_mini/pins_arduino.h#L49-L61
// schema from https://a.pololu-files.com/picture/0J3360.600.png?d94ef1356fab28463db67ff0619afadf

//#define LED_PIN LED_BUILTIN
int enable_pin[] =  {0}; //D3
int step_pin[] =    {5}; //D1
int dir_pin[] =     {4}; //D2


// STEPPER SETTINGS
#define             STEP_DELAY 9000 //delay for stepper in microseconds (computer for 32 microsteps, using calculator https://www.allaboutcircuits.com/tools/stepper-motor-calculator/ and 42BYGHW811 Wantai stepper motor)
#define             STEP_CM 20.0 // the difference between the old distance and the new one is then reduced in precision (0.05 cm = MIN_PRECISION = 1step = 1.8', 1 cm = 20steps = 36', 10 cm = 200steps = 360')
#define             MIN_PRECISION (1/STEP_CM) //precision of 1 step in cm
#define             MICROSTEPS 16L

// ANCHORS POSITION
#define NUM_ANCHORS 1
float x[] =         {0.0};
float y[] =         {0.0};
float z[] =         {0.0};

