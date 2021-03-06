help::


instemacs:
	$(MAKE) -C emacs.git install prefix=/usr/local/stow/emacs
	cd /usr/local/stow; stow emacs
help::
	@echo "sudo make install         install compiled emacs"

compemacs emacs.git/src/emacs: emacs.git/Makefile
	$(MAKE) -C emacs.git
help::
	@echo "make [-j] comp            compile emacs from source"

confemacs emacs.git/Makefile: emacs.git/configure
	cd emacs.git; \
	./configure \
		--with-cairo \
		--with-xwidgets \
		--with-x-toolkit=gtk3 \
		--without-gconf \
		--without-gpm \
		--without-gsettings \
		--without-hesiod \
		--without-imagemagick \
		--without-kerberos \
		--without-kerberos5 \
		--without-ns \
		--without-selinux \
		--without-wide-int \
		--without-xim \
		--without-native-compilation \
		CFLAGS='-pipe -O2 -g3 -march=native -fstack-protector-strong -Wformat -Werror=format-security -Wall' \
		CPPFLAGS='-Wdate-time -D_FORTIFY_SOURCE=2' \
		LDFLAGS='-Wl,-O1 -Wl,--as-needed -Wl,-z,relro' | tee my-configure.log

help::
	@echo "make conf                 configure emacs"

emacs.git/configure: emacs.git/.git/HEAD
	cd emacs.git; ./autogen.sh

pullemacs emacs.git/.git/HEAD:
ifeq ("$(wildcard emacs.git)","")
	git clone git://git.savannah.gnu.org/emacs.git emacs.git
else
	cd emacs.git; git pull
endif
help::
	@echo "make pullemacs            pull new emacs changes from git"

clean:
	cd emacs.git; git clean -fdx

uninstall:
	cd /usr/local/stow; stow -D emacs



PDF_BUILD=~/.emacs.d/.local/straight/build-28.0.50/pdf-tools/build/server
$(PDF_BUILD)/configure:
	cd $(PDF_BUILD); ./autogen.sh
$(PDF_BUILD)/Makefile: $(PDF_BUILD)/configure
	cd $(PDF_BUILD); ./configure
comppdf: $(PDF_BUILD)/Makefile
	$(MAKE) -C $(PDF_BUILD)
help::
	@echo "make compdf               compile pdf-utils"



pulldoom:
	@# doom started to annoy me with "do you want to see the diffs"?  Nope.
	@# it also asks me something like "do you want to continue"? This sucks.
	cd ~/.emacs.d; git pull --rebase
	cd ~/.emacs.d; git log --reverse --no-merges -p ORIG_HEAD..HEAD >NEWS
	cd ~/.emacs.d; bin/doom clean
	cd ~/.emacs.d; bin/doom sync -u
	@# recompile pdf-tools
	$(MAKE) comppdf
help::
	@echo "make pulldoom             pull new doom changes from git"

sync:
	cd ~/.emacs.d; bin/doom sync
help::
	@echo "make sync                 sync doom repos with packages.el"

build:
	cd ~/.emacs.d; bin/doom build
help::
	@echo "make build                rebuild binary doom modules"
