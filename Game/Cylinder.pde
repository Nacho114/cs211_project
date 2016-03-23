class Cylinders {
  float cylinderBaseSize = 20;
  float cylinderHeight = 20;
  int cylinderResolution = 40;
  float height;
  int w;
  int h;
  PShape cylinderShape = new PShape();

  color c = color(0, 0, 0);
  ArrayList<PVector> locations = new ArrayList<PVector>();

  /* 
   Note the w and h values are the width and height, which is used
   to translate between shift mode plane and game plane.
   (possibly better way exists?) 
   */
  Cylinders(float height, int w, int h, float cylinderBaseSize, float cylinderHeight) {
    this.height = height/2.;
    this.h = h/2;
    this.w = w/2;
    this.cylinderBaseSize = cylinderBaseSize;
    this.cylinderHeight = cylinderHeight;
    
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
}