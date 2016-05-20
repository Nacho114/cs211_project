class Hough {

  private final PImage edgeImg;
  private final int phiDim;
  private final int rDim;
  private final float discretizationStepsPhi;
  private final float discretizationStepsR;

  private final int[] accumulator;
  private final List<Integer> bestCandidates;
  private final List<PVector> lines;
  private final List<PVector> intersections;

  // pre-computed sin and cos values over discretizationStepsR
  float[] tabSin;
  float[] tabCos;


  public Hough(PImage edgeImg, float discretizationStepsPhi, float discretizationStepsR) {
    
    int minVotes = 150;
    int neighbourhood = 30;
    
    this.edgeImg = edgeImg;
    this.discretizationStepsPhi = discretizationStepsPhi;
    this.discretizationStepsR = discretizationStepsR;
    this.phiDim = (int) (Math.PI / discretizationStepsPhi);
    this.rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);

    tabSin = new float[phiDim];
    tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }

    this.accumulator = calculateAccumulator();
    this.bestCandidates = bestCandidates(minVotes, neighbourhood);
    this.lines = calculateLines();
    this.intersections = calculateIntersections();
  }

  public Hough(PImage edgeImg) {
    this(edgeImg, 0.06f, 2.5f);
  }

  private int[] calculateAccumulator() {
    // our accumulator (with a 1 pix margin around)
    int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          for (int phiStep = 0; phiStep < phiDim; ++phiStep) {
            float r = (x * tabCos[phiStep]) + (y * tabSin[phiStep]);
            r += (rDim - 1) * 0.5; // adjust to acc
            accumulator[(phiStep+1) * (rDim+2) + (int)(r+1)] += 1;
          }
        }
      }
    }
    return accumulator;
  }


  private List<Integer> bestCandidates(int minVotes, int neighbourhood) {

    List<Integer> bestCandidates = new ArrayList<Integer>();

    for (int accR = 0; accR < rDim; accR++) {
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {
        // compute current index in the accumulator
        int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
        if (accumulator[idx] > minVotes) {
          boolean bestCandidate=true;
          // iterate over the neighbourhood
          for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
            // check we are not outside the image
            if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
            for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
              // check we are not outside the image
              if (accR+dR < 0 || accR+dR >= rDim) continue;
              int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
              if (accumulator[idx] < accumulator[neighbourIdx]) {
                // the current idx is not a local maximum!
                bestCandidate=false;
                break;
              }
            }
            if (!bestCandidate) break;
          }
          if (bestCandidate) {
            // the current idx *is* a local maximum
            bestCandidates.add(idx);
          }
        }
      }
    }
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    return bestCandidates;
  }

  private List<PVector> calculateLines() {
    List<PVector> ret = new ArrayList<PVector>();
    for (int e : bestCandidates) {
      ret.add(vectorForElem(e));
    }
    return ret;
  }


  private PVector vectorForElem(int idx) {
    // first, compute back the (r, phi) polar coordinates:
    int accPhi = (int) (idx / (rDim + 2)) - 1;
    int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
    float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
    float phi = accPhi * discretizationStepsPhi;

    return new PVector(r, phi);
  }

  private void displayAccElem(int idx) {
    drawPolarLine(vectorForElem(idx));
  }

  public void drawPolarLine(PVector polarVec) {
    float r = polarVec.x;
    float phi = polarVec.y;

    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    // Finally, plot the
    stroke(204, 102, 0);
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    } else {
      if (x1 > 0) {
        if (y2 > 0)
          line(x1, y1, x2, y2);
        else
          line(x1, y1, x3, y3);
      } else
        line(x2, y2, x3, y3);
    }
  }

  public PVector intersection(PVector l1, PVector l2) {
    List<PVector> lines = new ArrayList<PVector>();
    lines.add(l1);
    lines.add(l2);
    return calculateIntersections().get(0);
  }

  private List<PVector> calculateIntersections() {
    List<PVector> intersections = new ArrayList<PVector>();
    for (int i = 0; i < lines.size() - 1; i++) {
      PVector line1 = lines.get(i);
      for (int j = i + 1; j < lines.size(); j++) {
        PVector line2 = lines.get(j);
        // compute the intersection and add it to ’intersections’

        if (line1.y != line2.y) { // Check that the lines are not parallel
          float d = cos(line2.y) * sin(line1.y) - cos(line1.y) * sin(line2.y);
          float x = (line2.x*sin(line1.y) - line1.x*sin(line2.y))/d;
          float y = (-line2.x*cos(line1.y) + line1.x*cos(line2.y))/d;
          intersections.add(new PVector(x, y));
        }
      }
    }
    return intersections;
  }

  public List<PVector> getIntersections() {
    return intersections;
  }

  public List<PVector> getPolarLines() {
    return lines;
  }


  public void drawIntersections() {
    pushStyle();
    for (PVector intersection : intersections) {
      fill(255, 128, 0);
      ellipse(intersection.x, intersection.y, 10, 10);
    }
    popStyle();
  }

  public void drawIntersection(PVector intersection) {
    pushStyle();
    fill(255, 128, 0);
    ellipse(intersection.x, intersection.y, 10, 10);
    popStyle();
  }

  public void drawLinesAndIntersections(int[] quad) {
    PVector l1 = lines.get(quad[0]);
    PVector l2 = lines.get(quad[1]);
    PVector l3 = lines.get(quad[2]);
    PVector l4 = lines.get(quad[3]);
    drawPolarLine(l1);
    drawPolarLine(l2);
    drawPolarLine(l3);
    drawPolarLine(l4);
    // (intersection() is a simplified version of the
    // intersections() method you wrote last week, that simply
    // return the coordinates of the intersection between 2 lines)
    PVector c12 = qd.intersection(l1, l2);
    PVector c23 = qd.intersection(l2, l3);
    PVector c34 = qd.intersection(l3, l4);
    PVector c41 = qd.intersection(l4, l1);
    drawIntersection(c12);
    drawIntersection(c23);
    drawIntersection(c34);
    drawIntersection(c41);
    // Choose a random, semi-transparent colour
    println(c12);
    println(c23);
    println(c34);
    println(c41);
  }

  public void drawLines() {
    for (int e : bestCandidates) {
      displayAccElem(e);
    }
  }

  public PImage accImg(int size) {
    PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    // You may want to resize the accumulator to make it easier to see:
    houghImg.resize(size, size);
    houghImg.updatePixels();
    return houghImg;
  }
}