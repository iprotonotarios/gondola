class ControlGui {

ControlP5 cp5;
RadioButton trace_files;      
DropdownList trace_commands,controller_ports,logging_ports;
CheckBox experiment_settings;
Accordion accordion;

Group calibration_group,manual_group,script_group,configuration_group;
 
  
  boolean isManual(){
    return manual_group.isOpen();
  }
  
  boolean isCalibrationText(){
    return (cp5.get(Textfield.class,"cal_x").isActive() || cp5.get(Textfield.class,"cal_y").isActive() || cp5.get(Textfield.class,"cal_z").isActive()) ;
  }
  
  boolean isCalibrationTextX(){
    return (cp5.get(Textfield.class,"cal_x").isActive());
  }
  boolean isCalibrationTextY(){
    return (cp5.get(Textfield.class,"cal_y").isActive());
  }
  boolean isCalibrationTextZ(){
    return (cp5.get(Textfield.class,"cal_z").isActive());
  }
  
  
  boolean isCalibration(){
    return calibration_group.isOpen();
  }
  
  boolean isScript(){
    return script_group.isOpen();
  }
  
  
  boolean isTracing(){
  return experiment_settings.getArrayValue()[0]==1;
  }
  
  boolean isLoop(){
  return experiment_settings.getArrayValue()[1]==1;
  }
  
  PVector get_cal(){
    float _x = float(cp5.get(Textfield.class,"cal_x").getText());
    float _y = float(cp5.get(Textfield.class,"cal_y").getText());
    float _z = float(cp5.get(Textfield.class,"cal_z").getText());
  return new PVector(_x,_y,_z);
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
    
    controller_ports.addItem(s, i);
    logging_ports.addItem(s, i);

  } 
    
    
  }
  
  float get_speed(){
  return cp5.getController("gondola_speed").getValue();
  }
  
  ControlGui(ControlP5 _parent, String[] filelist, Gondola _g){
  int controls_offset_y = 0;
  int controls_offset_x = 10;
  // create a controller
  cp5 = _parent;
    
  // create 3 groups
  calibration_group = cp5.addGroup("(1) calibration")
     .setBackgroundHeight(150)
     ;
  manual_group = cp5.addGroup("(2) manual") 
     .setBackgroundHeight(280)
     ;
  script_group = cp5.addGroup("(3) load_script")
     .setBackgroundHeight(150)
     ;   
     
  // Config   
   
     
   
     
      
     
  // Calibration   
  controls_offset_y = 20;
  
  cp5.addTextfield("cal_x")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(100,14)
     .setText(Float.toString(_g.position.x))
     .setAutoClear(false)
     .moveTo(calibration_group)
     ;
  controls_offset_y += 30;
  cp5.addTextfield("cal_y")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(100,14)
     .setText(Float.toString(_g.position.y))
     .setAutoClear(false)
     .moveTo(calibration_group)
     ;
  controls_offset_y += 30;
  cp5.addTextfield("cal_z")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(100,14)
     .setText(Float.toString(_g.position.z))
     .setAutoClear(false)
     .moveTo(calibration_group)
     ;
  controls_offset_y += 40;
  cp5.addButton("calibrate")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(100,14)
     .moveTo(calibration_group)
     ;        
  controls_offset_y = 20;  
  cp5.addNumberbox("gondola_x")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(100,14)
     .setScrollSensitivity(1.1)
     .setRange(0,x_range)
     .setDirection(Controller.HORIZONTAL)
     .setValue(_g.position.x)
     .moveTo(manual_group)
     ;  
  controls_offset_y += 30;
  cp5.addNumberbox("gondola_y")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(100,14)
     .setScrollSensitivity(1.1)
     .setRange(0,y_range)
     .setDirection(Controller.HORIZONTAL)
     .setValue(_g.position.y)
     .moveTo(manual_group)
     ;
  controls_offset_y += 30;
  cp5.addNumberbox("gondola_z")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(100,14)
     .setScrollSensitivity(1.1)
     .setRange(0,z_range)
     .setDirection(Controller.HORIZONTAL)
     .setValue(_g.position.z)
     .moveTo(manual_group)
     ;     
  controls_offset_y += 40;
  
   cp5.addKnob("gondola_speed")
               .setRange(100,2000)
               .setValue(500)
 .setNumberOfTickMarks(100)
               .setTickMarkLength(4)
               .snapToTickMarks(true)
               .setPosition(controls_offset_x,controls_offset_y)
               .setRadius(50)
               .setDragDirection(Knob.VERTICAL)
                    .moveTo(manual_group)
               ;
  
//  cp5.addNumberbox("gondola_speed")
//     .setPosition(controls_offset_x,controls_offset_y)
//     .setSize(100,14)
//     .setScrollSensitivity(1.1)
//     .setRange(1,10)
//     .setDirection(Controller.HORIZONTAL)
//     .setValue(3.0)
//     .moveTo(manual_group)
//     ;    
 controls_offset_y += 130;
 cp5.addButton("goto_xyz")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(100,14)
     .moveTo(manual_group)
     ;     
 
  // Experiment script
  controls_offset_y = 20;
  experiment_settings = cp5.addCheckBox("experiment_settings")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(10, 10)
     .setItemsPerRow(1)
     .addItem("Trace",0)
     .addItem("Loop",0)
     .addItem("Log",0)
     .moveTo(script_group)
     ;
      
  controls_offset_y += experiment_settings.getHeight() + 40;
  trace_files = cp5.addRadioButton("trace_files")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(10,10)
     .setItemsPerRow(1)
     .moveTo(script_group)
     ;
  for (int i=0; i<filelist.length; i++) {
    trace_files.addItem(filelist[i], i);
  } 
  
   controls_offset_y += trace_files.getHeight()+40;
     logging_ports = cp5.addDropdownList("logging_port")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(100,100)
     .setItemHeight(13)
     .setBarHeight(13)
     .moveTo(script_group)
     ; 
     
  
  controls_offset_y += 20;   
  cp5.addButton("execute_script")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(100,14)
     .moveTo(script_group)
     ;
     
  controls_offset_y += 40;
  trace_commands = cp5.addDropdownList("trace_commands")
     .setPosition(controls_offset_x,controls_offset_y)
     .setSize(100,150)
     .setItemHeight(15)
     .setBarHeight(15)
     .moveTo(script_group)
     ;    
     
     
  accordion = cp5.addAccordion("acc")
    .setPosition(10,40)
    .setWidth(120)
    .setHeight(600)
    .setCollapseMode(Accordion.SINGLE)
    .addItem(calibration_group)
    .addItem(manual_group)
    .addItem(script_group)
    ;  
    
   controller_ports = cp5.addDropdownList("controller_port")
     .setPosition(10,25)
     .setSize(120,120)
     .setItemHeight(13)
     .setBarHeight(13)
     ;    
    
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(!isCalibrationText()){accordion.open(0);accordion.close(1,2);}}}, '1');    
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(!isCalibrationText()){accordion.open(1);accordion.close(0,2);}}}, '2');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(!isCalibrationText()){accordion.open(2);accordion.close(0,1);}}}, '3');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){cp5.getController("gondola_x").setValue(cp5.getController("gondola_x").getValue()+10);}}}, 'a' );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){cp5.getController("gondola_x").setValue(cp5.getController("gondola_x").getValue()-10);}}}, 'z' );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){cp5.getController("gondola_y").setValue(cp5.getController("gondola_y").getValue()-10);}}}, 's' );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){cp5.getController("gondola_y").setValue(cp5.getController("gondola_y").getValue()+10);}}}, 'x' );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){cp5.getController("gondola_z").setValue(cp5.getController("gondola_z").getValue()-10);}}}, 'd' );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){cp5.getController("gondola_z").setValue(cp5.getController("gondola_z").getValue()+10);}}}, 'c' );  



  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){println("return");goto_xyz(0);}}}, RETURN );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isManual()){println("return");goto_xyz(0);}}}, ENTER );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isCalibration()){println("return");calibrate(0);}}}, RETURN );  
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isCalibration()){println("return");calibrate(0);}}}, ENTER );  
  
  // if we press tab in calibration and nothing is selected, select first field

  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isCalibrationTextZ()){cp5.get(Textfield.class,"cal_x").setFocus(false);cp5.get(Textfield.class,"cal_y").setFocus(false);cp5.get(Textfield.class,"cal_z").setFocus(false);}}}, TAB);    
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isCalibrationTextY()){cp5.get(Textfield.class,"cal_x").setFocus(false);cp5.get(Textfield.class,"cal_y").setFocus(false);cp5.get(Textfield.class,"cal_z").setFocus(true);}}}, TAB);    
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isCalibrationTextX()){cp5.get(Textfield.class,"cal_x").setFocus(false);cp5.get(Textfield.class,"cal_y").setFocus(true);cp5.get(Textfield.class,"cal_z").setFocus(false);}}}, TAB);    
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {if(isCalibration() && (!isCalibrationText())){cp5.get(Textfield.class,"cal_x").setFocus(true);}}}, TAB);    


  }
}
