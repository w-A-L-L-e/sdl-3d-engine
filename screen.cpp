/*=============================================================================
author        : Walter Schreppers
filename      : screen.cpp
created       : 30/4/2022 at 22:50:23
modified      :
version       :
copyright     : Walter Schreppers
bugreport(log):
=============================================================================*/

#include "screen.h"
#include <iostream>
#include <string>

/*-----------------------------------------------------------------------------
name        : init
description : initialize SDL screen
parameters  :
return      : void
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
void Screen::init() {
  SDL_Init(SDL_INIT_EVERYTHING);

  window = SDL_CreateWindow(this->window_title.c_str(), SDL_WINDOWPOS_UNDEFINED,
                            SDL_WINDOWPOS_UNDEFINED, width, height,
                            SDL_WINDOW_SHOWN);

  // the VSYNC makes it cap at 60fps (or whatever the screen refresh is) and
  // have smooth animation
  renderer = SDL_CreateRenderer(
      window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
  // showRenderInfo(renderer);

  texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888,
                              SDL_TEXTUREACCESS_STREAMING, width, height);

  running = true;
  setFullscreen(this->fullscreen);
}

/*-----------------------------------------------------------------------------
name        : Screen
description : constructor
parameters  :
return      :
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
Screen::Screen(Uint32 width, Uint32 height, const std::string &title, bool full_screen) {
  this->width = width;
  this->height = height;
  this->center_x = width / 2;
  this->center_y = height / 2;
  this->window_title = title;
  this->fullscreen = full_screen;

  window = NULL;
  renderer = NULL;
  texture = NULL;
  pixels = NULL;

  init();
}

/*-----------------------------------------------------------------------------
name        : ~Screen
description : destructor
parameters  :
return      :
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
Screen::~Screen() {
  running = false;
  if (renderer)
    SDL_DestroyRenderer(renderer);
  if (window)
    SDL_DestroyWindow(window);
  SDL_Quit();
}

void Screen::setFullscreen(bool fs) {
  this->fullscreen = fs;
  if (fs) {
    SDL_SetWindowFullscreen(window,
                            // SDL_WINDOW_FULLSCREEN);
                            SDL_WINDOW_FULLSCREEN_DESKTOP);
  } else {
    SDL_SetWindowFullscreen(window, 0);
  }

  // keep track of scaling factors when stretched on full screen mode.
  int screen_w, screen_h;
  SDL_GL_GetDrawableSize(window, &screen_w, &screen_h);
  this->x_scale = (double)screen_w / (double)this->width;
  this->y_scale = (double)screen_h / (double)this->height;
}

void Screen::handle_events() {

  while (SDL_PollEvent(&event)) {
    switch (event.type) {
    case SDL_QUIT:
      running = false;
      break;
    case SDL_KEYDOWN: // SDL_KEYUP also exists
      if (event.key.keysym.scancode == SDL_SCANCODE_F) {
        this->fullscreen = !this->fullscreen;
        setFullscreen(this->fullscreen);
      }
      if (event.key.keysym.scancode == SDL_SCANCODE_Q) {
        running = SDL_FALSE;
      }
      break;
    default:
      break;
    }
  }
}

void Screen::printFPS() {
  static Uint32 countedFrames = 0;
  static Uint32 startTick = SDL_GetTicks();
  Uint32 ticks = SDL_GetTicks();
  countedFrames++;
  if (countedFrames % 30 == 0) {
    float avgFPS = (int)countedFrames / ((ticks - startTick) / 1000.f);
    printf("fps %f\n", avgFPS);
  }
  if (countedFrames % 150 == 0) {
    startTick = ticks;
    countedFrames = 0;
  }
}

void Screen::showRenderInfo() {
  SDL_RendererInfo info;
  SDL_GetRendererInfo(renderer, &info);
  std::cout << "Renderer name: " << info.name << std::endl;
  std::cout << "Texture formats: " << std::endl;
  for (Uint32 i = 0; i < info.num_texture_formats; i++) {
    std::cout << SDL_GetPixelFormatName(info.texture_formats[i]) << std::endl;
  }
}

void Screen::clear(Uint32 r, Uint32 g, Uint32 b, Uint32 alpha) {
  // clear screen, is automatically done wiht locking texture
  SDL_SetRenderDrawColor(renderer, r, g, b, alpha); // 0 = transparent, 255=opaque
  SDL_RenderClear(renderer);

  // lock double buffer texture so we can manipulate lockedPixels directly
  int pitch = 0;
  SDL_LockTexture(texture, NULL, reinterpret_cast<void **>(&pixels), &pitch);

  // as optimization, normally all is zeroed and thus already ready for next frame
  if(r!=0 || g!=0 || b!=0 || alpha!=255){
    for(int offset=0;offset<(width*height*4)-4;offset+=4){
      pixels[offset + 0] = b;
      pixels[offset + 1] = g;
      pixels[offset + 2] = r;
      pixels[offset + 3] = alpha;
    }
  } 
  // we avoid this here ;)
  // std::memcpy( lockedPixels, pixels.data(), pixels.size() );
}

void Screen::draw(bool present) {
  // unlock and copy to renderer
  SDL_UnlockTexture(texture);
  SDL_RenderCopy(renderer, texture, NULL, NULL);

  if (present) {
    // show renderer on screen
    SDL_RenderPresent(renderer);
  }
}

void Screen::pixel(Uint32 x, Uint32 y, Uint32 red, Uint32 green, Uint32 blue,
                   Uint32 alpha) {
  if (x >= width)
    return;
  if (y >= height)
    return;

  const unsigned int offset = (width * 4 * y) + x * 4;
  pixels[offset + 0] = blue;  // b
  pixels[offset + 1] = green; // g
  pixels[offset + 2] = red;   // r
  pixels[offset + 3] = alpha; // a
}

void Screen::pixel(Uint32 x, Uint32 y) {
  if (x >= width)
    return;
  if (y >= height)
    return;

  const unsigned int offset = (width * 4 * y) + x * 4;
  pixels[offset + 0] = blue;  // b
  pixels[offset + 1] = green; // g
  pixels[offset + 2] = red;   // r
  pixels[offset + 3] = alpha; // a
}

void Screen::setColor(Uint32 red, Uint32 green, Uint32 blue, Uint32 alpha) {
  if (red > 255)
    red = 255;
  if (green > 255)
    green = 255;
  if (blue > 255)
    blue = 255;

  this->red = red;
  this->green = green;
  this->blue = blue;
  this->alpha = alpha;
}

// midpoint circle algorithm
// https://en.wikipedia.org/w/index.php?title=Midpoint_circle_algorithm&oldid=889172082#C_example
void Screen::circle(Uint32 centreX, Uint32 centreY, Uint32 radius) {
  const int32_t diameter = (radius * 2);

  int32_t x = (radius - 1);
  int32_t y = 0;
  int32_t tx = 1;
  int32_t ty = 1;
  int32_t error = (tx - diameter);

  while (x >= y) {
    //  Each of the following renders an octant of the circle
    pixel(centreX + x, centreY - y);
    pixel(centreX + x, centreY + y);
    pixel(centreX - x, centreY - y);
    pixel(centreX - x, centreY + y);
    pixel(centreX + y, centreY - x);
    pixel(centreX + y, centreY + x);
    pixel(centreX - y, centreY - x);
    pixel(centreX - y, centreY + x);

    if (error <= 0) {
      ++y;
      error += ty;
      ty += 2;
    }

    if (error > 0) {
      --x;
      tx += 2;
      error += (tx - diameter);
    }
  }
}

int Screen::abs(int v) {
  if (v < 0)
    return -v;
  return v;
}

// bresenham line
void Screen::line(int x0, int y0, int x1, int y1) {
  int dx = abs(x1 - x0), sx = x0 < x1 ? 1 : -1;
  int dy = -abs(y1 - y0), sy = y0 < y1 ? 1 : -1;
  int err = dx + dy, e2; /* error value e_xy */

  while (true) {
    pixel(x0, y0);
    if (x0 == x1 && y0 == y1)
      break;

    /* e_xy+e_x > 0 */
    e2 = 2 * err;
    if (e2 >= dy) {
      err += dy;
      x0 += sx;
    }

    /* e_xy+e_y < 0 */
    if (e2 <= dx) {
      err += dx;
      y0 += sy;
    }
  }
}

