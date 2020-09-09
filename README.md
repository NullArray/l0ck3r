# l0ck3r
Automated encryption utilities and installation

I wanted to write a script to automate some encryption related operations but i may have gone a little overboard. Regardless
the tool automates OpenSSL, has a feature to securely backup data in an encrypted archive and shred the original files.
It also automates the installation of the `pwgen`, `shred`, `OpenSSL`, `7z` and `encryptcli` utilities as well as the installation of VeraCrypt and Encryptpad.

## Quick Usage
Using L0ck3r is fairly straightforward.

Starting the script with -D or --dep-install
will install L0ck3r's dependencies. After
which the script is ready for use.

Choose Encryption or Decryption respectively
to start your crypto operations.

When supplying input files please enter full
paths. With some exceptions; Running the
script from the home directory to encrypt
files in the home directory entering the
target file should be done like so
when prompted:

Path: ./file_to_encrypt.txt


After you have made your choice you will be
asked for the algorithm you wish to use and
the password. The script does the rest.

## Note

There may be some bugs, this is a beta. I wasn't originally going to put this on Github, but i figured it might be useful to others.

If you're having issues, just running the installer operations will set you up nicely with a lot of useful stuff in and of itself. For your convenience, i pulled the installation function out and pasted it here, if you're interested.


```
#!/bin/bash
#____   ____             __
#\   \ /   /____   _____/  |_  ___________
# \   Y   // __ \_/ ___\   __\/  _ \_  __ \
#  \     /\  ___/\  \___|  | (  <_> )  | \/
#   \___/  \___  >\___  >__|  \____/|__|
#              \/     \/
#--Licensed under GNU GPL 3
#----Authored by Vector/NullArray
##############################################

ESC="\x1b["
RESET=$ESC"39;49;00m"
CYAN=$ESC"33;36m"
RED=$ESC"31;01m"
GREEN=$ESC"32;01m"

function warning(){
    echo -e "\n$RED [!] $1 $RESET\n"
    }

# Green notification
function notification(){
    echo -e "\n$GREEN [+] $1 $RESET\n"
    }

# Cyan notification
function notification_b(){
    echo -e "\n$CYAN [-] $1 $RESET\n"
    }


function logo(){
    echo -e "\n$CYAN
#################################
#  __    ___     _   ___        #
# |  |  |   |___| |_|_  |___    #
# |  |__| | |  _| '_|_  |  _|   #
# |_____|___|___|_,_|___|_|     #
#                    $RED V1.0-=# $CYAN
#=----------+------------------=#
#=-Authored |$GREEN Vector $CYAN
#=-Licensed |$GREEN GNU GPL 3 $CYAN
#########=--+---------------+$RESET "
    }

function deps(){
    logo && sleep 1.5
    # Install VeraCrypt
    notification "Installing Dependencies" && sleep 1.5
    notification_b "Fetching VeraCrypt"
    mkdir veracrypt && cd veracrypt
    wget -O veracrypt.tar.bz2 https://launchpad.net/veracrypt/trunk/1.23/+download/veracrypt-1.23-setup.tar.bz2
    tar -xvjf veracrypt.tar.bz2 || warning "Something went wrong" && exit 1
    touch ~/.local/l0ck3r-install.log
    echo -e " L0ck3r install log\n$now\n\n Installing VeraCrypt" >>  ~/.local/l0ck3r-install.log

    # Get Arch, install appropriate version
    MACHINE_TYPE=`uname -m`
    if [[ ${MACHINE_TYPE} == 'x86_64' ]]; then
        chmod +x veracrypt-1.23-setup-gui-x64
        ./veracrypt-1.23-setup-gui-x64 | tee -a ~/.local/l0ck3r-install.log && notification "Installed VeraCrypt"
    else
        chmod +x veracrypt-1.23-setup-gui-x86
        ./veracrypt-1.23-setup-gui-x86 | tee -a ~/.local/l0ck3r-install.log && notification "Installed VeraCrypt"
    fi

    # Format for install log
    echo -e "\n\n
Installing;
    OpenSSL
    shred
    pwgen
Optional;
    EncryptPad\n" >> ~/.local/l0ck3r-install.log

    notification "Installing OpenSSl, Shred, pwgen and 7z"
    # Install utilities
    if [[ -z $(which openssl) ]]; then sudo apt-get -y openssl | tee -a  ~/.local/l0ck3r-install.log; fi
    if [[ -z $(which shred) ]]; then sudo apt-get -y shred | tee -a  ~/.local/l0ck3r-install.log; fi
    if [[ -z $(which pwgen) ]]; then sudo apt-get -y pwgen | tee -a  ~/.local/l0ck3r-install.log; fi
    if [[ -z $(which 7z) ]]; then sudo apt-get -y 7z  | tee -a  ~/.local/l0ck3r-install.log; fi

    notification_b "Installation Complete" && sleep 1
    echo -e "Optionally you can install EncryptPad, which is a text editor that can encrypt plaintext"
    echo -e "And other files with a variety of cryptographic algorithms and operations.\n"
    echo -e "For details L0ck3r can open 'evpo.net' in your browser, or skip ahead to choose"
    echo -e "whether you would like L0ck3r to install it or not."

    read -p "Open web resource in browser? [Y/n]: " choice
    if [[ $choice == 'Y' || $choice == 'y' ]]; then
        python3 -m webbrowser 'evpo.net/encryptpad/'
    fi

    # Options to install EncryptPad
    read -p "Install EncryptPad? [Y/n]: " choice
    if [[ $choice == 'Y' || $choice == 'y' ]]; then
        if [[ -z $(which encryptcli) ]]; then
            sudo apt-get -y encryptpad encryptcli || no_ppa=1 && warning "Missing appropriate PPA"
            if [[ $no_ppa == 1 ]]; then
                clear && notification_b "Adding ppa:nilarimogard/webupd8 repository" && sleep 1.5
                sudo add-apt-repository ppa:nilarimogard/webupd8 | tee -a  ~/.local/l0ck3r-install.log
                sudo apt update
                sudo apt install encryptpad encryptcli | tee -a  ~/.local/l0ck3r-install.log
                sleep 2 && clear
                notification "Installation Completed"
            fi
        fi
    fi

    echo -e "[1]View log file\n[2]Create symbolic link\n[3]Proceed to main menu\n[Q]uit"
    read -p 'Choose action' action
    if [[ action == '1' ]]; then more   ~/.local/l0ck3r-install.log; fi
    if [[ action == '2' ]]; then sudo ln -s $(pwd)/l0cker.sh /usr/bin/l0ck3r || sudo ln -s $(pwd)/l0cker.sh /usr/local/bin/l0ck3r
    if [[ action == '3' ]]; then menu; fi
    if [[ action == 'Q' || action == 'q' ]]; then exit 1; fi
    }
    
deps
```

Feel free to Open a Ticket if you'd like to report a bug.

