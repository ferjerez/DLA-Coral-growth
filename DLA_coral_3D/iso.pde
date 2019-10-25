
void generateISO() {
  // taken from an example of ToxicLibs library
  // Generate ISO-Surface
  int DIMX = G3D.sx;
  int DIMY = G3D.sy;
  int DIMZ = G3D.sz;
  Vec3D SCALE=new Vec3D(G3D.gridsize, G3D.gridsize, G3D.gridsize).scaleSelf(DIMX, DIMY, DIMZ);

  VolumetricSpace volume=new VolumetricSpaceArray(SCALE, DIMX, DIMY, DIMZ);
  // fill volume  
  for (int z=0; z<DIMZ; z++) {
    for (int y=0; y<DIMY; y++) {
      for (int x=0; x<DIMX; x++) {
        float val = constrain(G3D.smooth[x][y][z], 0, 1);

        volume.setVoxelAt(x, y, z, val);
      }
    }
  }
  volume.closeSides();
  long t0=System.nanoTime();
  // store in IsoSurface and compute surface mesh for the given threshold value
  mesh=new WETriangleMesh("iso");
  surface=new HashIsoSurface(volume, 0.333333);
  surface.computeSurfaceMesh(mesh, ISO_TRESHOLD);

  float timeTaken=(System.nanoTime()-t0)*1e-6;
  println(timeTaken+"ms to compute "+mesh.getNumFaces()+" faces");
}
