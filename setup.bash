#!/bin/bash

if [ -x "$(command -v restic)" ]; then
	exit 1
fi

unameOut="$(uname -s)"
case "${unameOut}" in
    	Linux*)     machine=Linux;;
    	Darwin*)    machine=Mac;;
    	CYGWIN*)    machine=Cygwin;;
    	MINGW*)     machine=MinGw;;
    	*)          machine="UNKNOWN:${unameOut}"
esac
echo "System: ${machine}"

if [[ ${machine} == "Linux" ]]; then
	if [ ! -x "$(command -v restic)" ]; then
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
	fi
	
	if [ ! -x "$(command -v rsync)" ]; then
		echo "Rsync not installed. Installing..."
		sudo apt-get install -y rsync
	fi

fi

if [[ ${machine} == "Mac" ]]; then
		
		if [ -x "$(command -v brew)" ]; then
			echo "Installing restic, rsync with brew"
			brew update && brew upgrade
			brew install restic
			brew install rsync
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
				/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
				brew install restic
			else
				echo "Not installing. Break"
			fi
		fi
fi
