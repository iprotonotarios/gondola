import processing.serial.*;
import controlP5.*;
import java.util.*;

// Serial connection with arduino
Serial controllerPort = null;
Serial loggingPort = null;
String[] serialPorts;

// Script file 
String script_lines[];

// Anchors
List<PVector> anchors;

// GUI
Gondola g;
Projections p;
ControlGui c;
PGraphics view_3d;

// Room size (in cm)
float x_range = 657.9;
float y_range = 394.1;
float z_range = 311.9;

// calibration mode
boolean calibration = false;

// Trace files
String[] filelist;
int childCount = 0;
File dir;
String folder = "traces"; 

// Boot flag
boolean booting = true;
boolean connected = false;
boolean logging = false;


void setup() {
  // Set screen size and frame rate
  size(1280,768,P2D);
  frameRate(60);
  // Setup anchor points
  anchors = new ArrayList<PVector>();
  anchors.add(new PVector(54.0,6.0,11.5));
  anchors.add(new PVector(55.0,388.1,15.0));
  anchors.add(new PVector(651.0,380.5,11.5));
  anchors.add(new PVector(651.0,13.6,15.5));
  // Get trace files
  dir = new File(sketchPath(folder));
  filelist = dir.list(); 
  // Init objects
  g = new Gondola(new PVector(355.7,196.5,312.9),anchors);
  p = new Projections();
  c = new ControlGui(new ControlP5(this),filelist,g);
  // Create 3d view
  view_3d = createGraphics((int)p.y_view, (int)p.y_view, P3D);
  // Connect to serial port
  serialPorts = Serial.list();
  c.add_ports(serialPorts);
//  println(Serial.list());
  // Clear boot flag
  booting = false;
}

void draw() {
background(#000000);
// set next destination
if(g.isWaiting()){
      
  //println("gondola waiting");
  while (controllerPort.available() > 0) {
    int inByte = controllerPort.read();
    if(inByte==65) {
      //println("moving");
      g.destination_reached();      
      move_gondola(c.isLoop());
    }
  }
}
// Draw projections
p.draw(g,c,anchors,view_3d);

}

void controlEvent(ControlEvent theEvent) {
  // ignore calls while booting (it rises an exception)
  if (booting) return;
  // if a file is selected
      if(theEvent.isFrom(c.trace_files)) {
        script_lines = loadStrings(dir.getAbsolutePath()+"/"+filelist[(int)theEvent.getGroup().getValue()]);
        c.trace_commands.clear();
        for (int i = 0 ; i < script_lines.length; i++) {
          c.trace_commands.addItem(script_lines[i],i);
        }
        c.trace_commands.open();
  }  
  
  if(theEvent.isFrom(c.controller_ports)) {
        int port_idx = (int)theEvent.getGroup().getValue();
println("Set controller port to "+serialPorts[port_idx]);
  if (controllerPort!= null) controllerPort.stop();
  controllerPort = new Serial(this, serialPorts[port_idx], 9600);
  connected = true;

  }  
  
  if(theEvent.isFrom(c.logging_ports)) {
        int port_idx = (int)theEvent.getGroup().getValue();
println("Set controller port to "+serialPorts[port_idx]);
  if (loggingPort!= null) loggingPort.stop();
  loggingPort = new Serial(this, serialPorts[port_idx], 9600);
  logging = true;
  }  
  
  
}

public void move_gondola(boolean _loop){
  String out = "";
    if (!connected) {
     println("No controller connected");
      return;
    }
    List<Float> distances = g.move(_loop);    
  if (distances == null) return;
  //println("moving gondola");
  Iterator iterator = distances.iterator();
  while(iterator.hasNext()){
    // output in mm (x10) and with a precision of 0.5 (multiply by 2, round, divide by 2)
    out = out + round(((Float)iterator.next())*20.0)/2.0 + ":";
  }
  out = out + c.get_speed() + "\n";
  print("To controller: "+ out);
  controllerPort.write(out);
}

public void goto_xyz(int val) {
  
    if (!connected) {
     println("No controller connected");
      return;
    }
  
  // clear positions and enqueue the one on the GUI
  g.clear_positions();
  g.enqueue_position (c.get_position());
  move_gondola(false);
}

public void execute_script(int val) {
  
    if (!connected) {
     println("No controller connected");
      return;
    }
  
  // enqueue all positions
  for (int i = 0;i<script_lines.length;i++){
    String[] _xyz = split(script_lines[i], ' ');
    g.enqueue_position (new PVector(float(_xyz[0]),float(_xyz[1]),float(_xyz[2])));
    println(script_lines[i]);
  }
  // move to the first position
  move_gondola(c.isLoop());
}

public void calibrate(int val) {
  g.set_position(c.get_cal());
  c.set_position(c.get_cal());
}  


