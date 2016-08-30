import processing.serial.*;
import controlP5.*;
import java.util.*;
import peasy.*;
import javax.swing.*;

PeasyCam camera;
float rotationX = 0.0;
float rotationY = 0.0;
float rotationStep = PI/30;

// Serial connection with arduino and sensor node
Serial arduinoPort = null;
Serial sensorPort = null;
String[] serialPorts;

// Script file 
//String script_lines[];

// GUI
Gondola g;
World w;
Gui c;
Sensor s;
ScriptPlayer p;
PGraphics view_3d;


// calibration mode
boolean calibration = false;

// Boot flag
boolean booting = true;
boolean controllerConnected = false;
boolean sensorConnected = true;
boolean sensing = false;
boolean simulation = true;
boolean isrotating = false;


void setup() {
  
  // Set screen size and frame rate
  size(1280,768,P2D);
  frameRate(60);

  g = new Gondola(new PVector(100.0,100.0,100.0));
  w = new World(640.0,480.0,200.0);
  c = new Gui(new ControlP5(this),g);
  s = new Sensor();
  p = new ScriptPlayer();
  
  p.callOnChange("updatePositionList");
  // Create 3d view
  view_3d = createGraphics(1000, 768, P3D);  
  camera = new PeasyCam(this,view_3d, w.xDim/2,w.yDim/2,w.zDim/2, 800);
  camera.setActive(false);
  camera.rotateX(PI/2);

  // Setup anchor points
  g.addAnchor(new Anchor (new PVector(0.0,0.0,0.0)));
  g.addAnchor(new Anchor (new PVector(0.0,480.0,0.0)));
  g.addAnchor(new Anchor (new PVector(640.0,0.0,0.0)));
  g.addAnchor(new Anchor (new PVector(640.0,480.0,0.0)));


  // Get trace files
  //dir = new File(sketchPath(folder));
  //filelist = dir.list(); 

  // Connect to serial port
  serialPorts = Serial.list();
  c.add_ports(serialPorts);
  //  println(Serial.list());
  // Clear boot flag
  booting = false;
}

void draw() {
  
  if (booting) return;
  
  background(#000000);
  
  
  
  // wait for Gondola to reach is destination, i.e. get an ACK (char 'A') from the arduino.
  if(g.isMoving()){
    if (simulation) {
      g.destination_reached();
    } else {
      while (arduinoPort.available() > 0) {
        int inByte = arduinoPort.read();
        if(inByte==65) {
          g.destination_reached();
          //move_gondola(c.isLoop());
        }
      }
    }
  }

  if(g.isIdle()) move_gondola(c.isLoop());
  
  // Init 3D world
  view_3d.beginDraw();
  view_3d.background(#000000);
  view_3d.lights();
  view_3d.stroke(255);
  // draw world
  w.draw(view_3d);
  // draw gondola and anchors
  g.draw(view_3d);
  // draw sensed values
  s.draw(view_3d);
  
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
  camera.lookAt(w.xDim/2,w.yDim/2,w.zDim/2, 800,0);
  view_3d.endDraw();  
  // place 3D world into 2D window  
  image(view_3d, 280, 0); 
  w.draw_coordinates(view_3d,280,0);
  
}

void controlEvent(ControlEvent theEvent) {
  // ignore calls while booting (it rises an exception)
  if (booting) return;
   
  // if the arduino port is selected
  if(theEvent.isFrom(c.motorcontroller_ports)) {
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
  if(theEvent.isFrom(c.sensor_ports)) {
    int port_idx = (int)theEvent.getGroup().getValue();
    if (port_idx == 0){
      sensing = false;
      println("No sensor connected");
      return;
    }
    else {
      port_idx--;
      println("Set sensor port to "+serialPorts[port_idx]);
      if (sensorPort!= null) sensorPort.stop();
      sensorPort = new Serial(this, serialPorts[port_idx], 9600);
      sensorConnected = true;
      sensing = true;
    }
  } 
  
  // if the script checkbox is toggled
   if (theEvent.isFrom(c.experiment_settings)) { 
    p.setPlaying(c.isPlay()); //play
  }
  
}

public void move_gondola(boolean _putback){
  
  if (!controllerConnected && !simulation) {
    println("No controller connected");
    return;
  }
  
  PVector _pos = p.popPos(_putback);
  
  if (_pos == null) return;
  
  List<Float> distances = g.move(_pos);  
  if (distances == null) return;
  
  // Compose output string (to motor controller)
  String serial_output = "";
  Iterator iterator = distances.iterator();
  while(iterator.hasNext()){
    // output in mm (x10) and with a precision of 0.5 (multiply by 2, round, divide by 2)
    serial_output = serial_output + round(((Float)iterator.next())*20.0)/2.0 + ":";
  }
  // here we should compute the required moving time given the travel distance of gondola and the required speed. For now we just set the speed in motor ticks per second
  serial_output = serial_output + c.get_speed() + "\n";
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
  p.addPos(c.get_position());

}

public void sense(int val) {
 if (g.isIdle()) s.sense(g.getPosition());
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
    g.enqueue_position (new PVector(float(_xyz[0]),float(_xyz[1]),float(_xyz[2])));
    //println(script_lines[i]);
  }
  // move to the first position
  move_gondola(c.isLoop());
  */
}

public void calibrate(int val) {
  g.move(c.get_position());
  g.destination_reached();
  c.set_position(c.get_position());
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
    c.script_positions.clear();
    for (int i = 0 ; i < script_lines.length; i++) {
      c.script_positions.addItem(script_lines[i],i);
    }
    c.script_positions.open();

  }
    
    
  } 
  
public void updatePositionList(){
   List<PVector> positions = p.getPositions();
   c.script_positions.clear();

   for (PVector _pos : positions) {
      c.script_positions.addItem("x: " + _pos.x + " y:" + _pos.y + " z: " + _pos.z, 0);
    }
  
}

public void clear(int val){
  c.script_positions.clear();
  p.clearPositions();
}