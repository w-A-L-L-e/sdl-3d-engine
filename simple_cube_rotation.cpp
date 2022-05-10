/*=============================================================================
author        : Walter Schreppers
filename      : cube.cpp
created       : 8/5/2022 at 22:50:23
modified      : 8/5/2022
version       :
copyright     : Walter Schreppers
description   : The shortest way to draw a rotated cube using combined xyz matrix
=============================================================================*/

#include "screen.h"
#include <iostream>
#include <numeric>
#include <vector>

bool perspective_projection = true;

struct point {
  float x, y, z;
};

void add_point(std::vector<point> &v, float x, float y, float z) {
  point p = {x, y, z};
  v.push_back(p);
}

struct edge {
  int a, b;
};

void add_edge(std::vector<edge> &edges, int a, int b) {
  edge e = {a, b};
  edges.push_back(e);
}

void init_cube(std::vector<point> &v) {
  add_point(v, -100, 100, -100);
  add_point(v, -100, -100, -100);
  add_point(v, 100, -100, -100);
  add_point(v, 100, 100, -100);

  add_point(v, -100, 100, 100);
  add_point(v, -100, -100, 100);
  add_point(v, 100, -100, 100);
  add_point(v, 100, 100, 100);
}

void init_edges(std::vector<edge> &edges) {
  add_edge(edges, 0, 1);
  add_edge(edges, 1, 2);
  add_edge(edges, 2, 3);
  add_edge(edges, 3, 0);
  add_edge(edges, 4, 5);
  add_edge(edges, 5, 6);
  add_edge(edges, 6, 7);
  add_edge(edges, 7, 4);
  add_edge(edges, 4, 0);
  add_edge(edges, 5, 1);
  add_edge(edges, 6, 2);
  add_edge(edges, 7, 3);
}

// combined x,y,z matrix calculated by hand by Walter Schreppers in the 90's
void rotateXYZ(std::vector<float> &rotMat, float x = 0, float y = 0,
               float z = 0) {
  using namespace std;

  float sin_x = sin(x);
  float sin_y = sin(y);
  float sin_z = sin(z);

  float cos_x = cos(x);
  float cos_y = cos(y);
  float cos_z = cos(z);

  /* 
  // as implemented by hand in turbo pascal in 90's
  // this works for simple shapes and fixed point arithmetic
  // however the wolfram version is more precise.
  rotMat[0] = cos_z * cos_y;
  rotMat[1] = sin_z * cos_y;
  rotMat[2] = -sin_y;

  rotMat[3] = sin_x * sin_y * cos_z - cos_x * sin_z;
  rotMat[4] = sin_x * sin_y * sin_z + cos_x * cos_z;
  rotMat[5] = sin_x * cos_y;

  rotMat[6] = sin_x * sin_y * cos_z + sin_x * sin_z;
  rotMat[7] = cos_x * sin_y * sin_z - sin_x * cos_z;
  rotMat[8] = cos_x * cos_y;
  */

  /* computed using wolfram 2022*/
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

point rotate(const point &p, const std::vector<float> &rotMat) {
  point prot;

  prot.x = rotMat[0] * p.x + rotMat[1] * p.y + rotMat[2] * p.z;
  prot.y = rotMat[3] * p.x + rotMat[4] * p.y + rotMat[5] * p.z;
  prot.z = rotMat[6] * p.x + rotMat[7] * p.y + rotMat[8] * p.z;

  return prot;
}

void project(point &p, Screen &scr, bool perspective = true) { 
  if (perspective) {
    float zoom = 2.0;
    p.x = zoom * ((p.x * scr.width) / (-p.z + 4 * scr.center_x)) + scr.center_x;
    p.y = zoom * ((p.y * scr.height) / (-p.z + 4 * scr.center_y)) + scr.center_y;
  } else {
    p.x = p.x + scr.center_x;
    p.y = p.y + scr.center_y;
  }
}

int main(int argc, char **argv) {
  std::cout << "Minimal 3D cube example" << std::endl;
  std::cout << "=======================" << std::endl;
  std::cout << "Press 'f' to toggle fullscreen" << std::endl;
  std::cout << std::endl;

  std::vector<point> cube_points;
  init_cube(cube_points);

  std::vector<edge> cube_edges;
  init_edges(cube_edges);

  std::vector<point> rotated_points;
  for (int i = 0; i < cube_points.size(); i++)
    add_point(rotated_points, 0, 0, 0);

  std::vector<float> rotMatrix;
  for (int i = 0; i < 9; i++)
    rotMatrix.push_back(0.0);

  Screen screen(640, 400);

  // x,y,z rotation angles
  float ax = 0, ay = 0, az = 0;

  while (screen.opened()) {
    // screen.printFPS(); //prints fps
    screen.handle_events();
    screen.clear();

    ax += 0.01;
    ay += 0.02;
    az += 0.005;
    rotateXYZ(rotMatrix, ax, ay, az);

    // rotate points and do parallell or perspective projection
    for (unsigned int i = 0; i < cube_points.size(); i++) {
      rotated_points[i] = rotate(cube_points[i], rotMatrix);
      project(rotated_points[i], screen, perspective_projection);
    }

    // draw all edges
    screen.setColor(255, 255, 255);
    for (unsigned int i = 0; i < cube_edges.size(); i++) {
      point pa = rotated_points[cube_edges[i].a];
      point pb = rotated_points[cube_edges[i].b];
      screen.line(pa.x, pa.y, pb.x, pb.y);
    }

    // SDL_Delay(20); // use this to slow down
    screen.draw();
  }

  return 0;
}
