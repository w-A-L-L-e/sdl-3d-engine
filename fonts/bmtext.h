/*=============================================================================
author        : Walter Schreppers
filename      : bmtext.h
created       : 2/5/2022 at 23:42:16
modified      : 
version       : 
copyright     : Walter Schreppers
description   : BitmapText to render strings on graphics screen 
=============================================================================*/

#ifndef BMTEXT_H
#define BMTEXT_H

#include <string>
#include "screen.h"

//typedef struct {
//  unsigned char letters[2][5][8];
//} BMFont;

class BMText {

  public:
    //constructor & destructor
    //==========================
    BMText(Screen& s);
    ~BMText();

    //public members
    //==============
    void print(Uint32 x, Uint32 y, const std::string& text);
    void print_wavy(Uint32 x, Uint32 y, const std::string& text);
    void print_flashy(Uint32 x, Uint32 y, const std::string& text);

  private:
    //private members:
    //================
    void init();
    void initFont();

    //private locals:
    //===============
    Screen *screen;
    //BMFont font;
    unsigned char font_matrix[256][5];
    float text_sintab[256];

}; //end of class BMText

#endif

