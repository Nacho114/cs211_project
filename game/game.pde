float depth = 300;

int lastX;
int lastY;

float rx = 0.;
float rz = 0.;

int boxLength = 200;
int boxHeight = 10;

float amplifier = 1.0;

void settings() {
  size(800, 600, P3D);
}

void setup() {
  noStroke();
}

void draw() {
  camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
  directionalLight(200, 100, 50, 0, 1, 0);
  background(100);
  
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(rx);
  rotateZ(rz);
  box(boxLength, boxHeight, boxLength);
  drawAxes();
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
  lastX = mouseX;
  lastY = mouseY;
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

void drawAxes() {
  stroke(255, 0, 0);
  line(0, 0, 0, 50, 0, 0);
  
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 50, 0);
  
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 50);
}