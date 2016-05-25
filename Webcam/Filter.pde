class Filter {

  // maps img to result using threshold limit of img brightness to set Black or White colors
  public PImage brightnessFilterToBW(PImage img, float minThreshold, float maxThreshold) {
    PImage res = createImage(img.width, img.height, ALPHA);
    img.loadPixels();
    for (int i = 0; i < img.width * img.height; i++) {
      res.pixels[i] = (brightness(img.pixels[i]) >= minThreshold && brightness(img.pixels[i]) <= maxThreshold) ? white : black;
    }
    res.updatePixels();
    return res;
  }

  public PImage HSBFilter(PImage img, float minHue, float maxHue, float minSaturation, float maxSaturation, float minBrightness, float maxBrightness) {
    PImage res = createImage(img.width, img.height, ALPHA);
    img.loadPixels();
    for (int i = 0; i < img.width * img.height; i++) {
      float h = hue(img.pixels[i]);
      float b = brightness(img.pixels[i]);
      float s = saturation(img.pixels[i]);
      boolean condition = (h >= minHue && h <= maxHue) && (b >= minBrightness && b <= maxBrightness) && (s >= minSaturation && s <= maxSaturation);
      res.pixels[i] = (condition ? white : black);
    }
    res.updatePixels();
    return res;
  }
}