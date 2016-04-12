class Cylinders {
  float cylinderBaseSize = 20;
  float cylinderHeight = 20;
  int cylinderResolution = 40;
  float height;
  int w;
  int h;
  PShape cylinderShape = new PShape();

  // Variables used for topView
  PShape topViewCylinderShape = new PShape();
  float scale;

  color c = color(0, 0, 0);
  ArrayList<PVector> locations = new ArrayList<PVector>();

  /* 
   Note the w and h values are the width and height, which is used
   to translate between shift mode plane and game plane.
   (possibly better way exists?) 
   */
  Cylinders(float height, int w, int h, float cylinderBaseSize, float cylinderHeight, float scale) {
    this.height = height/2.;
    this.h = h/2;
    this.w = w/2;
    this.cylinderBaseSize = cylinderBaseSize;
    this.cylinderHeight = cylinderHeight;
    this.scale = scale;
    
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];

    //get the x and y positions on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }

    PShape sides = new PShape();
    PShape top = new PShape();
    PShape bottom = new PShape();

    sides = createShape();
    sides.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      sides.vertex(x[i], y[i], 0);
      sides.vertex(x[i], y[i], cylinderHeight);
    }
    sides.endShape();


    top = createShape();
    top.beginShape(TRIANGLE_FAN);
    top.vertex(0, 0, 0);
    //draw the top of the cylinder
    for (int i = 0; i < x.length; i++) {
      top.vertex(x[i], y[i], 0);
    }
    top.endShape();

    bottom = createShape();
    bottom.beginShape(TRIANGLE_FAN);
    bottom.vertex(0, 0, cylinderHeight);
    //draw the bottom of the cylinder
    for (int i = 0; i < x.length; i++) {
      bottom.vertex(x[i], y[i], cylinderHeight);
    }
    bottom.endShape();

    // For topView
    float scaleObj = 2 * scale; 
    topViewCylinderShape = createShape(ELLIPSE, 0, 0, cylinderBaseSize * scaleObj, cylinderBaseSize * scaleObj);

    cylinderShape = createShape(GROUP);
    cylinderShape.addChild(sides);
    cylinderShape.addChild(bottom);
    cylinderShape.addChild(top);
  }

  // Method to add vectors, w and h are subtracted in order to have it in 
  // coordinates with the center of the board game as the (0, 0) vector
  void add(float x, float y) {
    locations.add(new PVector(x - w, y - h));
  }

  // Method to draw all cylinders to the shift mode plane
  void drawAllInShiftMode() {
    for (PVector v : locations) {
      drawInShiftMode(v.x, v.y);
    }
  }

  // Method to draw all cylinders to the board game
  void paintAll() {
    for (PVector v : locations) {
      paint(v.x, v.y);
    }
  }

  // draw an individual cylinder to the shift plane
  // sums w and h to account for the translation to the center of the board.
  void drawInShiftMode(float x, float y) {

    pushMatrix();
    translate(x + w, y + h, 0);
    shape(cylinderShape);
    popMatrix();
  }

  // draws an individual cylinder to the board game
  void paint(float x, float y) {
    pushMatrix();
    rotateX(PI/2);
    translate(x, y, height);

    shape(cylinderShape);
    popMatrix();
  }


  // Method to draw all cylinders to the topView 
  void paintAllInTopView(PGraphics topView) {
    for (PVector v : locations) {
      paintTopView(v.x, v.y, topView);
    }
  }

  // Draw an individual cylinder to top view
  void paintTopView(float x, float y, PGraphics topView) {
    topView.pushMatrix();
    topView.pushStyle();
      topView.translate(x * scale, y * scale);
      topView.noStroke(); 
      topView.fill(102, 51, 0);
      topView.shape(topViewCylinderShape);
    topView.popStyle();
    topView.popMatrix();   
  }

}