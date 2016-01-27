
class Gondola {
  
  PVector position;
  PVector destination;
  float speed;
  
  int num_anchors = 0;  
  List<PVector> anchors = new ArrayList<PVector>();
  List<Float> anchors_dist = new ArrayList<Float>();
  List<Float> anchors_new_dist = new ArrayList<Float>();

  LinkedList<PVector> positions = new LinkedList<PVector>();

  
  String state = "idle";
  
  Gondola (PVector _pos,  List<PVector> _anchors) {  
    // add all anchors
    Iterator iterator = _anchors.iterator();
    while(iterator.hasNext()){
      anchors.add((PVector)iterator.next());
      anchors_dist.add(0.0);
      anchors_new_dist.add(0.0);
      num_anchors++;
    }  
    // set gondola position
    set_position(_pos);
    // Set destination to position 
    destination = _pos;
  } 

  boolean isIdle(){
  return state.equals("idle");
  }

  boolean isMoving(){
  return state.equals("moving");
  }

  boolean isWaiting(){
  return state.equals("waiting");
  }
  
  void set_position (PVector _pos){
   position = _pos;
   for(int i=0;i<num_anchors;i++){
   anchors_dist.set(i,PVector.dist(position,anchors.get(i)));
   }
  }
  
  public void set_distances (List<Float> _dist){
  for(int i=0;i<num_anchors;i++){
   anchors_dist.set(i,_dist.get(i));
   }
  float y = (pow(anchors_dist.get(0),2)-pow(anchors_dist.get(1),2)+pow(anchors.get(1).y,2))/(2*anchors.get(1).y);
  float x = (pow(anchors_dist.get(0),2)-pow(anchors_dist.get(2),2)+pow(anchors.get(2).y,2)+pow(anchors.get(2).x,2))/(2*anchors.get(2).x)-(anchors.get(2).y/anchors.get(2).x)*y;
  float z = sqrt(abs(pow(anchors_dist.get(0),2)-pow(y,2)-pow(x,2)));
  position.set(x,y,z);
  }


  void clear_positions(){
  positions.clear();
  }

  void enqueue_position(PVector _pos){
  positions.add(_pos);
  }

  
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
  
  public void destination_reached(){
  set_position(destination);
  //println("gondola stopping");
  //println("New distances "+anchors_dist);
  state = "idle";
  }
   
}
