class Mover {
  final static float gravityMagnitude = 0.1; 
  final static float mu = 0.02;
  final static float normalForce = 1;
  final static float frictionMagnitude = mu * normalForce;

  PVector location;
  PVector velocity;

  final int plateWidth;
  final int plateHeight;
  final int ballRadius;


  Mover(int plateWidth, int plateHeight, int ballRadius) {
    location = new PVector(0, -1 * (plateHeight/2. + ballRadius), 0);
    velocity = new PVector(0, 0, 0);
    this.plateWidth = plateWidth;
    this.plateHeight = plateHeight;
    this.ballRadius = ballRadius;
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
    sphere(ballRadius);
    popMatrix();
  }

  void checkEdges() {
    if (location.x + ballRadius > plateWidth/2.0) {
      location.x = plateWidth/2. - ballRadius ;
      velocity.x = velocity.x * -1;
    } else if(location.x - ballRadius < -1*plateWidth/2.0){
      location.x = -plateWidth/2. + ballRadius ;
      velocity.x = velocity.x * -1;
    }
    
    if (location.z + ballRadius > plateWidth/2.0) {
      location.z = plateWidth/2. - ballRadius ;
      velocity.z = velocity.z * -1;
    } else if  (location.z - ballRadius < -1*plateWidth/2.0){
      location.z = -plateWidth/2. + ballRadius ;
      velocity.z = velocity.z * -1;
    }
  }


  void checkCylinderCollision(ArrayList<PVector> cylinderLocations, float cylinderRadius) {
    PVector location2D = new PVector(location.x, location.z);
    PVector v1 = new PVector(velocity.x, velocity.z);
    for (PVector v : cylinderLocations) {
      if (v.dist(location2D) <= ballRadius + cylinderRadius) {
        PVector normal = location2D.copy().sub(v);
        normal.normalize();
        
        // update velocity
        float dot = v1.copy().dot(normal);
        v1.sub(normal.mult(2 * dot));
        velocity = new PVector(v1.x, 0, v1.y);
        
        // keep location outside of cylinder
        PVector location2Dupdated = v.copy();
        normal = location2D.copy().sub(v);
        normal.normalize();
        location2Dupdated.add(normal.mult(cylinderRadius + ballRadius));
        location.x = location2Dupdated.x;
        location.z = location2Dupdated.y;
      }
    }
  }
}