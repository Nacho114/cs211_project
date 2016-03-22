Mover mover;
Cylinder cylinder;

float depth = 300;

int lastX;
int lastY;

boolean shift_mode = false;

float rx = 0.;
float rz = 0.;

final int boxLength = 200;
final int boxHeight = 10;
final int radius = 10;
final int cylinder_radius = 15;
final int cylinder_height = 15;

float amplifier = 1.0;

void settings() {
  size(800, 600, P3D);
}

void setup() {
  mover = new Mover(boxLength, boxHeight, radius);
  cylinder = new Cylinder(boxHeight, width, height, cylinder_radius, cylinder_height);
}

void draw() {
  if (!shift_mode) 
    drawPlane();
  else 
    shiftMode();
}

void shiftMode() {
  camera();
  background(color(255));
  text(mouseX, 175, 140);
  text(mouseY, 300, 140);
  pushMatrix();
    translate(width/2, height/2, 0);
    stroke(0);          // Setting the outline (stroke) to black
    fill(150);          // Color of plane 
    box(boxLength, boxLength, 0);
  popMatrix();

  cylinder.drawAllInShiftMode();
}

void drawPlane() {

  camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
  directionalLight(200, 100, 50, 0, 1, 0);
  background(100);
  
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(rx);
  rotateZ(rz);
  box(boxLength, boxHeight, boxLength);
  //drawAxes();
  
  // check collision and print cylinder
  cylinder.paintAll();
  if(!cylinder.locations.isEmpty()) {
     mover.checkCylinderCollision(cylinder.locations, cylinder_radius);
  }

  // update ball
  mover.update(rx, rz);
  mover.checkEdges();
  mover.display();
  popMatrix();
  
  text(rx*180/PI, 175, 140);
  text(rz*180/PI, 230, 140);
  text(amplifier, 285, 140);

}

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
    cylinder.add(mouseX, mouseY);
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

void drawAxes() {
  stroke(255, 0, 0);
  line(0, 0, 0, 50, 0, 0);
  
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 50, 0);
  
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 50);
}




