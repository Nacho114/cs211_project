/*
    Class to play around with black and white, setting black or white depending 
    on bightness threshold level
*/

HScrollbar thresholdBar;
PImage img;
PImage result;

final static int THRESHOLD = 128;

final static int WIDTH = 1600;
final static int HEIGHT = 600;

final static int scrollWidth = WIDTH / 2;

void settings() {
    size(WIDTH, HEIGHT);
}

void setup() {
    thresholdBar = new HScrollbar(WIDTH / 2, 580, scrollWidth, 20, 10);

    img = loadImage("board1.jpg");
    result = createImage(img.width, img.height, RGB); // create a new, initially transparent, ’result’ image
    
    //noLoop(); // !!!!

}

void draw() {
    img.loadPixels();    
    result.loadPixels();    

    background(color(0,0,0));
    
    image(img, 0, 0);
    image(result, 800, 0);

    thresholdBar.display();
    thresholdBar.update();
    double thresh = (thresholdBar.getPos() - WIDTH / 2.0) / scrollWidth;  // normalizing

    hueMap(img, result, (int) (255 * thresh));
    
    result.updatePixels();    //result = convolute(img);
}

// IMAGE MAPPING FUNCTIONS

// maps img to result limiting thershold color
void updateImg(PImage img, PImage result, int threshold) {
    for(int i = 0; i < img.width * img.height; i++) 
        result.pixels[i] = (img.pixels[i] <= color(threshold)) ? img.pixels[i] : color(threshold);
}

// maps img to result using threshold limit of img brightness to set Black or White colors
void blackAndWhite(PImage img, PImage result, int threshold) {
    for(int i = 0; i < img.width * img.height; i++) 
        result.pixels[i] = (brightness(img.pixels[i]) <= threshold) ? color(0) : color(255);
}

// maps imt to corresponding hue value limited by the threshold
void hueMap(PImage img, PImage result, int threshold) {
    for(int i = 0; i < img.width * img.height; i++) 
        result.pixels[i] = (hue(img.pixels[i]) <= threshold) ? color(hue(img.pixels[i])) : color(hue(threshold));
}



// Convolution Functions


boolean bounded(int v, int from, int to) {
    return v >= from && v < to;
}



color extract(PImage img, int i, int j, float[][] kernel, float weight) {
     
    int offset = kernel.length / 2;
    float rtotal = 0.0;
    float gtotal = 0.0;
    float btotal = 0.0;

    for (int x = 0; x < kernel.length; ++x) {
        for (int y = 0; y < kernel.length; ++y) {

            int img_x = i + x - offset;  
            int img_y = j + y - offset;  
            int loc = img_y + img.width*img_x;
            loc = constrain(loc,0,img.pixels.length-1);
            rtotal += (red(img.pixels[loc]) * kernel[x][y]);
            gtotal += (green(img.pixels[loc]) * kernel[x][y]);
            btotal += (blue(img.pixels[loc]) * kernel[x][y]);

        }   
                

    }

    rtotal = constrain(rtotal, 0, 255);
    gtotal = constrain(gtotal, 0, 255);
    btotal = constrain(btotal, 0, 255);

    return color(rtotal/weight, gtotal/weight, btotal/weight);
}

PImage convolute(PImage img) {
    float[][] kernel = { { 0, 0, 0 },
                         { 0, 1, 0 },
                         { 0, 0, 0 }};

    int kerLen = kernel.length / 2;


    float weight = 1.f;

    // create a greyscale image (type: ALPHA) for output
    PImage result = createImage(img.width, img.height, ALPHA);

    for (int i = 0; i < img.height; ++i) {
        for (int j = 0; j < img.width; ++j) {

            int loc = j + (i * img.width);
            result.pixels[loc] = extract(img, i, j, kernel, weight);
        }
    }

    return result;
}

