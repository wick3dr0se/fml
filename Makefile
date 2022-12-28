PREFIX = /usr

all:
	@printf "Run 'make install' to install fm.\n"

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp -p fm $(DESTDIR)$(PREFIX)/bin/fm
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/fm

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/fm
