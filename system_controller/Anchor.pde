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
    // note that the motor controller approximate the distance by 0.5mm. Therefore, we return a distance that take this approximation into account
    // note also that in our system controller, we kkep the distances with the highest accuracy possible
    //return ((round(distance*20.0)/2.0) - (round(old_distance*2.0)/2.0));
    return distance-old_distance;
  }

  public void draw(PGraphics view, PVector _gondola){
    view.pushMatrix();
    view.translate(position.x,position.y,position.z);
    // TODO change color if the anchor is selected
    view.box(step_size);
    view.popMatrix();
    view.line(position.x,position.y,position.z,_gondola.x,_gondola.y,_gondola.z);
  }


}