void Screen::triangle(int x0, int y0, int x1, int y1, int x2, int y2) {
  line(x0, y0, x1, y1);
  line(x1, y1, x2, y2);
  line(x2, y2, x0, y0);
}

// Inspiration
// https://github.com/ssloy/tinyrenderer/wiki/Lesson-2:-Triangle-rasterization-and-back-face-culling
void Screen::fill_triangle(int x0, int y0, int x1, int y1, int x2, int y2) {

  if (y0 == y1 && y0 == y2)
    return; // skip one line triangles

  // sort the vertices, t0, t1, t2 lower−to−upper (bubblesort yay!)
  if (y0 > y1) {
    std::swap(y0, y1);
    std::swap(x0, x1);
  }
  if (y0 > y2) {
    std::swap(y0, y2);
    std::swap(x0, x2);
  }
  if (y1 > y2) {
    std::swap(y1, y2);
    std::swap(x1, x2);
  }

  int total_height = y2 - y0;

  for (int i = 0; i < total_height; i++) {
    bool second_half = i > y1 - y0 || y1 == y0;
    int segment_height = second_half ? y2 - y1 : y1 - y0;

    float ma = (float)i / total_height;
    // be careful: with above conditions no division by zero here
    float mb = (float)(i - (second_half ? y1 - y0 : 0)) / segment_height;

    int Ax, Ay, Bx, By;
    Ax = x0 + (x2 - x0) * ma;
    // Ay = y0 + (y2-y0)*ma;

    if (second_half) {
      Bx = x1 + (x2 - x1) * mb;
      // By = y1 + (y2-y1)*mb;
    } else {
      Bx = x0 + (x1 - x0) * mb;
      // By = y0 + (y1-y0)*mb;
    }

    if (Ax > Bx) {
      std::swap(Ax, Bx);
    }

    if ((y0 + i) >= height)
      continue;
    if ((y0 + i) < 0)
      continue;

    // This is simpler but slower:
    // for (int j=Ax; j<=Bx; j++) {
    //  pixel(j, y0+i);
    //}

    // Instead: fast draw the horizonal lines without using pixel
    // and only compute offset once
    if(Ax<0) Ax=0; // clip at left edge screen;
                   
    const unsigned int offset = (width * 4 * (y0 + i)) + Ax * 4;
    for (int j = 0; j < (Bx - Ax); j++) {
      if ((j + Ax) >= width)
        break;
      int xpos = offset + j * 4;

      pixels[xpos + 0] = blue;  // b
      pixels[xpos + 1] = green; // g
      pixels[xpos + 2] = red;   // r
      pixels[xpos + 3] = alpha; // a
    }
  }
}



