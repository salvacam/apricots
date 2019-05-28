#PLATFORM = linux_x86
#PLATFORM = linux_x64
#PLATFORM = mingw32	# win32
#PLATFORM = cegcc	# wince (arm)
#PLATFORM = gizmondo
#PLATFORM = gp2x
#PLATFORM = wiz
#PLATFORM = caanoo
#PLATFORM = dingux
PLATFORM = gcw
#PLATFORM ?= linux_x86

### GCW Zero
CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CXX := $(CROSS_COMPILE)g++
STRIP := $(CROSS_COMPILE)strip

# CC  := $(CROSS_COMPILE)gcc
# LD  := $(CROSS_COMPILE)gcc
# RC  := $(CROSS_COMPILE)windres

SYSROOT := $(shell $(CC) --print-sysroot)
SDL_CFLAGS := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

CFLAGS = $(SDL_CFLAGS) -mips32 -mtune=mips32 -G0 -fomit-frame-pointer -ffunction-sections -ffast-math -fsingle-precision-constant -mbranch-likely -DAP_AUDIO_SDLMIXER
LDFLAGS = 
LIB = -lSDL_mixer -lSDL -lpthread

###

ifdef DEBUG
	CFLAGS += -fpermissive -Wextra -Wall -ggdb3 -c -O2
else
	CFLAGS += -fpermissive -c -O2
endif

SRC =	src/ai.cpp		\
	src/all.cpp		\
	src/apricots.cpp	\
	src/collide.cpp	\
	src/drak.cpp	\
	src/drawall.cpp	\
	src/fall.cpp	\
	src/finish.cpp	\
	src/game.cpp	\
	src/init.cpp	\
	src/menu.cpp	\
	src/sampleio.cpp	\
	src/SDLfont.cpp	\
	src/setup.cpp	\
	src/shape.cpp
	
OBJ = $(SRC:.cpp=.o)
EXE = apricots/apricots.elf

build : $(SRC) $(EXE)

$(EXE): $(OBJ)
	$(CXX) $(LDFLAGS) $(OBJ) $(LIB) -o $@
ifndef DEBUG
	$(STRIP) $(EXE)
endif

.cpp.o:
	$(CXX) $(CFLAGS) $(SDL_LIBS) $< -o $@

clean:
	rm -rf *.o $(EXE)

ipk: build
	@rm -rf /tmp/.apricots-ipk/ && mkdir -p /tmp/.apricots-ipk/root/home/retrofw/games/apricots /tmp/.apricots-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@cp -r apricots/data apricots/apricots.elf apricots/apricots.man.txt apricots/apricots.png /tmp/.apricots-ipk/root/home/retrofw/games/apricots
	@cp apricots/apricots.lnk /tmp/.apricots-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" apricots/control > /tmp/.apricots-ipk/control
	@cp apricots/conffiles /tmp/.apricots-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.apricots-ipk/control.tar.gz -C /tmp/.apricots-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.apricots-ipk/data.tar.gz -C /tmp/.apricots-ipk/root/ .
	@echo 2.0 > /tmp/.apricots-ipk/debian-binary
	@ar r apricots/apricots.ipk /tmp/.apricots-ipk/control.tar.gz /tmp/.apricots-ipk/data.tar.gz /tmp/.apricots-ipk/debian-binary
