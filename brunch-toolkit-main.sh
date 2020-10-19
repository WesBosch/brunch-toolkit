#!/bin/bash
TOOLVER="v1.0.4b"
OPTS="$1"
# Do not move the DOWNLOADS variable from line 5!
DOWNLOADS="$HOME/Downloads"
SHELLTOOLS='brunch-toolkit,brunch-toolkit --quickbootsplash,brunch-toolkit --shell,'
BRUNCH=
CHROME=
METHOD=
RECOVERY=
FUNCTION=
INCLUDECHROME=false
OFFLINE=false
IGNORECHECK=false
DEBUGCHECK=false
VARS=false
LINUX=false
WSL=false
INSTALLING=false
SUGGESTED=
COMPCHECK=
DONTASK=
SECONDCHOICE=
SPECIALBUILD=
INSTALLTYPE=
DESTINATION=
CHROMEURL=
CHROMEURLVERS=
RECOVERYOPTIONS="eve grunt hatch lulu nami rammus samus"
VALIDRECOVERIES="alex asuka atlas banjo banon big blaze bob buddy butterfly candy caroline cave celes chell clapper coral cyan daisy drallion edgar elm enguarde eve expresso falco-li fievel fizz gandof glimmer gnawty grunt guado hana hatch heli jacuzzi jaq jerry kalista kefka kevin kip kitty kukui lars leon link lulu lumpy mario mccloud mickey mighty minnie monroe nami nautilus ninja nocturne octopus orco paine panther parrot peppy pi pit pyro quawks rammus reef reks relm rikku samus sand sarien scarlet sentry setzer skate snappy soraka speedy spring squawks stout stumpy sumo swanky terra tidus tiger tricky ultima winky wizpig wolf yuna zako zgb"
DISCORD="https://discord.gg/x2EgK2M"

#####################################################################
# Vanity Plate & Version Notes.
#####################################################################
vanity(){
cat << "EOF"
+---------------------------------------------------------------+
|                                                               |
|     ___                  _      _____         _ _   _ _       |
|    | _ )_ _ _  _ _ _  __| |_   |_   _|__  ___| | |_(_) |_     |
|    | _ \ '_| || | ' \/ _|  _ \   | |/ _ \/ _ \ | / / |  _|    |
|    |___/_|  \_,_|_||_\__|_||_|   |_|\___/\___/_|_\_\_|\__|    |
|                                                               |
+---------------------------------------------------------------+
|    Need help? Found a bug?                                    |
|    Find me in the Brunch Discord!                --Wisteria   |
+---------------------------------------------------------------+
EOF
printf "              \e]8;;$DISCORD\e\\ >> $DISCORD << \e]8;;\e\\"
echo ""
echo ""
}
#####################################################################
# Main Toolkit Functions
#####################################################################

# Main is the main process of the script
   main() {
        while true; do
        multifunction
        done
        cleanexit
    }