/*
 * Didn't have time to rewrite my own pascal texture mapping into c++
 * and figured someone already did it. stumbled upon this which seems to do what we need here 
 * mostly: ...
 *
 * The original pascal code did about the same with a different twist:
 * The routine was also TextureTriangle but it used GetXTri second function.
 * and it uses u,v as well for proper perspective scaling (we used screen3 for the texture image data, as
 * there was no SDL or OpenGL allowed back then ):
 * https://github.com/w-A-L-L-e/sdl-3d-engine/blob/cca4aa1c4ab64f74c7f57c19c2f8ae790c84ae1b/inspiration/3dengine.pas#L874
 *
 * if you read the getXTri original procedure I wrote in the 90's it has a lot of similarities in below c++
 * version. but somehow it doesn't need the w1,w2,w3. It only uses u1-u3 and v1-v3 yet I remember clearly solving the 
 * perspective issues with it also... 
 * https://github.com/w-A-L-L-e/sdl-3d-engine/blob/cca4aa1c4ab64f74c7f57c19c2f8ae790c84ae1b/inspiration/3dengine.pas#L642
 * 
 */
 

// Didn't have time to rewrite the original pascal source here, so re-used this routine:
// https://github.com/OneLoneCoder/olcPixelGameEngine/blob/12f634007c617e0fc3c7b8c5991f5310ea1b22b0/Extensions/olcPGEX_Graphics3D.h#L769

