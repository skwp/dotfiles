# Build the small MPD NP program.
# Enable debug printing with $ make -e DEBUG=1
DEBUG=0
CC = $(shell hash clang 2>/dev/null && echo clang || echo gcc)
CFLAGS = -O3 -Wall -std=c99 -I /usr/include/ -D DEBUG=${DEBUG}
LDLIBS = -lmpdclient
XKB_LAYOUT_LDLIBS= -lX11

.PHONY: all clean

all: np_mpd xkb_layout

xkb_layout: xkb_layout.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< $(XKB_LAYOUT_LDLIBS) -o $@

clean:
	$(RM) np_mpd
	$(RM) xkb_layout
