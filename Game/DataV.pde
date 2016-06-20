import java.text.DecimalFormat;

class DataV {
  private final static int margin = 10;
  private final static int textSize = 12;
  private final color topViewBoardColor = color(51, 153, 255);
  private final color barChartColor = color(255, 255, 255, 100);
  private final color scoreColor = color(255, 255, 255, 100);
  private final color red = color(255, 0, 0); // Color for negative scores
  private final color green = color(0, 255, 0); // Color for positive scores
  private final float minNewScore = 0.2; // abs(score) must be greater than this value to count
  private final int timeInterval = 1000; // For scorechart, one second
  private final int scrollBarLength = width / 2 - 4 * margin; // For scroll length
  
  PGraphics background;
  PGraphics scoreView;
  PGraphics topView;
  PGraphics barChart;
  
  int datavHeight;
  int gameBoxLength;
  int scorePosX;
  int scorePosY;
  int topViewPosX;
  int topViewPosY;
  int barChartPosX;
  int barChartPosY;
  int topViewBoardDim;
  float scoreLastTimeInterval = 0.;
  int lastTimeInterval = 0;
  Timer timer;
  HScrollbar hs;

  // Important for topView:
  // Note on scale, when drawing a shape it needs to be scaled 2 * scale
  // since the origin is in the middle of the plane.
  float scale;

  float lastScore = 0.;
  float totalScore = 0.;
  ArrayList<Float> scores = new ArrayList<Float>();
  
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
    barChartPosX = width/2 + margin;
    barChartPosY = margin;
    topViewBoardDim = datavHeight - 2*margin;
    scale = topViewBoardDim /((float) gameBoxLength);
    
    timer = new Timer();
    hs = new HScrollbar((3*width)/4 - scrollBarLength/2, height - 4 * margin, scrollBarLength, 20);

    scoreView = createGraphics(width/4 - 2*margin, datavHeight - 2*margin, P2D);
    topView = createGraphics(width/4 - 2*margin, datavHeight - 2*margin, P2D);
    barChart = createGraphics(width/2- 2*margin, datavHeight - 2*margin, P2D);
    
  }
  
  void updateScroll(){
    pushStyle();
      hs.update();
      hs.display();
    popStyle();
  }
  
  void pauseScore(){
    timer.pause();
  }
  
  void runScore(){
    timer.run();
  }
  
  void updateScoreStatistics(float newScore){
    if (timer.getElapsed()/timeInterval > lastTimeInterval){
      scores.add(scoreLastTimeInterval);
      lastTimeInterval++;
      scoreLastTimeInterval = 0.;
    }
    if (abs(newScore) > minNewScore){
      lastScore = newScore;
      totalScore += lastScore;
      scoreLastTimeInterval += newScore;
    }
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
          scoreView.background(scoreColor);
          
          fill(0);
          text("Total score : " + numberFormat.format(totalScore) 
            + "\n\nVelocity :     " + numberFormat.format(mover.velocity.mag()) 
            + "\n\nLast score :  " + numberFormat.format(lastScore), 0, 0);
        scoreView.endDraw();
      popMatrix();
    popStyle();
  }
  
  void drawBarChart(){
    hs.update();
    float chartLength = width/2 - 4*margin;
    int nbToShow = 10 + (int)(90 * ((exp(hs.getPos()) - 1) / exp(1)));
    int recHeight = 5;
    float recLength = chartLength / nbToShow;
    int heightBegin = datavHeight - 6*margin;
    pushStyle();
      barChart.beginDraw();
      barChart.background(barChartColor);
      int beginIndex = max(0, scores.size() - nbToShow);
      for (int i=beginIndex; i < scores.size(); i++){
        int h = 1 + (int)log(1. + 1000. * abs(scores.get(i))); // Logarithmic scale to show the differences
        if (scores.get(i) >= 0.)
          barChart.fill(green);
        else
          barChart.fill(red);
        for (int j=0; j<h; j++){
          barChart.rect(margin + ((i - beginIndex) * recLength), heightBegin - (j*recHeight), recLength, -recHeight);
        }
      }

      
      barChart.endDraw();
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
    drawBarChart();
    
    image(background, 0, 0);
    image(scoreView, scorePosX, scorePosY);
    image(topView, topViewPosX, topViewPosY);
    image(barChart, barChartPosX, barChartPosY);
  }
    
}