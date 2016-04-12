int rotX = 0;
int rotY = 0;

void settings() {
    size(500, 500, P3D);
}
void setup() {
    noStroke();
}
void draw() {
    background(200);
    camera(width/2, height/2, 450, 250, 250, 0, 0, 1, 0);
    directionalLight(200, 100, 50, 0, 1, 0);
    pushMatrix();
        translate(width/2, height/2, 0);
        rotateX(rotX);
        rotateY(rotY);
        stroke(0);          
        fill(135);   
        box(100, 100, 100);
    popMatrix();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      rotX -= 50;
    }
    else if (keyCode == DOWN) {
        rotX += 50; 
    }
    else if (keyCode == LEFT) {
        rotY += 50; 
    }
    else if (keyCode == RIGHT) {
        rotY -= 50; 
    }
  }
}
