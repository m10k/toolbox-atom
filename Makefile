PHONY = install uninstall clean

ifeq ($(PREFIX), )
	PREFIX = /usr
endif

all:

clean:

test:

install:
	chown -R root.root include
	find include -type d -exec chmod 755 {} \;
	find include -type f -exec chmod 644 {} \;
	mkdir -p $(DESTDIR)$(PREFIX)/share/toolbox/include/atom
	cp -a include/atom.sh $(DESTDIR)$(PREFIX)/share/toolbox/include/.
	cp -a include/atom/common.sh  $(DESTDIR)$(PREFIX)/share/toolbox/include/atom/.
	cp -a include/atom/entry.sh  $(DESTDIR)$(PREFIX)/share/toolbox/include/atom/.
	cp -a include/atom/feed.sh  $(DESTDIR)$(PREFIX)/share/toolbox/include/atom/.
	cp -a include/atom/xml.sh  $(DESTDIR)$(PREFIX)/share/toolbox/include/atom/.

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/share/toolbox/include/atom/common.sh
	rm -f $(DESTDIR)$(PREFIX)/share/toolbox/include/atom/entry.sh
	rm -f $(DESTDIR)$(PREFIX)/share/toolbox/include/atom/feed.sh
	rm -f $(DESTDIR)$(PREFIX)/share/toolbox/include/atom/xml.sh
	rmdir $(DESTDIR)$(PREFIX)/share/toolbox/include/atom
	rm -f $(DESTDIR)$(PREFIX)/share/toolbox/include/atom.sh

.PHONY: $(PHONY)
