# VaultWM Makefile

CC = gcc
CFLAGS = -Wall -Wextra -O2 -I. -I../monitor -I../window-rules -I../layouts -I../tags
LDFLAGS = -lX11 -lXrandr -lm
TARGET = vaultwm
SRC = main.c
MONITOR_SRC = ../monitor/monitor.c
RULES_SRC = ../window-rules/window-rules.c
LAYOUTS_SRC = ../layouts/layouts.c
TAGS_SRC = ../tags/window-tags.c
OBJ = $(SRC:.c=.o) $(MONITOR_SRC:.c=.o) $(RULES_SRC:.c=.o) $(LAYOUTS_SRC:.c=.o) $(TAGS_SRC:.c=.o)

PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(OBJ) -o $(TARGET) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(TARGET)

install: $(TARGET)
	install -D -m 755 $(TARGET) $(DESTDIR)$(BINDIR)/$(TARGET)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(TARGET)

.PHONY: all clean install uninstall

