import java.util.Map;

class Sensor {
   
private HashMap<PVector,FloatList> sensor_map;
//private HashMap<PVector,float> heat_map;
  
Sensor(){
  sensor_map = new HashMap<PVector,FloatList>();
  //heat_map = new HashMap<PVector,float>();
} 
  
  
//TODO add number of samples to be senses
public void senseN(PVector _pos, int _n){
}
  
public void sense(PVector _pos){
  FloatList values;
  if ( sensor_map.containsKey(_pos) ) {
    values = sensor_map.get(_pos);
  } else {
    values = new FloatList();
  }
  values.append(random(255));
  sensor_map.put(_pos,values); 
}



public void draw(PGraphics view){
  
for (Map.Entry sensor_point : sensor_map.entrySet()) {
  PVector _pos = (PVector)sensor_point.getKey();
  FloatList _values = (FloatList)sensor_point.getValue();
  // draw sensor point
  view.fill(_values.max());
  view.noStroke();
  view.pushMatrix();
  view.translate(_pos.x,_pos.y,_pos.z);
  view.box(5);
  view.popMatrix();
  view.noFill();
  view.stroke(255);
}

}
private void heatmap(){
  /*heat_map = new HashMap<PVector,float>();
  for (Map.Entry sensor_point : sensor_map.entrySet()) {
    PVector _pos = (PVector)sensor_point.getKey();
    FloatList _values = (FloatList)sensor_point.getValue();
    float _val = _values.max();
  
    _pos.x = (float)round(_pos.x);
    _pos.y = (float)round(_pos.y);
    _pos.z = (float)round(_pos.z);
  
     applyHeat(_pos);
     
     for (int _x = -1;i<=1;i++)
       for(int _y = -1;j<=1;j++;){
       PVector _v = new PVector()
       }
     
    

 
    if ( sensor_map.containsKey(_pos) ) {
      heat_map.put(_pos,sensor_map.get(_pos)+_val); 
    } else {
      heat_map.put(_pos,_val);
    }
    values.append(random(255));
    heat_map.put(_pos,sensor_map.get(_pos)+_val); 
    
    
  }  

  */
}


private void applyHeat(PVector _pos, float _val){
/*
  if ( sensor_map.containsKey(_pos) ) {
      heat_map.put(_pos,sensor_map.get(_pos)+_val); 
  } else {
      heat_map.put(_pos,_val);
  }
       
  }  
  */
}
  
  
  
}