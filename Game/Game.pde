Mover mover;
Cylinders cylinders;
DataV datav;

float depth;

int lastX;
int lastY;

boolean shift_mode = false;

float rx = 0.;
float rz = 0.;

final int boxLength = 300;
final int boxHeight = 10;
final int radius = 10;
final int cylinderRadius = 15;
final int cylinderHeight = 15;

float amplifier = 1.0;

void settings() {
  size(900, 600, P3D);
}



void setup() {
  noStroke();
  mover = new Mover(boxLength, boxHeight, radius);
  cylinders = new Cylinders(boxHeight, width, height, cylinderRadius, cylinderHeight);
  datav = new DataV();
  depth = sqrt(pow((height/2.0) / tan(PI*30.0 / 180.0), 2)-(height*height/16));
}

void draw() {
  if (!shift_mode) 
    drawPlane();
  else 
    shiftMode();

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
  camera(width/2.0, height/4.0, depth, width/2.0, height/2.0, 0, 0, 1, 0);
  directionalLight(200, 100, 50, 0, 1, 0);
  ambientLight(102, 102, 102);
  background(230);
  
  // data visualization
  pushMatrix();
    translate(width/2, height/2, 0);
    rotateX(atan(height/4/depth)); // adjust to face camera
    translate(-width/2, height/4, 0);
    datav.drawAll();
  popMatrix();

  // plate
  pushMatrix();
    translate(width/2, height/2, 0);
    rotateX(rx);
    rotateZ(rz);
    box(boxLength, boxHeight, boxLength);
    
    // update ball
    mover.update(rx, rz);
    
    // check collision with cylinders and edges
    if(!cylinders.locations.isEmpty()) {
       mover.checkCylinderCollision(cylinders.locations, cylinderRadius);
    }
    mover.checkEdges();
    
    // display
    mover.display();
    cylinders.paintAll();
  popMatrix();
  
  // display text
  /*pushMatrix();
    translate(width/2, height/2, 0);
    rotateX(atan(height/4/depth)); // adjust to face camera
    text(rx*180/PI + "\n" + +rz*180/PI + "\n" + amplifier, -width/4, -height/4);
  popMatrix();*/
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
    if(mouseX > width/2 - boxLength/2 && mouseX < width/2 + boxLength/2 && mouseY > height/2 - boxLength/2 && mouseY < height/2 + boxLength/2)
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
  }
}

void keyReleased() {
  if (keyCode == SHIFT) {
    shift_mode = false;
  }
}