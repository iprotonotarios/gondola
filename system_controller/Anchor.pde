class Anchor {
  
  int id;
  PVector position;
  boolean selected = false;
  Float distance = 0.0;
  
  Anchor (PVector _pos) {  
    position = _pos;
    selected = false;
    distance = 0.0;
  }  

  Float updateDistance(PVector gondola_position){
    Float old_distance = distance;
    distance = PVector.dist(gondola_position,position);
    return distance-old_distance;
  }

  public void draw(PGraphics view, PVector _gondola){
    view.pushMatrix();
    view.translate(position.x,position.y,position.z);
    // TODO change color if the anchor is selected
    view.box(10);
    view.popMatrix();
    view.line(position.x,position.y,position.z,_gondola.x,_gondola.y,_gondola.z);
  }


}