import processing.serial.*;
import controlP5.*;
import java.util.*;
import peasy.*;
import javax.swing.*;

// define the size of boxes, keyboard steps and sensing area
int step_size = 5;

PeasyCam camera;
float rotationX = 0.0;
float rotationY = 0.0;
float rotationStep = PI/30;
double zoom = 800;

// Serial connection with arduino and sensor node
Serial arduinoPort = null;
Serial sensorPort = null;
String[] serialPorts;

// Script file 
//String script_lines[];

// GUI
Gondola gondola;
World world;
Gui gui;
Sensor sensor;
ScriptPlayer player;
PGraphics view_3d;


// calibration mode
boolean calibration = false;

// Boot flag
boolean booting = true;
boolean controllerConnected = false;
boolean sensorConnected = false;
boolean sensing = false;
boolean simulation = true;
boolean isrotating = false;


void setup() {
  
  // Set screen size and frame rate
  size(1280,768,P2D);
  frameRate(60);

  gondola = new Gondola(new PVector(107,65.0,26.0));
  world = new World(150.0,120.0,100.0);
  gui = new Gui(new ControlP5(this),gondola);
  sensor = new Sensor();
  player = new ScriptPlayer();
  
  player.callOnChange("updatePositionList");
  // Create 3d view
  view_3d = createGraphics(1000, 768, P3D);  
  camera = new PeasyCam(this,view_3d, world.xDim/2,world.yDim/2,world.zDim/2, 800);
  camera.setActive(false);
  camera.rotateX(PI/2);

  // Setup anchor points
  gondola.addAnchor(new Anchor (new PVector(0.0,103.5,0.0)));
  gondola.addAnchor(new Anchor (new PVector(147.5,115.0,0.0)));
  gondola.addAnchor(new Anchor (new PVector(147.5,17.0,0.0)));
  //gondola.addAnchor(new Anchor (new PVector(640.0,480.0,0.0)));


  // Get trace files
  //dir = new File(sketchPath(folder));
  //filelist = dir.list(); 

  // Connect to serial port
  serialPorts = Serial.list();
  gui.add_ports(serialPorts);
  //  println(Serial.list());
  // Clear boot flag
  booting = false;
}

