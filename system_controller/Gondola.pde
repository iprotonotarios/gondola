class Gondola{
 
  private PVector position;
  private PVector destination;
  //private float speed;
  private GondolaState state = GondolaState.IDLE;
  private boolean selected = false; 
  private List<Anchor> anchors = new ArrayList<Anchor>();
  
  Gondola (PVector _pos){
    position = _pos;
    destination = _pos;
  } 

  public PVector getPosition(){
    return position;
  }

  public void addAnchor(Anchor _anchor){
    _anchor.updateDistance(position); //compute anchor's distance from gondola
    anchors.add(_anchor);
  }

  public List<Float> move (PVector _dst){
   List<Float> deltas = new ArrayList<Float>();
   
   if (state != GondolaState.IDLE){
     print("Cannot move gondola since it is not in IDLE state. Current state:");
     println(state);
     return null;
   }
    
   if (PVector.dist(position,_dst)==0) {
      println("Nothing to move");
      return null;
    }
    
   destination = _dst;
   state = GondolaState.MOVING;
   
   Iterator iter = anchors.iterator();
   while(iter.hasNext()){
      Anchor _a = (Anchor)iter.next();
      deltas.add(_a.updateDistance(_dst)); // update each anchor distance and store the spooling delta
   }
   
   return deltas;
  }

  public void destination_reached(){
    position = destination;
    state = GondolaState.IDLE;
    println("Reached destination");
  }

  public void draw(PGraphics view){
  // draw anchors and lines
  Iterator iterator = anchors.iterator();
  while(iterator.hasNext()){
    Anchor _a = (Anchor)iterator.next();
    _a.draw(view,position);
  }  
  // draw gondola
  view.pushMatrix();
  view.translate(position.x,position.y,position.z);
  // TODO change color if the anchor is selected
  view.box(10);
  view.popMatrix();
  
  }

  public boolean mouse_select(float mouseX, float mouseY){
    
  // scan all objects untile one is closer than x pixels. if no object is close to the mouse, return false
  // the selection is stored in the object
  
  // check distance with gondola
  // call mouse_select on each anchor and get back a bolean
  // return false
  
  
  //get selected object
  //print( view_3d.screenX(g.position.x, g.position.y, g.position.z));
  //print("-");
  //println( view_3d.screenY(g.position.x, g.position.y, g.position.z));
  return true;
  }

  boolean isIdle(){ 
    //return state.equals("idle");
    return (state==GondolaState.IDLE);
  }

  boolean isMoving(){ 
    //return state.equals("moving");
    return (state==GondolaState.MOVING);
  }

  //boolean isWaiting(){ return state.equals("waiting");}
  
  /*
  public void set_distances (List<Float> _dist){
  for(int i=0;i<num_anchors;i++){
   anchors_dist.set(i,_dist.get(i));
   }
  float y = (pow(anchors_dist.get(0),2)-pow(anchors_dist.get(1),2)+pow(anchors.get(1).y,2))/(2*anchors.get(1).y);
  float x = (pow(anchors_dist.get(0),2)-pow(anchors_dist.get(2),2)+pow(anchors.get(2).y,2)+pow(anchors.get(2).x,2))/(2*anchors.get(2).x)-(anchors.get(2).y/anchors.get(2).x)*y;
  float z = sqrt(abs(pow(anchors_dist.get(0),2)-pow(y,2)-pow(x,2)));
  position.set(x,y,z);
  }
  */
  
  /*
  void clear_positions(){
  positions.clear();
  }

  void enqueue_position(PVector _pos){
  positions.add(_pos);
  }
  */
  
  /*
  public List<Float> move(boolean loop){
    destination = positions.pollFirst();    
    if (destination == null) return null;
    
    if (PVector.dist(position,destination)==0) {
      println("Nothing to move");
      return null;
    }
    
    if (loop) positions.add(destination);
    
    for(int i=0;i<num_anchors;i++){
      anchors_new_dist.set(i,PVector.dist(destination,anchors.get(i))-anchors_dist.get(i));
    }
    state = "waiting";
    return anchors_new_dist;
  }
  */
  
  
}