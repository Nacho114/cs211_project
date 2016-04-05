class DataV {
    PGraphics background;
    DataV() {
        background = createGraphics(width-100, height/8, P3D);
    }

    void drawBackground() {
      background.background(0);
    }
    
    void drawAll(){
      drawBackground();
      
      image(background, 0, 0);
    }
    
}