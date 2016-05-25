void settings() {
  size(1000, 1000, P2D);
}
void setup () {
}
void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  //rotated around x
  float[][] transform1 = rotateXMatrix(PI/8);
  input3DBox = transformBox(input3DBox, transform1);
  projectBox(eye, input3DBox).render();
  //rotated and translated
  float[][] transform2 = translationMatrix(200, 200, 0);
  input3DBox = transformBox(input3DBox, transform2);
  projectBox(eye, input3DBox).render();
  //rotated, translated, and scaled
  float[][] transform3 = scaleMatrix(2, 2, 2);
  input3DBox = transformBox(input3DBox, transform3);
  projectBox(eye, input3DBox).render();
}

class My2DPoint {
  float x;
  float y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

/*
*  takes the center of projection (eye position) and a 
 point in 3D space and returns the perspective projection of it on the screen.
 *
 */
My2DPoint projectPoint(My3DPoint eye, My3DPoint p) { 
  float normW =  -1.0 * (p.z / eye.z) + 1; // -1.0 / p.z;

  return new My2DPoint((p.x - eye.x) / normW, (p.y - eye.y) / normW);
}


class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }

  void drawLine(My2DPoint p1, My2DPoint p2) {
    line (p1.x, p1.y, p2.x, p2.y);
  }

  void drawFace(My2DPoint p1, My2DPoint p2, My2DPoint p3, My2DPoint p4) {
    drawLine(p1, p4);
    drawLine(p1, p2);
    drawLine(p2, p3);
    drawLine(p3, p4);
  }

  void render() {
    drawFace(s[0], s[1], s[2], s[3]);
    drawFace(s[3], s[2], s[6], s[7]);
    drawFace(s[7], s[6], s[5], s[4]);
    drawFace(s[4], s[5], s[1], s[0]);
    drawFace(s[0], s[3], s[7], s[4]);
    drawFace(s[1], s[2], s[6], s[5]);
  }
}


class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x, y+dimY, z+dimZ), 
      new My3DPoint(x, y, z+dimZ), 
      new My3DPoint(x+dimX, y, z+dimZ), 
      new My3DPoint(x+dimX, y+dimY, z+dimZ), 
      new My3DPoint(x, y+dimY, z), 
      origin, 
      new My3DPoint(x+dimX, y, z), 
      new My3DPoint(x+dimX, y+dimY, z)
    };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}


My2DBox projectBox (My3DPoint eye, My3DBox box) { 
  My2DPoint[] hako = new My2DPoint[box.p.length];

  for (int i = 0; i < box.p.length; ++i) {
    hako[i] = projectPoint(eye, box.p[i]);
  }

  return new My2DBox(hako);
}


// Part 2: Transformations

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][]  rotateXMatrix(float angle) {
  return(new float[][] {{1, 0, 0, 0}, 
    {0, cos(angle), sin(angle), 0}, 
    {0, -sin(angle), cos(angle), 0}, 
    {0, 0, 0, 1}});
}

float[][] rotateYMatrix(float angle) { 
  return(new float[][] {{cos(angle), 0, sin(angle), 0}, 
    {0, 1, 0, 0}, 
    {-sin(angle), 0, cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateZMatrix(float angle) { // Complete the code!
  return(new float[][] {{cos(angle), sin(angle), 0, 0}, 
    {-sin(angle), cos(angle), 0, 0}, 
    {0, 0, 1, 0}, 
    {0, 0, 0, 1}});
}
float[][] scaleMatrix(float x, float y, float z) { 
  return(new float[][] {
    {x, 0, 0, 0}, 
    {0, y, 0, 0}, 
    {0, 0, z, 0}, 
    {0, 0, 0, 1}});
}

float[][] translationMatrix(float x, float y, float z) { 
  return(new float[][] {
    {1, 0, 0, x}, 
    {0, 1, 0, y}, 
    {0, 0, 1, z}, 
    {0, 0, 0, 1}});
}


// Part 3

float[] matrixProduct(float[][] a, float[] b) { 
  float[] prod = new float[b.length];

  for (int r = 0; r < a[0].length; r++) {
    for (int c = 0; c < a[1].length; c++) {
      prod[r] += a[r][c] * b[c];
    }
  }
  
  return prod;
}

// Normalizes the vector 
My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  //Complete the code! You need to use the euclidian3DPoint() function given below.
  My3DPoint[] transf = new My3DPoint[box.p.length];
  for (int i = 0; i < box.p.length; ++i) {
    float[] coord = {box.p[i].x, box.p[i].y, box.p[i].z, 1.0};
    transf[i] = euclidian3DPoint(matrixProduct(transformMatrix, coord));
  }
  return new My3DBox(transf);
}
