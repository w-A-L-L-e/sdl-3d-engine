/*=============================================================================
author        : Walter Schreppers
filename      : object.cpp
created       : 3/5/2022 at 22:23:28
modified      :
version       :
copyright     : Walter Schreppers
bugreport(log):
=============================================================================*/

#include "object.h"
#include <iostream>
#include <numeric>

/*-----------------------------------------------------------------------------
name        : init
description : initialize private locals
parameters  :
return      : void
exceptions  :
algorithm   : initialize points and edges here
-----------------------------------------------------------------------------*/
void Object::init() {
  points.clear();
  rotated_points.clear();
  edges.clear();
  this->palette = 0;
  triangles.clear();
  rotMatrix.clear();
  for (int i = 0; i < 9; i++)
    rotMatrix.push_back(0.0);
}

/*-----------------------------------------------------------------------------
name        : Object
description : constructor
parameters  :
return      :
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
Object::Object(Screen &scr) {
  screen = &scr;
  init();
}

/*-----------------------------------------------------------------------------
name        : ~Object
description : destructor
parameters  :
return      :
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
Object::~Object() {}

void Object::add_point(float x, float y, float z) {
  point p = {x, y, z};
  points.push_back(p);
  rotated_points.push_back(p);
}

void Object::add_edge(int a, int b) {
  point ap = points[a];
  point bp = points[b];

  // don't add edge if pa==pb
  if( (ap.x == bp.x) && (ap.y == bp.y) && (ap.z == bp.z) ) return;

  edge e = {a, b};
  edges.push_back(e);
}

void Object::add_triangle(int a, int b, int c) {
  point ap = points[a];
  point bp = points[b];
  point cp = points[c];

  // don't add triangle if it's a flat line
  if( (ap.x == bp.x) && (ap.y == bp.y) && (ap.z == bp.z) ) return; 
  if( (ap.x == cp.x) && (ap.y == cp.y) && (ap.z == cp.z) ) return; 
  if( (cp.x == bp.x) && (cp.y == bp.y) && (cp.z == bp.z) ) return; 

  triangle t = {a, b, c};
  compute_normal_vector(t);
  triangles.push_back(t);
}

void Object::compute_normal_vector(triangle &t) {
  float distance;
  point N;

  point a = points[t.a];
  point b = points[t.b];
  point c = points[t.c];

  N.x = -(((b.y - a.y) * (c.z - a.z)) - ((c.y - a.y) * (b.z - a.z)));
  N.y = (((b.x - a.x) * (c.z - a.z)) - ((c.x - a.x) * (b.z - a.z)));
  N.z = -(((b.x - a.x) * (c.y - a.y)) - ((c.x - a.x) * (b.y - a.y)));

  distance = std::sqrt(N.x * N.x + N.y * N.y + N.z * N.z);

  t.normaal.x = N.x / distance;
  t.normaal.y = N.y / distance;
  t.normaal.z = N.z / distance;
}

void Object::rotateX(std::vector<float> &M, float angle) {
  float s = std::sinf(angle);
  float c = std::cosf(angle);

  M[0] = 1; M[1] = 0; M[2] = 0;
  M[3] = 0; M[4] = c; M[5] = -s;
  M[6] = 0; M[7] = s; M[8] = c;
}

void Object::rotateY(std::vector<float> &M, float angle) {
  float s = std::sinf(angle);
  float c = std::cosf(angle);

  M[0] = c;  M[1] = 0; M[2] = s; 
  M[3] = 0;  M[4] = 1; M[5] = 0; 
  M[6] = -s; M[7] = 0; M[8] = c;
}

void Object::rotateZ(std::vector<float> &M, float angle) {
  float s = std::sinf(angle);
  float c = std::cosf(angle);

  M[0] = c; M[1] = -s; M[2] = 0;
  M[3] = s; M[4] = c;  M[5] = 0;
  M[6] = 0; M[7] = 0;  M[8] = 1;
}

void Object::matTimesMat(std::vector<float> &result, const std::vector<float> &A,
                         const std::vector<float> &B) {
  for (int i = 0; i <= 2; i++) {
    for (int j = 0; j <= 2; j++) {
      float sum = 0;
      for (int k = 0; k <= 2; k++) {
        int a_pos = i * 3 + k; // row i, col k
        int b_pos = k * 3 + j; // row k, col j
        sum = sum + A[a_pos] * B[b_pos];
      }
      int res_pos = i * 3 + j; // row i, col j
      result[res_pos] = sum;
    }
  }
}

void Object::rotateXYZ(std::vector<float> &rotXYZ, float x, float y, float z) {
  // make rotate x,y,z matrix M
  std::vector<float> X;
  std::vector<float> Y;
  std::vector<float> Z;
  std::vector<float> rotXY;

  X.resize(9);
  Y.resize(9);
  Z.resize(9);
  rotXY.resize(9);
  rotXYZ.resize(9);

  rotateX(X, x);
  rotateY(Y, y);
  rotateZ(Z, z);

  matTimesMat(rotXY, X, Y);
  matTimesMat(rotXYZ, rotXY, Z);
}

void Object::fast_rotateXYZ(std::vector<float> &rotMat, float x, float y, float z) {
  using namespace std;
  float sin_x = sinf(x);
  float sin_y = sinf(y);
  float sin_z = sinf(z);

  float cos_x = cosf(x);
  float cos_y = cosf(y);
  float cos_z = cosf(z);

  /* combined xyz rotation matrix generated with wolfram 2022*/
  rotMat[0] = cos_y * cos_z;
  rotMat[1] = -cos_y * sin_z;
  rotMat[2] = sin_y;

  rotMat[3] = sin_x * sin_y * cos_z + cos_x * sin_z;
  rotMat[4] = cos_x * cos_z - sin_x * sin_y * sin_z;
  rotMat[5] = sin_x * -cos_y;

  rotMat[6] = sin_x * sin_z - cos_x * sin_y * cos_z;
  rotMat[7] = cos_x * sin_y * sin_z + sin_x * cos_z;
  rotMat[8] = cos_x * cos_y;
}

