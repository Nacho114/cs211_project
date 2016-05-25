class Mover {
  final static float gravityMagnitude = 0.2; 
  final static float mu = 0.03;
  final static float normalForce = 1;
  final static float frictionMagnitude = mu * normalForce;

  PVector location;
  PVector velocity;

  final int plateWidth;
  final int plateHeight;
  final int ballRadius;

  // For topView
  float scale;


  Mover(int plateWidth, int plateHeight, int ballRadius, float scale) {
    location = new PVector(0, -1 * (plateHeight/2. + ballRadius), 0);
    velocity = new PVector(0, 0, 0);
    this.plateWidth = plateWidth;
    this.plateHeight = plateHeight;
    this.ballRadius = ballRadius;
    this.scale = scale;
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
    pushStyle();
    translate(location.x, location.y, location.z);
    sphere(ballRadius);
    popStyle();
    popMatrix();
  }

  void displayTopView(PGraphics topView) {
    topView.pushMatrix();
    topView.pushStyle();
    topView.translate(location.x * scale, location.z * scale);
    topView.noStroke(); 
    topView.fill(170, 1, 20);
    float scaleObj = 2 * scale;
    topView.ellipse(0, 0, ballRadius * scaleObj, ballRadius * scaleObj);
    topView.popStyle();
    topView.popMatrix();
  }

  // returns whether the ball bounced
  float checkEdges() {
    float speed = 0.;
    if (location.x + ballRadius > plateWidth/2.0) {
      location.x = plateWidth/2. - ballRadius ;
      velocity.x = velocity.x * -1;
      speed += velocity.x * velocity.x;
    } else if (location.x - ballRadius < -1*plateWidth/2.0) {
      location.x = -plateWidth/2. + ballRadius ;
      velocity.x = velocity.x * -1;
      speed += velocity.x * velocity.x;
    }

    if (location.z + ballRadius > plateWidth/2.0) {
      location.z = plateWidth/2. - ballRadius ;
      velocity.z = velocity.z * -1;
      speed += velocity.z * velocity.z;
    } else if  (location.z - ballRadius < -1*plateWidth/2.0) {
      location.z = -plateWidth/2. + ballRadius ;
      velocity.z = velocity.z * -1;
      speed += velocity.z * velocity.z;
    }
    return sqrt(speed);
  }


  // returns whether there was a colision
  boolean checkCylinderCollision(ArrayList<PVector> cylinderLocations, float cylinderRadius) {
    PVector location2D = new PVector(location.x, location.z);
    PVector v1 = new PVector(velocity.x, velocity.z);

    boolean colision = false;
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

        colision = true;
      }
    }
    return colision;
  }
}