PImage base;
HScrollbar hueBar2;
HScrollbar hueBar1;


void settings() {
  size(800, 600);
}
void setup() {
  base = loadImage("board1.jpg");
  hueBar2 = new HScrollbar(0, 580, 800, 20);
  hueBar1 = new HScrollbar(0, 550, 800, 20);
}
void draw() {
  background(color(0, 0, 0));

  // threshold image
  //PImage thres = createImage(width/2, height, ALPHA);
  //base.loadPixels();
  //for (int i = 0; i < base.width * base.height; i++) {
  //  if (hue(base.pixels[i]) <= hueBar2.getPos()*255 && hue(base.pixels[i]) >= hueBar1.getPos()*255)
  //    thres.pixels[i] = color(255);
  //  else
  //    thres.pixels[i] = color(0);
  //}
  //thres.updatePixels();
  //image(thres, 0, 0);

  // sobel
  PImage sobelImg = sobel(base);
  image(sobelImg, 0, 0);//width/2, 0);

  hough(sobelImg);

  // scroll bars
  hueBar2.display();
  hueBar2.update();

  hueBar1.display();
  hueBar1.update();
}

// convolute a single pixel
float convolutePix(PImage img, int x, int y, float[][] kernel) {
  int n = kernel.length;
  float weight=1.f;
  float newPix = 0;
  // iterate over kernel elements
  for (int k = -n/2; k <= n/2; ++k) {
    for (int l = -n/2; l <= n/2; ++l) {
      newPix += brightness(img.pixels[(x+k) + (y+l)*img.width]) * kernel[n/2+l][n/2+k];
    }
  }
  return newPix/weight;
}

// sobel algo
PImage sobel(PImage img) {
  // kernel size N = 3
  int n = 3;
  float[][] hKernel = { { 0, 1, 0 }, 
    { 0, 0, 0 }, 
    { 0, -1, 0 } };
  float[][] vKernel = { { 0, 0, 0 }, 
    { 1, 0, -1 }, 
    { 0, 0, 0 } };
  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }

  float max=0;
  float[] buffer = new float[img.width * img.height];

  img.loadPixels();
  // double convolution
  for (int i = 0; i < img.width; ++i) {
    for (int j = 0; j < img.height; ++j) {
      // border
      if (i < n/2 || i >= img.width-n/2 || j < n/2 || j >= img.height-n/2) {
        // do nothing
      } else {
        buffer[i + j*img.width] = 0;
        float hue = hue(img.pixels[i + j*img.width]);
        if (hue > hueBar1.getPos()*255 && hue < hueBar2.getPos()*255) {
          float sum_h = convolutePix(img, i, j, hKernel);
          float sum_v = convolutePix(img, i, j, vKernel);
          // set new pix
          buffer[i + j*img.width] = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
          // set max
          if (buffer[i + j*img.width] > max)
            max = buffer[i + j*img.width];
        }
      }
    }
  }

  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.25f)) { // 25% of the max
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }

  result.updatePixels();
  return result;
}


void hough(PImage edgeImg) {
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;

  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
        // Be careful: r may be negative, so you may want to center onto
        // the accumulator with something like: r += (rDim - 1) / 2
        for (int phiStep = 0; phiStep <= phiDim; ++phiStep) {
          float phi = phiStep * discretizationStepsPhi;
          float r = (x * cos(phi) + y * sin(phi))/discretizationStepsR;
          r += (rDim - 1) / 2; // adjust to acc
          accumulator[(phiStep+1) * (rDim+2) + (int)(r+1)] += 1;
        }
      }
    }
  }

  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(400, 400);
  houghImg.updatePixels();

  image(houghImg, 0, 0);


  for (int idx = 0; idx < accumulator.length; idx++) {
    if (accumulator[idx] > 200) {
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      
      //Cartesian equation of a line: 
      //  y = ax + b
      //    in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      //  => y = 0 : 
      //  x = r / cos(phi)
      //  => x = 0 : 
      //  y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
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
  }
}