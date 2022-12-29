PREFIX = /usr

install:
	@printf "=> wick3dr0se's fm file manager - a fast (ass) file manager.\n"
	@printf " "
	@read -p "=> You are about to install fm, press ENTER to install fm."
	@printf "=> Executing 3 commands.."
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp -p fm $(DESTDIR)$(PREFIX)/bin/fm
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/fm
	@printf "=> Thanks for installing fm."

uninstall:
	@printf "=> wick3dr0se's fm file manager - a fast (ass) file manager.\n"
	@printf " "
	@read -p "=> You are about to uninstall fm, press ENTER to uninstall fm."
	@printf "=> Executing 1 command.."
	@rm -rf $(DESTDIR)$(PREFIX)/bin/fm
	@printf "=> Thanks for using fm."
