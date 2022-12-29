PREFIX = /usr

install:
	@printf "=> wick3dr0se's fm file manager - a fast (ass) file manager.\n"
	@printf " "
	@read -p "=> You are about to install fm, press ENTER to install fm."
	@printf "=> Executing install.."
	@install -Dm755 fm.sh $(PREFIX)/local/bin/fm
	@printf "=> Thanks for installing fm."

uninstall:
	@printf "=> wick3dr0se's fm file manager - a fast (ass) file manager.\n"
	@printf " "
	@read -p "=> You are about to uninstall fm, press ENTER to uninstall fm."
	@printf "=> Executing rm.."
	@rm -f $(PREFIX)/local/bin/fm
	@printf "=> Thanks for using fm."
