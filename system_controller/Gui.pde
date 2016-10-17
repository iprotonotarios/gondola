class Gui {

ControlP5 cp5;
DropdownList script_positions;
RadioButton motorcontroller_ports,sensor_ports;
CheckBox experiment_settings;
Accordion accordion;

Group usb_group,calibration_group,manual_group,script_group,configuration_group;
 
  
  boolean isManual(){
    return manual_group.isOpen();
  }

  boolean isScript(){
    return script_group.isOpen();
  }
  
  
  boolean isSensing(){
  return experiment_settings.getArrayValue()[0]==1;
  }
 
  boolean isLoop(){
  return experiment_settings.getArrayValue()[1]==1;
  } 
 
  boolean isPlot(){
  return experiment_settings.getArrayValue()[2]==1;
  }
  
  boolean isPlay(){
  return experiment_settings.getArrayValue()[3]==1;
  } 
  
  PVector get_position(){
  return new PVector(cp5.getController("gondola_x").getValue(),cp5.getController("gondola_y").getValue(),cp5.getController("gondola_z").getValue());
  }
  
  void set_position(PVector _p){
  cp5.getController("gondola_x").setValue(_p.x);  
  cp5.getController("gondola_y").setValue(_p.y);  
  cp5.getController("gondola_z").setValue(_p.z);  
  }
  
  void add_ports(String[] _portlist){
  
  for (int i=0; i<_portlist.length; i++) {
    
    String s = _portlist[i];
    
    if (s.length() > 20) {
    s = s.substring(0, 17) + "...";
    }
    
    motorcontroller_ports.addItem("Controller on " + s, i+1);
    sensor_ports.addItem("Sensor on "+s, i+1);

  } 
    
    
  }
  
  float get_speed(){
  return cp5.getController("gondola_speed").getValue();
  }
  
  Gui(ControlP5 _parent, Gondola _g){
  
  int controls_offset_y = 0;
  int controls_offset_x = 10;

  // create a controller
  cp5 = _parent;
      
  // create 3 groups
  usb_group = cp5.addGroup("(1) USB ports");
  manual_group = cp5.addGroup("(2) Manual");
  script_group = cp5.addGroup("(3) Auto");      
     
  // Setup   
  controls_offset_y = 20;
  
  motorcontroller_ports = cp5.addRadioButton("Motor_controller")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(10,120)
     .setItemHeight(10)
     .setBarHeight(10)
     .moveTo(usb_group)
     ;    
  
  sensor_ports = cp5.addRadioButton("Sensor port")
     .setPosition(controls_offset_x+130,controls_offset_y)
     .setSize(10,120)
     .setItemHeight(10)
     .setBarHeight(10)
     .moveTo(usb_group)
     ;    
     
  motorcontroller_ports.addItem("Simulation", 0);
  motorcontroller_ports.activate(0);
  sensor_ports.addItem("No sensor", 0);
  sensor_ports.activate(0);
  usb_group.setBackgroundHeight(controls_offset_y+motorcontroller_ports.getItems().size()*10+20);   
  
 
  // manual control   
  controls_offset_y = 20;  
  cp5.addNumberbox("gondola_x")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(110,20)
     .setScrollSensitivity(0.1)
     .setRange(0,world.xDim)
     .setDirection(Controller.HORIZONTAL)
     .setValue(_g.position.x)
     .moveTo(manual_group)
     ; 
     
  cp5.addNumberbox("gondola_speed")
     .setPosition(controls_offset_x+130,controls_offset_y)
     .setSize(110,20)
     .setRange(0.2,10)
     .setScrollSensitivity(0.2)
     .setValue(1)
     .setDirection(Controller.HORIZONTAL)
     .moveTo(manual_group)
     ;  
     
  controls_offset_y += 40;
  cp5.addNumberbox("gondola_y")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(110,20)
     .setScrollSensitivity(1.1)
     .setRange(0,world.yDim)
     .setDirection(Controller.HORIZONTAL)
     .setValue(_g.position.y)
     .moveTo(manual_group)
     ;
     
  cp5.addButton("calibrate")
     .setPosition(controls_offset_x+130,controls_offset_y)
     .setSize(50,20)
     .moveTo(manual_group)
     ;   

  cp5.addButton("sense")
     .setPosition(controls_offset_x+130+50+10,controls_offset_y)
     .setSize(50,20)
     .moveTo(manual_group)
     ;   


  controls_offset_y += 40;
  cp5.addNumberbox("gondola_z")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(110,20)
     .setScrollSensitivity(1.1)
     .setRange(0,world.zDim)
     .setDirection(Controller.HORIZONTAL)
     .setValue(_g.position.z)
     .moveTo(manual_group)
     ;     
  
  cp5.addButton("move")
     .setPosition(controls_offset_x+130,controls_offset_y)
     .setSize(110,20)
     .moveTo(manual_group)
     ;     
 manual_group.setBackgroundHeight(controls_offset_y+50);
 
  // Experiment script
  controls_offset_y = 20;
  
  cp5.addButton("load")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(110,20)
     .moveTo(script_group)
     ;     
  
  experiment_settings = cp5.addCheckBox("experiment_settings")
     .setPosition(controls_offset_x+130,controls_offset_y)
     .setSize(20, 20)
     .setItemsPerRow(1)
     .addItem("Sense",0)
     .addItem("Loop",0)
     .addItem("Plot",0)
     .addItem("Play",0)
     .moveTo(script_group)
     .setItemsPerRow(2)
     .setSpacingColumn(55)
     .setSpacingRow(10)
     ;     
  
  experiment_settings.activate(2);
  experiment_settings.activate(3);
  
  controls_offset_y += 30;
  
  cp5.addButton("clear")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(110,20)
     .moveTo(script_group)
     ;     
     
  
  /*controls_offset_y += experiment_settings.getHeight() + 70; 
  trace_files = cp5.addRadioButton("trace_files")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(20,20)
     .setItemsPerRow(1)
     .moveTo(script_group)
     ;
  
  for (int i=0; i<filelist.length; i++) {
    trace_files.addItem(filelist[i], i);
  }
  */ 
  
  /*controls_offset_y += trace_files.getHeight()+50;
     logging_ports = cp5.addDropdownList("logging_port")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(260,260)
     .setItemHeight(13)
     .setBarHeight(13)
     .moveTo(script_group)
     ;
     
  controls_offset_y += 20;
  cp5.addButton("execute_script")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(260,20)
     .moveTo(script_group)
     ;
     */
  controls_offset_y += 30;
  script_positions = cp5.addDropdownList("Script positions")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(260,150)
     .setItemHeight(15)
     .setBarHeight(15)
     .moveTo(script_group)
     ;
  
  script_group.setBackgroundHeight(controls_offset_y+180);  
     
  accordion = cp5.addAccordion("acc")
    .setPosition(10,40)
    .setWidth(280)
    .setHeight(768)
    .setCollapseMode(Accordion.SINGLE)
    .addItem(usb_group)
    .addItem(manual_group)
    .addItem(script_group)
    ;  
   
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(!isrotating) rotationX += PI/2;}}, UP);   
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(!isrotating) rotationX -= PI/2;}}, DOWN);   
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(!isrotating) rotationY += PI/2;}}, LEFT);   
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(!isrotating) rotationY -= PI/2;}}, RIGHT);   
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {zoom-=100; println(zoom);}}, 'F');      
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {zoom+=100; println(zoom);}}, 'V');      

  
  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(0);accordion.close(1,2,3);}}, '1');      
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(1);accordion.close(0,2,3);}}, '2');    
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(2);accordion.close(0,1,3);}}, '3');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(3);accordion.close(0,1,2);}}, '4');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){cp5.getController("gondola_x").setValue(cp5.getController("gondola_x").getValue()+step_size);}}}, 'a' );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){cp5.getController("gondola_x").setValue(cp5.getController("gondola_x").getValue()-step_size);}}}, 'z' );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){cp5.getController("gondola_y").setValue(cp5.getController("gondola_y").getValue()-step_size);}}}, 's' );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){cp5.getController("gondola_y").setValue(cp5.getController("gondola_y").getValue()+step_size);}}}, 'x' );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){cp5.getController("gondola_z").setValue(cp5.getController("gondola_z").getValue()-step_size);}}}, 'd' );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){cp5.getController("gondola_z").setValue(cp5.getController("gondola_z").getValue()+step_size);}}}, 'c' );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){move(0);}}}, RETURN );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){move(0);}}}, ENTER );    
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){sense(0);}}}, ' ' ); 
  }
}