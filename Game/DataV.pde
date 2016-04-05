class DataV {
    PGraphics surface;
    DataV() {
        surface = createGraphics(400, 200, P3D);
    }

    void drawMySurface() {
        pushMatrix();
        rotateX(PI/2);
        surface.beginDraw();
        surface.background(0);

        surface.endDraw();
        popMatrix();
    }
}