void Object::rotate_point(const point &p, point &rp,
                          const std::vector<float> &rotMat) {
  // for parallell projection and no shading or triangles we wouldn't even need
  // rp.z
  rp.x = rotMat[0] * p.x + rotMat[1] * p.y + rotMat[2] * p.z;
  rp.y = rotMat[3] * p.x + rotMat[4] * p.y + rotMat[5] * p.z;
  rp.z = rotMat[6] * p.x + rotMat[7] * p.y + rotMat[8] * p.z;
}

bool Object::clockwize(const triangle &t) {
  long xa = rotated_points[t.a].x;
  long ya = rotated_points[t.a].y;

  long xb = rotated_points[t.b].x;
  long yb = rotated_points[t.b].y;

  long xc = rotated_points[t.c].x;
  long yc = rotated_points[t.c].y;

  return ( xb*yc - yb*xc - xa*yc + ya*xc + xa*yb - ya*xb)<=0;
  // long v = xb * yc - yb * xc - xa * yc + ya * xc + xa * yb - ya * xb;
  // return v > 0;
}

// We need triangle to have : normaal, rnormaal, middenz, color index
void Object::rotate_normals(std::vector<triangle> &triangles,
                            const std::vector<float> &rotMat) {
  for (int i = 0; i < triangles.size(); i++) {
    if (clockwize(triangles[i])) {

      // we only need the z component of the rotated normaal to calculate its
      // color
      triangles[i].rnormaal.z = rotMat[6] * triangles[i].normaal.x +
                                rotMat[7] * triangles[i].normaal.y +
                                rotMat[8] * triangles[i].normaal.z;

      // weighted average of rotated z value of triangle edges
      triangles[i].middenz = rotated_points[triangles[i].a].z +
                             rotated_points[triangles[i].b].z +
                             rotated_points[triangles[i].c].z;

      // make color dependent on the rotated normal's z value + some tweaks to
      // have enough light
      int tricol = std::abs(triangles[i].rnormaal.z * 255);
      // std::cout<<"tricol="<<tricol<<std::endl;

      if (tricol > 255)
        tricol = 255;
      if (tricol < 0)
        tricol = 0;

      triangles[i].color = tricol;
      triangles[i].visible = true;
    } else {
      triangles[i].visible = false;
    }
  }
}

void Object::project(point &p, bool perspective, float distance) {
  if (perspective) {
    // distance 200 - 20_000 is ok, default 600
    if(distance<200) distance=200;
    if(distance>20000) distance=20000;
    float zoom = 650;
    p.x = (zoom * p.x) / (p.z + distance) + screen->center_x;
    p.y = (zoom * p.y) / (p.z + distance) + screen->center_y;
  } else {
    p.x = p.x + screen->center_x;
    p.y = p.y + screen->center_y;
  }
}

