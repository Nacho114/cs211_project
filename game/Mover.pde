class Mover {
  final static float gravityMagnitude = 0.2; 
  final static float mu = 0.01;
  final static float normalForce = 1;
  final static float frictionMagnitude = mu * normalForce;
  
  PVector location;
  PVector velocity;
  
  final int width;
  final int height;
  final int radius;
  

  Mover(int width, int height, int radius) {
    location = new PVector(0, -1 * (height/2. + radius), 0);
    velocity = new PVector(0, 0, 0);
    this.width = width;
    this.height = height;
    this.radius = radius;
  }

  
  void update(float rx, float rz) {
    velocity.x += sin(rz) * gravityMagnitude;
    velocity.z -= sin(rx) * gravityMagnitude;
    
    PVector friction = velocity.copy();
    friction.normalize();
    friction.mult(-frictionMagnitude);
    
    velocity.add(friction);
    location.add(velocity);
  }

  void display() {
    pushMatrix();
    translate(location.x, location.y, location.z);
    sphere(radius);
    popMatrix();
  }

  void checkEdges() {
    if ((location.x + radius > width/2.0) || (location.x - radius < -1*width/2.0)) {
      velocity.x = velocity.x * -1;
    }
    if ((location.z + radius > width/2.0) || (location.z - radius < -1*width/2.0)) {
      velocity.z = velocity.z * -1;
    }
  }
}
