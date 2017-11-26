#!/bin/bash
now=$(date +"%r %a %d %h %y")

install_mac() {
	if [ ! "$(brew list | grep restic)" == "restic" ]; then
		echo "Restic not installed. Installing . . ."
		brew install restic
	fi
	if [ ! "$(brew list | grep rsync)" == "rsync" ]; then
		echo "Rsync not installed. Installing . . ."
		brew install rsync
	fi
	if [ ! "$(brew list | grep wget)" == "wget" ]; then
		echo "Wget not installed. Installing . . ."
		brew install wget
	fi
}

install_restic_linux() {
	version=0.7.3
	platform=linux_amd64
	latest=https://github.com/restic/restic/releases/download/v${version}/restic_${version}_${platform}.bz2
	bin=restic_0.7.3_linux_amd64
	compressed=${bin}.bz2

	echo ""
	echo "Download file"
	wget ${latest}

	echo ""
	echo "Move to /usr/local/bin"
	sudo mv ${compressed} /usr/local/bin/

	echo ""
	echo "Decompress"
	cd /usr/local/bin/ && sudo bzip2 -d ${compressed} 
	sudo mv ${bin} restic

	echo ""
	echo "Make executable"
	sudo chmod +x restic 

	echo ""
	echo "Test"
	restic version
}

install_brew() {
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

get_files() {
	cd ~
	echo "Getting necessary files..."
	wget https://raw.githubusercontent.com/juliangaal/bash-notes/master/.log
}

unameOut="$(uname -s)"
case "${unameOut}" in
    	Linux*)     machine=Linux;;
    	Darwin*)    machine=Mac;;
    	CYGWIN*)    machine=Cygwin;;
    	MINGW*)     machine=MinGw;;
    	*)          machine="UNKNOWN:${unameOut}"
esac

echo "$now"
echo "System: ${machine}"
sleep 1

if [[ ${machine} == "Linux" ]]; then
	if [ -x "$(command -v restic)" ] && [ -x "$(command -v rsync)" ]; then
		echo "Everything you need is installed"
		exit 1
	fi
	
	if [ ! -x "$(command -v restic)" ]; then
		install_restic_linux
	fi
	
	if [ ! -x "$(command -v rsync)" ]; then
		echo "Rsync not installed. Installing..."
		sudo apt-get install -y rsync
	fi
	
	get_files
	mkdir /home/${USER}/log
	echo "source /home/${USER}/.log" >> ~/.bashrc
	echo "Resource bash_profile with 'source ~/.bash_profile' or open new terminal"	
fi

if [[ ${machine} == "Mac" ]]; then
		
		if [ -x "$(command -v brew)" ]; then
			brew update && brew upgrade
			install_mac
		else
			echo ""
			echo "Brew is not installed, do you want to install?"
			read -p "Continue (y/n)?" choice
			case "$choice" in 
				y|Y ) chosen="yes";;
				n|N ) chosen="no";;
				* ) chosen="invalid";;
			esac

			if [[ ${chosen} == "yes" ]]; then
				install_brew
				install_mac
			else
				echo "Not installing. Break"
				exit 1
			fi
		fi
		
	get_files
	mkdir /Users/${USER}/log
	echo "source /Users/${USER}/.log" >> ~/.bash_profile	
	echo "Resource bash_profile with 'source ~/.bash_profile' or open new terminal"	
fi

