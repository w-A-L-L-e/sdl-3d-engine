/*=============================================================================
author        : Walter Schreppers
filename      : blenderobject.h
created       : 21/5/2022 at 00:41:44
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#ifndef BLENDEROBJECT_H
#define BLENDEROBJECT_H

#include "object.h"

class BlenderObject : public Object {

  public:
    //constructor & destructor
    //==========================
    BlenderObject(Screen&);
    ~BlenderObject();

    //public members
    //==============
    std::string name(){return object_name;}
    void load(const std::string& filename, float resize=300);
    void save(const std::string& filename);


    // this object can't use edge drawing yet
    void draw_edges(bool shaded){
      if(shaded) draw(1);
      else draw(0);
    }

  private:
    //private members:
    //================
    void init();
    void normalize_object(float resize=300);

    //private locals:
    //===============
    std::string file_name;
    std::string object_name;

}; //end of class BlenderObject

#endif

