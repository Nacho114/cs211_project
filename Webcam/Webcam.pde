import processing.video.*;
import java.util.Collections;
import java.util.Random;
import java.util.Arrays;

Capture cam;
PImage camImg;
PImage base;
Filter filter = new Filter();
Convolution conv = new Convolution();
Sobel sobel = new Sobel();
final color black = color(0);
final color white = color(255);

void settings() {
  size(1200, 600);
}

void setup() {
  // test static image
  base = loadImage("board4.jpg");
  // camera
  /*String[] cameras = Capture.list();
   if (cameras.length == 0) {
   println("There are no cameras available for capture.");
   exit();
   } else {
   println("Available cameras:");
   for (int i = 0; i < cameras.length; i++) {
   println(cameras[i]);
   }
   cam = new Capture(this, cameras[0]);
   cam.start();
   }*/
}

void draw() {
  /* if (cam.available() == true) {
   cam.read();
   }*/
  //camImg = cam.get();
  int t = millis();
  camImg = base;
  //PImage hueImg = filter.HSBFilter(camImg, 110, 140, 30, 255, 30, 150);
  //PImage hueImg = filter.HSBFilter(camImg, 95, 145, 80, 256, 30, 170);
  PImage hueImg = filter.HSBFilter(camImg, 95, 145, 100, 256, 30, 150);
  hueImg = conv.gaussianBlur(hueImg);
  hueImg = conv.gaussianBlur(hueImg);
  //PImage BWImg = brightnessFilterToBW(blurred, 254);
  PImage sobelImg = filter.brightnessFilterToBW(hueImg, 255, 256);
  sobelImg = sobel.sobel(hueImg);
  sobelImg = conv.gaussianBlur(sobelImg);
  sobelImg = conv.gaussianBlur(sobelImg);
  sobelImg = filter.brightnessFilterToBW(sobelImg, 170, 256);
  image(sobelImg, 0, 0);


  Hough hough = new Hough(sobelImg);
  hough.drawLines();
  hough.drawIntersections();
  image(hough.accImg(), 800, 0);

  QuadGraph qd = new QuadGraph();
  List<PVector> lines = hough.getPolarLines();
  qd.build(lines, camImg.width, camImg.height);
  for (int[] quad : qd.findCycles()) {
    /* PVector[] corners = qd.quadVertices(lines, quad);
     
     PVector v1 = corners[0];
     PVector v2 = corners[1];
     PVector v3 = corners[2];
     PVector v4 = corners[3];*/


    // Redo quad checking!!!!
    PVector l1 = lines.get(quad[0]);
    PVector l2 = lines.get(quad[1]);
    PVector l3 = lines.get(quad[2]);
    PVector l4 = lines.get(quad[3]);
    // (intersection() is a simplified version of the
    // intersections() method you wrote last week, that simply
    // return the coordinates of the intersection between 2 lines)
    PVector c12 = qd.intersection(l1, l2);
    PVector c23 = qd.intersection(l2, l3);
    PVector c34 = qd.intersection(l3, l4);
    PVector c41 = qd.intersection(l4, l1);
    // Choose a random, semi-transparent colour
    println(c12);
    println(c23);
    println(c34);
    println(c41);
    if (qd.isConvex(c12, c23, c34, c41) && qd.validArea(c12, c23, c34, c41, 600000, 100000) && qd.nonFlatQuad(c12, c23, c34, c41)) {
      Random random = new Random();
      fill(color(min(255, random.nextInt(300)), 
        min(255, random.nextInt(300)), 
        min(255, random.nextInt(300)), 50));
      quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
    }
  }
  t = millis() - t;
  println(t);

  noLoop(); // TODO remove
}