void draw() {
  
  if (booting) return;
  
  background(#000000);
  
  
  
  // wait for Gondola to reach is destination, i.e. get an ACK (char 'A') from the arduino.
  if(gondola.isMoving()){
    if (simulation) {
      reached_destination();
    } else {
      while (arduinoPort.available() > 0) {
        int inByte = arduinoPort.read();
        if(inByte==65) {
          reached_destination();
          //move_gondola(gui.isLoop());
        }
      }
    }
  }

  if(gondola.isIdle()) move_gondola(gui.isLoop());
  
  // Init 3D world
  view_3d.beginDraw();
  view_3d.background(#000000);
  view_3d.lights();
  view_3d.stroke(255);
  // draw world
  world.draw(view_3d);
  // draw gondola and anchors
  gondola.draw(view_3d);
  // draw sensed values
  if(gui.isPlot())  sensor.draw(view_3d);
  
  isrotating = false;
  // rotate camera
  if (rotationX>=rotationStep) {
    isrotating = true;
    camera.rotateX(rotationStep);
    rotationX = rotationX - rotationStep;
  } 
  else if (rotationX<=-rotationStep) {
    isrotating = true;
    camera.rotateX(-rotationStep);
    rotationX = rotationX + rotationStep;
  }
  else{
    camera.rotateX(rotationX);
    rotationX = 0;
  }
  if (rotationY>=rotationStep) {
    isrotating = true;
    camera.rotateY(rotationStep);
    rotationY = rotationY - rotationStep;
  }
  else if (rotationY<=-rotationStep) {
    isrotating = true;
    camera.rotateY(-rotationStep);
    rotationY = rotationY + rotationStep;
  } 
  else{
    camera.rotateY(rotationY);
    rotationY = 0;
  }
  // center the camera
  camera.lookAt(world.xDim/2,world.yDim/2,world.zDim/2, zoom, 0);
  view_3d.endDraw();  
  // place 3D world into 2D window  
  image(view_3d, 280, 0); 
  world.draw_coordinates(view_3d,280,0);
  
}

void controlEvent(ControlEvent theEvent) {
  // ignore calls while booting (it rises an exception)
  if (booting) return;
   
  // if the arduino port is selected
  if(theEvent.isFrom(gui.motorcontroller_ports)) {
    int port_idx = (int)theEvent.getGroup().getValue();
    if (port_idx == 0){
      simulation = true;
      println("Set to simulated port");
      return;
    }
    else {
      port_idx--;
      println("Set controller port to "+serialPorts[port_idx]);
      if (arduinoPort!= null) arduinoPort.stop();
      arduinoPort = new Serial(this, serialPorts[port_idx], 9600);
      controllerConnected = true;
      simulation = false;
    }
  }  
  
  // if the sensor port is selected
  if(theEvent.isFrom(gui.sensor_ports)) {
    int port_idx = (int)theEvent.getGroup().getValue();
    if (port_idx == 0){
      sensing = false;
      sensorConnected = false;
      println("No sensor connected");
      return;
    }
    else {
      port_idx--;
      println("Set sensor port to "+serialPorts[port_idx]);
      if (sensorPort!= null) sensorPort.stop();
      sensorPort = new Serial(this, serialPorts[port_idx], 115200);
      sensorConnected = true;
      sensing = true;
    }
  } 
  
  // if the script checkbox is toggled
   if (theEvent.isFrom(gui.experiment_settings)) { 
    player.setPlaying(gui.isPlay()); //play
  }
  
}


public void reached_destination(){
  //update gondola's status
  gondola.destination_reached();
  //perform sensing
  sense(0);
}

public void move_gondola(boolean _putback){
  
  if (!controllerConnected && !simulation) {
    println("No controller connected");
    return;
  }
  
  PVector _pos = player.popPos(_putback);
  
  if (_pos == null) return;
  
  
  float travel_distance = PVector.dist(gondola.getPosition(),_pos); //distance in cm
  float speed = gui.get_speed(); //speed in cm/s
  float timebudget = travel_distance/speed;
  
  List<Float> distances = gondola.move(_pos);  
  if (distances == null) return;
  
  // Compose output string (to motor controller)
  String serial_output = "";
  Iterator iterator = distances.iterator();
  while(iterator.hasNext()){
    // output in mm and with a precision of 0.5
    //serial_output = serial_output + round(((Float)iterator.next())*20.0)/2.0 + ":";
    
    serial_output = serial_output + ((Float)iterator.next())*10.0 + ":"; //return spooling distances in mm rather than cm 
  }
  // here we should compute the required moving time given the travel distance of gondola and the required speed. For now we just set the speed in motor ticks per second
  
  serial_output = serial_output + round(timebudget*1000)*1.0 + ":\n"; //time budget is give in ms
  print("To motor controller: "+ serial_output);
  if (!simulation) arduinoPort.write(serial_output);
  
  
  
}

public void move(int val) {
/*
  if (!connected && !simulation) {
    println("No controller connected");
    return;
  }
*/  
  player.addPos(gui.get_position());

}

public void sense(int val) {
  //this function can be triggered manually OR when gondola reaches a destination and the sense toggle is ON
  if (gui.isSensing()){
    int lf = 10;  
    gondola.setSensing(true); // does not allow gondola to move while sensing
    sensor.clear(gondola.getPosition());
    
    if (sensorConnected){
      sensorPort.clear();  //clear previous data in the buffer
      //print(sensorPort.readStringUntil(lf));
    }
    
    for (int i=0;i<10;i++){  //collect 10 samples
        float _value = 0.0;
        if (sensorConnected){
          //print("Listening ");
          
          while(sensorPort.available()<=0) delay(1); //wait for incoming data
          
          //if (sensorPort.available() > 0) {
            //print(" IN ");
            String _string = sensorPort.readStringUntil(lf);
            //print(_string);
            //print(" ");
            if (_string != null) {
              //print(_string);  // Prints String
              _value = float(_string);  // Converts and prints float
              //println(_value);
            }
          //}
        }
        else{
          _value = (float)random(255);
        }
        sensor.sense(gondola.getPosition(),_value);
    }
    gondola.setSensing(false);
  }
}


public void execute_script(int val) {
  /*
    
    if (!connected && !simulation) {
     println("No controller connected 3");
      return;
    }
    
  
  // enqueue all positions
  for (int i = 0;i<script_lines.length;i++){
    String[] _xyz = split(script_lines[i], ' ');
    gondola.enqueue_position (new PVector(float(_xyz[0]),float(_xyz[1]),float(_xyz[2])));
    //println(script_lines[i]);
  }
  // move to the first position
  move_gondola(gui.isLoop());
  */
}

public void calibrate(int val) {
  gondola.move(gui.get_position());
  gondola.destination_reached();
  gui.set_position(gui.get_position());
}  

public void load(int val){
selectInput("Select a file to process:", "fileSelected");
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    //println("User selected " + selection.getAbsolutePath());
    String[] script_lines = loadStrings(selection.getAbsolutePath());
    gui.script_positions.clear();
    for (int i = 0 ; i < script_lines.length; i++) {
      gui.script_positions.addItem(script_lines[i],i);
    }
    gui.script_positions.open();

  }
    
    
  } 
  
public void updatePositionList(){
   List<PVector> positions = player.getPositions();
   gui.script_positions.clear();

   for (PVector _pos : positions) {
      gui.script_positions.addItem("x: " + _pos.x + " y:" + _pos.y + " z: " + _pos.z, 0);
    }
  
}

public void clear(int val){
  gui.script_positions.clear();
  player.clearPositions();
}