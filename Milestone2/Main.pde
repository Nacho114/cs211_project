import java.util.Collections;
import java.util.Arrays;

// Predefine some colors
final color black = color(0);
final color white = color(255);

// Used because there are no static functions in processing
Filter filter = new Filter();
Convolution conv = new Convolution();
Sobel sobel = new Sobel();

// Put as a global variable to avoid passing the quadGraph as a parameter
QuadGraph qd = new QuadGraph();

// The input image
PImage base;

// The height of the output and the corresponding ratio. Lowering size will have the side effect to be
//          less precise in the corner detection (the calculations are based on the resized image).
//          Furthermore, the minVotes, minArea and maxArea values must be adapted when changing size.
int size = 400;
float ratio;

// ::::::::::::::::::::::::::::::: CHANGE INPUT IMAGE HERE :::::::::::::::::::::::::::::::
void settings() {
  // Load image, calculate the size of the output
  base = loadImage("board1.jpg");
  ratio = ((float) size) / ((float) base.height);
  int width = (int) (size + 2 * (ratio * base.width));
  size(width, size);
}

void setup() {
}

void draw() {
  // To mesure time
  int t = millis();
  
  // Resize image for easily readable output
  base.resize((int) (ratio * base.width), size);
  base.updatePixels();
  
  // Output resized input image
  image(base, 0, 0);
  
  // Apply a HSB thresholding and blurr it
  PImage hueImg = filter.HSBFilter(base, 95, 145, 100, 256, 30, 150);
  PImage blurred = conv.gaussianBlur(hueImg);
  blurred = conv.gaussianBlur(blurred);

  // Run the Sobel algorithm
  PImage sobelImg = sobel.sobel(blurred);

  // Generate the accumulator of lines and selects all lines with enough votes
  Hough hough = new Hough(sobelImg);
  List<PVector> lines = hough.getPolarLines();
  
  // Find all possible quads and select the largest one that fits the requirements
  qd.build(lines, base.width, base.height);
  int maxAreaIndex = 0;
  float biggestArea = 0.;
  boolean found = false;
  List<int[]> quads = qd.findCycles();
  for (int i=0; i<quads.size(); i++) {
    int[] quad = quads.get(i);
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
    int minArea = 40_000;
    int maxArea = 250_000;
    if (qd.isConvex(c12, c23, c34, c41) && qd.validArea(c12, c23, c34, c41, maxArea, minArea) && qd.nonFlatQuad(c12, c23, c34, c41)) {
      float area = qd.area(c12, c23, c34, c41);
      if (area > biggestArea) {
        maxAreaIndex = i;
        biggestArea = area;
        found = true;
      }
    }
  }
  
  // Calculate elapsed time
  t = millis() - t;
  
  // Output corners and draw them
  if (found) {
    println("The program took " + t + " milliseconds to finish and found following corners:");
    hough.drawLinesAndIntersections(quads.get(maxAreaIndex));
  }
  else {
    println("The program took " + t + " milliseconds to finish and was not able to detect corners. Please change some parameters!");
  }

  // Output the accumulator and the result of Sobel's algorithm
  image(hough.accImg(size), base.width, 0);
  image(sobelImg, size + base.width, 0);

  noLoop(); // We only use a static image here, nothing changes
}