class Projections {

  

  
// Views size (in pixel)
float x_view = x_range*0.8;
float y_view = y_range;
float z_view = z_range;

// Views offsets
float side_off_x = 170;
float side_off_y = 10;
float top_off_x = side_off_x;
float top_off_y = 20+z_view;
float front_off_x = side_off_x+10+x_view;
float front_off_y = 10;


 Projections(){
 }
 


void onClick(){
//TODO: check if one of the projection was clicked. In case select and translate arrows keys into movements

}
 
void draw(Gondola _g, ControlGui _c, List<PVector> _anchors, PGraphics _pg){
 
noStroke();

    // Draw views' background
  fill(#ffffff);
  rect(side_off_x,side_off_y,x_view,z_view);  
  rect(top_off_x,top_off_y,x_view,y_view);
  rect(front_off_x,front_off_y,y_view,z_view);

  fill(#000000);
  textAlign(RIGHT,BOTTOM);
  text("SIDE",front_off_x-15,top_off_y-15);
  textAlign(RIGHT,TOP);
  text("TOP",front_off_x-15,top_off_y+5);
  textAlign(LEFT,BOTTOM);
  text("BACK",front_off_x+5,top_off_y-15);

  _pg.beginDraw();
  _pg.background(#000000);
  _pg.lights();
  _pg.translate(50, 50);
  _pg.rotateY(frameCount * 0.01);
  _pg.box(20);
  _pg.endDraw();  

  image(_pg, front_off_x, top_off_y); 


// Plot gondola
//fill(#ff0000);

//fill(#666666);

// Plot anchors and their cables
int num = 1;
Iterator iterator = _anchors.iterator();
while(iterator.hasNext()){
  PVector a = (PVector)iterator.next();
  strokeWeight(1); 
  stroke(#0000ff);
  line_all(_g.position,a);
  
  // Draw anchor
  noStroke();
  fill(#0000ff);    
  point_all(a,str(num++));

}  

point_all(_c.get_position(),"D");
point_all(_g.position,"G");
 
 }
  
  
  void point(float _x, float _y, String _name){
  fill(#ffffff);  
  stroke(#000000);  
  rect(_x-7,_y-7,14,14);
  textSize(10);
  textAlign(CENTER, CENTER);
  fill(#000000);  
  text(_name, _x, _y); 
  }
  
  
  void point_side(float x, float z, String _name){
float new_x = (1-(x/x_range))*(x_view)+side_off_x;
float new_z = (z/z_range)*(z_view)+side_off_y;
point(new_x,new_z,_name);
}

void point_top(float x, float y, String _name){
float new_x = (1-(x/x_range))*(x_view)+top_off_x;
float new_y = (y/y_range)*(y_view)+top_off_y;
point(new_x,new_y,_name);
}

void point_front(float y, float z, String _name){
float new_y = (1-(y/y_range))*(y_view)+front_off_x;
float new_z = (z/z_range)*(z_view)+front_off_y;
point(new_y,new_z,_name);
}

void point_all(PVector p, String _name){
point_side(p.x,p.z,_name);
point_top(p.x,p.y,_name);
point_front(p.y,p.z,_name);
}

void line_side(float x1, float z1,float x2, float z2){
float new_x1 = (1-(x1/x_range))*(x_view)+side_off_x;
float new_z1 = ((z1/z_range)*z_view)+side_off_y;
float new_x2 = (1-(x2/x_range))*(x_view)+side_off_x;
float new_z2 = ((z2/z_range)*z_view)+side_off_y;
line(new_x1,new_z1,new_x2,new_z2);
}

void line_top(float x1, float y1,float x2, float y2){
float new_x1 = (1-(x1/x_range))*(x_view)+top_off_x;
float new_y1 = (y1/y_range)*(y_view)+top_off_y;
float new_x2 = (1-(x2/x_range))*(x_view)+top_off_x;
float new_y2 = (y2/y_range)*(y_view)+top_off_y;
line(new_x1,new_y1,new_x2,new_y2);
}

void line_front(float y1, float z1,float y2, float z2){
float new_y1 = (1-(y1/y_range))*(y_view)+front_off_x;
float new_z1 = (z1/z_range)*(z_view)+front_off_y;
float new_y2 = (1-(y2/y_range))*(y_view)+front_off_x;
float new_z2 = (z2/z_range)*(z_view)+front_off_y;
line(new_y1,new_z1,new_y2,new_z2);
}

void line_all(PVector p1,PVector p2){
line_side(p1.x,p1.z,p2.x,p2.z);
line_top(p1.x,p1.y,p2.x,p2.y);
line_front(p1.y,p1.z,p2.y,p2.z);
}
  
}
