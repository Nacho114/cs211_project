class Sobel {

  // sobel algo
  PImage sobel(PImage img) {
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

    // check if 1 or 2
    for (int y = 1; y < img.height - 1; y++) {
      for (int x = 1; x < img.width - 1; x++) {
        int index = y * img.width + x;
        float h = conv.convolutePix(img, x, y, hKernel, 1.);
        float v = conv.convolutePix(img, x, y, vKernel, 1.);
        buffer[index] = sqrt((h*h) + (v*v));
        max = max(max, buffer[index]);
      }
    }
    for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges
      for (int x = 1; x < img.width - 1; x++) { // Skip left and right
        int index = y * img.width + x;
        if (buffer[index] > (int)(max * 0.3f)) { // 30% of the max
          result.pixels[index] = white;
        } else {
          result.pixels[index] = black;
        }
      }
    }

    result.updatePixels();
    
    // We blurr two times the image and do a brightness thresholding to improve the result of the Sobel algorithm
    result = conv.gaussianBlur(result);
    result = conv.gaussianBlur(result);
    result = filter.brightnessFilterToBW(result, 170, 256);
    
    return result;
  }
}