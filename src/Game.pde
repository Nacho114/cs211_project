
float depth = 2000;
float limSup = 1.0472;
float limInf = -1.0472;

float ypos = 0;

void settings() {
  size(500, 500, P3D);
}


void setup() {
  noStroke();
}

void draw() {
  camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(200);
  translate(width/2, height/2, 0);
  float rz = map(mouseY, 0, height, 0, PI);
  float rx = map(mouseX, 0, width, 0, PI);
  float ry = map(ypos, 0, depth, 0, PI);
  constrain(rx, limInf, limSup);
  constrain(rz, limInf, limSup);
  rotateZ(rz);
  rotateX(rx);




  // box dimensions
  float w = 300;
  float h = 30;
  float d = 300;
  box(w, h, d);
}


void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      ypos -= 50;
    }
    else if (keyCode == DOWN) {
    ypos += 50; }
} }

