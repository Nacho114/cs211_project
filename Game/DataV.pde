import java.text.DecimalFormat;

class DataV {
  private final static int margin = 10;
  private final static int textSize = 12;
  private final color topViewBoardColor = color(51, 153, 255);
  
  PGraphics background;
  PGraphics scoreView;
  PGraphics topView;
  
  int datavHeight;
  int gameBoxLength;
  int scorePosX;
  int scorePosY;
  int topViewPosX;
  int topViewPosY;
  int topViewBoardDim;

  // Important for topView:
  // Note on scale, when drawing a shape it needs to be scaled 2 * scale
  // since the origin is in the middle of the plane.
  float scale;

  float lastScore = 0.;
  float totalScore = 0.;
  
  DecimalFormat numberFormat = new DecimalFormat("#0.000");
  
  DataV(int gameBoxLength) {
    datavHeight = height/4;
    this.gameBoxLength = gameBoxLength;
    background = createGraphics(width, datavHeight, P3D);
    drawBackground(); // only needs to be drawn once
    
    scorePosX = width/4 + margin;
    scorePosY = margin;
    topViewPosX = margin;
    topViewPosY = margin;
    topViewBoardDim = datavHeight - 2*margin;
    scale = topViewBoardDim /((float) gameBoxLength);

    scoreView = createGraphics(width/4 - 2*margin, datavHeight - 2*margin, P3D);
    topView = createGraphics(width/4 - 2*margin, datavHeight - 2*margin, P3D);
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
  
  void drawTopView(Mover mover, Cylinders cylinders) {
    pushStyle();
      topView.beginDraw();
      topView.fill(topViewBoardColor);
      topView.rect(0, 0, topViewBoardDim, topViewBoardDim);

      topView.pushMatrix();
        topView.translate(topViewBoardDim/2.0, topViewBoardDim/2.0);
        mover.displayTopView(topView); 
        cylinders.paintAllInTopView(topView);
      topView.popMatrix();

      topView.endDraw();
    popStyle();
  } 
  
  // the origin here is the top left corner of the background
  void drawAll(Mover mover, Cylinders cylinders){
    drawScore();
    drawTopView(mover, cylinders);
    
    image(background, 0, 0);
    image(scoreView, scorePosX, scorePosY);
    image(topView, topViewPosX, topViewPosY);
  }
    
}