void Object::rotate(float x, float y, float z, bool perspective_projection, float distance) {

  //rotate_XYZ(rotMatrix, x,y,z); //classic way of doing it
  fast_rotateXYZ(rotMatrix, x, y, z); // fast xyz computed with wolfram

  for (unsigned int i = 0; i < points.size(); i++) {
    rotate_point(points[i], rotated_points[i], rotMatrix);
    project(rotated_points[i], perspective_projection, distance);
  }

  rotate_normals(triangles, rotMatrix);
}

void Object::setShadingColor(int c){
  if(this->palette){
    Color pcol = this->palette->getColor(c);
    screen->setColor(pcol.red, pcol.green, pcol.blue);
  }
  else{ //greyscale manually
    screen->setColor(c, c, c);
  }
}

void Object::draw(int shading) {
  // sort triangles based on visible = true and middenz value
  // this might become deprecated when we do depth buffering
  std::vector<vtriangle> vtriangles;
  for(unsigned int i = 0; i < triangles.size(); i++){
    if(triangles[i].visible){
      vtriangle vt;
      vt.middenz = triangles[i].middenz;
      vt.tripos = i;
      vtriangles.push_back(vt);
    }
  }
  std::sort(vtriangles.begin(), vtriangles.end());


  for (unsigned int i = 0; i < vtriangles.size(); i++) {
    point pa = rotated_points[triangles[vtriangles[i].tripos].a];
    point pb = rotated_points[triangles[vtriangles[i].tripos].b];
    point pc = rotated_points[triangles[vtriangles[i].tripos].c];

    // shading == 0 -> unfilled triangle
    int c = triangles[vtriangles[i].tripos].color;

    if(shading==0){
      screen->setColor(0,0,0);
      screen->fill_triangle(pa.x, pa.y, pb.x, pb.y, pc.x, pc.y);
      setShadingColor(c);
      screen->triangle(pa.x, pa.y, pb.x, pb.y, pc.x, pc.y);
    }
    if(shading==1){
      setShadingColor(c);
      screen->fill_triangle(pa.x, pa.y, pb.x, pb.y, pc.x, pc.y);
    }
  }


  /* for drawing all triangles we can use this loop
  for (unsigned int i = 0; i < triangles.size(); i++) {
    point pa = rotated_points[triangles[i].a];
    point pb = rotated_points[triangles[i].b];
    point pc = rotated_points[triangles[i].c];

    if (triangles[i].visible) {
      // shading == 0 -> unfilled triangle
      int c = triangles[i].color;

      screen->setColor(c, c, c); // or use some palette index
      if(shading==0) screen->triangle(pa.x, pa.y, pb.x, pb.y, pc.x, pc.y);
      if(shading==1) screen->fill_triangle(pa.x, pa.y, pb.x, pb.y, pc.x, pc.y);
    }
  }
  */
}





// alternate drawing/render routines here, mostly useful for debugging or some old school effects:
void Object::draw_points() {
  for (unsigned int i = 0; i < points.size(); i++) {
    screen->pixel( points[i].x, points[i].y );
  }
}

void Object::draw_rotated_points() {
  if(this->palette){
    Color pcol = this->palette->getColor(255);
    screen->setColor(pcol.red, pcol.green, pcol.blue);
  }
  else{ //greyscale manually
    screen->setColor(255, 255, 255);
  }

  for (unsigned int i = 0; i < rotated_points.size(); i++) {
    screen->pixel( rotated_points[i].x, rotated_points[i].y );
  }
}


void Object::setPalette(Palette& pal){
  this->palette = &pal;
}

void Object::draw_edges(bool shading) {
  // draw lines
  for (unsigned int i = 0; i < edges.size(); i++) {
    point pa = rotated_points[edges[i].a];
    point pb = rotated_points[edges[i].b];

    if (shading) {
      // shading far away lines
      float depth = std::abs(pa.z + pb.z + 200) / 2;
      int col = 255 - depth;
      if (col < 0)
        col = 0;

      if(this->palette){
        Color pcol = this->palette->getColor(col);
        screen->setColor(pcol.red, pcol.green, pcol.blue);
      }
      else{ //greyscale manually
        screen->setColor(col, col, col);
      }
    }

    screen->line(pa.x, pa.y, pb.x, pb.y);
  }
}


