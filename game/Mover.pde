class Mover {
  final static float gravityMagnitude = 0.2; 
  final static float mu = 0.01;
  final static float normalForce = 1;
  final static float frictionMagnitude = mu * normalForce;
  
  PVector location;
  PVector velocity;
  
  final int boxLength;
  final int boxHeight;
  final int floorHeight;
  
  

  Mover(int boxLength, int boxHeight, int floorHeight) {
    location = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    this.boxLength = boxLength;
    this.boxHeight = boxHeight;
    this.floorHeight = floorHeight;
  }

  
  void update(float rx, float rz) {
    velocity.x += sin(rz) * gravityMagnitude;
    velocity.z -= sin(rx) * gravityMagnitude;
    
    PVector friction = velocity.get();
    friction.normalize();
    friction.mult(-frictionMagnitude);
    
    velocity.add(friction);
    location.add(velocity);
  }

  void display() {
    pushMatrix();
    translate(location.x, -(floorHeight + 10), location.z);
    sphere(10);
    popMatrix();
  }

  void checkEdges() {
    if (location.x <= -boxLength / 2.){
      location.x = -boxLength / 2.;
      velocity.x *= -1;
    }
    else if (location.x >= boxLength / 2.){
      location.x = boxLength / 2.;
      velocity.x *= -1;
    }
    if (location.z <= -boxLength / 2.){
      location.z =- -boxLength / 2.;
      velocity.z *= -1;
    }
    else if (location.z >= boxLength / 2.){
      location.z = boxLength / 2.;
      velocity.z *= -1;
    }
  }
}