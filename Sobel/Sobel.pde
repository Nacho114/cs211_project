PImage base;
HScrollbar hueBar2;
HScrollbar hueBar1;


void settings() {
  size(1600, 600);
}
void setup() {
  base = loadImage("board1.jpg");
  hueBar2 = new HScrollbar(0, 580, 800, 20);
  hueBar1 = new HScrollbar(0, 550, 800, 20);
}
void draw() {
  background(color(0, 0, 0));

  // threshold image
  PImage thres = createImage(width/2, height, ALPHA);
  base.loadPixels();
  for (int i = 0; i < base.width * base.height; i++) {
    if (hue(base.pixels[i]) <= hueBar2.getPos()*255 && hue(base.pixels[i]) >= hueBar1.getPos()*255)
      thres.pixels[i] = color(255);
    else
      thres.pixels[i] = color(0);
  }
  thres.updatePixels();
  image(thres, 0, 0);

  // sobel
  image(sobel(base), width/2, 0);

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
      if (buffer[y * img.width + x] > (int)(max * 0.2f)) { // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }

  result.updatePixels();
  return result;
}