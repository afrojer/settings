#!/bin/bash
VIMRC_ME=${1:-afrojer}
GITHUB_USER=${2:-afrojer}

function log() {
	echo -e "\n======================================================================"
	echo -e "$@\n"
}

echo -n "GitHub User: [$GITHUB_USER]: "
read tmpname
if [ ! -z "$tmpname" ]; then
	GITHUB_USER="$tmpname"
fi

echo -n "Vim RC config: [$VIMRC_ME]: "
read tmpname
if [ ! -z "$tmpname" ]; then
	VIMRC_ME="$tmpname"
fi


echo -n "Use writeable git remotes (requires appropriate public SSH key) (y/N): "
read WRITABLE

if [[ "$WRITABLE" == "y" || "$WRITABLE" == "Y" ]]; then
	GITHUB_URL="git@github.com:${GITHUB_USER}"
else
	GITHUB_URL="git://github.com/${GITHUB_USER}"
fi

SYSNAME=`uname -s`
MAC_PORTS="coreutils binutils cmake fuse4x fuse4x-kext i386-elf-binutils sshfs htop tmux tmux-pasteboard git-core stgit curl cscope ncurses"
LINUX_PKGS="zsh tmux vim git curl cscope build-essential gcc-4.6-arm-linux-gnueabi minicom libncurses-dev"
echo -n "Install Mac Ports / apt packages? (y|N): "
read DOINST
if [[ "$DOINST" == "y" || "$DOINST" == "Y" ]]; then
	log "Ensuring you have the required packages"
	if [ "${SYSNAME}" = "Darwin" ]; then
		sudo port install ${MAC_PORTS}
	else
		sudo apt-get install ${LINUX_PKGS}
	fi
else
	log "Skipping MacPorts / apt package install."
fi

log "Taking care of your vim config..."

if [[ ! -f ~/.vimrc ]]; then
	pushd $HOME
	rm -f ~/.vimrc ~/.gvimrc ~/.vim
	git clone $GITHUB_URL/vim-config.git .vim
	pushd .vim
	mkdir swap
	make install ME=${VIMRC_ME}
	popd
	ln -s .vim/vimrc .vimrc
	ln -s .vim/gvimrc .gvimrc
	popd
else
	echo -e "existing ~/.vimrc, moving on."
fi

log "Taking care of your tmux config..."
if [[ ! -f ~/.tmux.conf ]]; then
	pushd $HOME
	rm -rf ~/.tmux
	git clone $GITHUB_URL/tmux-config.git .tmux
	pushd .tmux
	make install
	popd
	popd
else
	echo -e "existing ~/.tmux.conf, moving on."
fi

log "Taking care of your ZSH config..."
if [[ ! -f ~/.zshrc ]]; then
	pushd $HOME
	rm -rf ~/.oh-my-zsh
	git clone $GITHUB_URL/zsh-config.git .oh-my-zsh
	pushd .oh-my-zsh
	git submodule init
	git submodule update
	popd
	ln -s .oh-my-zsh/zshrc .zshrc
	chsh -s `which -a zsh | grep -v aliased`
	popd
else
	echo -e "existing ~/.zshrc, moving on."
fi

log "Done, happy coding!"
