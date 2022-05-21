/*=============================================================================
author        : Walter Schreppers
filename      : object.h
created       : 3/5/2022 at 22:23:28
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#ifndef TDOBJECT_H
#define TDOBJECT_H
#include <vector>
#include <string>
#include "screen.h"

struct point{
  float x,y,z;
};

struct edge{
  int a,b;
};

struct triangle{
  int a,b,c;
  point normaal;
  point rnormaal;
  float middenz;
  int color;
  bool visible;
};

//only the visible triangles for sorting
struct vtriangle{
  int tripos;
  float middenz;

  bool operator < (const vtriangle& rhs) const {
    return middenz > rhs.middenz;
  }
};



class Object {

  public:
    //constructor & destructor
    //========================
    Object(Screen& scr);
    ~Object();

    //public members
    //==============
    void rotate(float x=0, float y=0, float z=0, bool perspective_projection=true);
    virtual void draw_points();
    virtual void draw_rotated_points();
    virtual void draw_edges(bool shading=true);
    virtual void draw(int shade_technique=0);
    virtual std::string name(){return "Object";}

  private:
    //private members:
    //================
    void init();
    void init_points(){}
    void init_edges(){}
    void init_triangles(){}
    bool smaller_middenz(const vtriangle& a, const vtriangle& b);

    //private locals
    //==============
    

  protected:
    //protected members 
    //=================
    void add_point(float x, float y, float z);
    void add_edge(int a, int b);
    void add_triangle(int a, int b, int c);
    void rotateX(std::vector<float> &M, float x_angle);
    void rotateY(std::vector<float> &M, float x_angle);
    void rotateZ(std::vector<float> &M, float x_angle);
    void matTimesMat(std::vector<float> &result, const std::vector<float> &A, const std::vector<float> &B);
    void rotateXYZ(std::vector<float> &M, float x=0, float y=0, float z=0);
    void fast_rotateXYZ( std::vector<float>& rotMat, float x=0, float y=0, float z=0 );
    bool clockwize(const triangle& t);
    void rotate_normals(std::vector<triangle>& triangles, const std::vector<float>& rotMat);
    void rotate_point(const point& p, point& rp, const std::vector<float>& rotMat);
    void project(point &p, bool perspective=true);
    void compute_normal_vector(triangle& t);
 
    //protected locals
    //================
    Screen* screen;
    std::vector<point> points;
    std::vector<point> rotated_points;
    
    //edges and triangles have indeces to points
    std::vector<edge> edges;
    std::vector<triangle> triangles;
    
    std::vector<float> rotMatrix;

}; //end of class 3D Object

#endif

