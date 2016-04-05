class DataV {
    PGraphics background;
    DataV() {
        background = createGraphics(width, height/4, P3D);
        drawBackground();
    }

    void drawBackground() {
      background.beginDraw();
        background.background(255, 255, 255, 100);
      background.endDraw();
    }
    
    // the origin here is the top left corner of the background
    void drawAll(){
      image(background, 0, 0);
    }
    
}