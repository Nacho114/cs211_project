import java.text.DecimalFormat;

class DataV {
  private final static int margin = 10;
  private final static int textSize = 12;
  
  PGraphics background;
  PGraphics scoreView;
  
  int datavHeight;
  int scorePosX;
  int scorePosY;
  
  float lastScore = 0.;
  float totalScore = 0.;
  
  DecimalFormat numberFormat = new DecimalFormat("#0.000");
  
  DataV() {
    datavHeight = height/4;
    background = createGraphics(width, datavHeight, P3D);
    drawBackground(); // only needs to be drawn once
    
    scorePosX = width/4 + margin;
    scorePosY = margin;
    scoreView = createGraphics(width/4 - 2*margin, datavHeight - 2*margin, P3D);
  }
  
  void addScore(float newScore){
    lastScore = newScore;
    totalScore += lastScore; 
  }
  
  void drawBackground() {
    background.beginDraw();
      background.background(255, 255, 255, 100);
    background.endDraw();
  }
  
  void drawScore(){
    pushStyle();
      textSize(textSize);
      pushMatrix();
        translate(scorePosX + margin, scorePosY + textSize + margin);
        scoreView.beginDraw();
          scoreView.background(255, 255, 255, 100);
          
          fill(0);
          text("Total score : " + numberFormat.format(totalScore) 
            + "\n\nVelocity :     " + numberFormat.format(mover.velocity.mag()) 
            + "\n\nLast score :  " + numberFormat.format(lastScore), 0, 0);
        scoreView.endDraw();
      popMatrix();
    popStyle();
  }
  
  // the origin here is the top left corner of the background
  void drawAll(){
    drawScore();
    
    image(background, 0, 0);
    image(scoreView, scorePosX, scorePosY);
  }
    
}