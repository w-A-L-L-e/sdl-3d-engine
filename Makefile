# LIBS=`sdl2-config --libs`
# LIBS=`sdl2-config --static-libs`
# STATIC (/usr/local/lib/libSDL2main.a for windows might be needed)
LIBS=/usr/local/lib/libSDL2.a -lm -liconv -Wl,-framework,CoreAudio -Wl,-framework,AudioToolbox -Wl,-weak_framework,CoreHaptics -Wl,-weak_framework,GameController -Wl,-framework,ForceFeedback -lobjc -Wl,-framework,CoreVideo -Wl,-framework,Cocoa -Wl,-framework,Carbon -Wl,-framework,IOKit -Wl,-weak_framework,QuartzCore -Wl,-weak_framework,Metal
CPPFLAGS=-I. -I objects -I fonts
ENGINE_OBJECTS=screen.o menu.o \
								 fonts/turbotext.o \
								 objects/object.o objects/turtlecube.o \
								 objects/cube.o objects/torus.o \
								 objects/wineglass.o objects/wallelogo.o \
								 objects/blenderobject.o objects/world.o \
								 palette.o
EXECUTABLES= world_engine engine pixeldemo simple_cube_rotation triangle_test
all: $(EXECUTABLES)

world_engine: $(ENGINE_OBJECTS) world_engine.o
	$(CXX) -O2 $^ -o world_engine -Iinclude $(LIBS)

engine: $(ENGINE_OBJECTS) engine.o 
	$(CXX) -O2 $^ -o engine -Iinclude $(LIBS)

pixeldemo: benchmarks/pixeldemo.o screen.o
	$(CXX) -O2 $^ -o pixeldemo -Iinclude $(LIBS)

triangle_test: benchmarks/triangle_test.o screen.o fonts/turbotext.o
	$(CXX) -O2 $^ -o triangle_test -Iinclude $(LIBS)

simple_cube_rotation: simple_cube_rotation.o screen.o
	$(CXX) -O2 $^ -o simple_cube_rotation -Iinclude $(LIBS)

clean:
	@rm -vf *.o objects/*.o fonts/*.o benchmarks/*.o $(EXECUTABLES)

