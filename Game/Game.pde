Mover mover;
Cylinders cylinders;
DataV datav;
import processing.video.*;

// ############### GAME ######################

// distance (on y axis) of the camera from the plate
float depth;

// last click (-> cylinder position)
int lastX;
int lastY;

boolean shift_mode = false;

// rotation around x and z axis
float rx = 0.;
float rz = 0.;

// dimensions
final int boxLength = 300;
final int boxHeight = 10;
final int radius = 10;
final int cylinderRadius = 15;
final int cylinderHeight = 15;

// speed at which the plate is tilted
float amplifier = 1.0;


// ############### IMAGE PROC ####################
ImageProcessing imgproc;

// The input image
PImage base;

// The video
Movie video;

// Put as a global variable to avoid passing the quadGraph as a parameter
QuadGraph qd = new QuadGraph();

// Used because there are no static functions in processing
Filter filter = new Filter();
Convolution conv = new Convolution();
Sobel sobel = new Sobel();

// Predefine some colors
final color black = color(0);
final color white = color(255);



// ############### PROCESSING METHODS ####################

void settings() {
  size(900, 600, P3D);

  // Load image, calculate the size of the output
  base = loadImage("data/board2.jpg");
}


void setup() {  
  // game
  datav = new DataV(boxLength);
  float scale = datav.scale;
  noStroke();
  mover = new Mover(boxLength, boxHeight, radius, scale);
  cylinders = new Cylinders(boxHeight, width, height, cylinderRadius, 
    cylinderHeight, scale);
  depth = sqrt(pow((height/2.0) / tan(PI*30.0 / 180.0), 2)-(height*height/16));
  // image proc
  imgproc = new ImageProcessing();
  //String []args = {"Image processing window"};
  //PApplet.runSketch(args, imgproc);
  
  // video
  video = new Movie(this, "testvideo.mp4");
  video.loop();
}

void draw() {  
  // get image from video
  video.read();
  video.updatePixels();
  base = video.get();
  PImage resized = base.copy();
  resized.resize(0, 200);
  
  // perform detection
  imgproc.process();
  
  // display game
  if (shift_mode) 
    shiftMode();
  else 
    drawPlane();
    
  image(resized, 0, 0);
}


// ########## MODES ############

void shiftMode() {
  camera();
  background(color(255));
  text(mouseX, 175, 140);
  text(mouseY, 300, 140);

  pushMatrix();
  pushStyle();
  translate(width/2, height/2, 0);
  stroke(0);          // Setting the outline (stroke) to black
  fill(150);          // Color of plane 
  box(boxLength, boxLength, 0);
  popStyle();
  popMatrix();

  cylinders.drawAllInShiftMode();
}

void drawPlane() {
  directionalLight(200, 100, 50, 0, 1, 0);
  ambientLight(102, 102, 102);
  background(230);
  
  // get rotations from imgProc
  rx = imgproc.getRotX();
  rz = imgproc.getRotZ();
  rx = min(rx, PI/3);
  rx = max(rx, -PI/3);
  rz = min(rz, PI/3);
  rz = max(rz, -PI/3);

  // data visualization
  pushMatrix();
  pushStyle();
  noStroke();
  fill(200);
  translate(0, (3 * height) / 4, 0);
  datav.drawAll(mover, cylinders);
  popStyle();
  popMatrix();
  datav.updateScroll();

  // plate
  pushMatrix();
  pushStyle();
  noStroke();
  fill(200);
  translate(width/2, height/2, 0);
  rotateX(rx);
  rotateZ(rz);
  box(boxLength, boxHeight, boxLength);

  // update ball
  mover.update(rx, rz);

  // check collision with cylinders and edges, and update score
  datav.updateScoreStatistics(-mover.checkEdges());
  if (mover.checkCylinderCollision(cylinders.locations, cylinderRadius))
    datav.updateScoreStatistics(mover.velocity.mag());

  // display
  mover.display();
  cylinders.paintAll();
  popStyle();
  popMatrix();


  // display text
  pushMatrix();
  translate(width/2, height/2, 0);
  //rotateX(atan(height/4/depth)); // adjust to face camera
  text(rx*180/PI + "\n" + +rz*180/PI + "\n" + amplifier, -width/4, -height/4);
  text(mover.location.x + " : x ", -width/4, -height/4);
  popMatrix();

}


// ########## EVENTS #########

void mouseWheel(MouseEvent event) {
  amplifier -= event.getCount()/50.;
  amplifier = max(0.2, amplifier);
  amplifier = min(5, amplifier);
}


void mousePressed() {
  if (!shift_mode) {
    lastX = mouseX;
    lastY = mouseY;
  } else {
    if (mouseX > width/2 - boxLength/2 && mouseX < width/2 + boxLength/2 && mouseY > height/2 - boxLength/2 && mouseY < height/2 + boxLength/2)
      cylinders.add(mouseX, mouseY);
  }
}

void mouseDragged() {
  rx -= (mouseY - lastY)/1000.*amplifier;
  rz += (mouseX - lastX)/1000.*amplifier;
  rx = min(rx, PI/3);
  rx = max(rx, -PI/3);
  rz = min(rz, PI/3);
  rz = max(rz, -PI/3);

  lastY = mouseY;
  lastX = mouseX;
}

void keyPressed() {
  if (keyCode == SHIFT) {
    shift_mode = true;
    datav.pauseScore();
  }
}

void keyReleased() {
  if (keyCode == SHIFT) {
    shift_mode = false;
    datav.runScore();
  }
}