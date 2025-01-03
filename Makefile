TARGETS = $(HOME)/.gitconfig $(HOME)/.gitignore $(HOME)/.bashrc env
SHELL = /bin/zsh
CWD = $(shell pwd)

define check_file
	@if [[ -e $1 && "$(OVERWRITE)" != "1" ]]; then \
		echo "make install won't overwrite $1"; \
		echo "1) remove it yourself or 2) use 'make install OVERWRITE=1'"; \
		false \
	else true; \
	fi
endef

all:
	@echo type make install.

env:
	./configure-env.sh

$(HOME)/.%: %
	$(call check_file,$@)
	ln -fs $(PWD)/$< $@

install: $(TARGETS)

update:
	git pull

.PHONY: install update
