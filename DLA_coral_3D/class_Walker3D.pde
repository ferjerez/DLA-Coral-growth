class Walker3D {
  PVector pos;
  // Possible movements
  PVector[] dir ={
    new PVector( 1, 0, -1), 
    new PVector(-1, 0, -1), 
    new PVector( 0, 1, -1), 
    new PVector( 0, -1, -1), 
    new PVector( 1, 1, -1), 
    new PVector( -1, -1, -1), 
    new PVector( -1, 1, -1), 
    new PVector( 1, -1, -1), 
    new PVector( 1, 0, 0), 
    new PVector(-1, 0, 0), 
    new PVector( 0, 1, 0), 
    new PVector( 0, -1, 0), 
    new PVector( 1, 1, 0), 
    new PVector( -1, -1, 0), 
    new PVector( -1, 1, 0), 
    new PVector( 1, -1, 0)
  };
  Grid3D G;

  float stickness = 1; // percentaje of collision
  float gravity = 0.2; // Z-increment per step 
  int neigh = 3; // neighbours required for collision
  int blobradius = 2; // radius of the 'blob/ball' created when collide


  Walker3D(Grid3D _G, int x, int y, int z) {
    pos = new PVector(x, y, z);  
    G = _G;
  }

  void step(int t) {
    for (int i = 0; i<t; i++) step();
  }
  void step() {
    // move random
    PVector vel = new PVector();
    vel.set(dir[floor(random(dir.length))]); // random direction

    // add velocity/direction
    pos.x = (pos.x+vel.x+G.sx) % G.sx;
    pos.y = (pos.y+vel.y+G.sy) % G.sy;
    pos.z = (pos.z+vel.z*gravity+G.sz) % G.sz; // apply gravity factor in z component


    // Check neighborhood
    int n = G3D.neighboursDown((int)pos.x, (int)pos.y, (int)pos.z);

    if (n>=neigh && random(1)<stickness ) { 
      G.fillSphere((int)pos.x, (int)pos.y, (int)pos.z, blobradius, 1);

      // reset the walker
      pos.set(floor(random(G.sx)), floor(random(G.sy)), G.sz-2);
    }
  }

  void display() {
    noStroke();
    fill(255, 0, 0);
    pushMatrix();
    translate(pos.x*G.gridsize, pos.y*G.gridsize, pos.z*G.gridsize);
    box(G.gridsize);
    popMatrix();
  }
}
