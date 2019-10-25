/*
'Coral' generator using DLA technique.
 Fernando Jerez 2019 Twitter/Instagram: @ferjerez3D
 Models ready to print: https://www.myminifactory.com/object/3d-print-103355
 
 License: Creative Commons.
 
 Feel free to use, as you wish. Commercial use allowed.
 
 Tested in Processing 3. Libraries required: PeasyCam and ToxicLibs
 How to use:
 Run the sketch.
 Watch how the 'coral' growths as the 'random walkers' fall and stick in the structure.
 
 Keys:
 r: restart simulation
 i: Changes between 'growing' mode and 'Isosurface' mode
 
 In ISO mode:
 +/-: Rebuild the Iso surface with different tresholds.
 l: Apply a Laplacian smooth
 d: Apply a diffusion filter
 c: Apply a CA (cellular automaton) for smoothing and expand
 e: Export in STL format in stls/ folder (using timestamp for the file name)
 */

// PeasyCam Library
import peasy.*;
// ToxicLibs Library
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import toxi.volume.*;
import toxi.math.noise.*;
import toxi.processing.*;
import toxi.util.*;

import java.util.Date;

ToxiclibsSupport gfx;
IsoSurface surface;
WETriangleMesh mesh;
PeasyCam cam;

Grid3D G3D; // the 3D array where everithing happens
boolean ISO = false; // ISO mode (true) / growing mode (false)


float ISO_TRESHOLD = 0.5;

int WALKERS = 100; // Number of Walkers 

ArrayList<Walker3D> WL;

void setup() {
  size(800, 800, P3D);
  // set the camera
  cam = new PeasyCam(this, 350);
  cam.rotateZ(radians(25)); 
  cam.rotateX(-radians(80));


  // Build the GRID
  G3D = new Grid3D(128, 128, 256);


  WL = new ArrayList<Walker3D>();

  gfx=new ToxiclibsSupport(this);
}

void draw() {
  background(0);
  translate(-G3D.sx*G3D.gridsize*.5, -G3D.sy*G3D.gridsize*.5, -G3D.sz*G3D.gridsize*.25);
  ambientLight(48, 48, 48);
  lightSpecular(230, 230, 230);
  directionalLight(255, 255, 255, 0, -0.5, 1);
  specular(255, 255, 255);
  shininess(16.0);

  if (!ISO) {
    // GROWING MODE
    for (Walker3D W : WL) {
      W.step(100); // Move the walkers Parameter: number of steps (for speeding up the simulation)
      W.display();
    }
    G3D.display();

    // Add one walker per frame until reach the Max WALKERS limit
    if (WL.size()<WALKERS) {
      WL.add(new Walker3D(G3D, floor(random(G3D.sx)), floor(random(G3D.sy)), G3D.sz-2));
    }
  } else {
    // ISO MODE: Shows the isosurface generated
    noStroke();
    fill(255);
    pushMatrix();
    translate(G3D.sx*G3D.gridsize*.5, G3D.sy*G3D.gridsize*.5, G3D.sz*G3D.gridsize*.5);
    gfx.mesh(mesh);
    popMatrix();
  }


  // HUD: Shows the frameRate
  cam.beginHUD();
  fill(255);
  text(floor(frameRate), 2, 12);
  cam.endHUD();
}

void keyPressed() {
  Date d=new Date();
  long sesionid = d.getTime();
  switch (key) {
  case 'r':
  case 'R':
    // restart
    ISO = false;

    G3D.fillGrid(0); // clean grid
    // Can use fillDisc, fillZ, fillSphere here for setup the initial structure
    G3D.fillSphere(G3D.sx/2, G3D.sy/2, 0, 15, 1);  
    //G3D.fillDisc(G3D.sx/2, G3D.sy/2, 0, 55, 4, 1); 

    break;
  case 'i':
  case 'I':
    // Swaps ISO/Growing mode
    if (!ISO) {
      G3D.fillDisc(G3D.sx/2, G3D.sy/2, 0, 25, 4, 1); // Adds a base disc (totally unnecesary)       
      G3D.copyGrid(G3D.cells, G3D.smooth); 
      G3D.applyCA(1, G3D.smooth); // smooths and expand a bit
      G3D.diffusion(3); // smooths 

      generateISO(); // Compute isosurface

      ISO = true;
    } else {
      ISO = false;
    }
    break;
  case 'c':
  case 'C':
    // Smooth and expand the structure
    if (ISO) {       
      G3D.applyCA(1, G3D.smooth);
      generateISO();
    }
    break;
  case 'd':
  case 'D':
    // Diffusion smooth
    if (ISO) {
      G3D.diffusion(1);
      generateISO();
    }
    break;


  case 'l':
  case 'L':
    // Laplacian smooth
    if (ISO) new LaplacianSmooth().filter(mesh, 1);      
    break;

  case 'e':
  case 'E':
    // export
    if (ISO)
      mesh.saveAsSTL(sketchPath()+"\\stls\\coral_"+sesionid+".stl");
    break;

  case '+':
    if (ISO) {
      ISO_TRESHOLD = min(1, ISO_TRESHOLD+.05);
      generateISO();
    }
    break;
  case '-':
    if (ISO) {
      ISO_TRESHOLD = max(0, ISO_TRESHOLD-.05);
      generateISO();
    }
    break;
  }
}
