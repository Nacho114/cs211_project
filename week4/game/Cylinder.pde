class Cylinder {
  float cylinderBaseSize = 20;
  float cylinderHeight = 20;
  int cylinderResolution = 40;
  float height;
  int w;
  int h;
  PShape openCylinder = new PShape();
  PShape top = new PShape();
  PShape bottom = new PShape();
  color c = color(0, 0, 0);
  ArrayList<PVector> locations = new ArrayList<PVector>();

  /* 
     Note the w and h values are the width and height, which is used
     to translate between shift mode plane and game plane.
    (possibly better way exists?) 
  */
  Cylinder(float height, int w, int h, float cylinderBaseSize, float cylinderHeight) {
    this.height = height/2.;
    this.h = h/2;
    this.w = w/2;
    this.cylinderBaseSize = cylinderBaseSize;
    this.cylinderHeight = cylinderHeight;

    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    //get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], y[i], 0);
      openCylinder.vertex(x[i], y[i], cylinderHeight);
    }
    openCylinder.vertex(0, 0, cylinderHeight);
    openCylinder.endShape();

    top = createShape();
    top.beginShape(TRIANGLES);
    //draw top of cylinder
    for (int j = 0; j < x.length; j++) {
      top.vertex(0, 0, cylinderHeight);
      top.vertex(x[j], y[j], cylinderHeight);
      top.vertex(0, 0, cylinderHeight);
    }
    top.endShape();

    bottom = createShape();
    bottom.beginShape(TRIANGLES);
    //draw bottom of cylinder
    for (int j = 0; j < x.length; j++) {
      bottom.vertex(0, 0, 0);
      bottom.vertex(x[j], y[j], 0);
      bottom.vertex(0, 0, 0);
    }
    bottom.endShape();

  }
  
  // Method to add vectors, w and h are subtracted in order to have it in 
  // coordinates with the center of the board game as the (0, 0) vector
  void add(float x, float y) {
    locations.add(new PVector(x - w, y - h));
  }

  // Method to draw all cylinders to the shift mode plane
  void drawAllInShiftMode() {
    for (PVector v: locations) {
      drawInShiftMode(v.x, v.y);
    }
  }
  
  // Method to draw all cylinders to the board game
  void paintAll() {
    for (PVector v: locations) {
      paint(v.x, v.y);
    }
  }

  // draw an individual cylinder to the shift plane
  // sums w and h to account for the translation to the center of the board.
  void drawInShiftMode(float x, float y) {

    pushMatrix();
    translate(x + w, y + h, 0);
    shape(top);
    shape(openCylinder);
    shape(bottom);
    popMatrix();
  }

  // draws an individual cylinder to the board game
  void paint(float x, float y) {
    pushMatrix();
    rotateX(PI/2);
    translate(x, y, height);

    shape(top);
    shape(openCylinder);
    shape(bottom);
    popMatrix();
  }


}
