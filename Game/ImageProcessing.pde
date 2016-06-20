import java.util.Collections;
import java.util.Arrays;
import processing.video.*;

class ImageProcessing {
  
  private float rx = 0.;
  private float rz = 0.;


  void process() {
    //if (cam.available() == true) {
    // cam.read();
    //}
    //cam.updatePixels();
    //base = cam.get();

    // To mesure time
    int t = millis();

    // Apply a HSB thresholding and blurr it
    PImage hueImg = filter.HSBFilter(base, 110, 130, 100, 256, 60, 150);
    PImage blurred = conv.gaussianBlur(hueImg);
    blurred = conv.gaussianBlur(blurred);
    
    //image(blurred, 0, 0);

    // Run the Sobel algorithm
    PImage sobelImg = sobel.sobel(blurred);

    // Generate the accumulator of lines and selects all lines with enough votes
    Hough hough = new Hough(sobelImg);
    List<PVector> lines = hough.getPolarLines();

    // Find all possible quads and select the largest one that fits the requirements
    qd.build(lines, base.width, base.height);
    int maxAreaIndex = 0;
    float biggestArea = 0.;
    List<PVector> intersections = null;
    boolean found = false;
    List<int[]> quads = qd.findCycles();
    //println("\tNumber of quads found: " + quads.size());
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
      int minArea = 0;//40_000;
      int maxArea = 350_000;
      if (qd.isConvex(c12, c23, c34, c41) && qd.validArea(c12, c23, c34, c41, maxArea, minArea) && qd.nonFlatQuad(c12, c23, c34, c41)) {
        float area = qd.area(c12, c23, c34, c41);
        if (area > biggestArea) {
          maxAreaIndex = i;
          biggestArea = area;
          intersections = Arrays.asList(c12, c23, c34, c41);
          found = true;
        }
      }
    }

    // Calculate elapsed time
    t = millis() - t;

    // Output corners and draw them
    if (found) {
      //println("The program took " + t + " milliseconds to finish and found following corners:");
      //hough.drawLinesAndIntersections(quads.get(maxAreaIndex));
      // pose estimation
      TwoDThreeD d = new TwoDThreeD(base.width, base.height);
      PVector anglesRad = d.get3DRotations(sortCorners(intersections));
      //println("x: " + Math.toDegrees(anglesRad.x));
      //println("y: " + Math.toDegrees(anglesRad.y));
      //println("z: " + Math.toDegrees(anglesRad.z));
      rx = anglesRad.x;
      rz = anglesRad.z;
    } else {
      //println("The program took " + t + " milliseconds to finish and was not able to detect corners. Please change some parameters!");
    }

    // Output the accumulator and the result of Sobel's algorithm
    //image(hough.accImg(size), base.width, 0);
    //image(sobelImg, size + base.width, 0);

    //noLoop(); // We only use a static image here, nothing changes
  }

  // GETTERS ---------------
  public float getRotX() {
    return rx;
  }
  public float getRotZ() {
    return rz;
  }

  // CORNERS SORTING -----------
  public  List<PVector> sortCorners(List<PVector> quad) {
    // Sort corners so that they are ordered clockwise
    PVector a = quad.get(0);
    PVector b = quad.get(2);
    PVector center = new PVector((a.x+b.x)/2, (a.y+b.y)/2);

    Collections.sort(quad, new CWComparator(center));
    PVector min = quad.get(0);
    int minIdx = 0;
    for (int i = 1; i < 4; ++i) {
      if (min.x > quad.get(i).x && min.y > quad.get(i).y) {
        min = quad.get(i);
        minIdx = i;
      }
    }

    Collections.rotate(quad, quad.size()-minIdx);

    return quad;
  }


  class CWComparator implements Comparator<PVector> {
    PVector center;
    public CWComparator(PVector center) {
      this.center = center;
    }
    @Override
      public int compare(PVector b, PVector d) {
      if (Math.atan2(b.y-center.y, b.x-center.x)<Math.atan2(d.y-center.y, d.x-center.x))
        return -1;
      else return 1;
    }
  }
}