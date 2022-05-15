/*=============================================================================
author        : Walter Schreppers
filename      : turbotext.h
created       : 2/5/2022 at 23:42:16
modified      : 
version       : 
copyright     : Walter Schreppers
description   : Turbo Pascal bitmap font re-surrected from the 90's
=============================================================================*/

#ifndef TURBOTEXT_H
#define TURBOTEXT_H

#include <string>
#include "screen.h"

class TurboText {

  public:
    //constructor & destructor
    //==========================
    TurboText(Screen& s);
    ~TurboText();

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

}; //end of class TurboText

#endif

