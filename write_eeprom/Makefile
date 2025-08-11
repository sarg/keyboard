HIDRAW:=$(shell pkg-config --cflags --libs hidapi-hidraw)
CC?=gcc

all:
	$(CC) write_eeprom.c -o write_eeprom $(HIDRAW) $(CFLAGS)

install: all
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 0755 write_eeprom $(DESTDIR)$(PREFIX)/bin

.PHONY: all install
