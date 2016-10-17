class ScriptPlayer{

boolean playing = true;
private List<PVector> positions  = new ArrayList<PVector>();

boolean doesCallback = false;
String callbackFunction = "";

void ScriptPlayer(){
}


public List<PVector> getPositions(){
  return positions;
}

public void clearPositions(){
positions.clear();
}

public void callOnChange(String _callback){
doesCallback = true;
callbackFunction = _callback;
}

public void clearOnChange(){
doesCallback = false;
callbackFunction = "";
}


public void setPlaying(boolean _playing){
  playing = _playing;
}

public void loadFile(String _name){

  if (doesCallback) method(callbackFunction);

}

public void addPos(PVector _pos){
  positions.add(_pos);
  if (doesCallback) method(callbackFunction);
}

public PVector popPos(boolean _putback){
  
  if (positions.isEmpty()) return null;
  if (!playing) return null;
  
  PVector _temp = positions.get(0);
  positions.remove(0);
  if ((_putback) && (positions.size()>0)) positions.add(_temp);
  
  if (doesCallback) method(callbackFunction);
  
  return _temp;
}





}