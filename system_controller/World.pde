class World{

  public Float xDim;
  public Float yDim;
  public Float zDim;
  
  World(float _x, float _y, float _z){
    xDim = _x;
    yDim = _y;
    zDim = _z;
  }
  
  public boolean contains(PVector _pos){
    //check is a position is contained in the boundaries
    return true;
  }
  
  public void draw(PGraphics view){ 
    view.pushMatrix();
    view.translate(xDim/2,yDim/2,zDim/2);
    view.noFill();
    view.box(xDim,yDim,zDim);
    view.popMatrix();
    //draw coordinate system
    view.stroke(255, 0, 0);
    view.line(0,0,0,100,0,0);
    view.stroke(0, 255, 0);
    view.line(0,0,0,0,100,0);
    view.stroke(0, 0, 255);
    view.line(0,0,0,0,0,100);
    view.stroke(255);    
  }
  
  public void draw_coordinates(PGraphics _view, int offsetX, int offsetY){
  fill(255,0,0);   
  text('x', offsetX + _view.screenX(100,0,0),offsetY + _view.screenY(100,0,0));
  fill(0,255,0);   
  text('y', offsetX + _view.screenX(0,100,0),offsetY + _view.screenY(0,100,0));
  fill(0,0,255);   
  text('z', offsetX + _view.screenX(0,0,100),offsetY + _view.screenY(0,0,100));
  fill(255);
  }

}