import java.util.Map;

class Sensor {
   
private HashMap<PVector,FloatList> sensor_map;
//private HashMap<PVector,float> heat_map;
  
Sensor(){
  sensor_map = new HashMap<PVector,FloatList>();
  //heat_map = new HashMap<PVector,float>();
} 
  
    
public void clear(PVector _pos){
sensor_map.remove(_pos);
}

public void sense(PVector _pos,float _val){
  FloatList values;
  if ( sensor_map.containsKey(_pos) ) {
    values = sensor_map.get(_pos);
  } else {
    values = new FloatList();
  }
  values.append(_val);
  sensor_map.put(_pos,values); 
  print("Sensing ");
  print(values.get(values.size()-1));
  print(" at position ");
  println(_pos);
}


// http://www.andrewnoske.com/wiki/Code_-_heatmaps_and_color_gradients
// other gradients https://msdn.microsoft.com/en-us/library/mt712854.aspx
private float[] getHeatmap(float _val){
     
  float[] rgb =    {0.0,0.0,0.0};
  float[] red =    {0.0,0.0,1.0,1.0};
  float[] green =  {0.0,1.0,1.0,0.0};
  float[] blue =   {1.0,0.0,0.0,0.0};
  int num_colors = 4;
  int idx1;        // |-- Our desired color will be between these two indexes in "color".
  int idx2;        // |
  float fractBetween = 0.0;  // Fraction between "idx1" and "idx2" where our value is.

  if(_val <= 0) {
    idx1 = 0;
    idx2 = 0;
  }
  else if(_val >= 1) {  
    idx1 = num_colors-1;
    idx2 = num_colors-1; 

  }    // accounts for an input >=0
  else {
    _val = _val * (num_colors-1);        // Will multiply value by 3.
    idx1  = floor(_val);                  // Our desired color will be after this index.
    idx2  = idx1+1;                        // ... and before this index (inclusive).
    fractBetween = _val - (1.0*idx1);    // Distance between the two indexes (0-1).  
  }
  rgb[0]   = red[idx1]*(1-fractBetween) + red[idx2]*fractBetween;
  rgb[1]   = green[idx1]*(1-fractBetween) + green[idx2]*fractBetween;
  rgb[2]   = blue[idx1]*(1-fractBetween) + blue[idx2]*fractBetween;
  return rgb;
}


public void draw(PGraphics view){

float _max = -100000000.0;
float _min = 100000000.0;

// get the min and max median for all positions (this way we ignore outliers)
for (Map.Entry sensor_point : sensor_map.entrySet()) {
  FloatList _values = (FloatList)sensor_point.getValue();
  _values.sort();
  float _median = _values.get(floor(_values.size()/2));
  if (_max < _median) _max = _median;
  if (_min > _median) _min = _median;
}

for (Map.Entry sensor_point : sensor_map.entrySet()) {
  PVector _pos = (PVector)sensor_point.getKey();
  FloatList _values = (FloatList)sensor_point.getValue();
  float _median,greyscale;
  float[] heatmap;
  // compute median value and normalize color based on min and max median
  _values.sort();
  _median = _values.get(floor(_values.size()/2));
  greyscale = (_median-_min)/(_max-_min);
  heatmap = getHeatmap(greyscale);
  // draw sensor point  
  view.fill(heatmap[0]*255,heatmap[1]*255,heatmap[2]*255);
  view.noStroke();
  view.pushMatrix();
  view.translate(_pos.x,_pos.y,_pos.z);
  view.box(step_size/2);
  view.popMatrix();
  view.noFill();
  view.stroke(255);
}

}


  
  
  
}