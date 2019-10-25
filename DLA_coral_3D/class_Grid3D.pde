class Grid3D {
  int sx, sy, sz;

  float[][][] cells;
  float[][][] smooth;

  PVector[][][] force;

  int gridsize = 2;

  Grid3D(int x, int y, int z) {
    gridsize = 2;
    sx = x;
    sy = y;
    sz = z;
    cells = new float[sx][sy][sz];
    smooth = new float[sx][sy][sz];

    force = new PVector[sx][sy][sz];

    fillGrid(0);

    //fillZ(0, 1);
    fillSphere(sx/2, sy/2, 0, 15, 1);
  }

  // fills a disc centered in cx,cy,cz with radius r , height h and value for each cell of v
  void fillDisc(int cx, int cy, int cz, int r, int h, float v) {  
    for (int x = cx-r; x<=cx+r; x++) {
      for (int y = cy-r; y<=cy+r; y++) {
        for (int z = cz; z<cz+h; z++) {
          if (x>=0 && x<sx && y>=0 && y<sy && z>=0 && z<sz) {
            if (dist(x, y, cx, cy)<=r) {
              cells[x][y][z] = v;
              smooth[x][y][z] = v;
            }
          }
        }
      }
    }
  }
  // Fills a sphere centered in cx,cy,cz with radius r and value v
  void fillSphere(int cx, int cy, int cz, int r, float v) {  
    for (int x = cx-r; x<=cx+r; x++) {
      for (int y = cy-r; y<=cy+r; y++) {
        for (int z = cz-r; z<=cz+r; z++) {
          if (x>=0 && x<sx && y>=0 && y<sy && z>=0 && z<sz) {
            if (dist(x, y, z, cx, cy, cz)<=r) {
              cells[x][y][z] = v;
              smooth[x][y][z] = v;
            }
          }
        }
      }
    }
  }

  // fill a plane in height z with value v
  void fillZ(int z, float v) {  
    for (int x = 0; x<sx; x++) {
      for (int y = 0; y<sy; y++) {

        cells[x][y][z] = v;
        smooth[x][y][z] = v;
      }
    }
  }

  // Fill all grid with value v
  void fillGrid(float v) {  
    for (int x = 0; x<sx; x++) {
      for (int y = 0; y<sy; y++) {
        for (int z = 0; z<sz; z++) {
          cells[x][y][z] = v;
          smooth[x][y][z] = v;
        }
      }
    }
  }

  // REturns numbers of cell actives around x,y,z
  int neighbours(int x, int y, int z) {
    int n = 0;
    int r = 1;
    for (int i = -r; i<=r; i++) {
      for (int j = -r; j<=r; j++) {
        for (int k = -r; k<=r; k++) {
          if (x+i>=0 && x+i<sx && y+j>=0 && y+j<sy && z+k>=0 && z+k<sz) {
            n+=(cells[x+i][y+j][z+k]!=0)?1:0;
          }
        }
      }
    }
    return n;
  }

  // returns number of active cells under x,y,z (works better for 3d printing)
  int neighboursDown(int x, int y, int z) {
    int n = 0;
    int r = 1;
    for (int i = -r; i<=r; i++) {
      for (int j = -r; j<=r; j++) {
        for (int k = -r; k<0; k++) {
          if (x+i>=0 && x+i<sx && y+j>=0 && y+j<sy && z+k>=0 && z+k<sz) {
            n+=(cells[x+i][y+j][z+k]!=0)?1:0;
          }
        }
      }
    }
    return n;
  }

  // smooth grid
  void diffusion(int times) {
    int b = 1; // border (0=periodic)
    float diffRate = .5;

    float[][][] buff = new float[sx][sy][sz];
    // Copy smooth->buff

    copyGrid(smooth, buff);


    for (int t = 0; t<times; t++) {
      for (int i = b; i<sx-b; i++) {
        for (int j = b; j<sy-b; j++) {
          for (int k = b; k<sz-b; k++) {

            float sum = 0;

            sum+=smooth[(i+1) % sx][j][k];
            sum+=smooth[(i-1+sx) % sx][j][k];
            sum+=smooth[i][(j+1) % sy][k];
            sum+=smooth[i][(j-1+sy) % sy][k];
            sum+=smooth[i][j][(k+1) % sz];
            sum+=smooth[i][j][(k-1+sz) % sz];
            buff[i][j][k] =  (smooth[i][j][k] + diffRate*sum) / (1 + 6 * diffRate);
          }
        }
      }    
      // switch smooth - buff;
      swapGrid(smooth, buff);
    }
  }

  // Change cells to 1 or 0 if have mor or less than 'n' neighbours (expand & smooth)
  void applyCA(int times, float[][][] grid) {
    int b = 0;
    int n = 10;
    float[][][] buff = new float[sx][sy][sz];
    for (int t = 0; t<times; t++) {
      for (int i = b; i<sx-b; i++) {
        for (int j = b; j<sy-b; j++) {
          for (int k = b; k<sz-b; k++) {
            if (neighbours(i, j, k)>=n) buff[i][j][k] = 1; 
            else if (neighbours(i, j, k)<n) buff[i][j][k] = 0; 
            else buff[i][j][k] = grid[i][j][k];
          }
        }
      }
      // switch smooth - buff;
      swapGrid(grid, buff);
    }
    copyGrid(grid, cells);
  }

  // Array copy for 3D arrays
  void copyGrid(float[][][] g1, float[][][] g2) {
    int b = 0;
    for (int i = b; i<sx-b; i++) {
      for (int j = b; j<sy-b; j++) {
        for (int k = b; k<sz-b; k++) {

          g2[i][j][k] = g1[i][j][k];
        }
      }
    }
  }
  // Array swap for 3d arrays
  void swapGrid(float[][][] g1, float[][][] g2) {
    int b = 0;
    for (int i = b; i<sx-b; i++) {
      for (int j = b; j<sy-b; j++) {
        for (int k = b; k<sz-b; k++) {
          float tmp = g1[i][j][k];
          g1[i][j][k] = g2[i][j][k];
          g2[i][j][k] = tmp;
        }
      }
    }
  }

  // Show grid
  void display() {
    int g = gridsize;

    pushMatrix();
    noFill();
    stroke(255);
    translate(sx*g*.5, sy*g*.5, sz*g*.5);
    box(g*sx, g*sy, g*sz);
    popMatrix();

    noStroke();
    fill(255);

    for (int x = 0; x<sx; x++) {
      for (int y = 0; y<sy; y++) {
        for (int z = 0; z<sz; z++) {
          if (cells[x][y][z]!=0) {
            pushMatrix();
            translate(x*g, y*g, z*g);
            box(g);
            popMatrix();
          }
        }
      }
    }
  }
}
