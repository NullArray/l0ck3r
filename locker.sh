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


# Don't log to shell history
set +o history
history -c

# Save current date for install log
now=$(date)

# Associative array for algos
declare -A alg

alg[1]="-rc4"
alg[2]="-aes256"
alg[3]="-blowfish"
# Default enc type
default=${alg[1]}

# Associative array for pwgen char length
declare -A char

char[1]=$(pwgen -s 32 1)
char[2]=$(pwgen -s 16 1)
char[3]=$(pwgen -s 12 1)


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

function usage(){
    clear && logo
    echo -e "Welcome to L0ck3r\n
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

The default algorithm is RC4. Most of the
crypto operations in this script are performed
with OpenSSL. To secure data at scale the dep
manager also deploys the GUI Version of VeraCrypt
in case your crypto requirements are beyond the
scope of OpenSSL and encrypted archives.

EncryptPad is also available through the
installer.

The Backup option allows you to create an
encrypted 7z archive.

Choosing the VeraCrypt option will start the
VeraCrypt graphical user interface. \n"
    notification_b "Enter any key to return to the menu."
    read -p ' ' null
    menu
    }


function keyfile(){
    notification "Generating Keyfile" && sleep 1.5
    mkdir tmpdir >> /dev/null
    cd tmpdir

    notification_b "Writing Randomized Source Data" && sleep 1.5
    pwgen -s 32 64 >> random.txt
    notification_b "Encoding..." && sleep 1.5
    openssl enc -a -in random.txt -out random.b64
    notification_b "Writing Keyfile" && sleep 1.5
    openssl enc -writerand -e -in random.b64 -out FSX_SECTOR_SECURITY_AUTHORITY.pem
    cd ..
    cp -f /tmpdir/*.pem $(pwd)/*.pem
    kfile="$(pwd)/*.pem"

    notification "Keyfile Completed"
    echo -e "Your keyfile can be found here: \n" $kfile
    read -p "Enter any key to continue..." null
    sleep 1.5 && clear
    notification_b "Cleaning up."
    # Destroy Generated Input
    pwgen -s 32 64 > /tmpdir/random.txt
    find tmpdir -depth -type f -exec shred -v -n 1 -z -u {} \; && rm -rf tmpdir

    notification "All Keyfile Operations Have Been Completed" && sleep 2
    menu
    }

function encode(){
    clear && logo
    notification "Encoder Mode"

    echo -e "Please provide the path to a file you'd like to encrypt"
    read -p "Path: " path
    #stat $path >> /dev/null || warning "Invalid Path" && menu

    notification_b "Please select your preference"
    echo -e "\n[1]Custom Passphrase\n[2]Securely Generated Pass\n[3]Securely Generated Keyfile\n[Q]uit"
    read -p "Preference: " pref

    if [[ $pref == '1' ]]; then
        echo -e "\n[1]AES-256\n[2]RC4\n[3]Blowfish\n[Q]uit"
        read -p 'Choice: ' choice
        warning "Manual Password Selected"
        echo -e 'Password: '
        read -s password

        if [[ $choice == '1' ]]; then
            openssl enc -aes256 -e -k $password -pbkdf2 -in $path -out $path.enc
            notification_b "Operation Completed" && sleep 2
        elif [[ $choice == '2' ]]; then
            openssl enc -rc4 -e -k $password -pbkdf2 -in $path -out $path.rc4
            notification_b "Operation Completed" && sleep 2
        elif [[ $choice == '3' ]]; then
            openssl enc -blowfish -e -k $password -pbkdf2 -in $path -out $path.bfsh
            notification_b "Operation Completed" && sleep 2
        elif [[ $choice == 'Q' || $choice == 'q'  ]]; then
            warning "Quitting"
        else
            warning "Unhandled Option"
        fi

    elif [[ $pref == '2' ]]; then
        echo -e "\nSecurely generated passwords:"

        for KEY in "${!alg[@]}"; do
            echo -e "${alg[$KEY]}"

        notification_b "Please select a securely generated password"
        read -p 'Choice: ' pass

        if [[ $choice == '1' ]]; then
            openssl enc -aes256 -e -k $pass -pbkdf2 -in $path -out $path.enc
            notification "Operation Completed" && sleep 2
        elif [[ $choice == '2' ]]; then
            openssl enc -rc4 -e -k $pass -pbkdf2 -in $path -out $path.rc4
            notification "Operation Completed" && sleep 2
        elif [[ $choice == '3' ]]; then
            openssl enc -blowfish -e -k $pass -pbkdf2 -in $path -out $path.bfsh
            notification "Operation Completed" && sleep 2
        elif [[ $choice == 'Q' || $choice == 'q'  ]]; then
            warning "Quitting"
        else
            warning "Unhandled Option"
        fi

    elif [[ $pref == '3' ]]; then
        keyfile
        if [[ $choice == '1' ]]; then
            openssl enc -aes256 -e -kfile $kfile -pbkdf2 -in $path -out $path.enc #KEYFILE
            notification "Operation Completed" && sleep 2
        elif [[ $choice == '2' ]]; then
            openssl enc -rc4 -e -kfile $kfile -pbkdf2 -in $path -out $path.rc4   #KEYFILE
            notification "Operation Completed" && sleep 2
        elif [[ $choice == '3' ]]; then
            openssl enc -blowfish -e -kfile $kfile  -pbkdf2 -in $path -out $path.bfsh #KEYFILE
            notification "Operation Completed" && sleep 2
        elif [[ $choice == 'Q' || $choice == 'q'  ]]; then
            warning "Quitting"
        else
            warning "Unhandled Option"
        fi
    fi
    }

function decode(){
    clear && logo
    notification "Decoder Mode"
    echo -e "Accepted input for algorithms are '-aes256'\n'-rc4'[Default] and '-blowfish'."
    echo -e "Enter all relevant info to start decoding.\n" && sleep 2
    read -p 'File: ' infile
    echo -e 'Password: \n'
    read -s password
    read -p 'Keyfile (Leave blank if no Keyfile)' kfile
    read -p 'Algorithm (Default is RC4)' algo

    for KEY in "${!alg[@]}"; do
        if [[ $KEY == $algo ]]; then
            pass=1 && echo -e "Configured Algorithm: ${alg[$KEY]}"
        else
            pass=0 && warning "Invalid Algorithm" && menu
    done

    if [[ $kfile != '' && $pass == 1 ]]; then
        openssl enc $algo -d -kfile $kfile -pbkdf2 -in $infile -out $infile.out
    elif [[ $kfile == '' && $pass == 1 ]]; then
        openssl enc $algo -d -k $password -pbkdf2 -in $infile -out $infile.out
    else
        warning "An error has occurred"
    }


function archive(){
    clear && logo
    notification "Encrypted Archive Mode"
    mkdir Archive > /dev/null
    cd Archive

    read -p "Path to files: " path
    stat $path > /dev/null || warning "Invalid Path" && menu
    cp -f $path/* $(pwd)/*

    notification_b "Done copying files. Archiving..."
    7z a results.7z * -p
    mv results.7z ..
    cd ..

    find Archive -depth -type f -exec shred -v -n 1 -z -u {} \; && rm -rf Archive
    notification_b "Archive as 'results.7z' in the current working directory"
    menu
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

function menu(){
    clear && logo
    PS3='Please enter your choice: '
    options=("Help" "Encryption" "Decryption" "Veracrypt" "Back Up" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Help")
                usage
                printf "%b \n"
                ;;
            "Encryption")
                encode
                printf "%b \n"
                ;;
            "Decryption")
                decode
                printf "%b \n"
                ;;
             "VeraCrypt")
                veracrypt
                printf "%b \n"
                ;;
             "Back Up")
                archive
                printf "%b \n"
                ;;
            "Quit")
                # Re-enable Shell logging
                #history -c
                set -o history
                break
                ;;
            *) echo invalid option;;
        esac
    done

    }

if [[ "$1" != "" ]]; then
    case $1 in
        '-D' || '--dep-install' )
        dep=1
    esac
fi

if [[ dep == 1 ]]; then
    notification "Checking for installation log" && sleep 1.5
    stat ~/.local/l0ck3r-install.log || deps
    notification_b "l0cker.sh appears to have been installed."
    sleep 2 && menu
fi

if [[ "$1" != "" ]]; then
    case $1 in
        '-e' || '--encode' )
        encode
    esac
fi

if [[ "$1" != "" ]]; then
    case $1 in
        '-d' || '--decode' )
        decode
    esac
fi


if [[ "$EUID" -ne 0 ]]; then
   warning "Running as $USER"

   read -p 'Continue without root? Y/n : ' choice
   if [[ $choice == 'y' || $choice == 'Y' ]]; then
       menu
   else
       exit 0

   fi
else
    menu

fi