/*  example call: 
		{
				TexturedTriangle(t.p[0].x, t.p[0].y, t.t[0].u, t.t[0].v, t.t[0].w,
					t.p[1].x, t.p[1].y, t.t[1].u, t.t[1].v, t.t[1].w,
					t.p[2].x, t.p[2].y, t.t[2].u, t.t[2].v, t.t[2].w, sprTex1);
				
				//FillTriangle(t.p[0].x, t.p[0].y, t.p[1].x, t.p[1].y, t.p[2].x, t.p[2].y, t.sym, t.col);
				DrawTriangle(t.p[0].x, t.p[0].y, t.p[1].x, t.p[1].y, t.p[2].x, t.p[2].y, PIXEL_SOLID, FG_WHITE);
			}
		}
*/
void Screen::texture_triangle(
    int x1, int y1, float u1, float v1, float w1,
		int x2, int y2, float u2, float v2, float w2,
		int x3, int y3, float u3, float v3, float w3,
		SDL_Texture* tex) {

    // re-order points in triangle and swap along u,v,w as well
    // we want to have y1 < y2 < y3
		if (y2 < y1)
		{
      std::swap(y1, y2);
			std::swap(x1, x2);
			std::swap(u1, u2);
			std::swap(v1, v2);
			std::swap(w1, w2);
		}

		if (y3 < y1)
		{
      std::swap(y1, y3);
			std::swap(x1, x3);
			std::swap(u1, u3);
			std::swap(v1, v3);
			std::swap(w1, w3);
		}

		if (y3 < y2)
		{
      std::swap(y2, y3);
			std::swap(x2, x3);
			std::swap(u2, u3);
			std::swap(v2, v3);
			std::swap(w2, w3);
		}

		int dy1 = y2 - y1;
		int dx1 = x2 - x1;
		float dv1 = v2 - v1;
		float du1 = u2 - u1;
		float dw1 = w2 - w1;

		int dy2 = y3 - y1;
		int dx2 = x3 - x1;
		float dv2 = v3 - v1;
		float du2 = u3 - u1;
		float dw2 = w3 - w1;

		float tex_u, tex_v, tex_w;

		float dax_step = 0, dbx_step = 0,
			du1_step = 0, dv1_step = 0,
			du2_step = 0, dv2_step = 0,
			dw1_step=0, dw2_step=0;

		if (dy1) dax_step = dx1 / (float)abs(dy1);
		if (dy2) dbx_step = dx2 / (float)abs(dy2);

		if (dy1) du1_step = du1 / (float)abs(dy1);
		if (dy1) dv1_step = dv1 / (float)abs(dy1);
		if (dy1) dw1_step = dw1 / (float)abs(dy1);

		if (dy2) du2_step = du2 / (float)abs(dy2);
		if (dy2) dv2_step = dv2 / (float)abs(dy2);
		if (dy2) dw2_step = dw2 / (float)abs(dy2);

		if (dy1)
		{
			for (int i = y1; i <= y2; i++)
			{
				int ax = x1 + (float)(i - y1) * dax_step;
				int bx = x1 + (float)(i - y1) * dbx_step;

				float tex_su = u1 + (float)(i - y1) * du1_step;
				float tex_sv = v1 + (float)(i - y1) * dv1_step;
				float tex_sw = w1 + (float)(i - y1) * dw1_step;

				float tex_eu = u1 + (float)(i - y1) * du2_step;
				float tex_ev = v1 + (float)(i - y1) * dv2_step;
				float tex_ew = w1 + (float)(i - y1) * dw2_step;

				if (ax > bx)
				{
          std::swap(ax, bx);
					std::swap(tex_su, tex_eu);
					std::swap(tex_sv, tex_ev);
					std::swap(tex_sw, tex_ew);
				}

				tex_u = tex_su;
				tex_v = tex_sv;
				tex_w = tex_sw;

				float tstep = 1.0f / ((float)(bx - ax));
				float t = 0.0f;

				for (int j = ax; j < bx; j++)
				{
					tex_u = (1.0f - t) * tex_su + t * tex_eu;
					tex_v = (1.0f - t) * tex_sv + t * tex_ev;
					tex_w = (1.0f - t) * tex_sw + t * tex_ew;


          //TODO: change this to use our own depth buffer , and pixel draw call
					//if (tex_w > pDepthBuffer[i*ScreenWidth() + j])
					//{
					//	Draw(j, i, tex->SampleGlyph(tex_u / tex_w, tex_v / tex_w), tex->SampleColour(tex_u / tex_w, tex_v / tex_w));
					//	pDepthBuffer[i*ScreenWidth() + j] = tex_w;
					//}
					t += tstep;
				}

			}
		}

		dy1 = y3 - y2;
		dx1 = x3 - x2;
		dv1 = v3 - v2;
		du1 = u3 - u2;
		dw1 = w3 - w2;

		if (dy1) dax_step = dx1 / (float)abs(dy1);
		if (dy2) dbx_step = dx2 / (float)abs(dy2);

		du1_step = 0, dv1_step = 0;
		if (dy1) du1_step = du1 / (float)abs(dy1);
		if (dy1) dv1_step = dv1 / (float)abs(dy1);
		if (dy1) dw1_step = dw1 / (float)abs(dy1);

		if (dy1)
		{
			for (int i = y2; i <= y3; i++)
			{
				int ax = x2 + (float)(i - y2) * dax_step;
				int bx = x1 + (float)(i - y1) * dbx_step;

				float tex_su = u2 + (float)(i - y2) * du1_step;
				float tex_sv = v2 + (float)(i - y2) * dv1_step;
				float tex_sw = w2 + (float)(i - y2) * dw1_step;

				float tex_eu = u1 + (float)(i - y1) * du2_step;
				float tex_ev = v1 + (float)(i - y1) * dv2_step;
				float tex_ew = w1 + (float)(i - y1) * dw2_step;

				if (ax > bx)
				{
          std::swap(ax, bx);
					std::swap(tex_su, tex_eu);
					std::swap(tex_sv, tex_ev);
					std::swap(tex_sw, tex_ew);
				}

				tex_u = tex_su;
				tex_v = tex_sv;
				tex_w = tex_sw;

				float tstep = 1.0f / ((float)(bx - ax));
				float t = 0.0f;

				for (int j = ax; j < bx; j++)
				{
					tex_u = (1.0f - t) * tex_su + t * tex_eu;
					tex_v = (1.0f - t) * tex_sv + t * tex_ev;
					tex_w = (1.0f - t) * tex_sw + t * tex_ew;

          //TODO: change this to use our own depth buffer
          //use pixel instead of draw call, and use sdl_texture source here also

					//if (tex_w > pDepthBuffer[i*ScreenWidth() + j])
					//{
					//	Draw(j, i, tex->SampleGlyph(tex_u / tex_w, tex_v / tex_w), tex->SampleColour(tex_u / tex_w, tex_v / tex_w));
					//	pDepthBuffer[i*ScreenWidth() + j] = tex_w;
					//}


					t += tstep;
				}
			}	
		}		
	}


