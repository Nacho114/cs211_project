
class Timer{
  int elapsed;
  int last;
  boolean paused;
  
  Timer(){
    init();
  }
  
  void init(){
    elapsed = 0;
    last = millis();
    paused = false;
  }
  
  void pause(){ // To pause timer
    if (!paused){
      getElapsed();
      paused = true;
    }
  }
  
  void run(){
    if (paused){
      paused = false;
      last = millis();
    }
  }
  
  int getElapsed(){
    if (paused)
      return elapsed;
    int curr = millis();
    elapsed += curr - last;
    last = curr;
    return elapsed;
  }
  
}