# AIO function to set all necessary variables up from the start
    setvars() {
        if [ "$VARS" == "false" ] ; then
        VARS=true
        webtest
        if [ "$DEBUGCHECK" == "true" ] ; then
            echo "[!] DEBUG Mode enabled!"
            echo "File operations will still happen,"
            echo "but installs and updates are blocked."
        fi
    # Get the brunch version in two formats for readability
        CURRENT=$(awk '{print $4}' 2> /dev/null < /etc/brunch_version)
        if [ -z "$CURRENT" ] ; then
        CURRENT=false
        fi
        CRB=$(printenv | grep CHROMEOS_RELEASE_BOARD | cut -d"=" -f2 | cut -d"-" -f1)
        PS3=" >> "
    # Save a user's current working directory no matter where this script is called from
        BOOKMARK=$(pwd)
        KERNEL1=$(uname -r 2>/dev/null | awk -F'[_.]' '{print $1}')
        KERNEL2=$(uname -r 2>/dev/null | awk -F'[_.]' '{print $2}')
        KERNEL3=$(uname -r 2>/dev/null | awk -F'[_.]' '{print $3}' | cut -c1-3)
        CPUTYPE=$(cat /proc/cpuinfo | grep "model name" | head -1 | awk -F '[:]' '{print $2}')
    # Set the working directory to simplify downloads and processes
        if [ "$BOOKMARK" != $DOWNLOADS ] && [ "$WSL" == "false" ] ; then
            cd $DOWNLOADS 2> /dev/null || { echo "[ERROR] Could not access $DOWNLOADS!" ; cleanexit ; }
        elif [ "$BOOKMARK" != $DOWNLOADS ] && [ "$WSL" == "true" ] ; then
            :
        fi
    # Find and count all necessary files
        FINDSHELL=$(ls /usr/local/bin/brunch-toolkit-assets/shell-tools.btst 2> /dev/null)
        FILES="$(find *runch*tar.gz 2> /dev/null | sort -r)"
        FILECOUNT=$(find *runch*.tar.gz 2> /dev/null | sort -r | wc -l)
        OTHERTARGZ="$(find *.tar.gz 2> /dev/null | sort -r)"
        CROS="$(find *hrome*.bin* 2> /dev/null | sort -r)"
        ANIMS="$(find boot_splash*.zip 2> /dev/null | sort -r)"
        NOANIMS="$(find *.zip 2> /dev/null | sort -r)"
        WEBANIMSPREFIX="https://github.com/WesBosch/brunch-bootsplash/releases/download/"
    # Get the latest brunch version directly from github, fail quietly if not able
        if [ $OFFLINE == false ]; then
            WEBANIMS="$(curl -s https://api.github.com/repos/WesBosch/brunch-bootsplash/releases | grep 'name' | cut -d\" -f4 | grep 'zip' | sed -e s/.zip//)"
            LATESTBRUNCH=$(curl -s "https://api.github.com/repos/sebanc/brunch/releases/latest" | grep 'name' | cut -d\" -f4 | grep 'tar.gz' )
            TKLA=$(curl -s https://api.github.com/repos/WesBosch/brunch-toolkit/releases/latest | grep 'name' | cut -d\" -f4 | grep '.sh' | cut -d'-' -f3 | sed -e s/.sh// )
            TKLAURL=$(curl -s https://api.github.com/repos/WesBosch/brunch-toolkit/releases/latest | grep 'browser_' | cut -d\" -f4 | grep '.sh')
        fi
        if [ "$LINUX" == true ] ; then
            getextras
        fi
        echo "All necessary components loaded"
        fi
    }

    getextras(){
    EXTRAS=$(dpkg-query -l cgpt pv tar unzip | grep 'no packages found matching')
        if [ -n "$EXTRAS" ] ; then
        echo "[!] This toolkit and the Brunch script require the following dependencies:"
        echo "pv, cgpt, unzip and tar"
        echo "Installing dependencies, please wait..."
        sudo apt-get update >> $BOOKMARK/toolkit-log.txt
        sudo apt-get -y install pv cgpt unzip tar >> $BOOKMARK/toolkit-log.txt
        fi
    }

# This addition was proposed by DennisLfromGA
# Checks to see if brunch_version exists and warns users if it doesn't. This file should only exist on brunch systems.
# Boots into linux mode on linux devices
    checkcurrentos() {
            # check if script is run as root
        uid=`id -u $USERNAME`
        if [ $uid -eq 0 ]; then
            echo "$0 must NOT be run as root."
            cleanexit
        fi
            vanity
            RELEASE=$(cat /etc/brunch_version 2>/dev/null)
        if [ -z "$RELEASE" ] && [[ $(grep icrosoft /proc/version 2> /dev/null) ]] ; then
            echo "[!] Launching in Windows WSL Mode"
            echo "WSL support is limited! This script will use your current directory."
            echo "Please be sure to cd into the directory where this script is located or some functions may fail."
            LINUX=true
            WSL=true
            debug
            cleanexit
        elif [ -z "$RELEASE" ] && [[ -z $(grep icrosoft /proc/version 2> /dev/null) ]] ; then
            echo "[!] Launching in Linux Mode"
            LINUX=true
            debug
            cleanexit
        else
            echo "[!] Launching in Brunch Mode"
            LINUX=false
            debug
            cleanexit
        fi
    }

# Please route all paths out of the script though this call
# Returns all variables to their default to prevent bad interactions with other scripts
    cleanexit() {
        echo "[!] Exiting..."
        CURRENT=
        PS3=
        BRUNCH=
        CHROME=
        METHOD=
        RECOVERY=
        RELEASE=
        KERNEL1=
        KERNEL2=
        KERNEL3=
        CROS=
        CHROME=
        TOOLVER=
        OPTS=
        LATESTBRUNCH=
        OFFLINE=
        OTHERTARGZ=
        CPUTYPE=
        IGNORECHECK=
        DEBUGCHECK=
        FUNCTION=
        INCLUDECHROME=
        CROSSN1=
        CROSSN2=
        CROSSN3=
        CROSSN4=
        BRUNCHSN1=
        BRUNCHSN2=
        BRUNCHSN3=
        BRUNCHSN4=
        BRUNCHSN5=
        VARS=
        LINUX=
        WSL=
        SUGGESTED=
        INSTALLING=
        DESTINATION=
        CHROMEURL=
        CHROMEURLVERS=
        RECOVERYOPTIONS=
        VALIDRECOVERIES=
        TMPNZIP=
        TKLA=
        TKLAURL=
        TOOLKITOPTS=
        cd "$BOOKMARK" || exit
        BOOKMARK=
        exit
    }

#####################################################################
# Toolkit Main Functions
#####################################################################

# Experimental multifunction to easily perform certain tasks
# Provide a list of funtions at launch and proceed as directed
# This is skipped if a debug option is selected instead
# Placeholder
    multifunction() {
        #echo "Not all functions are ready yet!"
        echo ""
        echo "+---------------------------------------------------------------+"
        echo "|                           Main Menu                           |"
        echo "+---------------------------------------------------------------+"
        echo ""
        if [ "$LINUX" == "true" ] ; then
        linuxfunction
        else
        select FUNCTION in "Update Brunch" "Update Chrome OS & Brunch" "Install Brunch" "Compatibility Check" "Change Boot Animation" "Install/Update Toolkit" "Shell Options" "Changelog" "Version" "About" Quit; do
        if [[ -z "$FUNCTION" ]] ; then
           echo "[ERROR] Invalid option"
        elif [[ $FUNCTION == "Update Brunch" ]] ; then
            mfbrunch
        elif [[ $FUNCTION == "Update Chrome OS & Brunch" ]] ; then
            mfchrome
        elif [[ $FUNCTION == "Install Brunch" ]] ; then
            mfinstall
        elif [[ $FUNCTION == "Compatibility Check" ]] ; then
            compatibilitycheck
        elif [[ $FUNCTION == "Changelog" ]] ; then
            changelog
        elif [[ $FUNCTION == "Version" ]] ; then
            version
        elif [[ $FUNCTION == "About" ]] ; then
            help
        elif [[ $FUNCTION == "Change Boot Animation" ]] ; then
            mfbootanim
        elif [[ $FUNCTION == "Install/Update Toolkit" ]] ; then
            mftoolkit
        elif [[ $FUNCTION == "Shell Options" ]] ; then
            brunchshellsetup
        elif [[ $FUNCTION == "Quit" ]] ; then
            cleanexit
        else
        :
        fi
        done
        fi
    }


    linuxfunction() {
    select FUNCTION in "Install Brunch" "Compatibility Check" "Changelog" "Version" "About" Quit; do
        if [[ -z "$FUNCTION" ]] ; then
           echo "[ERROR] Invalid option"
        elif [[ $FUNCTION == "Install Brunch" ]] ; then
            mfinstall
        elif [[ $FUNCTION == "Compatibility Check" ]] ; then
            compatibilitycheck
        elif [[ $FUNCTION == "Changelog" ]] ; then
            changelog
        elif [[ $FUNCTION == "Version" ]] ; then
            version
        elif [[ $FUNCTION == "About" ]] ; then
            help
        elif [[ $FUNCTION == "Quit" ]] ; then
            cleanexit
        else
        :
        fi
        done
    }

    mfbootanim() {
        getanim
        cleanexit
    }

# Quick brunch update with no prompts.
    quickupdate() {
        vanity
        RELEASE=$(cat /etc/brunch_version 2>/dev/null)
            if [ -z "$RELEASE" ] ; then
            echo "[ERROR] Quick Update only works on Brunch systems!"
            cleanexit
            fi
        setvars
        echo "Quick update in progress, please wait..."
        if [[ $LATESTBRUNCH =~ .*"$CURRENT".* ]] && [ "$IGNORECHECK" == false ] ; then
            echo "[!] You already have the latest version of Brunch. ($RELEASE)"
            cleanexit
        fi
# If no brunch files, download latest
        if [ -z  "$FILES" ] && [ "$OFFLINE" == "false" ] ; then
            echo "[ERROR] No Brunch files found!"
            echo "Now downloading latest release $LATESTBRUNCH, please wait..."
            wget -q --show-progress "$(curl -s https://api.github.com/repos/sebanc/brunch/releases/latest | grep 'browser_' | cut -d\" -f4)"
            echo "Brunch update downloaded! Updating, please wait..."
            echo ""
            FILES="$(find *runch*tar.gz 2> /dev/null | sort -r | head -1 )"
            BRUNCH=$FILES
            update
# If no internet, warn
        elif [ -z  "$FILES" ] && [ "$OFFLINE" == "true" ] ; then
        echo "[ERROR] No Brunch file found, Downloading one..."
        echo "[ERROR] Unable to automatically download update, please download it manually."
        echo "You can find the latest release here:"
            echo ""
            printf '    \e]8;;https://github.com/sebanc/brunch/releases\e\\ >> https://github.com/sebanc/brunch/releases << \e]8;;\e\\\n'
            echo ""
            echo "Please run this script again after your download finishes."
        cleanexit
# Get list of brunch files, proceed only if there's just one target and it matches the github release
        elif [ "$FILECOUNT" == "1" ] && [[ $FILES =~ .*"$LATESTBRUNCH".* ]] ; then
            BRUNCH=$FILES
            update
        elif [ "$FILECOUNT" == "1" ] && [[ ! $FILES =~ .*"$LATESTBRUNCH".* ]] ; then
            echo "[!] Brunch file may not be recent or has an unexpected filename!"
            echo "Now downloading latest release $LATESTBRUNCH, please wait..."
            wget -q --show-progress "$(curl -s https://api.github.com/repos/sebanc/brunch/releases/latest | grep 'browser_' | cut -d\" -f4)"
            echo "Brunch update downloaded! Updating, please wait..."
            echo ""
            BRUNCH=$LATESTBRUNCH
            update
# Warn if there is more than one brunch file present
        else
            echo "[!] There are too many Brunch files present to use Quick mode."
            echo "Relaunching in standard update mode, please wait..."
            echo ""
            main
        fi
        }

# Installs Brunch to USB or HDD
# Placeholder
    mfinstall() {
        INCLUDECHROME=true
        INSTALLING=true
        if [ "$LINUX" == "true" ] ; then
            getfiles
        else
            installos
        fi
        cleanexit
    }

# Initiates Brunch update without checking to update ChromeOS
    mfbrunch() {
        getfiles
        cleanexit
    }

# Initiates Brunch & Chrome OS Update
# Downloads recovery if one is not present
    mfchrome() {
        INCLUDECHROME=true
        getfiles
        cleanexit
    }

# Installs the toolkit for easier access later
    mftoolkit(){
        checktoolkitver
        cleanexit
    }

#####################################################################
# Toolkit Installer / Updater
#####################################################################

    checktoolkitver(){
        if [ "$TOOLVER" == "$TKLA" ] ; then
            echo ""
            echo "You're already using the latest version of the Brunch Toolkit"
        fi
        if [ "$OFFLINE" == "true" ] ; then
            tkoffline
            cleanexit
        fi
        echo ""
        echo "Current toolkit version:   $TOOLVER"
        echo "Latest toolkit version:    $TKLA"
        echo ""
        echo "What would you like to do?"
        echo ""
        select TOOLKITOPTS in "Install Brunch Toolkit $TOOLVER" "Update to Brunch Toolkit $TKLA" "Update & Install $TKLA" Quit; do
        if [[ -z "$TOOLKITOPTS" ]] ; then
           echo "[ERROR] Invalid option"
        elif [[ $TOOLKITOPTS == "Install Brunch Toolkit $TOOLVER" ]] ; then
            tbinstall
        elif [[ $TOOLKITOPTS == "Update to Brunch Toolkit $TKLA" ]] ; then
            tbupdate
        elif [[ $TOOLKITOPTS == "Update & Install $TKLA" ]] ; then
            tbupandin
        elif [[ $TOOLKITOPTS == "Quit" ]] ; then
            cleanexit
        else
        :
        fi
        done
        cleanexit
    }

    tkoffline(){
        echo ""
        echo "Current toolkit version:   $TOOLVER"
        echo ""
        echo "What would you like to do?"
        echo ""
        select TOOLKITOPTS in "Install Brunch Toolkit $TOOLVER" Quit; do
        if [[ -z "$TOOLKITOPTS" ]] ; then
           echo "[ERROR] Invalid option"
        elif [[ $TOOLKITOPTS == "Install Brunch Toolkit $TOOLVER" ]] ; then
            tbinstall
        elif [[ $TOOLKITOPTS == "Quit" ]] ; then
            cleanexit
        else
        :
        fi
        done
        cleanexit
    }

    tbinstall(){
        mv -f $DOWNLOADS/brunch-toolkit-$TOOLVER.sh /usr/local/bin/brunch-toolkit
        chmod +x /usr/local/bin/brunch-toolkit
        mkdir /usr/local/bin/brunch-toolkit-assets
        echo "Brunch Toolkit has been installed!"
        echo "To use the installed version, just type 'brunch-toolkit' without quotes"
        echo "It should look something like this:"
        echo ""
        echo ""
        echo -e "\e[01;32mchronos@localhost \e[01;34m/ $ \e[0mbrunch-toolkit"
        echo ""
        echo ""
        echo "Note that the installed version does not require '.sh' at the end"
        cleanexit
    }

    tbupdate(){
        echo "Downloading latest Brunch Toolkit, please wait..."
        wget -q --show-progress "$TKLAURL"
        echo "Downloaded successfully!"
    }

    tbupandin(){
        tbupdate
        TOOLVER=$TKLA
        tbinstall
    }

#####################################################################
# Boot Animation Changer
#####################################################################

    getanim(){
    CURRENTLYSET=$(cd /usr/share/chromeos-assets/images_100_percent/ && ls *.btbs 2> /dev/null | sed -e s/.btbs//)
    PREVIOUSSET=$(cd /usr/local/bin/brunch-toolkit-assets/ && ls *.btbs 2> /dev/null | sed -e s/.btbs//)
    if [ -n "$PREVIOUSSET" ] && [ -z "$CURRENTLYSET" ] ; then
    echo ""
    echo "The boot animation was reset to the default, this is typical after an update."
    echo "You can reset it to your last animation with the options here,"
    echo "or reset it quickly by running the script again with -qb"
    RESETPOSSIBLE=true
    fi
    echo ""
    echo "Getting boot animation files, please wait..."
    echo ""
    if [ -z  "$ANIMS" ] && [ "$OFFLINE" == "false" ] ; then
            webanimcheck
        elif [ -z  "$ANIMS" ] && [ "$OFFLINE" == "true" ] ; then
            echo "[ERROR] No boot animation files found!"
            cleanexit
        elif [ "$OFFLINE" == "true" ] ; then
            echo "Boot animation files found!"
            selectanimoffline
        else [ "$OFFLINE" == "false" ]
            echo "Boot animation files found!"
            selectanim
        fi
    }

    selectanim() {
        echo ""
        echo "Enter the number of the animation you want to use."
        if [ "$RESETPOSSIBLE" == "true" ] ; then
        echo "Your previously set animation was $PREVIOUSSET"
        echo ""
        select BOOTSPLASH in "Use previous animation" "Download others from github" ${ANIMS} Quit; do
        if [ -z "$BOOTSPLASH" ] ; then
           echo "[ERROR] Invalid option"
        elif [[ $BOOTSPLASH =~ .*"previous".* ]] ; then
            resetanim
        elif [[ $BOOTSPLASH =~ .*"Download".* ]] ; then
            webanimcheck
        elif [ "$BOOTSPLASH" == "Quit" ] ; then
            cleanexit
        else
            echo "Boot animation file selected."
            changebootsplash
        fi
        done
        else
        if [ -n "$CURRENTLYSET" ] ; then
        echo "Your currently set animation is $CURRENTLYSET"
        fi
        echo ""
        select BOOTSPLASH in "Download others from github" ${ANIMS} Quit; do
        if [ -z "$BOOTSPLASH" ] ; then
           echo "[ERROR] Invalid option"
        elif [[ $BOOTSPLASH =~ .*"Download".* ]] ; then
            webanimcheck
        elif [ "$BOOTSPLASH" == "Quit" ] ; then
            cleanexit
        else
            echo "Boot animation file selected."
            changebootsplash
        fi
        done
        fi
    }

    selectanimoffline() {
        echo ""
        echo "Enter the number of the animation you want to use."
        if [ "$RESETPOSSIBLE" == "true" ] ; then
        echo "Your previously set animation was $PREVIOUSSET"
        echo ""
        select BOOTSPLASH in "Use previous animation" ${ANIMS} Quit ; do
        if [ -z "$BOOTSPLASH" ] ; then
           echo "[ERROR] Invalid option"
        elif [[ $BOOTSPLASH =~ .*"previous".* ]] ; then
            resetanim
        elif [ "$BOOTSPLASH" == "Quit" ] ; then
            cleanexit
        else
            echo "Boot animation file selected."
            changebootsplash
        fi
        done
        else
        if [ -n "$CURRENTLYSET" ] ; then
        echo "Your currently set animation is $CURRENTLYSET"
        fi
        echo ""
        select BOOTSPLASH in ${ANIMS} Quit ; do
        if [ -z "$BOOTSPLASH" ] ; then
           echo "[ERROR] Invalid option"
        elif [ "$BOOTSPLASH" == "Quit" ] ; then
            cleanexit
        else
            echo "Boot animation file selected."
            changebootsplash
        fi
        done
        fi
    }

    webanimcheck(){
        echo ""
        echo "These are the avaliable animations from the brunch-bootsplash github."
        echo ""
        select WEBSPLASH in ${WEBANIMS} Quit ; do
        if [ -z "$WEBSPLASH" ] ; then
           echo "[ERROR] Invalid option"
        elif [ "$WEBSPLASH" == "Quit" ] ; then
            cleanexit
        else
            echo "Boot animation file selected."
            getnewanim
        fi
        done
    }

    getnewanim() {
        echo "Now downloading animation from github, please wait..."
        wget -q --show-progress $WEBANIMSPREFIX$WEBSPLASH/$WEBSPLASH.zip
        echo "Boot animation downloaded! Refreshing, please wait..."
        echo ""
        ANIMS="$(find boot_splash*.zip 2> /dev/null)"
        echo "[DEBUG] $ANIMS"
        selectanimoffline
    }

    changebootsplash(){
    # Unzip selection
        echo "Unzipping archive, please wait..."
        BSDIR=$(echo "$BOOTSPLASH" | sed -e s/.zip//)
        unzip "$BOOTSPLASH" -d $DOWNLOADS/"$BSDIR" || { echo "[ERROR] Unable to unzip animation archive" ; cleanexit ; }
        sudo cp $DOWNLOADS/$BSDIR/boot_splash_frame*.png /usr/share/chromeos-assets/images_100_percent || { echo "[ERROR] Unable to apply boot animation" ; cleanexit ; }
        sudo cp $DOWNLOADS/$BSDIR/boot_splash_frame*.png /usr/share/chromeos-assets/images_200_percent 2> /dev/null
        mkdir /usr/local/bin/brunch-toolkit-assets 2> /dev/null
        sudo cp $DOWNLOADS/$BSDIR/boot_splash_frame*.png /usr/local/bin/brunch-toolkit-assets 2> /dev/null
        sudo rm /usr/share/chromeos-assets/images_100_percent/*.btbs 2> /dev/null
        rm /usr/local/bin/brunch-toolkit-assets/*.btbs 2> /dev/null
        sudo touch /usr/share/chromeos-assets/images_100_percent/$BSDIR.btbs 2> /dev/null
        sudo touch /usr/local/bin/brunch-toolkit-assets/$BSDIR.btbs 2> /dev/null
        rm -rf $DOWNLOADS/$BSDIR
    # Cleanup
    # Prompt to reboot
        echo "New boot animation applied, please reboot to see results."
        echo "Custom boot animations will only last until a framework or system update."
        echo "Updating Brunch, ChromeOS or your framework options may remove the animation."
        echo ""
        cleanexit
    }

    resetanim(){
    echo ""
        if [ -z "$PREVIOUSSET" ] ; then
    echo "[ERROR] Your previous boot animation could not be detected!"
    echo "If you've just updated the toolkit or haven't installed a boot animation yet"
    echo "please use the toolkit's menu to set an animation manually first."
    echo ""
    cleanexit
    fi
    echo "Quickly resetting your custom boot animation, please wait..."
        sudo cp /usr/local/bin/brunch-toolkit-assets/boot_splash_frame*.png /usr/share/chromeos-assets/images_100_percent || { echo "[ERROR] Unable to apply boot animation" ; cleanexit ; } 2> /dev/null
        sudo cp /usr/local/bin/brunch-toolkit-assets/boot_splash_frame*.png /usr/share/chromeos-assets/images_200_percent
        sudo rm /usr/share/chromeos-assets/images_100_percent/*.btbs 2> /dev/null
        sudo touch /usr/share/chromeos-assets/images_100_percent/$PREVIOUSSET.btbs 2> /dev/null
        echo "New boot animation applied, please reboot to see results."
        echo "Custom boot animations will only last until a framework or system update."
        echo "Updating Brunch, ChromeOS or your framework options may remove the animation."
        echo ""
        cleanexit
    }

#####################################################################
# Brunch Updater Functions
#####################################################################

# Determine if Brunch files are present and if user is offline
    getfiles() {
        echo ""
        echo "Getting Brunch release files, please wait..."
        echo ""
        if [ -z  "$FILES" ] && [ "$OFFLINE" == "false" ] ; then
            getupdate
        elif [ -z  "$FILES" ] && [ "$OFFLINE" == "true" ] ; then
            echo "[ERROR] No Brunch files found!"
            echo "Looking for any .tar.gz in $DOWNLOADS..."
            wrongfile
        elif [ "$OFFLINE" == "true" ] ; then
            echo "Brunch files found!"
            selectbrunchoffline
        else [ "$OFFLINE" == "false" ]
            echo "Brunch files found!"
            selectbrunch
        fi
    }

# Prompts the user to select which update they want to apply from the list stored in var $FILES
    selectbrunch() {
        echo ""
        echo "Enter the number of the release you want to use."
        echo "The options at the top should be the most recent."
        echo ""
        select BRUNCH in "Download the latest release: $LATESTBRUNCH" ${FILES} Quit; do
        if [ -z "$BRUNCH" ] ; then
           echo "[ERROR] Invalid option"
        elif [[ $BRUNCH =~ .*"Download".* ]] ; then
            webverscheck
        elif [ "$BRUNCH" == "Quit" ] ; then
            cleanexit
        else
            echo "Brunch release file selected."
            sanitycheck
        fi
        done
    }

# Prompts the user to select which update they want to apply from the list stored in var $FILES
    selectbrunchoffline() {
        echo ""
        echo "Enter the number of the release you want to use."
        echo "The options at the top should be the most recent."
        echo ""
        select BRUNCH in ${FILES} Quit; do
        if [ -z "$BRUNCH" ] ; then
           echo "[ERROR] Invalid option"
        elif [[ $BRUNCH == "Quit" ]] ; then
            cleanexit
        else
            echo "Brunch release file selected."
            sanitycheck
        fi
        done
    }

# Backup updater if Brunch files are not found, but may still exist under a different name.
# This function is only called if a brunch .tar.gz file is not present AND the user is offline
    wrongfile() {
        if [ -z "$OTHERTARGZ" ] ; then
            echo "No possible tar.gz files found."
            echo "You can find the latest release here:"
            echo ""
            printf '    \e]8;;https://github.com/sebanc/brunch/releases/latest\e\\ >> https://github.com/sebanc/brunch/releases/latest << \e]8;;\e\\\n'
            echo ""
            echo "Please run this script again after your download finishes."
            cleanexit
        fi
        echo ""
        echo "Possible update files found!"
        echo "Your Brunch files may have an unexpected filename."
        echo "This can happen if you renamed them or downloaded from another source."
        echo "If any of these are your Brunch release file, you can select it"
        echo ""
        select BRUNCH in ${OTHERTARGZ} "None of these" Quit; do
        if [ -z "$BRUNCH" ] ; then
           echo "[ERROR] Invalid option"
        elif [[ $BRUNCH =~ .*"None".* ]] ; then
        echo "If none of these files are Brunch releases, you can find the latest release here:"
        echo ""
            printf '    \e]8;;https://github.com/sebanc/brunch/releases/latest\e\\ >> https://github.com/sebanc/brunch/releases/latest << \e]8;;\e\\\n'
            echo ""
            echo "Please run this script again after your download finishes."
            cleanexit

        elif [ "$BRUNCH" == "Quit" ] ; then
            cleanexit
        else
            echo "Brunch release file selected."
            sanitycheck
        fi
        done
    }

# Checks current version against the selected brunch update and prompts the user if they're already using that version.
# Proceed to check for ChromeOS recoveries next
# chechchrome & chromecount can probably be combined with this to reduce user input
    sanitycheck() {
        while true; do
            if [[ $INCLUDECHROME == true ]]; then
                getcros
            fi
            getbrunchshortname
            echo ""
            echo "Target version:  ${BRUNCHSN1^} $BRUNCHSN2 $BRUNCHSN3.$BRUNCHSN4 $BRUNCHSN5"
            echo "Current version: $RELEASE"
            echo ""
            if [[ $BRUNCH =~ .*"$CURRENT".* ]] ; then
                echo "[!] You are already using the selected version."
                    read -rp "Do you want to update anyway? (y/n): " yn
                    case $yn in
                        [Yy]* ) update; break;;
                        [Nn]* ) echo "Update cancelled!"; cleanexit;;
                        * ) echo "[ERROR] Invalid option, Please type yes or no.";;
                    esac
            else
            read -rp "Update with this release? (y/n): " yn
            case $yn in
                [Yy]* ) update; break;;
                [Nn]* ) echo "Update cancelled!"; cleanexit;;
                * ) echo "[ERROR] Invalid option, Please type yes or no.";;
            esac
            fi
        done
    }


    getbrunchshortname() {
        BRUNCHSN1=$(echo "$BRUNCH" | awk -F'[_.]' '{print $1}')
        BRUNCHSN2=$(echo "$BRUNCH" | awk -F'[_.]' '{print $2}')
        BRUNCHSN3=$(echo "$BRUNCH" | awk -F'[_.]' '{print $3}')
        BRUNCHSN4=$(echo "$BRUNCH" | awk -F'[_.]' '{print $4}')
        BRUNCHSN5=$(echo "$BRUNCH" | awk -F'[_.]' '{print $6}')
    }

#####################################################################
# ChromeOS Updater Functions
#####################################################################


# Determine if Chrome recovery files are present and if user is offline
    getcros() {
        echo ""
        echo "Getting Chrome OS recovery files, please wait..."
        echo ""
        if [ -z  "$CROS" ] && [ "$OFFLINE" == "false" ] ; then
            getcrosupdate
        elif [ -z  "$CROS" ] && [ "$OFFLINE" == "true" ] ; then
            echo "[ERROR] No Chrome OS files found!"
            echo "Updating Brunch only..."
            INCLUDECHROME=false
                sanitycheck
        elif [ "$OFFLINE" == "true" ] ; then
            echo "Chrome OS Recovery files found!"
            selectcrosoffline
        else [ "$OFFLINE" == "false" ]
            echo "Chrome OS Recovery files found!"
            selectcros
        fi
    }

# Prompts the user to select which recovery they want to apply from the list stored in var $FILES
    selectcros() {
        echo ""
        echo "Enter the number of the Recovery you want to use."
        echo "The options at the top should be the most recent."
        echo ""
        select CHROME in "Download the latest recovery from list" ${CROS} Quit; do
        if [ -z "$CHROME" ] ; then
           echo "[ERROR] Invalid option"
        elif [[ $CHROME =~ .*"Download".* ]] ; then
            crosverscheck
        elif [ "$CHROME" == "Quit" ] ; then
            cleanexit
        else
            finalcheck
        fi
        done
    }

# Prompts the user to select which update they want to apply from the list stored in var $FILES
    selectcrosoffline() {
        if [ -z $CROS ] ; then
            echo "[ERROR] Chrome OS recoveries could not be identified!"
            echo "Make sure the recovery bin or bin.zip is in $DOWNLOADS and the filename contains 'chromeos'"
            echo "Updating Brunch only..."
            INCLUDECHROME=false
            sanitycheck
        fi
        echo ""
        echo "Enter the number of the Recovery you want to use."
        echo "The options at the top should be the most recent."
        echo ""
        select CHROME in ${CROS} Quit; do
        if [ -z "$CHROME" ] ; then
           echo "[ERROR] Invalid option"
        elif [[ $CHROME == "Quit" ]] ; then
            cleanexit
        else
            finalcheck
        fi
        done
    }

# Final sanity check
    finalcheck() {
        while true; do
            checkunzip
            if [ -z "$CHROME" ] && [ "$INSTALLING" == "true" ] ; then
                echo "[ERROR] Chrome OS recovery could not be identified!"
                echo "Make sure the recovery bin or bin.zip is in $DOWNLOADS and the filename contains 'chromeos'"
                echo "Unable to install, please verify your files and install manually..."
                cleanexit
            elif [ -n "$CHROME" ] && [ "$INSTALLING" == "true" ]; then
                installos
            elif [ -z "$CHROME" ] ; then
                echo "[ERROR] Chrome OS Recovery could not be identified!"
                echo "Updating Brunch only..."
                INCLUDECHROME=false
                sanitycheck
            fi
            echo "Chrome OS recovery file selected."
            echo ""
            getcrosver
            echo "Current Brunch version: $RELEASE"
            getbrunchshortname
            echo "Current Chrome OS version: $CROSVER"
            getcrosshortname
            echo ""
            if [[ $BRUNCH =~ .*"$CURRENT".* ]] ; then
                echo "[!] You are already using the selected Brunch version."
                    read -rp "Do you want to update anyway? (y/n): " yn
                    case $yn in
                        [Yy]* ) update; break;;
                        [Nn]* ) echo "Update cancelled!"; cleanexit;;
                        * ) echo "[ERROR] Invalid option, Please type yes or no.";;
                    esac
            else
            read -rp "Update with these files? (y/n): " yn
            case $yn in
                [Yy]* ) update; break;;
                [Nn]* ) echo "Update cancelled!"; cleanexit;;
                * ) echo "[ERROR] Invalid option, Please type yes or no.";;
            esac
            fi
        done
    }

    checkunzip(){
    if [[ "$CHROME" =~ .*"zip".* ]] ; then
    echo "Unzipping selected file, please wait..."
            unzip "$CHROME" || { echo "[ERROR] Unzip failed!" ; echo "Try another file." ; echo "If this keeps happening, please try to unzip the file manually." ; getcros ; }
            TMPNZIP=$CHROME
            rm "$CHROME"
            CHROME=${TMPNZIP%.zip}
            echo "$CHROME unzipped, proceeding..."
    fi
    }

    getcrosshortname() {
        CROSSN1=$(echo "$CHROME" | awk -F'[_.]' '{print $5}')
        CROSSN2=$(echo "$CHROME" | awk -F'[_.]' '{print $2}')
        CROSSN3=$(echo "$CHROME" | awk -F'[_.]' '{print $3}')
        CROSSN4=$(echo "$CHROME" | awk -F'[_.]' '{print $4}')
        echo "Target Chrome OS recovery: ${CROSSN1^} $CROSSN2.$CROSSN3.$CROSSN4"
    }

#####################################################################
# Brunch Downloader Functions
#####################################################################

# If no brunch update is present, prompt user to download most recent to link to github releases
# getbrunch can probably be combined with this to reduce user input
    getupdate() {
        echo "[ERROR] A Brunch release file was not found in $DOWNLOADS"
        echo ""
        echo "What would you like to do?"
        echo "Select one of the following options."
        echo ""
        select METHOD in "Download the newest release: $LATESTBRUNCH" "Visit the releases page" Quit; do
        if [[ $METHOD =~ .*"Download".* ]]; then
            webverscheck
        elif [[ $METHOD =~ .*"Visit".* ]]; then
            echo "You can find the latest release here:"
            echo ""
            printf '    \e]8;;https://github.com/sebanc/brunch/releases\e\\ >>https://github.com/sebanc/brunch/releases<< \e]8;;\e\\\n'
            echo ""
            echo "Please run this script again after your download finishes."
            cleanexit
        elif [ "$METHOD" == "Quit" ] ; then
            cleanexit
        else
            echo "[ERROR] Invalid option"
        fi
        done
    }

# Immediately download the latest brunch release, quiet but shows progress bar
# Returns the user to the beginning of the brunch updater to use the downloaded file immediately
    getbrunch() {
        echo "Now downloading latest release $LATESTBRUNCH, please wait..."
        wget -q --show-progress "$(curl -s https://api.github.com/repos/sebanc/brunch/releases/latest | grep 'browser_' | cut -d\" -f4)"
        echo "Brunch release downloaded! Refreshing, please wait..."
        echo ""
        FILES="$(ls -ArR *runch*tar.gz 2> /dev/null)"
        selectbrunchoffline
    }

# Checks present files and current brunch version against the latest github release
# Silently proceeds to getbrunch if no matches are found
    webverscheck() {
        if [[ $FILES =~ .*"$LATESTBRUNCH".* ]] ; then
        echo "$FILES"
            echo "[!] You already have this file!"
            read -rp "Do you want to delete the older file and download it again? (y/n): " yn
            case $yn in
                [Yy]* ) delbrunch; return;;
                [Nn]* ) echo "Download cancelled!"; cleanexit;;
                    * ) echo "[ERROR] Invalid option, Please type yes or no.";;
            esac
        elif [[ $LATESTBRUNCH =~ .*"$CURRENT".* ]] ; then
            echo "[!] You are are already using the selected version."
            read -rp "Do you want to download it anyway? (y/n): " yn
            case $yn in
                [Yy]* ) getbrunch; return;;
                [Nn]* ) echo "Download cancelled!"; cleanexit;;
                    * ) echo "[ERROR] Invalid option, Please type yes or no.";;
            esac
        else
           getbrunch
        fi
    }

# Deletes old version of brunch matching the latest github release then proceeds to getbrunch
    delbrunch() {
        rm "$LATESTBRUNCH"
        getbrunch
        }


#####################################################################
# Chrome OS Downloader Functions
#####################################################################

# If no brunch update is present, prompt user to download most recent to link to github releases
    getcrosupdate() {
        echo "[ERROR] A Chrome OS recovery file was not found in $DOWNLOADS"
        echo ""
        echo "What would you like to do?"
        echo "Select one of the following options."
        echo ""
        select METHOD in "Download the newest recovery" "Visit the releases page" Quit; do
        if [[ $METHOD =~ .*"Download".* ]]; then
            crosverscheck
        elif [[ $METHOD =~ .*"Visit".* ]]; then
            echo "You can find the latest release here:"
            echo ""
            printf '    \e]8;;https://cros.tech\e\\ >>https://cros.tech<< \e]8;;\e\\\n'
            echo ""
            echo "Please run this script again after your download finishes."
            cleanexit
        elif [ "$METHOD" == "Quit" ] ; then
            cleanexit
        else
            echo "[ERROR] Invalid option"
        fi
        done
    }

# Immediately download the chosen Chrome OS recovery, quiet but shows progress bar
# Returns the user to the beginning of the chromeos updater to use the downloaded file immediately
    getchrome() {
        getchromeurl
        echo "Chrome OS recovery downloaded! Unzipping, please wait..."
        echo ""
        CHROME="$(find *$RECOVERYTODOWNLOAD*.bin.zip 2> /dev/null | sort -r | head -1)"
        unzip "$CHROME"
        CROS="$(find *$RECOVERYTODOWNLOAD*.bin 2> /dev/null | sort -r | head -1)"
        rm "$CHROME"
        selectcrosoffline
    }

    getchromeurl(){
        CHROMEURL=$(curl https://cros.tech/device/$RECOVERYTODOWNLOAD | perl -nle'print $& while m{href="https://[^"]+\.zip"}g' | perl -nle'print $& while m{https://[^"]+}g' | tail -1)
        CHROMEURLVERS=$(curl https://cros.tech/device/$RECOVERYTODOWNLOAD | perl -nle'print $& while m{>[0-9][0-9]*<}g' | perl -nle'print $& while m{[0-9][0-9]*}g' | tail -1)
# Possible to create case where user can select version, but I'm not going to rn
        echo "Downloading $RECOVERYTODOWNLOAD r$CHROMEURLVERS, please wait..."
        wget -q --show-progress $CHROMEURL
        }


# Receovery Download Handler
    crosverscheck() {
        quietcompatibilitycheck
        echo ""
        echo "CPU:$CPUTYPE"
        if [ "$SUGGESTED" == "grunt" ] && [ "$STONEYRIDGE" == "true" ; then
        echo "Your CPU is only compatible with Grunt."
        echo "You may select others if you want, but they may not work."
        elif [ "$SUGGESTED" == "grunt" ] && [ "$STONEYRIDGE" == "false" ; then
        echo "Your CPU may only be compatible with Grunt, but isn't a known Stoney Ridge CPU."
        echo "Only AMD's Stoney Ridge CPUs are compatible with Grunt."
        echo "You may select others if you want, but they may not work."
        elif [ "$SUGGESTED" != "grunt" ] ; then
        echo "The suggested recovery for your CPU is $SUGGESTED"
        fi
        if [ "$SECONDCHOICE" == true ] && [ "$SUGGESTED" != "grunt" ] ; then
        echo "Your CPU is also compatible with Eve, Nami and Hatch."
        fi
        if [ "$SPECIALBUILD" == true ] && [ "$SUGGESTED" != "grunt" ] ; then
        echo "Your CPU may require a special build to boot!"
        echo "If you run into problems, check out our discord for assistance."
        fi
        if [ "$SUGGESTED" == "unknown" ] ; then
        echo "Your CPU could not be determined or may not be compatible with Brunch."
        echo "You can continue, but be aware that it may not work!"
        echo "Which recovery would you like to download?"
        echo ""
        echo "Grunt only works on AMD Stoney Ridge CPUs"
        echo "Samus is suggested for Intel Core ix 3rd gen and older CPUs."
        echo "Rammus is suggested for Intel Core ix 4th gen and newer CPUS."
        echo "All other CPUs are currently unsupported."
        echo ""
        select RECOVERYTODOWNLOAD in rammus samus grunt "Choose another" Quit; do
        if [[ -z "$RECOVERYTODOWNLOAD" ]] ; then
           echo "[ERROR] Invalid option"
        elif [[ $RECOVERYTODOWNLOAD == "Quit" ]] ; then
            cleanexit
        else
            getchrome
        fi
        done
        fi
        echo ""
        echo "Which recovery would you like to download?"
        echo "If you aren't sure what to use, go with the suggestion"
        if [ "$LINUX" == "false" ] ; then
            echo "You are currently using $CRB"
        fi
        echo ""
        select RECOVERYTODOWNLOAD in "Use suggested ($SUGGESTED)" ${RECOVERYOPTIONS} "Select another" Quit; do
        if [[ -z "$RECOVERYTODOWNLOAD" ]] ; then
           echo "[ERROR] Invalid option"
        elif [[ $RECOVERYTODOWNLOAD == "Quit" ]] ; then
            cleanexit
        elif [[ $RECOVERYTODOWNLOAD == "Use suggested" ]] ; then
            RECOVERYTODOWNLOAD=$SUGGESTED
            getchrome
        elif [[ $RECOVERYTODOWNLOAD == "Select another" ]] ; then
            echo "Please enter the board name of the recovery you'd like to use"
            echo "Enter 'back' if you'd like to go back."
            bringyourownrecovery
        else
            getchrome
        fi
        done
        }

        bringyourownrecovery(){
            read -rp " >> " -e RECOVERYTODOWNLOAD
            case $OWNRECOVERY in
                * ) checkvalidrecovery; return;;
            esac
        }

        checkvalidrecovery(){
            if [[ -z "$RECOVERYTODOWNLOAD" ]] ; then
                echo "[ERROR] Invalid option, Please type a valid board name or type back to return to the list."
                bringyourownrecovery
            elif [[ "$VALIDRECOVERIES" =~ .*"$RECOVERYTODOWNLOAD".* ]] ; then
                getchrome
            elif [[ "$RECOVERYTODOWNLOAD" =~ .*"ack".* ]] ; then
                crosverscheck
            else
                echo "[ERROR] Invalid option, Please type a valid board name or type back to return to the list."
                bringyourownrecovery
            fi
        }

#####################################################################
# Core Functions
#####################################################################

# Combined update call
    update() {
        if [ "$DEBUGCHECK" == "true" ] ; then
            debugupdate
        else
            trueupdate
        fi
    }

# Checks to see if $CHROME was set to include a ChromeOS recovery in the update
    trueupdate() {
        if [ -z "$CHROME" ] ; then
            echo "Launching Brunch update script, please wait..."
            sudo chromeos-update -f $DOWNLOADS/"$BRUNCH"
            cleanexit
        else
            echo "Launching Brunch & Chrome OS update script, please wait..."
            sudo chromeos-update -r $DOWNLOADS/"$CHROME" -f $DOWNLOADS/"$BRUNCH"
            cleanexit
        fi
    }

# Debug ending script. prevents accidental installs or updates while testing.
    debugupdate() {
        if [ -z "$RECOVERY" ] ; then
            echo "Launching Brunch update script, please wait..."
            echo "sudo chromeos-update -f $DOWNLOADS/$BRUNCH"
            echo "No update has happened. Exiting debug mode..."
            cleanexit
        else
            echo "Launching Brunch & Chrome OS update script, please wait..."
            echo "sudo chromeos-update -r $DOWNLOADS/$RECOVERY -f $DOWNLOADS/$BRUNCH"
            echo "No update has happened. Exiting debug mode..."
            cleanexit
        fi
    }

    installos(){
        if [ "$LINUX" == "true" ] && [ "$WSL" == "false" ] ; then
            { find $DOWNLOADS/brunch-toolkit-workspace 2> /dev/null ; rm -rf $DOWNLOADS/brunch-toolkit-workspace/ 2> /dev/null ; mkdir $DOWNLOADS/brunch-toolkit-workspace ; echo "Brunch Toolkit workspace has been cleaned." ; } || { mkdir $DOWNLOADS/brunch-toolkit-workspace ; echo "Brunch Toolkit workspace has been created." ; }
            echo "Preparing to extract selected Brunch files, please wait..."
            sudo tar zxvf $DOWNLOADS/$BRUNCH -C $DOWNLOADS/brunch-toolkit-workspace
        elif [ "$LINUX" == "true" ] && [ "$WSL" == "true" ] ; then
            { find $BOOKMARK/brunch-toolkit-workspace 2> /dev/null ; rm -rf $BOOKMARK/brunch-toolkit-workspace/ 2> /dev/null ; mkdir $BOOKMARK/brunch-toolkit-workspace ; echo "Brunch Toolkit workspace has been cleaned." ; } || { mkdir $BOOKMARK/brunch-toolkit-workspace ; echo "Brunch Toolkit workspace has been created." ; }
             echo "Preparing to extract selected Brunch files, please wait..."
            sudo tar zxvf $BOOKMARK/$BRUNCH -C $BOOKMARK/brunch-toolkit-workspace
            installercheck
        else
            { find $DOWNLOADS/brunch-toolkit-workspace 2> /dev/null ; rm -rf ~Downloads/brunch-toolkit-workspace/ 2> /dev/null ; mkdir $DOWNLOADS/brunch-toolkit-workspace ; echo "Brunch Toolkit workspace has been cleaned." ; } || { mkdir $DOWNLOADS/brunch-toolkit-workspace ; echo "Brunch Toolkit workspace has been created." ; }
        fi
        echo ""
        echo "Please select which kind of installation you'd prefer."
        echo ""
        getdestination
    }

    getdestination(){
        select INSTALLTYPE in "Singleboot only Chrome OS" "Dualboot with another OS" Quit; do
        if [ -z "$INSTALLTYPE" ] ; then
            echo "[ERROR] Invalid option"
        elif [[ $INSTALLTYPE =~ .*"OS".* ]] ; then
            selectdst
        elif [ "$INSTALLTYPE" == "Quit" ] ; then
            cleanexit
        fi
        done
    }

    selectdst(){
        if [[ "$INSTALLTYPE" =~ .*"Single".* ]] ; then
            echo ""
            echo "+---------------------------------------------------------------+"
            echo "|                  Disks present on the device                  |"
            echo "+---------------------------------------------------------------+"
            echo ""
            lsblk -po NAME,SIZE,TYPE | grep "[sm][dm]" | grep -Ev "part" | awk '{print $1"        "$2}' | tr -s "       "
            echo ""
            echo "Please select which of these disks you would like to install to."
            echo "This will erase all contents of that disk!"
            echo "Selected disk must have at least 14GB of free space."
            echo ""
            POSSIBLEOUTS=$(lsblk -po NAME,SIZE,TYPE | grep "[sm][dm]" | grep -Ev "part" | awk '{print $1}')
        elif [[ "$INSTALLTYPE" =~ .*"Dual".* ]] ; then
            echo ""
            echo "+---------------------------------------------------------------+"
            echo "|               Partitions present on the device                |"
            echo "+---------------------------------------------------------------+"
            echo ""
            lsblk -po NAME,SIZE,TYPE | grep "[sm][dm]" | grep -Ev "disk"  | awk '{print $1"        "$2}' | tr -d "\`├─|-"
            echo ""
            echo "Please select the partition you would like to install to."
            echo "Selected partition must have at least 14GB of free space."
            echo "If you do not have a partition prepared, please make one and try again."
            echo "NTFS and EXT4 formats are supported, EXT4 is suggested."
            echo ""
            POSSIBLEOUTS=$(lsblk -po NAME,SIZE,TYPE | grep "[sm][dm]"  | grep -Ev "disk" | awk '{print $1}' | tr -d "\`├─|-")
        fi
        select DESTINATION in ${POSSIBLEOUTS} Quit; do
        if [ -z "$DESTINATION" ] ; then
           echo "[ERROR] Invalid option"
        elif [ "$DESTINATION" == "Quit" ] ; then
            cleanexit
        elif [[ "$DESTINATION" =~ .*"dev".* ]] ; then
            echo "Selected $DESTINATION"
            setdst
        else
            echo "[ERROR] Invalid option"
        fi
        done
        }

    setdst(){
    if [[ "$INSTALLTYPE" =~ .*"Single".* ]] ; then
        installercheck
    elif [[ "$INSTALLTYPE" =~ .*"Dual".* ]] ; then
        find ~/tmpmount > /dev/null || { mkdir ~/tmpmount 2> /dev/null ; echo "Mountpoint created." ; }
        sudo umount ~/tmpmount 2> /dev/null
        { sudo mount "$DESTINATION" ~/tmpmount 2> /dev/null ; echo "Destination mounted." ; } || { echo "[ERROR]  Brunch Toolkit could not mount the destination." ; echo "If destination is an NTFS partiton, please make sure any Windows installations were shut down cleanly." ; cleanexit ; }
        setsize
    fi
    }

    setsize(){
        echo ""
        echo "What size in GB would you like the dualboot img to be?"
        echo "It must be greater than 14, but smaller than the destination."
        echo ""
        SIZEP1=$(df -h "$DESTINATION" | awk 'NR==2 {print $4}')
        SIZEP2=$(lsblk -po NAME,SIZE "$DESTINATION" | grep "[sm][dm]" | grep -Ev "disk" | awk '{print $1"            "$2}')
        echo "Destination:    Total Size:    Avaliable:"
        echo "$SIZEP2            $SIZEP1"
        echo ""
        choosesize
    }

    choosesize(){
    read -rp "Please enter a number: " SIZE
    case $SIZE in
        [0-9]|1[0-3] ) echo "Entered value is too small" ; choosesize;;
   1[4-9]|[2-9][0-9] ) echo "Entered value is OK!" ; installercheck;;
     [1-9][0-9][0-9]* ) echo "Entered value is OK!" ; installercheck;;
                  * ) echo "[ERROR] Invalid option, Please enter a number greater than 14." ; choosesize;;
        esac
        cleanexit
    }

    installercheck(){
        if [ "$DEBUGCHECK" == "true" ] && [ "$LINUX" == "true" ] && [ "$WSL" == "true" ] ; then
            wsldebuginstall
        elif [ "$DEBUGCHECK" == "false" ] && [ "$LINUX" == "true" ] && [ "$WSL" == "true" ] ; then
            wsltrueinstall
        elif [ "$DEBUGCHECK" == "true" ]  && [ "$LINUX" == "true" ] && [ "$WSL" == "false" ]  ; then
            NBdebuginstall
        elif [ "$DEBUGCHECK" == "false" ]  && [ "$LINUX" == "true" ] && [ "$WSL" == "false" ]  ; then
            NBtrueinstall
        elif [ "$DEBUGCHECK" == "true" ] && [ "$LINUX" == "false" ] ; then
            debuginstall
        elif [ "$DEBUGCHECK" == "false" ] && [ "$LINUX" == "false" ] ; then
            trueinstall
        fi
        }

    trueinstall() {
        if [[ "$INSTALLTYPE" =~ .*"Single".* ]] ; then
            echo "Launching Brunch install script, please wait..."
            sudo bash $DOWNLOADS/brunch-toolkit-workspace/chromeos-install.sh -src $DOWNLOADS/$RECOVERY -dst $DESTINATION
            cleanexit
        elif [[ "$INSTALLTYPE" =~ .*"Dual".* ]] ; then
            echo "Launching Brunch install script, please wait..."
            sudo bash $DOWNLOADS/brunch-toolkit-workspace/chromeos-install.sh -src $DOWNLOADS/$RECOVERY -dst ~/tmpmount/chromeos.img -s $SIZE
            echo "Copy the boot entry from the above text and save it someplace safe!"
            echo "Please enter that boot entry into your prefered grub installation."
            cleanexit
        fi
    }

# Debug ending script. prevents accidental installs or updates while testing.
    debuginstall() {
        if [[ "$INSTALLTYPE" =~ .*"Single".* ]] ; then
            echo "Launching Brunch install script, please wait..."
            echo "sudo chromeos-install -dst $DESTINATION"
            echo "No install has happened, exiting debug mode..."
            cleanexit
        elif [[ "$INSTALLTYPE" =~ .*"Dual".* ]] ; then
            echo "Launching Brunch install script, please wait..."
            echo "sudo chromeos-install -dst ~/tmpmount/chromeos.img -s $SIZE"
            echo "Copy the boot entry from the above text and save it someplace safe"
            echo "Please enter that boot entry into your prefered grub installation."
            echo "No install has happened, exiting debug mode..."
            cleanexit
        fi
    }

    NBtrueinstall() {
        if [[ "$INSTALLTYPE" =~ .*"Single".* ]] ; then
            echo "Launching Brunch install script, please wait..."
            sudo bash $DOWNLOADS/brunch-toolkit-workspace/chromeos-install.sh -src $DOWNLOADS/$RECOVERY -dst $DESTINATION
            cleanexit
        elif [[ "$INSTALLTYPE" =~ .*"Dual".* ]] ; then
            echo "Launching Brunch install script, please wait..."
            sudo bash $DOWNLOADS/brunch-toolkit-workspace/chromeos-install.sh -src $DOWNLOADS/$RECOVERY -dst ~/tmpmount/chromeos.img -s $SIZE
            echo "Copy the boot entry from the above text and save it someplace safe"
            echo "Please enter that boot entry into your prefered grub installation."
            cleanexit
        fi
    }

# Debug ending script. prevents accidental installs or updates while testing.
    NBdebuginstall() {
        if [[ "$INSTALLTYPE" =~ .*"Single".* ]] ; then
            echo "Launching Brunch install script, please wait..."
            echo "sudo bash $DOWNLOADS/brunch-toolkit-workspace/chromeos-install.sh -src $DOWNLOADS/$CHROME -dst $DESTINATION"
            echo "No install has happened, exiting debug mode..."
            cleanexit
        elif [[ "$INSTALLTYPE" =~ .*"Dual".* ]] ; then
            echo "Launching Brunch install script, please wait..."
            echo "sudo bash $DOWNLOADS/brunch-toolkit-workspace/chromeos-install.sh -src $DOWNLOADS/$CHROME -dst ~/tmpmount/chromeos.img -s $SIZE"
            echo "Copy the boot entry from the above text and save it someplace safe"
            echo "Please enter that boot entry into your prefered grub installation."
            echo "No install has happened, exiting debug mode..."
            cleanexit
        fi
    }

    wsltrueinstall() {
            echo "Launching Brunch install script, please wait..."
            sudo bash $BOOKMARK/brunch-toolkit-workspace/chromeos-install.sh -src $BOOKMARK/$CHROME -dst $BOOKMARK/brunch-toolkit-workspace/chromeos.img
            getetcher
            cleanexit
    }

# Debug ending script. prevents accidental installs or updates while testing.
    wsldebuginstall() {
            echo "Launching Brunch install script, please wait..."
            echo "sudo bash $BOOKMARK/brunch-toolkit-workspace/chromeos-install.sh -src $BOOKMARK/$CHROME -dst $BOOKMARK/brunch-toolkit-workspace/chromeos.img"
            getetcher
            cleanexit
    }

    getetcher(){
    ETCHER=$(find $BOOKMARK/balenaEtcher*ortable*.exe 2> /dev/null | head -1 )
    ETCHERLINK=$(curl -s https://api.github.com/repos/balena-io/etcher/releases/latest | grep 'browser_' | cut -d\" -f4 | grep 'Portable')
    if [ -z "$ETCHER" ] ; then
        wget -q --show-progress $ETCHERLINK
    fi
    echo "The Etcher window should open shortly, please select your chromeos.img and your USB to write the img."
    $ETCHER
    }

#####################################################################
# DEBUG Functions
#####################################################################

# grabs and displays a changelog from the script itself (here)
    legacychangelog() {
        echo "
        Legacy Changelog:
    
        v0.1:
        Initial release
        -It updated Brunch! That was all
    
        v0.2:
        Add Brunch downloading funtions
        Add sanity checks before updating
        Overall organization improvements
    
        v0.3:
        Add DEBUG changelog function
        Add DEBUG version function
        Add DEBUG help function
        Add combined update function
        Add current OS check by DennisLfromGA
        Add code comments
        Changed script name to Brunch Toolkit
        Overall organization improvements
    
        v0.4:
        Improvements to Brunch update downloader
        - Now checks against files and current version
        - Combined download and file select functions
        Add DEBUG offline function
        - Offline mode disables download prompts and
          has slightly faster load times
        - Offline mode also has a special backup handler
          for if an update file isn't found
        Add DEBUG quick function
        - Allows the user to update without any prompts
        - Uses default mode if there are multiple files
        Set placeholders for other planned functions
        
        v0.5:
        Add DEBUG flag to prevent accidental installs while testing
        - File operations are still permitted
        Started work on Chrome OS update functions
        - Downloads are not enabled yet
        - Added file unzip
        - Cleaned up scripts
        Started work on seperate toolkit installer program
        
        v0.6
        Cleaned up code
        - Fixed typo in update function preventing updates
        - switched instances of 'ls' to 'find'
        - updated 'egrep ...' calls to 'grep -E ...'
        Added section to Version for supported recoveries by Sebanc
        
        v0.6
        Cleaned up code
        - Fixed typo in update function preventing updates
        - switched instances of 'ls' to 'find'
        - updated 'egrep ...' calls to 'grep -E ...'
        Added section to Version for supported recoveries by Sebanc
        
        v0.7
        Added DEBUG compatibility check function
        Added preliminary Linux Mode for non-brunch devices
        - currently only running the script with -k is supported

        v0.8
        Added install function. Currently only working on Brunch devices
        - The framework for linux device installs is mostly finished
        Added recovery download function.
        - Allows user to select from a list or type a board name
        - File selection now unzips bin.zip entries automatically
        Update functions and brunch install functions are considered DONE
        New TODO list: Linux & WSL compatibility.
        Added easter egg :)
        
        v0.9
        Added boot animation changing function.
        - Only works on Brunch devices.

        v1.0
        Reworked Linux and WSL compatibility
        - Script should now work fully on Brunch, most *buntu linux distros and WSL
        Some code snippets were reworked for better compatibility
        - Color text has been removed for compatibility with certain bash shells
        - Hyperlinks changed to allow CTRL + Click when linking isn't supported
        Brunch Mode now includes an installer for better toolkit access

        v1.0.1b
        Fixed bug with downloading boot_splash files
        
        v1.0.2b
        Added new DOWNLOADS variable to allow pro users to have more control
        
        v1.0.3b
        Added new feature to Version and Cros Recovery downloading in Brunch Mode
        - Now reminds user of which recovery they're currently using
        Added check for sudo and sudo su to help mitigate errors
        Added --legacychangelog (-lc) to view entire changelog
        - updated --changelog (-c) to only display most recent changes
        Added new check to boot animation changing function for previous installs
        - Now includes a method to quickly reinstall previous animations on resets
        - Added --quickbootsplash (-qb) to do this near instantly without input
        
        v1.0.4b
        Add --shell (-s) to allow adding and modifying the crosh shell tools
        - This feature is intended to work alongside an extention to modify crosh
        - Get it here: https://github.com/WesBosch/chrome-secure-shell/releases/latest
        "
        cleanexit
    }
    
    changelog(){
        echo "
        Recent Changelog
        
        v1.0.4b
        Add --shell (-s) to allow adding and modifying the crosh shell tools
        - This feature is intended to work alongside an extention to modify crosh
        - Get it here: https://github.com/WesBosch/chrome-secure-shell/releases/latest
        "
        cleanexit
    }

# Displays current Brunch, ChromeOS and Toolkit versions
    version() {
        OFFLINE=true
        setvars
        echo ""
        echo "    Toolkit version: $TOOLVER"
        getcpu
        getvirt
        getcrosver
        echo "    System: $CROSVER"
        echo "    Kernel: $KERNEL1.$KERNEL2.$KERNEL3"
        if [ "$LINUX" == "false" ] ; then
            echo "    Recovery: ${CRB^}"
        fi
        getbrunchver
        echo ""
       cleanexit
    }


    getvirt() {
        VIRT=$(grep -Ewo 'vmx|svm|hypervisor' /proc/cpuinfo  | sort | uniq | sed -e 's/svm/    AMD-V Virtualization supported/g' -e 's/vmx/    Intel Virtualization supported/g' -e 's/hypervisor/    Hypervisor detected/g')
        if [ -z "$VIRT" ]; then
            echo "    Virtualization is not avaliable or not detected"
        else
            echo "$VIRT"
        fi
    }

# Determine if user is running ChromeOS or another system and display relevant information.
# Might expand on this later for future plans
    getcrosver() {
        source /etc/os-release 2>/dev/null
        if [ -z "$GOOGLE_CRASH_ID" ]; then
            CROSVER=$"$ID $VERSION $BUILD_ID"
        else
            CROSVER=$"$GOOGLE_CRASH_ID $VERSION $BUILD_ID"
        fi
        }

# Determine if user is running Brunch or another system.
    getbrunchver() {
        if [ -z "$RELEASE" ]; then
        echo "    This script tastes better with Brunch!"
        else
        echo "    Framework Version: $RELEASE"
        fi
    }

# Displays just a user's CPU, quietly fails if the option returns nothing
    getcpu() {
        if [ -z "$CPUTYPE" ]; then
        :
        else
        echo "    CPU: $CPUTYPE"
        fi
    }

# Displays a help menu with useful debug commands for the user
    help() {
    if [ "$LINUX" == "false" ] ; then
        echo "
    Avaliable Brunch Mode Debug Commands:

    --bootsplash (-b)
        Skips the main menu and starts the boot animation changer.

    --brunch (-br)
        Skips the main menu and starts the Brunch update function.

    --changelog (-c)
        Displays a changlog for the last several updates of this script

    --chrome (-cr)
        Skips the main menu and starts the Chrome & Brunch update function.

    --compatibility (-k)
        Displays helpful info about CPU compatibility.
        This option should work on most linux distros.

    --debug (-d)
        Tests the script without allowing updates or installs.

    --help (-h)
        Displays this page.
        Run the program without command line arguments for normal usage.
        
    --legacychangelog (-lc)
        Displays the entire changlog of this script.

    --install (-n)
        Skips the main menu and starts the Brunch install function.

    --offline (-o)
        Disables all internet functions of the tooklit.
        It will not prompt for an internet connection at all.
        Useful if you know you don't need to download anything.

    --quick (-q)
        This is an experimental quick update process.
        Only use this if you know what you're doing!
        The toolkit will update Brunch WITHOUT prompts using the
        brunch file in $DOWNLOADS. (~/Downloads by default, it will only look for one)
        If the latest release does not match the file it auto-downloads it.
        If there are no brunch files it auto-downloads the latest.
        If there are multiple files it will exit quick mode.
        This is only meant to be used with one update file present.
    
    --quickbootsplash (-qb)
        Checks for a previously installed boot animation, and resets the current one.
        This is useful for when an update returns the animation to the default.
    
    --quickignore (-qi)
        Same as --quick but ignores the current version check,
        allows users to update into the release they are already on.


    --shell (-s)
        Allows the user to install and modify crosh shell tools for brunch.
        
    --version (-v)
        Displays useful system information including:
        The version of the toolkit you're using
        The kernel used by your system
        Which version of Chrome OS you're on
        Which version of Brunch you're on
        Which recoveries are supported or recomended


    Usage Notes:

        This toolkit looks for files in the $DOWNLOADS directory. (~/Downloads by default)
        It does expect files to have the default filenames!
        Brunch files must start with brunch and have a tar.gz extention.
        Chrome revoveries must start with chromeos and have a .bin extention.
        Downloading files will fail if the file exists already or if offline.


    Additional assistance for this toolkit can be found at:
    "
  elif [ "$LINUX" == "true" ] ; then
  echo "
    Avaliable Linux Mode Debug Commands:

    --changelog (-c)
        Displays a changlog for the last several updates of this script

    --compatibility (-k)
        Displays helpful info about CPU compatibility.
        This option should work on most linux distros.

    --debug (-d)
        Tests the script without allowing updates or installs.

    --help (-h)
        Displays this page.
        Run the program without command line arguments for normal usage.

    --legacychangelog (-lc)
        Displays the entire changlog of this script.
        
    --install (-n)
        Skips the main menu and starts the Brunch install function.

    --offline (-o)
        Disables all internet functions of the tooklit.
        It will not prompt for an internet connection at all.
        Useful if you know you don't need to download anything.

    --version (-v)
        Displays useful system information including:
        The version of the toolkit you're using
        The kernel used by your system
        Which version of Chrome OS you're on
        Which version of Brunch you're on
        Which recoveries are supported or recomended


    Usage Notes:

        This toolkit looks for files in the $DOWNLOADS directory. (~/Downloads by default)
        It does expect files to have the default filenames!
        Brunch files must start with brunch and have a tar.gz extention.
        Chrome revoveries must start with chromeos and have a .bin extention.
        Downloading files will fail if the file exists already or if offline.


    Additional assistance for this toolkit can be found at:
"
    fi
    printf '        \e]8;;https://github.com/WesBosch/Brunch-Updater\e\\ https://github.com/WesBosch/Brunch-Updater \e]8;;\e\\\n'
        echo ""
        echo "    Additional assistance for Brunch can be found at:
    "
    printf '        \e]8;;https://github.com/sebanc/brunch\e\\ https://github.com/sebanc/brunch \e]8;;\e\\\n'
    echo ""
    cleanexit
    }

# Define function to determine brunch compatibility & suggested recoveries
# Ideally this entire code can be safely incorperated into other scripts
    compatibilitycheck(){
        echo ""
        echo "+---------------------------------------------------------------+"
        echo "|          Starting compatibility check, please wait...         |"
        echo "+---------------------------------------------------------------+"
        echo ""
        CPUTYPE=$(cat /proc/cpuinfo | grep "model name" | head -1 | awk -F '[:]' '{print $2}')
        echo "CPU:$CPUTYPE"
        if [[ ! "$CPUTYPE" =~ .*"AMD".* ]] && [[ ! "$CPUTYPE" =~ .*"Intel".* ]]   ; then
             echo "[X] Brunch may not be compatible with this CPU."
             echo "This toolkit is unable to determine what recovery your processor should use."
             echo "This could be a bug. Please refer to the wiki page to determine compatibility for yourself."
             echo ""
             printf '\e]8;;https://github.com/sebanc/brunch/wiki/CPUs-&-Recoveries\e\\> Get More Info <\e]8;;\e\\\n'
        elif [[ "$CPUTYPE" =~ .*"AMD".* ]] ; then
            amdcpu
        elif [[ "$CPUTYPE" =~ .*"Intel".* ]] ; then
            intelcpu
        else
            echo "[ERROR] An unexpected error has occurred."
            echo "$CPUTYPE"
            echo "$AMDTYPE"
            echo "Please report these results."
            cat /proc/cpuinfo >> $DOWNLOADS/toolkit-log.txt
            echo "CPU info should be found in $DOWNLOADS/toolkit.log"
        fi
        echo ""
        echo "Check complete!"
        cleanexit
    }

    amdcpu(){
        AMDTYPE=$(cat /proc/cpuinfo | grep "[a|e][0-9]-9" | head -1 | awk -F '[:]' '{print $2}')
        if [[ "$CPUTYPE" =~ .*"$AMDTYPE".* ]] ; then
            echo "[!] Brunch may be compatible with this CPU!"
            echo "AMD support is limited, Grunt is recommended."
            SUGGESTED="grunt"
            STONEYRIDGE=true
            asktoinstall
        elif [[ -z "$AMDTYPE" ]] ; then
            echo "[X] Brunch may not be compatible with this CPU."
            echo "AMD support is limited to Stoney Ridge processors, Grunt is recommended."
            echo "Please look up your processor and use your best judgement."
            SUGGESTED="grunt"
            STONEYRIDGE=false
            asktoinstall
        else
            SUGGESTED="unknown"
        fi
        CPUTYPE=
        AMDTYPE=
        cleanexit
    }

    intelcpu(){
        NEWCPU=$(grep -Ewo 'movbe|avx|vaes' /proc/cpuinfo  | sort | uniq | sed -e 's/movbe/Rammus is recommended./g' -e 's/avx/Eve, Nami, and Hatch are supported./g' -e 's/vaes/This CPU may require a special build to boot!/g')
        OLDCPU=$(grep -Ewo 'sse4_2' /proc/cpuinfo  | sort | uniq | sed -e 's/sse4_2/Samus is recommended./g')
        if [ -z "$OLDCPU" ] ; then
            echo "[X] Brunch may not be compatible with this CPU.\e[0m"
            echo "This computer's CPU does not have the instructions required to run Brunch."
            SUGGESTED="unknown"
            if [ "$DONTASK" == false ] ; then
            asktoinstall
            fi
        elif [ -n "$OLDCPU" ] && [ -z "$NEWCPU" ] ; then
            echo "Brunch is compatible with this CPU!"
            echo "$OLDCPU"
            SUGGESTED="samus"
            asktoinstall
        elif [ -n "$NEWCPU" ] ; then
            echo "Brunch is compatible with this CPU!"
            echo "$NEWCPU"
            SUGGESTED="rammus"
            if [[ "$NEWCPU" =~ .*"supported".* ]] ; then
            SECONDCHOICE=true
            fi
            if [[ "$NEWCPU" =~ .*"special".* ]] ; then
            SPECIALBUILD=true
            fi
            asktoinstall
        else
            echo "[X] Something seems to have gone wrong, your support could not be determined."
            echo "If you're seeing this error, please contact Wisteria on the Brunch Discord Server."
            echo ""
            printf '\e]8;;https://discord.gg/x2EgK2M\e\\> Join Brunch Discord <\e]8;;\e\\\n'
            echo ""
            OLDCPU=
            NEWCPU=
            CPUTYPE=
        echo "Getting toolkit ready, please wait..."
            SUGGESTED="unknown"
            asktoinstall
        fi
        echo ""
        echo "Check complete!"
        OLDCPU=
        NEWCPU=
        CPUTYPE=
        cleanexit
    }

    asktoinstall(){
        echo "Check complete!"
        echo ""
        echo "Would you like to install Brunch to this device? (y/n)"
        echo ""
        installchoice
     }

     installchoice(){
            read -rp " >> " yn
            case $yn in
                [Yy]* ) mfinstall; return;;
                [Nn]* ) cleanexit;;
                    * ) echo "[ERROR] Invalid option, Please type yes or no.";;
            esac
    }

     quietcompatibilitycheck(){
        CPUTYPE=$(cat /proc/cpuinfo | grep "model name" | head -1 | awk -F '[:]' '{print $2}')
        if [[ ! "$CPUTYPE" =~ .*"AMD".* ]] && [[ ! "$CPUTYPE" =~ .*"Intel".* ]]   ; then
            SUGGESTED="unknown"
        elif [[ "$CPUTYPE" =~ .*"AMD".* ]] ; then
            quietamdcpu
        elif [[ "$CPUTYPE" =~ .*"Intel".* ]] ; then
            quietintelcpu
        else
            SUGGESTED="unknown"
        fi
    }

    quietamdcpu(){
        AMDTYPE=$(cat /proc/cpuinfo | grep "[a|e][0-9]-9" | head -1 | awk -F '[:]' '{print $2}')
        if [[ "$CPUTYPE" =~ .*"$AMDTYPE".* ]] ; then
            SUGGESTED="grunt"
            STONEYRIDGE=true
        elif [[ -z "$AMDTYPE" ]] ; then
            SUGGESTED="grunt"
            STONEYRIDGE=false
        else
            SUGGESTED="unknown"
        fi
    }

    quietintelcpu(){
        NEWCPU=$(grep -Ewo 'movbe|avx|vaes' /proc/cpuinfo  | sort | uniq | sed -e 's/movbe/Rammus is recommended./g' -e 's/avx/Eve, Nami, and Hatch are supported./g' -e 's/vaes/This CPU may require a special build to boot!/g')
        OLDCPU=$(grep -Ewo 'sse4_2' /proc/cpuinfo  | sort | uniq | sed -e 's/sse4_2/Samus is recommended./g')
        if [ -z "$OLDCPU" ] ; then
            SUGGESTED="unknown"
        elif [ -n "$OLDCPU" ] && [ -z "$NEWCPU" ] ; then
            SUGGESTED="samus"
        elif [ -n "$NEWCPU" ] ; then
            SUGGESTED="rammus"
            if [[ "$NEWCPU" =~ .*"supported".* ]] ; then
            SECONDCHOICE=true
            fi
            if [[ "$NEWCPU" =~ .*"special".* ]] ; then
            SPECIALBUILD=true
            fi
        else
            SUGGESTED="unknown"
        fi
    }
    
# Setup /usr/local/bin/brioche-tools with a variety of commands for accesibility
    brunchshellsetup(){
        if [[ -z "$FINDSHELL" ]] ; then
        touch $DOWNLOADS/shell-tools.btst
        echo "[!] Shell tools not found, please wait..."
        SHELLFOUND="false"
        elif [[ -n "$FINDSHELL" ]] ; then
        cp /usr/local/bin/brunch-toolkit-assets/shell-tools.btst $DOWNLOADS/shell-tools.btst 2> /dev/null
        SHELLFOUND="true"
        fi
        echo ""
        if [ "$SHELLFOUND" == "true" ] ; then 
        CURRENTTOOLS=$(cat /usr/local/bin/brunch-toolkit-assets/shell-tools.btst | sed 's/,/\n/g')
        TOOLSVAR=$(cat /usr/local/bin/brunch-toolkit-assets/shell-tools.btst)
        echo "Your current shell tools are:"
        echo "$CURRENTTOOLS"
        echo ""
        echo "What would you like to do?"
        echo ""
        select SHELLOPT in "Uninstall shell tools" "Add another tool" "Remove a tool" Quit; do
        if [[ $SHELLOPT =~ .*"Uninstall".* ]]; then
            uninstallshelltools
        elif [[ $SHELLOPT =~ .*"Add".* ]]; then
            addshelltools
        elif [[ $SHELLOPT =~ .*"Remove".* ]]; then
            echo ""
            echo "Choose which tool to remove."
            echo ""
            removeshelltools
        elif [ "$SHELLOPT" == "Quit" ] ; then
            cleanexit
        else
            echo "[ERROR] Invalid option"
        fi
        done
        elif [ "$SHELLFOUND" == "false" ] ; then 
            echo "The default shell tools are:"
            echo "$SHELLTOOLS"  | sed 's/,/\n/g'
        CURRENTTOOLS=$(echo "$SHELLTOOLS"  | sed 's/,/\n/g')
        TOOLSVAR="$SHELLTOOLS"
        echo ""
        echo "What would you like to do?"
        echo ""
        select SHELLOPT in "Install shell tools" "Add another tool" "Remove a tool" Quit; do
        if [[ $SHELLOPT =~ .*"Install".* ]]; then
            installshelltools
        elif [[ $SHELLOPT =~ .*"Add".* ]]; then
            addshelltools
        elif [[ $SHELLOPT =~ .*"Remove".* ]]; then
            removeshelltools
        elif [ "$SHELLOPT" == "Quit" ] ; then
            rm -f $DOWNLOADS/shell-tools.btst
            cleanexit
        else
            echo "[ERROR] Invalid option"
        fi
        done
        fi
    }
    
    addshelltools(){
    echo ""
    echo "You can add your own commands here for easy access to scripts or chroots"
    echo "These commands must be one line and can not include commas (,)"
    echo "Type the whole command and press enter, you can remove it later."
    echo "(You do not need to include a trailing comma, this is added automatically)"
    echo ""
    addshelltoolssub
    }
    
    addshelltoolssub(){
    echo "Current tools:"
    echo "$TOOLSVAR"
    echo ""
    read -rp "Please enter a command to add: " ADOPT
    case $ADOPT in
        * ) shelltooladdition;;
        esac
    }

    shelltooladdition(){
    TOOLSVAR="$TOOLSVAR$ADOPT,"
    ADOPT=
    CURRENTTOOLS=$(echo "$TOOLSVAR"  | sed 's/,/\n/g')
    echo ""
    echo "Current tools:"
    echo "$TOOLSVAR"
    echo "Add another?"
    echo ""
    select ANOPT in "Add more tools" "Remove a tool" "Install these tools" Quit; do
        if [[ -z "$ANOPT" ]]; then
            echo "[ERROR] Invalid option"
        elif [[ $ANOPT == "Add more tools" ]]; then
            addshelltoolssub
        elif [[ $ANOPT == "Remove a tool" ]]; then
            removeshelltools
        elif [[ $ANOPT == "Install these tools" ]]; then
            installshelltools
        elif [ "$ANOPT" == "Quit" ] ; then
            rm -f $DOWNLOADS/shell-tools.btst
            cleanexit
        else
            shelltoolremoval
        fi
        done
    }

    removeshelltools(){
        echo ""
        echo "Choose which tool to remove."
        echo "You can add them back later."
        echo ""
        echo "Current tools:"
        echo "$TOOLSVAR"
        echo ""
        IFS=$'\n' ; select RMOPT in ${CURRENTTOOLS} "Add a tool" "Install these tools" Quit; do
        if [[ -z "$RMOPT" ]]; then
            echo "[ERROR] Invalid option"
        elif [[ $RMOPT == "Add a tool" ]]; then
            addshelltools
        elif [[ $RMOPT == "Install these tools" ]]; then
            installshelltools
        elif [ "$RMOPT" == "Quit" ] ; then
            rm -f $DOWNLOADS/shell-tools.btst
            cleanexit
        else
            shelltoolremoval
        fi
        done
    }
    
    shelltoolremoval(){
        TOOLSVAR=${TOOLSVAR//$RMOPT,/}
        CURRENTTOOLS=$(echo "$TOOLSVAR"  | sed 's/,/\n/g')
        removeshelltools
    }
        
    
    installshelltools(){
        echo "$TOOLSVAR" > $DOWNLOADS/shell-tools.btst
        mv -f $DOWNLOADS/shell-tools.btst /usr/local/bin/brunch-toolkit-assets/shell-tools.btst
        if [ "$SHELLFOUND" = "true" ] ; then 
            echo "Shell tools have been updated!"
        else
            echo "Shell tools have been installed!"
        fi
        cleanexit
    }
    
    uninstallshelltools(){
        echo ""
        rm -f $DOWNLOADS/shell-tools.btst
        rm -f /usr/local/bin/brunch-toolkit-assets/shell-tools.btst
        echo "Shell tools have been uninstalled!"
        cleanexit
    }

# DEBUG option handler. Silently proceeds to set variables if no options are present.
    debug() {
        echo "Getting toolkit ready, please wait..."
        if [ "$LINUX" == "true" ] ; then
          linuxdebug
        fi
        if [ "$OPTS" == "--help" ] || [ "$OPTS" == "-h" ]; then
            help
        elif [ "$OPTS" == "--version" ] || [ "$OPTS" == "-v" ]; then
            version
        elif [ "$OPTS" == "--changelog" ] || [ "$OPTS" == "-c" ]; then
            changelog
        elif [ "$OPTS" == "--legacychangelog" ] || [ "$OPTS" == "-lc" ]; then
            legacychangelog
        elif [ "$OPTS" == "--compatibility" ] || [ "$OPTS" == "-k" ]; then
            OFFLINE=true
            compatibilitycheck
        elif [ "$OPTS" == "--offline" ] || [ "$OPTS" == "-o" ]; then
            echo "[!] Running in offline mode."
            OFFLINE=true
            setvars
        elif [ "$OPTS" == "--brunch" ] || [ "$OPTS" == "-br" ]; then
            setvars
            mfbrunch
        elif [ "$OPTS" == "--bootsplash" ] || [ "$OPTS" == "-b" ]; then
            setvars
            mfbootanim
        elif [ "$OPTS" == "--quickbootsplash" ] || [ "$OPTS" == "-qb" ]; then
            PREVIOUSSET=$(cd /usr/local/bin/brunch-toolkit-assets/ && ls *.btbs 2> /dev/null | sed -e s/.btbs//)
            resetanim
        elif [ "$OPTS" == "--chrome" ] || [ "$OPTS" == "-cr" ]; then
            setvars
            mfchrome
        elif [ "$OPTS" == "--install" ] || [ "$OPTS" == "-n" ]; then
            setvars
            mfinstall
        elif [ "$OPTS" == "--quick" ] || [ "$OPTS" == "-q" ]; then
            quickupdate
        elif [ "$OPTS" == "--quickignore" ] || [ "$OPTS" == "-i" ]; then
            IGNORECHECK=true
            quickupdate
        elif [ "$OPTS" == "--debug" ] || [ "$OPTS" == "-d" ]; then
            DEBUGCHECK=true
            setvars
        elif [ "$OPTS" == "--shell" ] || [ "$OPTS" == "-s" ]; then
            OFFLINE=true
            setvars
            brunchshellsetup
        elif [ "$OPTS" == "" ]; then
            setvars
        elif [ "$OPTS" != "" ] ; then
            validop "$OPTS"  && "$OPTS" || echo "[ERROR] Not a valid function"
            cleanexit
        else
        :
        fi
        main
    }

    linuxdebug() {
        if [ "$OPTS" == "--help" ] || [ "$OPTS" == "-h" ]; then
            help
        elif [ "$OPTS" == "--version" ] || [ "$OPTS" == "-v" ]; then
            version
        elif [ "$OPTS" == "--changelog" ] || [ "$OPTS" == "-c" ]; then
            changelog
        elif [ "$OPTS" == "--legacychangelog" ] || [ "$OPTS" == "-lc" ]; then
            legacychangelog
        elif [ "$OPTS" == "--compatibility" ] || [ "$OPTS" == "-k" ]; then
            OFFLINE=true
            compatibilitycheck
        elif [ "$OPTS" == "--offline" ] || [ "$OPTS" == "-o" ]; then
            echo "[!] Running in offline mode."
            OFFLINE=true
            setvars
        elif [ "$OPTS" == "--install" ] || [ "$OPTS" == "-n" ]; then
            setvars
            mfinstall
        elif [ "$OPTS" == "--debug" ] || [ "$OPTS" == "-d" ]; then
            DEBUGCHECK=true
            setvars
        elif [ "$OPTS" == "" ]; then
            setvars
        elif [ "$OPTS" != "" ] ; then
            validop "$OPTS"  && "$OPTS" || echo "[ERROR] Not a valid function"
            cleanexit
        else
        :
        fi
        main
    }

# Checks non-specified options to see if they are possible functions
    validop() {
        declare -F -- "$OPTS" >/dev/null;
        }

# Checks for an internet connection and disables unnecessary options when no connection is present
    webtest() {
        if [ $OFFLINE = false ]; then
            case "$(curl -s --max-time 2 -I http://google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
                [23]) echo "Toolkit Online";;
                5) echo "[!] Check your firewall settings, running in offline mode."; OFFLINE=true;;
                *) echo "[!] The network is down or very slow, running in offline mode."; OFFLINE=true;;
            esac
        else
        :
        fi
}


#####################################################################
# Script Execution
#####################################################################

# Looks for OS first, then calls the main script
checkcurrentos
