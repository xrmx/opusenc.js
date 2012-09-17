EMSCRIPTEN ?= ~/src/emscripten
NODEJS ?= nodejs
EMCONFIGURE = $(EMSCRIPTEN)/emconfigure
EMMAKE = $(EMSCRIPTEN)/emmake
EMCC = $(EMSCRIPTEN)/emcc

all: opus-js

setup:
	wget http://downloads.xiph.org/releases/ogg/libogg-1.3.0.tar.gz
	tar xvzf libogg-1.3.0.tar.gz
	wget http://downloads.xiph.org/releases/opus/opus-1.0.1.tar.gz
	tar xvzf opus-1.0.1.tar.gz
	wget http://downloads.xiph.org/releases/opus/opus-tools-0.1.5.tar.gz
	tar xvzf opus-tools-0.1.5.tar.gz
	cd libogg-1.3.0 && \
		patch -p0 < ../remove-lame-optimization-level.diff
	cd opus-1.0.1 && \
		patch -p0 < ../remove-malloc_hook-check.diff && autoreconf --install --force
	cd opus-tools-0.1.5 && \
		patch -p0 < ../force-opusenc-quiet.diff

ogg:
	cd libogg-1.3.0 && \
		$(EMCONFIGURE) ./configure && \
		$(EMMAKE) make && \
		ln -s src/.libs .libs

opus:
	cd opus-1.0.1 && \
		$(EMCONFIGURE) ./configure && \
		$(EMMAKE) make

opus-tools:
	cd opus-tools-0.1.5 && \
		$(EMCONFIGURE) ./configure --with-ogg-includes=../libogg-1.3.0/include/ --with-ogg-libraries=../libogg-1.3.0/ --with-opus-includes=../opus-1.0.1/include/ --with-opus-libraries=../opus-1.0.1/ && \
		$(EMMAKE) make opusenc

getopt:
	$(EMCC) $(EMSCRIPTEN)/tests/openjpeg/common/getopt.c -I $(EMSCRIPTEN)/tests/openjpeg/common/ -o getopt.o

opus-js: ogg opus opus-tools getopt opusenc-js

opusenc-js:
	$(EMCC) -02 -o opusenc.js getopt.o opus-tools-0.1.5/src/opus_header.o opus-tools-0.1.5/src/opusenc.o opus-tools-0.1.5/src/resample.o opus-tools-0.1.5/src/audio-in.o opus-tools-0.1.5/src/diag_range.o opus-tools-0.1.5/src/lpc.o opus-tools-0.1.5/win32/unicode_support.o libogg-1.3.0/.libs/libogg.a opus-1.0.1/.libs/libopus.a --embed-file test/familyguy.wav

go:
	$(NODEJS) opusenc.js familyguy.wav - > nodejs.opus

clean: clean-ogg clean-opus clean-opus-tools 

clean-ogg:
	cd libogg-1.3.0 && \
		$(EMMAKE) make clean

clean-opus:
	cd opus-1.0.1 && \
		$(EMMAKE) make clean

clean-opus-tools:
	cd opus-tools-0.1.5 && \
		$(EMMAKE) make clean

clean-setup:
	cd libogg-1.3.0 && \
		patch -p0 -R < ../remove-lame-optimization-level.diff && \
		rm -f .libs
	cd opus-1.0.1 && \
		patch -p0 -R < ../remove-malloc_hook-check.diff
	cd opus-tools-0.1.5 && \
		patch -p0 -R < ../force-opusenc-quiet.diff
