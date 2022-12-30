PREFIX = /usr

install:
	@printf "=> fml - file manager lite\n\n"
	@read -p "=> You are about to install fml, press ENTER to continue"
	@install -Dm755 fml $(PREFIX)/bin/fml
	@printf "=> Thanks for installing fml!\n"

uninstall:
	@printf "=> fml - file manager lite\n\n"
	@read -p "=> You are about to uninstall fml, press ENTER to continue"
	@rm -f $(PREFIX)/bin/fml
	@printf "=> Thanks for using fml!\n"
