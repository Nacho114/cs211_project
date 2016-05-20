class Convolution {
  // convolute a single pixel
  float convolutePix(PImage img, int x, int y, float[][] kernel, float weight) {
    int n = kernel.length; // We assume that the kernel is a square
    float newPix = 0;
    // iterate over kernel elements
    for (int k = -n/2; k <= n/2; ++k) {
      for (int l = -n/2; l <= n/2; ++l) {
        newPix += brightness(img.pixels[(x+k) + (y+l)*img.width]) * kernel[n/2+l][n/2+k];
      }
    }
    return newPix/weight;
  }

  PImage convolution(PImage img, float[][] kernel, float weight) {
    int n = kernel.length; // We assume that the kernel is a square
    float maximum = 0;
    float minimum = 10000000;
    img.loadPixels();
    PImage res = createImage(img.width, img.height, ALPHA);
    for (int i = 0; i < img.width; ++i) {
      for (int j = 0; j < img.height; ++j) {
        // border
        int index = j*img.width + i;
        if (i < n/2 || i >= img.width-n/2 || j < n/2 || j >= img.height-n/2) {
          res.pixels[index] = color(brightness(img.pixels[index]));
        } else {
          float c = convolutePix(img, i, j, kernel, weight);
          res.pixels[index] = color(c);
          maximum = max(maximum, c);
          minimum = min(minimum, c);
        }
      }
    }
    res.updatePixels();
    return res;
  }

  PImage gaussianBlur(PImage img) {
    float[][] kernel = {{9, 12, 9}, {12, 15, 12}, {9, 12, 9}};
    return convolution(img, kernel, 99);
  }
}