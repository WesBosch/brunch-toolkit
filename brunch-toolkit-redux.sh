#!/bin/bash

#+===============================================================+
#|  Default Variables                                            |
#|  Most of these dont need changed or control major functions   |
#+===============================================================+

# Environmental variables
PS3=" >> "

# Toolkit uses the ~/Downloads location unless a global variable specifies otherwise
if [ -z $DOWNLOADS ] ; then
    downloads="$HOME/Downloads"
else
    downloads="$DOWNLOADS"
fi

# LANG='en' # revisit this later for possible multilingual options

# These variables never need to change in the script. Preserve some old vars for backwards compatibility
readonly toolkitversion="v2.0.0b"  #TOOLVER
readonly TOOLVER="$toolkitversion"
readonly quickstart="$1" #OPTS
readonly OPTS="$quickstart"
readonly defaultshelltools='brunch-toolkit,brunch-toolkit --quickbootsplash,brunch-toolkit --shell,'
readonly discordinvite="https://discord.gg/x2EgK2M"
readonly userid=`id -u $USERNAME`
# Incorrect formatting is intentional here
PS3="
 >> "

# All currently known framework options. Update this list as necessary (any order)
readonly defaultframeworkoptions=(acpi_power_button alt_touchpad_config alt_touchpad_config2 android_init_fix baytrail_chromebook enable_updates force_tablet_mode internal_mic_fix mount_internal_drives broadcom_wl iwlwifi_backport rtl8188eu rtl8723bu rtl8723de rtl8812au rtl8821ce rtl88x2bu rtbth ipts oled_display disable_intel_hda asus_c302 sysfs_tablet_mode suspend_s3 advanced_als)
# All currently known descriptions. Mind string length
readonly fwodesc=(
"Patches in better support for Power Button hardware"
"Alternative configuration to fix touchpad issues"
"Alternative configuration to fix touchpad issues"
"Alternative init for Android services, may fail"
"Applies audio fixes specific to Baytrail devices"
"Enables native ChromeOS updating from the settings"
"Enables tablet mode on boot using sysfs control"
"Patches to force mic to work on some devices"
"Mounts internal drives at boot, visible in files app"
"Patches in support for some Broadcom wireless cards"
"Patches in support for some Intel wireless cards"
"Patches in support for rtl8188eu wireless cards"
"Patches in support for rtl8723bu wireless cards"
"Patches in support for rtl8723de wireless cards"
"Patches in support for rtl8812au wireless cards"
"Patches in support for rtl8821ce wireless cards"
"Patches in support for rtl88x2bu wireless cards"
"Patches in support for rt3290 & rt3298le bluetooth"
"Patches in support for Surface touchscreens"
"Patches in support for oled display in Kernel 5.10"
"Blacklists the snd_hda_intel module"
"Applies fixes specific to Asus c302 devices"
"Allows users to force tablet mode from the shell (See github)"
"Disables suspend to idle (S0ix) and uses S3 instead"
"Enables more auto-brightness levels on supported hardware"
)
# Currently avaliable kernels
readonly avaliablekernels=(kernel-4.19 kernel-5.4 kernel-5.10)
# Some of the most common Chome OS recoveries for a user to choose from (ordered A->Z)
readonly defaultrecoveries="eve grunt hatch lulu nami rammus samus zork" #RECOVERYOPTIONS
# All currently known Chrome OS recoveries. Update this list as necessary (any order)
readonly allrecoveries="alex asuka atlas banjo banon big blaze bob buddy butterfly candy caroline cave celes chell clapper coral cyan daisy drallion edgar elm enguarde eve expresso falco-li fievel fizz gandof glimmer gnawty grunt guado hana hatch heli jacuzzi jaq jerry kalista kefka kevin kip kitty kukui lars leon link lulu lumpy mario mccloud mickey mighty minnie monroe nami nautilus ninja nocturne octopus orco paine panther parrot peppy pi pit pyro quawks rammus reef reks relm rikku samus sand sarien scarlet sentry setzer skate snappy soraka speedy spring squawks stout stumpy sumo swanky terra tidus tiger tricky ultima winky wizpig wolf yuna zako zgb zork" #VALIDRECOVERIES
# Currently avaliable Brunch Bootsplash OPTIONS
readonly bbsopts="blank default default_notext croissant croissant_notext neon neon_notext colorful colorful_dark brunchbook"

# These variables are expected to have a "false" state unless otherwise set
onlineallowed=true
notifyonline=
ignoreversioncheck=false
debugmode=false
notifydebug=
prestartcomplete=false
installing=false
includechrome=false

# https://unix.stackexchange.com/questions/146570/arrow-key-enter-menu/415155#415155
# Renders a text based list of options that can be selected by the
# user using up, down and enter keys and returns the chosen option.
#
#   Arguments   : list of options, maximum of 256
#                 "opt1" "opt2" ...
#   Return value: selected index (0 for opt1, 1 for opt2 ...)
function select_option {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m" ; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;     fi
                         if [[ $key = $ESC[B ]]; then echo down;   fi
                         if [[ $key = ""     ]]; then echo enter;  fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

function select_opt {
    select_option "$@" 1>&2
    local result=$?
    echo $result
    return $result
}


#+===============================================================+
#|  Vanity plates                                                 |
#|  Display something pretty when a user opens a menu             |
#+===============================================================+
# ASCII Art provided by  http://patorjk.com/software/taag

# all vanity calls pass through here and are rerouted to the correct plates
vanity(){
# Divider for easily reading through debug logs
echo "
█████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████
"
clear
if [ -n "$widget" ] ; then
$widget
widget=
fi
displayvanity
}

# This section intentionally breaks formatting for a specific look
displayvanity(){
    if [ "$plate" == "startup" ] ; then
echo "
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
█╔═════════════════════════════════════════════════════════════╗█
█║    ___                  _      _____         _ _   _ _      ║█
█║   | _ )_ _ _  _ _ _  __| |_   |_   _|__  ___| | |_(_) |_    ║█
█║   | _ \ '_| || | ' \/ _|  _ \   | |/ _ \/ _ \ | / / |  _|   ║█
█║   |___/_|  \_,_|_||_\__|_||_|   |_|\___/\___/_|_\_\_|\__|   ║█
█║  _________________________________________________________  ║█
█║                                                             ║█
█║   Need help? Found a bug?                                   ║█
█║   Find me in the Brunch Discord!               --Wisteria   ║█
█║                                                             ║█
█║              >> $discordinvite <<               ║█
█║                                                             ║█
█╚═════════════════════════════════════════════════════════════╝█
█┌─────────────────────────────────────────────────────────────┐█
█│   Tip: Hold the Ctrl key while clicking links to open them! │█
█│Debug Key: [o] Ok! [!] Notice! [x] Warning! [ERROR] Critical!│█
█└─────────────────────────────────────────────────────────────┘█
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Loading toolkit $toolkitversion...
"
    elif [ "$plate" == "bootsplash" ] ; then
cat << "EOF"

╔═══════════════════════════════════════════════════════════════╗
║              _        _            _   _                      ║
║             /_\  _ _ (_)_ __  __ _| |_(_)___ _ _              ║
║            / _ \| ' \| | '  \/ _` |  _| / _ \ ' \             ║
║           /_/_\_\_||_|_|_|_|_\__,_|\__|_\___/_||_|            ║
║                  ___       _   _                              ║
║                 / _ \ _ __| |_(_)___ _ _  ___                 ║
║                | (_) | '_ \  _| / _ \ ' \(_-<                 ║
║                 \___/| .__/\__|_\___/_||_/__/                 ║
║                      |_|                                      ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

EOF

elif [ "$plate" == "toolkitoptions" ] ; then
cat << "EOF"

╔═══════════════════════════════════════════════════════════════╗
║                   _____         _ _   _ _                     ║
║                  |_   _|__  ___| | |_(_) |_                   ║
║                    | |/ _ \/ _ \ | / / |  _|                  ║
║                    |_|\___/\___/_|_\_\_|\__|                  ║
║                   ___       _   _                             ║
║                  / _ \ _ __| |_(_)___ _ _  ___                ║
║                 | (_) | '_ \  _| / _ \ ' \(_-<                ║
║                  \___/| .__/\__|_\___/_||_/__/                ║
║                       |_|                                     ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo "
[o] Current toolkit version:   $toolkitversion"
if [ "$toolkitversion" == "$latesttoolkit" ] && [ "$onlineallowed" == "true" ] ; then
    echo "[!] You're using the latest version of the Brunch Toolkit!"
elif [ "$toolkitversion" != "$latesttoolkit" ] && [ "$onlineallowed" == "true" ] ; then
    echo "[!] Latest toolkit version:    $latesttoolkit"
fi
echo "
┌───────────────────────────────────────────────────────────────┐
│                   ~ Toolkit Options Menu ~                    │
│                                                               │
│        Update the toolkit or install for easy access          │
│                                                               │
│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
       Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
"
elif [ "$plate" == "editgrubconfig" ] ; then
cat << "EOF"

╔═══════════════════════════════════════════════════════════════╗
║                       ___          _                          ║
║                      / __|_ _ _  _| |__                       ║
║                     | (_ | '_| || | '_ \                      ║
║                      \___|_|  \_,_|_.__/                      ║
║                  ___       _   _                              ║
║                 / _ \ _ __| |_(_)___ _ _  ___                 ║
║                | (_) | '_ \  _| / _ \ ' \(_-<                 ║
║                 \___/| .__/\__|_\___/_||_/__/                 ║
║                      |_|                                      ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

EOF
elif [ "$plate" == "kerneloptions" ] ; then
echo "
┌───────────────────────────────────────────────────────────────┐
│                   ~ Kernel Options Menu ~                     │
│                                                               │
│     Users can change the kernel Brunch uses to boot here      │
│                                                               │
│  WARNING! Changing kernels can prevent users from logging in  │
│  to their ChromeOS account, in which case a powerwash is the  │
│  only solution (CTRL + ALT + SHIFT + R at the login screen).  │
│                                                               │
│            Before switching to a different kernel,            │
│         make sure there is a backup of all user data!         │
│                                                               │
│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
       Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
"
elif [ "$plate" == "bbsmain" ] ; then
echo "
┌───────────────────────────────────────────────────────────────┐
│                 ~ Brunch Bootsplash Menu ~                    │
│                                                               │
│    These options allow users to change what Brunch displays   │
│     on boot. This is a seperate splashscreen from the one     │
│    from the one ChromeOS uses. To edit that, please see the   │
│        ChromeOS Boot Animation tool from the main menu.       │
│                                                               │
│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
       Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
"
else
echo "$plate"
fi
}

#+===============================================================+
#|  Startup Functions                                            |
#|  Functions that happen before the main menu loads             |
#+===============================================================+

# Perform a series of checks while starting up the toolkit before giving control to user
prestart(){
    plate="startup" ; vanity
    checkforroot
    checkforsystemtype
    if [ "$scriptmode" == "brunch" ] ; then
    checkfordualboot
    fi
    checkforquickstartoptions
    startmenu
}

checkfordualboot(){
    source=$(rootdev -d)
    if (expr match "$source" ".*[0-9]$" >/dev/null); then
        partsource="$source"p
    else
        partsource="$source"
    fi
    if [[ "$source" =~ .*"loop".* ]] ; then
      dualboot="true"
    else
      dualboot="false"
    fi
}


# Toolkit behaves badly if ran as root, check to avoid that
checkforroot(){
    if [ $userid -eq 0 ] ; then
        exitcode="1"
        cleanexit
    fi
}

# Checks the user's system for keywords and adjusts the functions of the script accordingly
checkforsystemtype(){
    currentrelease=$(cat /etc/brunch_version 2>/dev/null)
    if [ -z "$currentrelease" ] && [[ $(grep icrosoft /proc/version 2> /dev/null) ]] && [[ -f "/etc/arch-release" ]] ; then
        echo "[o] Launching in Arch Mode for Windows WSL.
[!] Windows WSL Mode support is limited!
    This script will use your current directory.
    Please be sure to cd into the directory where this script
    is located or some functions may fail."
        scriptmode="archwsl"
    elif [ -z "$currentrelease" ] && [[ $(grep icrosoft /proc/version 2> /dev/null) ]] ; then
        echo "[o] Launching in Linux Mode for Windows WSL.
[!] Windows WSL Mode support is limited!
    This script will use your current directory.
    Please be sure to cd into the directory where this script
    is located or some functions may fail."
        scriptmode="wsl"
    elif [ -z "$currentrelease" ] && [[ -f "/etc/arch-release" ]] ; then
        echo "[o] Launching in Arch Mode."
        scriptmode="arch"
    elif [ -z "$currentrelease" ] && [[ -z $(grep icrosoft /proc/version 2> /dev/null) ]] ; then
        echo "[o] Launching in Linux Mode."
        scriptmode="linux"
    else
        echo "[o] Launching in Brunch Mode."
        scriptmode="brunch"
    fi
}

# AIO function to set all necessary variables up from the start. Add to this function as necessary
setvars() {
    # Check to see if this has been done before, skips entirely if it has.
    if [ "$prestartcomplete" == "false" ] ; then
        prestartcomplete=true
        checkonlinestatus
    if [ "$debugmode" == "true" ] ; then
        echo "[!] DEBUG Mode enabled!"
    fi
    # Save a user's current working directory no matter where this script is called from
        previousdir=$(pwd)
    # Get the brunch version in two formats for readability
        currentbrunchversion=$(awk '{print $3}' 2> /dev/null < /etc/brunch_version)
        if [ -z "$currentbrunchversion" ] ; then
        currentbrunchversion=false
        else
        chromeosreleaseboard=$(printenv | grep CHROMEOS_RELEASE_BOARD | cut -d"=" -f2 | cut -d"-" -f1)
        # Check the bootsplash status, only look if using brunch (Dont use anymore!)
        #currentlyset=$(cd /usr/share/chromeos-assets/images_100_percent/ && ls *.btbs 2> /dev/null | sed -e s/.btbs//)
        #previouslyset=$(cd /usr/local/bin/brunch-toolkit-assets/ && ls *.btbs 2> /dev/null | sed -e s/.btbs//)
        fi
    # Get kernel info and line it up
        kernel1=$(uname -r 2>/dev/null | awk -F'[_.]' '{print $1}')
        kernel2=$(uname -r 2>/dev/null | awk -F'[_.]' '{print $2}')
        kernel3=$(uname -r 2>/dev/null | awk -F'[_.]' '{print $3}' | cut -c1-3)
        #kernelnumber="$kernel1.$kernel2.$kernel3"
        kernelnumber="$kernel1.$kernel2"
        cputype=$(cat /proc/cpuinfo | grep "model name" | head -1 | awk -F '[:]' '{print $2}')
    # Set the working directory to simplify downloads and processes, ignore failure in wsl
        if [ "$previousdir" != $downloads ] && [ "$scriptmode" != "wsl" ] ; then
            cd $downloads 2> /dev/null || { exitcode="3" ; cleanexit ; }
        elif [ "$previousdir" != $downloads ] && [ "$scriptmode" == "wsl" ] ; then
            :
        fi
    # Get height and width of the user's screen for setting boot animation SIZE
        width=$(dmesg | grep -i drm_get_panel | tail -1 | cut -d" " -f8 | sed "s#width=##g")
        height=$(dmesg | grep -i drm_get_panel | tail -1 | cut -d" " -f9 | sed "s#height=##g")
    # Find and count all expected files
        IFS=$'\n'
        shelltools=$(ls /usr/local/bin/brunch-toolkit-assets/shell-tools.btst 2> /dev/null)
        brunchfiles=($(find *runch_r*tar.gz 2> /dev/null | sort -r))
        brunchfiles+=("Help" "Back" "Quit")
        onebrunchfile=$(find *runch_r*.tar.gz 2> /dev/null | sort -r | wc -l)
        otherarchives=($(find *.tar.gz 2> /dev/null | sort -r))
        otherarchives+=("Help" "Back" "Quit")
        chromerecoveries=($(find *hrome*.bin* 2> /dev/null | sort -r))
        chromerecoveries+=("Help" "Back" "Quit")
        bootsplashzip=($(find -maxdepth 1 -type f \( -iname \boot_splash*.zip -o -iname \*.gif -o -iname \*.png \) 2> /dev/null | sort -r | cut -c3- ))
        bootsplashurl="https://github.com/WesBosch/brunch-bootsplash/releases/download/"
        if [ "$onlineallowed" == "false" ] ; then
    # remake array without github option if it's OFFLINE
        bootsplashzip+=("Help" "Back" "Quit")
        else
        bootsplashzip+=("Download from github" "Help" "Back" "Quit")
        fi
    # Get some online data, skip this if running in offline mode
        if [[ $onlineallowed == true ]] ; then
            onlinebootsplashzip=($(curl -s https://api.github.com/repos/WesBosch/brunch-bootsplash/releases | grep 'name' | cut -d\" -f4 | grep 'zip' | sed -e s/.zip//))
            onlinebootsplashzip+=("Help" "Back" "Quit")
            latestbrunch=$(curl -s "https://api.github.com/repos/sebanc/brunch/releases/latest" | grep 'name' | cut -d\" -f4 | grep 'tar.gz' )
            #latestbrunchversion=$(curl -s "https://api.github.com/repos/sebanc/brunch/releases/latest" | grep 'name' | cut -d\" -f4 | grep 'tar.gz' | cut -d'_' -f4 | cut -d'.' -f1)
            latesttoolkit=$(curl -s https://api.github.com/repos/WesBosch/brunch-toolkit/releases/latest | grep 'name' | cut -d\" -f4 | grep '.sh' | cut -d'-' -f3 | sed -e s/.sh// )
            latesttoolkiturl=$(curl -s https://api.github.com/repos/WesBosch/brunch-toolkit/releases/latest | grep 'browser_' | cut -d\" -f4 | grep '.sh')
            lbuv0=$(curl -s "https://api.github.com/repos/sebanc/brunch-unstable/releases/latest" | grep 'name' | cut -d\" -f4 | grep 'tar.gz')
            # Strip all of the unnecessary bits off, integers only
            lbuv1=${lbuv0/stable_}
            lbuv2=${lbuv1/unstable_}
            lbuv3=${lbuv2/testing_}
            latestbrunchunstableversion=$(echo "$lbuv3" | cut -d'_' -f3 | cut -d'.' -f1)
            lbv0=$(curl -s "https://api.github.com/repos/sebanc/brunch/releases/latest" | grep 'name' | cut -d\" -f4 | grep 'tar.gz')
            # Strip all of the unnecessary bits off, integers only
            lbv1=${lbuv0/stable_}
            lbv2=${lbuv1/unstable_}
            lbv3=${lbuv2/testing_}
            latestbrunchversion=$(echo "$lbuv3" | cut -d'_' -f3 | cut -d'.' -f1)
        fi
        unset IFS
        if [ "$scriptmode" != "brunch" ] ; then
            getdependencies
        fi
        echo "[o] All necessary components loaded."
        fi
}

# Linux systems may need certain dependencies. Use this to get them. Arch support is untested
getdependencies(){
    echo "[!] Checking for dependencies, please wait..."
    if [ "$scriptmode" == "linux" ] || [ "$scriptmode" == "wsl" ] ; then
        dependencysearch
        sudo apt-get update >> /dev/null
        sudo apt-get -y install $neededprograms
    elif [ "$scriptmode" == "arch" ] || [ "$scriptmode" == "archwsl" ] ; then
      clear
      echo "
┌───────────────────────────────────────────────────────────────┐
│                   ~ Arch Linux Detected ~                     │
│                                                               │
│     This script requires the following packages to work:      │
│            pv unzip tar and vboot-utils (for cgpt)            │
│                                                               │
│    Currently this script is not able to automate this step,   │
│    Please make sure you have everything before continuing!    │
│                                                               │
│                  Are you ready to continue?                   │
└───────────────────────────────────────────────────────────────┘
            Please type Yes or No (y/n) to continue."

      read -rp " >> " yn
      case $yn in
          [Yy]* ) echo "[o] Continuing to main menu..." ;;
          [Nn]* ) exitcode="16"; cleanexit;;
      esac
    fi
    }
# If I ever figure out arch support, this is all I have so far
#        sudo sudo pacman -Syu
#        sudo pacman -S pv unzip tar vboot-utils

lookforprogram(){
    if command -v "$program" 2>/dev/null ; then
    :
    else
    neededprograms="$neededprograms $program"
    fi
    }

dependencysearch(){
    program="pv"
    lookforprogram
    program="cgpt"
    lookforprogram
    program="unzip"
    lookforprogram
    program="tar"
    lookforprogram
    }


# Checks for an internet connection and disables unnecessary options when no connection is present
checkonlinestatus() {
    if [[ $onlineallowed == true ]] ; then
        case "$(curl -s --max-time 2 -I http://google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
            [23]) echo "[o] Toolkit Online, internet features enabled.";;
               5) notifyonline="
│    Check your firewall settings, running in Offline Mode.     │"; onlineallowed=false;;
               *) notifyonline="
│  The network is down or very slow, running in Offline Mode.   │"; onlineallowed=false;;
        esac
    else
        echo "[!] Running in Offline Mode."
        fi
}

# Quickstart option handler. Silently proceeds to set variables if no options are present.
# Add new quickstart options here as necessary
checkforquickstartoptions() {
    echo "[o] Getting toolkit ready, please wait..."
    if [ "$quickstart" == "" ]; then
        setvars
    elif [ "$quickstart" == "--help" ] || [ "$quickstart" == "-h" ]; then
        displayhelp
    elif [ "$quickstart" == "--version" ] || [ "$quickstart" == "-v" ]; then
        displayversion
    elif [ "$quickstart" == "--changelog" ] || [ "$quickstart" == "-c" ]; then
        displaychangelog
    elif [ "$quickstart" == "--legacychangelog" ] || [ "$quickstart" == "-lc" ]; then
        displaylegacychangelog
    elif [ "$quickstart" == "--compatibility" ] || [ "$quickstart" == "-k" ]; then
        onlineallowed=false
        compatibilitycheckmain
    elif [ "$quickstart" == "--offline" ] || [ "$quickstart" == "-o" ]; then
        echo "[!] Running in offline mode."
        onlineallowed=false
        setvars
    elif [ "$quickstart" == "--debug" ] || [ "$quickstart" == "-d" ]; then
        debugmode=true
        setvars
    elif [ "$quickstart" == "--install" ] || [ "$quickstart" == "-n" ]; then
        setvars
        installbrunchmain
# Brunch Mode exclusive Quick Start options.
    elif [ "$quickstart" == "--brunch" ] || [ "$quickstart" == "-br" ]; then
        brunchexclusive
        setvars
        updatebrunchmain
    elif [ "$quickstart" == "--bootsplash" ] || [ "$quickstart" == "-b" ]; then
        brunchexclusive
        setvars
        updatebootsplashmain
    elif [ "$quickstart" == "--quickbootsplash" ] || [ "$quickstart" == "-qb" ]; then
        brunchexclusive
        previousbootsplash=$(cd /usr/local/bin/brunch-toolkit-assets/ && ls *.btbs 2> /dev/null | sed -e s/.btbs//)
        resetbootsplashmain
    elif [ "$quickstart" == "--chrome" ] || [ "$quickstart" == "-cr" ]; then
        brunchexclusive
        setvars
        updatebrunchandchrome
    elif [ "$quickstart" == "--quick" ] || [ "$quickstart" == "-q" ]; then
        brunchexclusive
        quickupdatebrunchmain
    elif [ "$quickstart" == "--quickignore" ] || [ "$quickstart" == "-i" ]; then
        brunchexclusive
        ignoreversioncheck=true
        quickupdatebrunchandignore
    elif [ "$quickstart" == "--shell" ] || [ "$quickstart" == "-s" ]; then
        brunchexclusive
        echo "[!] Running in offline mode."
        onlineallowed=false
        setvars
        brunchshellsetupmain
    elif [ "$quickstart" == "--grub" ] || [ "$quickstart" == "-g" ]; then
        brunchexclusive
        echo "[!] Running in offline mode."
        onlineallowed=false
        setvars
        editgrubconfigmain
    elif [ "$quickstart" == "--updatetoolkit" ] || [ "$quickstart" == "-u" ]; then
        brunchexclusive
        setvars
        updateandinstalltoolkit
    elif [ "$quickstart" == "--pwa-auto-update" ] || [ "$quickstart" == "-pwa-au" ]; then
            pwa-autoupdate
    elif [ "$quickstart" == "--pwa-unstable-update" ] || [ "$quickstart" == "-pwa-uu" ]; then
            pwa-autoupdate
    else
        validop "$quickstart"  && "$quickstart" || exitcode="3"
        cleanexit
    fi
}

# Checks to be sure the user is running brunch, exits if not
brunchexclusive(){
    if [ "$scriptmode" != "brunch" ] ; then
        exitcode="4"
        cleanexit
    fi
}

# Checks non-specified options to see if they are possible functions
validop() {
    declare -F -- "$quickstart" >/dev/null;
}

#+===============================================================+
#|  Main Menu functions                                          |
#|  Functions that display and control the menu                  |
#+===============================================================+

# Display notifications above the main menu if there are any
notifications(){
  notifytoolkit=""
  notifybrunch=""
  notifychromeos=""
  notifybootsplash=""
# Check if toolkit is outdated
currentsemversion=$(echo "$toolkitversion" | sed -e "s/^v//" -e "s/b$//")
csvint1=$(echo "$currentsemversion" | cut -d'.' -f1)
csvint2=$(echo "$currentsemversion" | cut -d'.' -f2)
csvint3=$(echo "$currentsemversion" | cut -d'.' -f3)
latestsemversion=$(echo "$latesttoolkit" | sed -e "s/^v//" -e "s/b$//")
lsvint1=$(echo "$latestsemversion" | cut -d'.' -f1)
lsvint2=$(echo "$latestsemversion" | cut -d'.' -f2)
lsvint3=$(echo "$latestsemversion" | cut -d'.' -f3)
if [ -z "$latesttoolkit" ] ; then
:
elif (( "$csvint1" < "$lsvint1" )) ; then
  notifytoolkit="
│  The current version of the Brunch Toolkit may be outdated!   │"
elif [ "$csvint1" == "$lsvint1" ] && (( "$csvint2" < "$lsvint2" )) ; then
  notifytoolkit="
│  The current version of the Brunch Toolkit may be outdated!   │"
elif [ "$csvint1" == "$lsvint1" ] && [ "$csvint2" == "$lsvint2" ] && (( "$csvint3" < "$lsvint3" )) ; then
  notifytoolkit="
│  The current version of the Brunch Toolkit may be outdated!   │"
else
  : # Toolkit version is greater or equal in all aspects, don't notify
fi
# Check if Brunch is outdated
if [ -z "$latestbrunchversion" ] ; then
:
elif [ "$currentbrunchver" != "false" ] && (( "$currentbrunchversion" < "$latestbrunchversion" )) ; then
notifybrunch="
│         There's a new Brunch Stable release!        │"
fi
if [ -z "$latestbrunchversion" ] ; then
:
elif [ "$currentbrunchver" != "false" ] && (( "$currentbrunchversion" < "$latestbrunchunstableversion" )) ; then
notifybrunch="
│        There's a new Brunch Unstable release!       │"
fi
# Check if ChromeOS is outdated

# Check if Bootsplash needs fixed
#if [ -n "$previouslyset" ] && [ -z "$currentlyset" ] ; then
#animneedsset="true"
#notifybootsplash="
#│  The boot animation may have been reset by a system update!   │"
#fi
# Check if github's API limit has been reached or if Github is down
if [[ $onlineallowed == true ]] && [ -z "$latesttoolkit" ] || [[ $onlineallowed == true ]] && [ -z "$latestbrunchversion" ] ; then
notifygithub="
│     The toolkit is online, but Github cannot be reached!      │"
onlineallowed="false"
fi
# If any notifications are avaliable, display them
if [ -n "$notifytoolkit" ] || [ -n "$notifybrunch" ] || [ -n "$notifychromeos" ] || [ -n "$notifybootsplash" ] || [ -n "$notifygithub" ] || [ -n "$notifyonline" ] ; then
printf "\n│\033[7m░░░░░░░░░░░░░░░░░░░░░░░░ Notifications ░░░░░░░░░░░░░░░░░░░░░░░░\033[27m│\n"
echo "│                                                               │$notifytoolkit$notifybrunch$notifychromeos$notifybootsplash$notifygithub$notifyonline
│                                                               │
└───────────────────────────────────────────────────────────────┘"
fi
}

# Actual main menu functions
startmenu(){
widget="notifications"
plate="
┌───────────────────────────────────────────────────────────────┐
│                         ~ Main Menu ~                         │
│                                                               │
│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
       Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
" ; vanity
# Context aware menu Options, these are for aesthetics only, the functions themselves will handle the context
#if [ "$animneedsset" == "true" ] ; then
#  bootanimationmenu="Fix ChromeOS Boot Animation"
#else
#  bootanimationmenu="Change ChromeOS Boot Animation"
#fi
if [ "$scriptmode" != "brunch" ] ; then
#    startmenuopts=("Install Brunch" "Compatibility Check" "Changelog" "System Specs" "Help" "Quit")
    startmenuopts=("Help" "Quit")
elif [ "$dualboot" == "false" ] ; then
#    startmenuopts=("Update Brunch" "Update Chrome OS & Brunch" "Install Brunch" "Compatibility Check" "$bootanimationmenu" "Install/Update Toolkit" "Shell Shortcuts" "Grub Options" "Changelog" "System Specs" "Help" "Quit")
    startmenuopts=("Grub Options" "Help" "Quit")
elif [ "$dualboot" == "true" ] ; then
#    startmenuopts=("Update Brunch" "Update Chrome OS & Brunch" "Install Brunch" "Compatibility Check" "$bootanimationmenu" "Install/Update Toolkit" "Shell Shortcuts" "Changelog" "System Specs" "Help" "Quit")
    startmenuopts=("Update Brunch" "Update Chrome OS & Brunch" "Install Brunch" "Compatibility Check" "$bootanimationmenu" "Install/Update Toolkit" "Shell Shortcuts" "Changelog" "System Specs" "Help" "Quit")
fi
    case `select_opt "${startmenuopts[@]}"` in
        *) mainmenuchoice="${startmenuopts[$?]}" ;;
    esac
if [[ -n "$mainmenuchoice" ]] ; then
    echo "[o] User selected: $mainmenuchoice"
fi
if [[ -z "$mainmenuchoice" ]] ; then
    echo "[x] Invalid option"
elif [[ "$mainmenuchoice" == "Update Brunch" ]] ; then
    updatebrunchmain
elif [[ "$mainmenuchoice" == "Update ChromeOS & Brunch" ]] ; then
    updatebrunchandchrome
elif [[ "$mainmenuchoice" == "Install Brunch" ]] ; then
    installbrunchmain
elif [[ "$mainmenuchoice" == "Compatibility Check" ]] ; then
    compatibilitycheckmain
elif [[ "$mainmenuchoice" == "Changelog" ]] ; then
    displaychangelog
elif [[ "$mainmenuchoice" == "System Specs" ]] ; then
    displayversion
elif [[ "$mainmenuchoice" == "Help" ]] ; then
    startmenuhelp
elif [[ "$mainmenuchoice" == "Change ChromeOS Boot Animation" ]] || [[ "$mainmenuchoice" == "Fix ChromeOS Boot Animation" ]] ; then
    updatebootsplashmain
elif [[ "$mainmenuchoice" == "Install/Update Toolkit" ]] ; then
    toolkitoptionsmain
elif [[ "$mainmenuchoice" == "Shell Shortcuts" ]] ; then
    brunchshellsetupmain
elif [[ "$mainmenuchoice" == "Grub Options" ]] ; then
    editgrubconfigmain
elif [[ "$mainmenuchoice" == "Quit" ]] ; then
    cleanexit
else
    :
fi
}

startmenuhelp(){
previousmenu="startmenu"
if [[ "$scriptmode" == "brunch" ]] ; then
helpentry="
┌───────────────────────────────────────────────────────────────┐
│                                                               |
│                         Main Menu Help                        │
│                                                               │
│   This is the main menu, from here users can access most of   │
│   the toolkit. Here's what all of the main menu options do:   │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│   Update Brunch                                               │
│       Allows Brunch users to update their Brunch framework    │
│       with the toolkit. It can download the files for you.    │
│                                                               │
│   Update Chrome OS & Brunch                                   │
│       Allows Brunch users to update their Brunch framework    │
│       and Chrome OS version together at the same time.        │
│                                                               │
│   Install Brunch                                              │
│       Walks the user through most of the Brunch installation  │
│       process. Then it will help select a disk or partition   │
│       and filesize if necessary, then install to the selected │
│       destination.                                            │
│                                                               │
│   Compatibility Check                                         │
│       The toolkit will check the user's system and tell them  │
│       if their CPU is compatible, and which recovery file(s)  │
│       they should use to install Brunch. This does NOT check  │
│       for graphics card compatibility, so keep that in mind!  │
│                                                               │
│   Change/Fix ChromeOS Boot Animation                          │
│       Allows Brunch users to modify their boot animations.    │
│       The script will also allow them to download one from    │
│       a repo if they don't have any prepared. There is an     │
│       option to restore boot animations lost after updating.  │
│                                                               │
│   Install/Update Toolkit                                      │
│       Allows Brunch users to install this toolkit for easier  │
│       access. The toolkit can also be updated from this menu. │
│                                                               │
│   Shell Options                                               │
│       This is a menu for advanced users. It will allow users  │
│       to add and remove options from the toolbar if they use  │
│       the chrome-secure-shell extention modified for Brunch.  │
│                                                               │
│   Framework Options                                           │
│       This is a menu for advanced users. It will allow users  │
│       to add and remove Brunch framework options directly     │
│       through the user's grub. Does NOT work in Dualboot!     │
│                                                               │
│   Changelog                                                   │
│       Displays a recent changelog for the toolkit.            │
│                                                               │
│   System Specs                                                │
│       Displays some info about the user's system.             │
│                                                               │
│   Help                                                        │
│       Displays relevant help information about the current    │
│       options available to the user at that time. It is not   │
│       always the same page, so check it when help is needed!  │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│     Tip: Use Shift + Up (↑) or Shift + Down (↓) to scroll!    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
"
else
helpentry="
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│                         Main Menu Help                        │
│                                                               │
│   This is the main menu, from here users can access most of   │
│   the toolkit. Here's what all of the main menu options do:   │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│   Install Brunch                                              │
│       Walks the user through most of the Brunch installation  │
│       process. It will help them select a Brunch release and  │
│       a Chrome OS recovery. Then it will help select a disk   │
│       or partition and filesize if necessary, then install to │
│       the destination they selected.                          │
│                                                               │
│   Compatibility Check                                         │
│       The toolkit will check the user's system and tell them  │
│       if their CPU is compatible, and which recovery file(s)  │
│       they should use to install Brunch. This does NOT check  │
│       for graphics card compatibility, so keep that in mind!  │
│                                                               │
│   Changelog                                                   │
│       Displays a recent changelog for the toolkit.            │
│                                                               │
│   System Specs                                                │
│       Displays some info about the user's system.             │
│                                                               │
│   Help                                                        │
│       Displays relevant help information about the current    │
│       options available to the user at that time. It is not   │
│       always the same page, so check it when help is needed!  │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│     Tip: Use Shift + Up (↑) or Shift + Down (↓) to scroll!    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
"
fi
helpmenu
}

#+===============================================================+
#|  Update Brunch Functions                                      |
#|  Everything related to the Brunch update function goes here   |
#+===============================================================+



#+===============================================================+
#|  Install Brunch Functions                                     |
#|  Everything related to the Brunch install function goes here  |
#+===============================================================+



#+===============================================================+
#|  Compatibility Check Functions                                |
#|  Everything related to the compatibility checker goes here    |
#+===============================================================+

universalversioncheck(){
    if [[ "$currentbrunchversion" < "$neededversion" ]] ; then
        uvc="false"
    else
        uvc="true"
    fi
}


#+===============================================================+
#|  Install and Update Toolkit Functions                         |
#|  Everything related to upgrading the toolkit goes here        |
#+===============================================================+

toolkitoptionsmain(){
    plate="toolkitoptions" ; vanity
    checktoolkitver
}

checktoolkitver(){
    if [ "$onlineallowed" == "false" ] ; then
        toolkitchoiceoffline
    else
        toolkitchoice
    fi
}

toolkitchoice(){
    select toolkitopts in "Install Brunch Toolkit $toolkitversion" "Update to Brunch Toolkit $latesttoolkit" "Update & Install $latesttoolkit" Help Quit; do
    if [[ -z "$toolkitopts" ]] ; then
       echo "[x] Invalid option"
    elif [[ $toolkitopts == "Install Brunch Toolkit $toolkitversion" ]] ; then
        tbinstall
    elif [[ $toolkitopts == "Update to Brunch Toolkit $latesttoolkit" ]] ; then
        tbupdate
    elif [[ $toolkitopts == "Update & Install $latesttoolkit" ]] ; then
        updateandinstalltoolkit
    elif [[ $toolkitopts == "Help" ]] ; then
        toolkitchoicehelp
    elif [[ $toolkitopts == "Quit" ]] ; then
        cleanexit
    else
    :
    fi
    done
    cleanexit
}

toolkitchoiceoffline(){
    select toolkitopts in "Install Brunch Toolkit $toolkitversion" Help Quit; do
    if [[ -z "$toolkitopts" ]] ; then
       echo "[Ex] Invalid option"
    elif [[ $toolkitopts == "Install Brunch Toolkit $toolkitversion" ]] ; then
        tbinstall
    elif [[ $toolkitopts == "Help" ]] ; then
        toolkitchoiceofflinehelp
    elif [[ $toolkitopts == "Quit" ]] ; then
        cleanexit
    else
    :
    fi
    done
    cleanexit
}

tbinstall(){
    mv -f $downloads/brunch-toolkit-$toolkitversion.sh /usr/local/bin/brunch-toolkit || { exitcode="10" ; cleanexit ; }
    chmod +x /usr/local/bin/brunch-toolkit || { exitcode="11" ; cleanexit ; }
    mkdir /usr/local/bin/brunch-toolkit-assets || { exitcode="12" ; cleanexit ; }
    echo -e "[o] Brunch Toolkit has been installed!
    To use the installed version just type 'brunch-toolkit' without quotes,
    it should look something like this:


    \e[01;32mchronos@localhost \e[01;34m/ $ \e[0mbrunch-toolkit


[!] Note that the installed version does not require '.sh' at the end."
    cleanexit
}

tbupdate(){
    echo "[o] Downloading latest Brunch Toolkit, please wait..."
    curl -l -O --progress-bar "$latesttoolkiturl"
    echo "[o] Downloaded successfully!"
}

updateandinstalltoolkit(){
    tbupdate
    toolkitversion=$latesttoolkit
    tbinstall
}

#+===============================================================+
#|  Shell Options                                                |
#|  Everything related to the shell extention goes here          |
#+===============================================================+

brunchshellsetupmain(){
    plate="brunchshellsetup" ; vanity
    brunchshellsetup
}

brunchshellsetup(){
        if [[ -z "$shelltools" ]] ; then
        touch $downloads/shell-tools.btst
        echo "[!] Shell shortcuts not found, please wait..."
        shellfound="false"
        elif [[ -n "$shelltools" ]] ; then
        cp /usr/local/bin/brunch-toolkit-assets/shell-tools.btst $downloads/shell-tools.btst 2> /dev/null
        shellfound="true"
        fi
        echo ""
        if [ "$shellfound" == "true" ] ; then
        currenttools=$(cat /usr/local/bin/brunch-toolkit-assets/shell-tools.btst | sed 's/,/\n/g')
        toolsvar=$(cat /usr/local/bin/brunch-toolkit-assets/shell-tools.btst)
        echo "Your current shell shortcuts are:"
        echo "$currenttools"
        echo ""
        echo "What would you like to do?"
        echo ""
        select shellopt in "Uninstall shell shortcuts" "Add another  shortcut" "Remove a  shortcut" Quit; do
        if [[ $shellopt =~ .*"Uninstall".* ]]; then
            uninstallshelltools
        elif [[ $shellopt =~ .*"Add".* ]]; then
            addshelltools
        elif [[ $shellopt =~ .*"Remove".* ]]; then
            echo ""
            echo "Choose which shortcut to remove."
            echo ""
            removeshelltools
        elif [ "$shellopt" == "Quit" ] ; then
            cleanexit
        else
            echo "[x] Invalid option"
        fi
        done
        elif [ "$shellfound" == "false" ] ; then
            echo "The default shell shortcuts are:"
            echo "$shelltools"  | sed 's/,/\n/g'
        currenttools=$(echo "$shelltools"  | sed 's/,/\n/g')
        toolsvar="$shelltools"
        echo ""
        echo "What would you like to do?"
        echo ""
        select shellopt in "Install shell shortcuts" "Add another shortcut" "Remove a shortcut" Quit; do
        if [[ $shellopt =~ .*"Install".* ]]; then
            installshelltools
        elif [[ $shellopt =~ .*"Add".* ]]; then
            addshelltools
        elif [[ $shellopt =~ .*"Remove".* ]]; then
            removeshelltools
        elif [ "$shellopt" == "Quit" ] ; then
            rm -f $downloads/shell-tools.btst
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
    echo "Current shortcuts:"
    echo "$toolsvar"
    echo ""
    read -rp "Please enter a command to add: " adopt
    case $adopt in
        * ) shelltooladdition;;
        esac
    }

    shelltooladdition(){
    toolsvar="$toolsvar$adopt,"
    adopt=
    currenttools=$(echo "$toolsvar"  | sed 's/,/\n/g')
    echo ""
    echo "Current shortcuts:"
    echo "$toolsvar"
    echo "Add another?"
    echo ""
    select anopt in "Add more shortcuts" "Remove a shortcut" "Install these shortcuts" Quit; do
        if [[ -z "$anopt" ]]; then
            echo "[ERROR] Invalid option"
        elif [[ $anopt == "Add more shortcuts" ]]; then
            addshelltoolssub
        elif [[ $anopt == "Remove a shortcut" ]]; then
            removeshelltools
        elif [[ $anopt == "Install these shortcuts" ]]; then
            installshelltools
        elif [ "$anopt" == "Quit" ] ; then
            rm -f $downloads/shell-tools.btst
            cleanexit
        else
            shelltoolremoval
        fi
        done
    }

    removeshelltools(){
        echo ""
        echo "Choose which shortcut to remove."
        echo "You can add them back later."
        echo ""
        echo "Current shortcuts:"
        echo "$toolsvar"
        echo ""
        IFS=$'\n' ; select rmopt in ${currenttools} "Add a shortcut" "Install these shortcuts" Quit; do
        if [[ -z "$rmopt" ]]; then
            echo "[ERROR] Invalid option"
        elif [[ $rmopt == "Add a shortcut" ]]; then
            addshelltools
        elif [[ $rmopt == "Install these shortcuts" ]]; then
            installshelltools
        elif [ "$rmopt" == "Quit" ] ; then
            rm -f $downloads/shell-tools.btst
            cleanexit
        else
            shelltoolremoval
        fi
        done
    }

    shelltoolremoval(){
        toolsvar=${toolsvar//$rmopt,/}
        currenttools=$(echo "$toolsvar"  | sed 's/,/\n/g')
        removeshelltools
    }


    installshelltools(){
        echo "$toolsvar" > $downloads/shell-tools.btst
        mv -f $downloads/shell-tools.btst /usr/local/bin/brunch-toolkit-assets/shell-tools.btst
        if [ "$shellfound" = "true" ] ; then
            echo "[o] Shell shortcuts have been updated!"
        else
            echo "[o] Shell shortcuts have been installed!"
        fi
        cleanexit
    }

    uninstallshelltools(){
        echo ""
        rm -f $downloads/shell-tools.btst
        rm -f /usr/local/bin/brunch-toolkit-assets/shell-tools.btst
        echo "[!] Shell shortcuts have been uninstalled!"
        cleanexit
    }



#+===============================================================+
#|  grub options                                                 |
#|  Everything related to grub goes here                         |
#+===============================================================+

editgrubconfigmain(){
    plate="editgrubconfig" ; vanity
    grubstartup
    mountgrub
    gruboptions
    unmountgrub
    grubmain
}

grubstartup(){
    echo "[o] Checking install configuration, please wait..."
    if [ "$dualboot" == "true" ] ; then
    clear
    echo "
┌───────────────────────────────────────────────────────────────┐
│             ~ Dualboot installation Detected ~                │
│                                                               │
│      This tool is not compatible with the dualboot img.       │
│    You will need to edit grub manually from your other OS.    │
│                                                               │
│                   Return to the main menu?                    │
└───────────────────────────────────────────────────────────────┘
"
    read -rp "(y/n): " yn
    case $yn in
        [Yy]* ) echo "[o] Returning to main menu..." ; startmenu;;
        [Nn]* ) exitcode="17"; cleanexit;;
    esac
    else
        echo "[o] Singleboot installation detected."
    fi
}

mountgrub(){
    sudo mkdir -p /root/tmpgrub || { exitcode="13" ; cleanexit ; }
    echo "[o] Mounting partition12, please wait..."
    sudo mount "$partsource"12 /root/tmpgrub || { exitcode="14" ; cleanexit ; }
    echo "[o] Partition mounted successfully."
    grubmounted="true"
}

unmountgrub(){
    if [ "$grubmounted" == "true" ] ; then
    echo "[!] Unmounting partition12, please wait..."
    sudo umount /root/tmpgrub || { grubmounted="false" ; exitcode="15" ; cleanexit ; }
    echo "[o] Unmounted successfully."
    grubmounted="false"
    fi
}

gruboptions(){
    findoptions=$(cat /root/tmpgrub/efi/boot/grub.cfg | grep "options=")
    originalfwoopts=$(cat /root/tmpgrub/efi/boot/grub.cfg | grep -m 1 "options=" | sed "s/.*options=//g" | cut -d' ' -f1 | sed "s/,/ /g")
    fwoopts=$(cat /root/tmpgrub/efi/boot/grub.cfg | grep -m 1 "options=" | sed "s/.*options=//g" | cut -d' ' -f1 | sed "s/,/ /g")
    originalkernelopts=$(cat /root/tmpgrub/efi/boot/grub.cfg | grep -m 1 "kernel" | sed "s/.*kernel/kernel/g" | cut -d' ' -f1)
    kerneloptions=$(cat /root/tmpgrub/efi/boot/grub.cfg | grep -m 1 "kernel" | sed "s/.*kernel/kernel/g" | cut -d' ' -f1)
    findbootsplash=$(cat /root/tmpgrub/efi/boot/grub.cfg | grep "brunch_bootsplash=")
    originalbbsopts=$(cat /root/tmpgrub/efi/boot/grub.cfg | grep -m 1 "brunch_bootsplash=" | sed "s/.*brunch_bootsplash=//g" | cut -d' ' -f1)
    bbsoptions=$(cat /root/tmpgrub/efi/boot/grub.cfg | grep -m 1 "brunch_bootsplash=" | sed "s/.*brunch_bootsplash=//g" | cut -d' ' -f1)
    findchromeanim=$(cat /root/tmpgrub/efi/boot/grub.cfg | grep "chromeos_bootsplash=")
    originalchromeanim=$(cat /root/tmpgrub/efi/boot/grub.cfg | grep -m 1 "chromeos_bootsplash=" | sed "s/.*chromeos_bootsplash=//g" | cut -d' ' -f1)
    userchromeanim=$(cat /root/tmpgrub/efi/boot/grub.cfg | grep -m 1 "chromeos_bootsplash=" | sed "s/.*chromeos_bootsplash=//g" | cut -d' ' -f1)
    cbaopts=$(ls /mnt/stateful_partition/unencrypted/bootsplash/)
}

grubmain(){
    clear
    plate="
┌───────────────────────────────────────────────────────────────┐
│                     ~ Grub Options Menu ~                     │
│                                                               │
│       This menu allows users to modify their grub entry.      │
│      Misuse of the tools here can result in a non-booting     │
│      system, please be responsible & keep backups of data.    │
│                                                               │
│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
       Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
" ; vanity
    previousmenu="startmenu"
    grubmenuopts=("Framework Options" "Kernels" "Brunch Bootsplash" "ChromeOS Boot Animation" "Edit Grub Manually" "Help" "Back" "Quit")
    case `select_opt "${grubmenuopts[@]}"` in
        *) grubmenuoptions="${grubmenuopts[$?]}" ;;
    esac
    if [[ -n "$grubmenuoptions" ]] ; then
        echo "[o] User selected: $grubmenuoptions"
    fi
    if [ "$grubmenuoptions" == "Back" ] ; then
        $previousmenu
    elif [ "$grubmenuoptions" == "Quit" ] ; then
        cleanexit
    elif [ "$grubmenuoptions" == "Help" ] ; then
        grubmenuhelp
    elif [ "$grubmenuoptions" == "Framework Options" ] ; then
        fwosub
    elif [ "$grubmenuoptions" == "Kernels" ] ; then
        kernelsub
    elif [ "$grubmenuoptions" == "Brunch Bootsplash" ] ; then
        bbssub
    elif [ "$grubmenuoptions" == "ChromeOS Boot Animation" ] ; then
        cbasub
    elif [ "$grubmenuoptions" == "Edit Grub Manually" ] ; then
        sudo edit-grub-config
        editgrubconfigmain
    else
        echo "[x] Invalid option"
    fi
}

CBAwidget(){
if [ -n "$userchromeanim" ] ; then
currentcba1=$(echo "Currently set boot animation:" | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
currentcba2=$(echo "$userchromeanim" | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
printf "\n│\033[7m░░░░░░░░░░░░░░░░░░░░░ Boot Animation Info ░░░░░░░░░░░░░░░░░░░░░\033[27m│\n"
echo "│                                                               │
|$currentcba1|
|$currentcba2|"
echo "│                                                               │
└───────────────────────────────────────────────────────────────┘"
fi
}

cbasub(){
      clear
      widget="CBAwidget"
      plate="
┌───────────────────────────────────────────────────────────────┐
│               ~ ChromeOS Boot Animation Menu ~                │
│                                                               │
│   Quickly install or swap between installed boot animations   │
│                                                               │
│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
       Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
  " ; vanity
      previousmenu="grubmain"
      cbamenuoptions=(${cbaopts[@]})
      cbamenuoptions+=("default" "Install New Animation" "Remove an Animation" "Help" "Back" "Quit")
      case `select_opt "${cbamenuoptions[@]}"` in
          *) cbamenuoptions="${cbamenuoptions[$?]}" ;;
      esac
      if [[ -n "$cbamenuoptions" ]] ; then
          echo "[o] User selected: $cbamenuoptions"
      fi
      if [ "$cbamenuoptions" == "Back" ] ; then
          $previousmenu
      elif [ "$cbamenuoptions" == "Quit" ] ; then
          cleanexit
      elif [ "$cbamenuoptions" == "Help" ] ; then
          cbamenuhelp
      elif [ "$cbamenuoptions" == "Install New Animation" ] ; then
          cbainstaller
      elif [ "$cbamenuoptions" == "Remove an Animation" ] ; then
          cbaremover
      else
          grubaction="changecba"
          previousmenu="cbasub"
          savegrub
      fi
}

changecba(){
      if [[ -z "$findchromeanim" ]] ; then
        echo "chromeos_bootsplash not found, adding manually!"
        sudo sed -i "s/cros_debug/cros_debug chromeos_bootsplash=$cbamenuoptions/" /root/tmpgrub/efi/boot/grub.cfg
      else
        sudo sed -i "s/chromeos_bootsplash=$userchromeanim/chromeos_bootsplash=$cbamenuoptions/" /root/tmpgrub/efi/boot/grub.cfg
      fi
      cbaopts=$(ls /mnt/stateful_partition/unencrypted/bootsplash/)
      sudo rm -rf /usr/share/chromeos-assets/images_100_percent
      sudo rm -rf /usr/share/chromeos-assets/images_200_percent
}

cbaremover(){
  clear
  previousmenu="cbasub"
  widget="CBAwidget"
  plate="
┌───────────────────────────────────────────────────────────────┐
│            ~ ChromeOS Boot Animation Remover Menu ~           │
│                                                               │
│             Easily remove unwanted boot animations            │
│                                                               │
│          Please select one of the following to remove         │
└───────────────────────────────────────────────────────────────┘
      Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
  " ; vanity
  cbaremoptions=(${cbaopts[@]})
  cbaremoptions+=("Help" "Back" "Quit")
  case `select_opt "${cbaremoptions[@]}"` in
      *) cbaremchoice=${cbaremoptions[$?]} ; echo "[o] User selected: $cbaremchoice";;
  esac
  if [ "$cbaremchoice" == "Help" ] ; then
      previousmenu="cbaremover"
      cbaremhelp
  elif [ "$cbaremchoice" == "Back" ] ; then
      $previousmenu
  elif [ "$cbaremchoice" == "Quit" ] ; then
      cleanexit
  else
      rembootsplash
  fi
}

cbainstaller(){
  clear
  previousmenu="cbasub"
  widget="CBAwidget"
  if [ "$onlineallowed" = "true" ] ; then
  platesub="│      Easily download or change ChromeOS boot animations       │"
  else
  platesub="│            Easily change ChromeOS boot animations             │"
  fi
  plate="
┌───────────────────────────────────────────────────────────────┐
│           ~ ChromeOS Boot Animation Installer Menu ~          │
│                                                               │
$platesub
│                                                               │
│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
      Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
  " ; vanity
  case `select_opt "${bootsplashzip[@]}"` in
      *) bootsplashchoice=${bootsplashzip[$?]} ; echo "[o] User selected: $bootsplashchoice";;
  esac
  if [ "$bootsplashchoice" == "Download from github" ] ; then
      webanimcheck
  elif [ "$bootsplashchoice" == "Help" ] ; then
      previousmenu="cbainstaller"
      cbainstallerhelp
  elif [ "$bootsplashchoice" == "Back" ] ; then
      $previousmenu
  elif [ "$bootsplashchoice" == "Quit" ] ; then
      cleanexit
  else
      changebootsplash
  fi
}

webanimcheck(){
    previousmenu="selectanim"
    widget="CBAwidget"
    plate="
┌───────────────────────────────────────────────────────────────┐
│               ~ Boot Animation Online Downloader ~            │
│                                                               │
│      These are the avaliable animations from the github.      │
│                                                               │
│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
       Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
    " ; vanity
    case `select_opt ${onlinebootsplashzip[@]}` in
    *) webzip=${onlinebootsplashzip[$?]} ; echo "[o] User selected: $webzip";;
    esac
    if [ "$webzip" == "Help" ] ; then
        previousmenu="webanimcheck"
        webanimhelp
    elif [ "$webzip" == "Back" ] ; then
        $previousmenu
    elif [ "$webzip" == "Quit" ] ; then
        cleanexit
    else
        getnewanim
    fi
}

getnewanim() {
    echo "[o] Now downloading animation from github, please wait..."
    wget -q --show-progress $bootsplashurl$webzip/$webzip.zip
    echo "[o] Boot animation downloaded! Refreshing, please wait..."
    IFS=$'\n'
    bootsplashzip=($(find boot_splash*.zip 2> /dev/null | sort -r))
    bootsplashzip+=("Help" "Back" "Quit")
    unset IFS
    bootsplashchoice="$webzip.zip"
    changebootsplash
}

rembootsplash(){
  sudo rm -rf /mnt/stateful_partition/unencrypted/bootsplash/"$cbaremchoice"
  if [ "$cbaremchoice" == "$userchromeanim" ] ; then
  grubaction="changecba"
  previousmenu="cbasub"
  cbamenuoptions="default"
  savegrub
  else
  # Reset this so things dont go missing between menus
      cbaopts=$(ls /mnt/stateful_partition/unencrypted/bootsplash/)
  cbasub
  fi
}

changebootsplash(){
    bsdir=$(echo "$bootsplashchoice" | sed -e s/.${bootsplashchoice##*.}//)
    rm -rf $downloads/$bsdir 2> /dev/null
    mkdir -p $downloads/$bsdir
    temppwd=$(pwd)
    cd $downloads/$bsdir
    
#See what kind of file it is
if [ "${bootsplashchoice##*.}" == "gif" ] ; then
    cp $downloads/$bootsplashchoice $downloads/$bsdir
#do this thing to get png from gif
    echo "[!] Splitting GIF, please wait..."
    for i in {1..13} ; do
    convert -coalesce "$bootsplashchoice"[$i] boot_splash_frame%02d.png
    done
    #get primary color from first frame
    #usercolor=$(convert boot_splash_frame01.png +dither -colors 5 -unique-colors txt: | grep "0,0" | xargs | cut -d' ' -f3)
    usercolor=$(convert boot_splash_frame01.png -format "%[pixel:p{0,0}]" info:)
# Do this thing to make pngs look nice
    pngw=$(identify boot_splash_frame01.png | cut -f 3 -d " " | sed s/x.*//)
    pngh=$(identify boot_splash_frame01.png | cut -f 3 -d " " | sed s/.*x//)
# If images are the perfect size or larger, leave them be
    if (( $pngw >= $width )) || (( $pngh >= $height )) ; then
        if (( $pngh > $pngw )) ; then
        padding=$(( $pngh - $pngw ))
        pngw=$(( $pngw + $padding ))
        pngh="0"
        else
        pngw="0"
        pngh="0"
        fi
    else
    pngw=$(( $width - $pngw ))
    pngh=$(( $height - $pngh ))
    fi
# assume black for now, set up selector later
    if [ -z "$usercolor" ] ; then
    usercolor="black"
    fi
    echo "Converting boot animation to fit your screen, please wait..."
    giflist=$(ls *png)
    for img in $giflist ; do
    convert $img -gravity center -background "$usercolor" -flatten -extent "$pngw"x"$pngh" -geometry "$width"x"$height"^ -crop "$width"x"$height"+0+0 -set filename:f "%t" ./"%[filename:f].png"
    done

elif [ "${bootsplashchoice##*.}" == "zip" ] ; then
    mv $downloads/$bootsplashchoice $downloads/$bsdir
    echo "[!] Unzipping archive, please wait..."
    bsdtar -xvf "$bootsplashchoice" --exclude "*_MACOSX*" | pv -s $(du -sb $downloads/$bsdir | awk '{print $1}')
    # Insert resize command here
    if [ -n "$width" ] && [ -n "$height" ] ; then
        echo "Converting boot animation to fit your screen, please wait..."
    convert *.png -geometry "$width"x"$height"^ -gravity center -crop "$width"x"$height"+0+0 -set filename:f "%t" ./"%[filename:f].png"
    fi

elif [ "${bootsplashchoice##*.}" == "png" ] ; then
    cp $downloads/$bootsplashchoice $downloads/$bsdir
# Do this thing to make pngs look nice
    #get primary color from first frame
    #usercolor=$(convert $bootsplashchoice +dither -colors 5 -unique-colors txt: | grep "0,0" | xargs | cut -d' ' -f3)
    usercolor=$(convert $bootsplashchoice -format "%[pixel:p{0,0}]" info:)
# If images are the perfect size or larger, leave them be
    if (( $pngw >= $width )) || (( $pngh >= $height )) ; then
        if (( $pngh > $pngw )) ; then
        padding=$(( $pngh - $pngw ))
        pngw=$(( $pngw + $padding ))
        pngh="0"
        else
        pngw="0"
        pngh="0"
        fi
    else
    pngw=$(( $width - $pngw ))
    pngh=$(( $height - $pngh ))
    fi
# assume black for now, set up selector later
    if [ -z "$usercolor" ] ; then
    usercolor="black"
    fi
    echo "Converting image to fit your screen, please wait..."
    convert $bootsplashchoice -gravity center -background "$usercolor" -flatten -extent "$pngw"x"$pngh" -geometry "$width"x"$height"^ -crop "$width"x"$height"+0+0 boot_splash_frame01.png
fi

    cd $temppwd
    # Put them where they belong
    sudo mkdir -p /mnt/stateful_partition/unencrypted/bootsplash/"$bsdir"/images_100_percent
    sudo mkdir -p /mnt/stateful_partition/unencrypted/bootsplash/"$bsdir"/images_200_percent
    sudo cp $downloads/"$bsdir"/boot_splash_frame*.png /mnt/stateful_partition/unencrypted/bootsplash/"$bsdir"/images_100_percent || { exitcode="9" ; cleanexit ; }
    sudo cp $downloads/"$bsdir"/boot_splash_frame*.png /mnt/stateful_partition/unencrypted/bootsplash/"$bsdir"/images_200_percent 2> /dev/null
    rm -rf $downloads/$bsdir 2> /dev/null
    grubaction="changecba"
    previousmenu="cbasub"
    cbamenuoptions="$bsdir"
    savegrub
}

BBSwidget(){
  if [ -n "$bbsoptions" ] ; then
bbsstatus=$(echo "Current Bootsplash: $bbsoptions" | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
printf "\n│\033[7m░░░░░░░░░░░░░░░░░░░░░░░ Boostplash Info ░░░░░░░░░░░░░░░░░░░░░░░\033[27m│\n"
echo "│                                                               │
|$bbsstatus|"
echo "│                                                               │
└───────────────────────────────────────────────────────────────┘"
fi
}

bbssub(){
      clear
      widget="BBSwidget"
      plate="
┌───────────────────────────────────────────────────────────────┐
│                      ~ Bootsplash Menu ~                      │
│                                                               │
│       Quickly swap between avaliable bootsplash images        │
│                                                               │
│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
       Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
  " ; vanity
      previousmenu="grubmain"
      bbsmenuoptions=(${bbsopts[@]})
      bbsmenuoptions+=("Help" "Back" "Quit")
      case `select_opt "${bbsmenuoptions[@]}"` in
          *) bbsmenuoptions="${bbsmenuoptions[$?]}" ;;
      esac
      if [[ -n "$bbsmenuoptions" ]] ; then
          echo "[o] User selected: $bbsmenuoptions"
      fi
      if [ "$bbsmenuoptions" == "Back" ] ; then
          $previousmenu
      elif [ "$bbsmenuoptions" == "Quit" ] ; then
          cleanexit
      elif [ "$bbsmenuoptions" == "Help" ] ; then
          bbsmenuhelp
      else
          grubaction="changebbs"
          previousmenu="bbssub"
          savegrub
      fi
}

changebbs(){
      if [[ -z "$findbootsplash" ]] ; then
        if [[ -z "$findoptions" ]] ; then
        echo "Options not found, adding manually!"
        sudo sed -i "s/cros_debug/cros_debug options=/g" /root/tmpgrub/efi/boot/grub.cfg
        fi
        sudo sed -i "s/options=/options= console= vt.global_cursor_default=0 brunch_bootsplash=$bbsmenuoptions quiet/" /root/tmpgrub/efi/boot/grub.cfg
      else
        sudo sed -i "s/brunch_bootsplash=$bbsoptions/brunch_bootsplash=$bbsmenuoptions/g" /root/tmpgrub/efi/boot/grub.cfg
      fi
}

KRNLwidget(){
if [ "$originalkernelopts" == "kernel" ] ; then
    originalkernelopts="kernel-5.4"
  fi
kernelstatus=$(echo "Current Kernel: $originalkernelopts" | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
printf "\n│\033[7m░░░░░░░░░░░░░░░░░░░░░░░░░ Kernel Info ░░░░░░░░░░░░░░░░░░░░░░░░░\033[27m│\n"
echo "│                                                               │
|$kernelstatus|"
echo "│                                                               │
└───────────────────────────────────────────────────────────────┘"
}

kernelsub(){
      clear
      widget="KRNLwidget"
      plate="
┌───────────────────────────────────────────────────────────────┐
│                    ~ Kernel Options Menu ~                    │
│                                                               │
│         Quickly swap between avaliable Brunch kernels         │
│                                                               │
│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
       Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
  " ; vanity
      previousmenu="grubmain"
      kernelmenuoptions=(${avaliablekernels[@]})
      kernelmenuoptions+=("Help" "Back" "Quit")
      case `select_opt "${kernelmenuoptions[@]}"` in
          *) kernelmenuoptions="${kernelmenuoptions[$?]}" ;;
      esac
      if [[ -n "$kernelmenuoptions" ]] ; then
          echo "[o] User selected: $kernelmenuoptions"
      fi
      if [ "$kernelmenuoptions" == "Back" ] ; then
          $previousmenu
      elif [ "$kernelmenuoptions" == "Quit" ] ; then
          cleanexit
      elif [ "$kernelmenuoptions" == "Help" ] ; then
          kernelmenuhelp
      else
          grubaction="changekernel"
          previousmenu="kernelsub"
          savegrub
      fi
}

changekernel(){
    if [ "$kernelmenuoptions" == "kernel-5.4" ] ; then
      kernelmenuoptions="kernel"
    fi
    sudo sed -i "s/$kerneloptions/$kernelmenuoptions/g" /root/tmpgrub/efi/boot/grub.cfg
}

fwosub(){
  clear
  # Not working like how I want it to yet, put this info in the help menu instead
  getbrunchdex
  #widget="FWOwidget"
  plate="
┌───────────────────────────────────────────────────────────────┐
│              Options marked with ◯ are disabled              │
│              Options marked with ◆ are enabled               │
└───────────────────────────────────────────────────────────────┘
  Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to toggle or select.
" ; vanity
  previousmenu="grubmain"
  #Declare two variables here to see if B is contained in A
  arrA=(${defaultframeworkoptions[@]})
  arrB=(${fwoopts[@]})
  settoggles
  # check if there have been any changes made and prompt to safe. disregard order of options
  #difcheck=(`echo ${originalfwoopts[@]} ${fwoopts[@]} | tr ' ' '\n' | sort | uniq -u`)
  #if [[ -n ${difcheck[@]} ]] ; then
  #arrA+=("Save Changes")
  #fi
  # Add some QOL options after setting radios
  arrA+=("Help" "Back" "Quit")
  getdesc="0"
  # Call the menu using the new array A
  case `select_opt "${arrA[@]}"` in
        *) toggleopt="${arrA[$?]}" ;;
  esac
  if [[ "$toggleopt" == "Save Changes" ]] ; then
    previousmenu="fwosub"
    grubaction="changefwo"
    savegrub
  elif [[ "$toggleopt" == "Help" ]] ; then
    fwosubhelp
  elif [[ "$toggleopt" == "Back" ]] ; then
    $previousmenu
  elif [[ "$toggleopt" == "Quit" ]] ; then
    exit
  fi
  # Get rid of fancy radio dots before continuing
  toggleopt=$(echo $toggleopt | cut -d' ' -f2)
  # If selected item is already selected, remove it from the selection array #!/usr/bin/env bash
  # Whitespace doesnt matter for what we're doing here
  if [[ "${fwoopts[@]}" =~ "$toggleopt" ]] ; then
      fwoopts=( "${fwoopts[@]/$toggleopt}" )
      for target in "${toggleopt[@]}"; do
        for i in "${!fwoopts[@]}";do
          if [[ ${fwoopts[i]} = $target ]]; then
            unset 'fwoopts[i]'
          fi
        done
      done
      for i in "${!fwoopts[@]}"; do
        temparr+=("${fwoopts[i]}")
      done
      fwoopts=("${temparr[@]}")
      unset temparr
  else
      fwoopts+=($toggleopt)
  fi
  # Always start fresh to prevent graphical bugs, loop for seamless experience
  unset arrA
  previousmenu="fwosub"
  grubaction="changefwo"
  savegrub
}

settoggles(){
# If theres nothing, declare something to prevent bugs with empty arrays
if [ -z "$arrB" ] ; then
  arrB=(None)
fi
# Check everything in the first array against everything in the second
# Mark anything that matches with a filled radio ◉
for (( i=0; i < ${#arrA[@]}; i++ )) ; do
  for (( j=0; j < ${#arrB[@]}; j++ )) ; do
    if [[ ${arrA[$i]} = ${arrB[$j]} ]]; then
    arrA[$i]="◆ ${arrA[$i]}"
    fi
done
done
# Put an empty radio on unselected items ◯
for i in "${!arrA[@]}"; do
    if [[ ! ${arrA[$i]} =~ .*"◆".* ]]; then
    arrA[$i]="◯ ${arrA[$i]}"
  fi
done
}

FWOwidget(){
if [ -n "$fwomemo3" ] ; then
printf "\n│\033[7m░░░░░░░░░░░░░░░░░░ Framework Option Details ░░░░░░░░░░░░░░░░░░░\033[27m│\n"
echo "│                                                               │
|$fwomemo3|"
echo "│                                                               │
└───────────────────────────────────────────────────────────────┘
$fwomemo1
$fwomemo2
"
fi
}

getbrunchdex(){
for i in "${!defaultframeworkoptions[@]}"; do
  if [[ "${defaultframeworkoptions[$i]}" = "${toggleopt}" ]]; then
    optdesc=${fwodesc[i]}
  fi
done
  fwomemo1=$(echo "Toggle an option on or off with Enter (⏎) to see what it does." | awk '{ z = 64 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
  fwomemo2=$(echo "(You can turn it back off if you want)" | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
  fwomemo3=$(echo "$optdesc" | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
}

savegrub(){
  clear
  mountgrub
  $grubaction
  gruboptions
  unmountgrub
  $previousmenu
}

changefwo(){
  originalfwoopts=$(echo ${originalfwoopts[@]} | xargs | sed "s/ /,/g")
  fwoopts=$(echo ${fwoopts[@]} | xargs | sed "s/ /,/g")
  if [[ -z "$findoptions" ]] ; then
    # if options= is not there, find cros_debug and add options directly after.
    echo "Options not found, adding manually!"
    sudo sed -i "s/cros_debug/cros_debug options=/g" /root/tmpgrub/efi/boot/grub.cfg
    sudo sed -i "s/options=/options=$fwoopts/" /root/tmpgrub/efi/boot/grub.cfg
else
    echo "Options updated!"
    sudo sed -i "s/options=$originalfwoopts/options=$fwoopts/" /root/tmpgrub/efi/boot/grub.cfg
fi
}

grubmenuhelp(){
previousmenu="grubmain"

helpentry="
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│                     Grub Options Menu Help                    │
│                                                               │
│   This is the grub options menu, from here users can make     │
│   changes to the system's grub configuration.                 │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│                      Under Construction!                      │
│                                                               │
│   Help                                                        │
│       Displays relevant help information about the current    │
│       options available to the user at that time. It is not   │
│       always the same page, so check it when help is needed!  │
│                                                               │
│   Back                                                        │
│       Takes the user back to the previous menu. In this case  │
│       it leads to the Brunch Toolkit main menu.               │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│     Tip: Use Shift + Up (↑) or Shift + Down (↓) to scroll!    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
"

helpmenu
}

cbasubhelp(){
previousmenu="cbasub"

helpentry="
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│                 ChromeOS Boot Animation Help                  │
│                                                               │
│   This is the ChromeOS boot animation menu, from here users   │
│   can install or swap between installed animation packs       │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│                      Under Construction!                      │
│                                                               │
│   Help                                                        │
│       Displays relevant help information about the current    │
│       options available to the user at that time. It is not   │
│       always the same page, so check it when help is needed!  │
│                                                               │
│   Back                                                        │
│       Takes the user back to the previous menu. In this case  │
│       it leads to the Grub Options main menu.                 │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│     Tip: Use Shift + Up (↑) or Shift + Down (↓) to scroll!    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
"

helpmenu
}

fwosubhelp(){
previousmenu="fwosub"

helpentry="
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│                    Framework Options Help                     │
│                                                               │
│   This is the framework options menu, from here users can     │
│   toggle framework options on or off easily.                  │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│                      Under Construction!                      │
│                                                               │
│   Help                                                        │
│       Displays relevant help information about the current    │
│       options available to the user at that time. It is not   │
│       always the same page, so check it when help is needed!  │
│                                                               │
│   Back                                                        │
│       Takes the user back to the previous menu. In this case  │
│       it leads to the Grub Options main menu.                 │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│     Tip: Use Shift + Up (↑) or Shift + Down (↓) to scroll!    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
"

helpmenu
}

bbssubhelp(){
previousmenu="bbssub"

helpentry="
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│                    Brunch Bootsplash Help                     │
│                                                               │
│   This is the brunch bootsplash menu, from here users can     │
│   swap between different brunch bootsplash options easily.    │
│   These splashscreens are not loaded in debug mode and are    │
│   seperate from the Chrome OS Boot Animations.                │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│   blank                                                       |
|       Displays a black splashscreen with no debug text        |
|                                                               │
|   default & default_notext                                    │
│       This option displays the Brunch logo with some text     │
│       to show the boot status. The notext option omits this.  │
|                                                               │
|   croissant & croissant_notext                                │
│       This option displays the Croissant logo with some text  │
│       to show the boot status. The notext option omits this.  │
│                                                               │
|   neon & neon_notext                                          │
│       This option displays a stylized brunch logo with some   │
│       text for the boot status. The notext option omits this. │
│                                                               │
|   colorful & colorful_dark                                    │
│       This is an experimental light theme option with a       │
│       dark theme variant avaliable. Both use a unique logo.   │
│                                                               │
│   brunchbook                                                  │
│       A minimalist light theme created by xeu100              │
│                                                               │
│   Help                                                        │
│       Displays relevant help information about the current    │
│       options available to the user at that time. It is not   │
│       always the same page, so check it when help is needed!  │
│                                                               │
│   Back                                                        │
│       Takes the user back to the previous menu. In this case  │
│       it leads to the Grub Options main menu.                 │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│     Tip: Use Shift + Up (↑) or Shift + Down (↓) to scroll!    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
"

helpmenu
}

cbainstallerhelp(){
if [ "$onlineallowed" = "true" ] ; then
helpsub="
│                                                               │
│   Download from github                                        │
│       This option allows the toolkit to connect to github,    │
│       the avaliable animation files will be listed in a       │
│       new menu for the user to select from.                   │"
fi
helpentry="
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│                  Boot Animation Menu Help                     │
│                                                               │
│   This is the animation menu, from here users can select      │
│   from the locally downloaded animation files on the system   │
│   or download them through the toolkit from a github repo.    │
│   Users should select one with the same resolution they use.  │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│   [Listed bootsplash files]                                   │
│       The files listed here are the local animation files     │
│       already on the system. The toolkit looks for these in   │
│       the pc's downloads directory (default: ~/Downloads)     │
│       If a user's files aren't listed, make sure they are     │
│       zip files starting with boot_splash for the filename.   │$helpsub
│                                                               │
│   Help                                                        │
│       Displays relevant help information about the current    │
│       options available to the user at that time. It is not   │
│       always the same page, so check it when help is needed!  │
│                                                               │
│   Back                                                        │
│       Takes the user back to the previous menu. In this case  │
│       it leads to the Brunch Toolkit's main menu.             │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│     Tip: Use Shift + Up (↑) or Shift + Down (↓) to scroll!    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
"
helpmenu
}

webanimhelp(){
helpentry="
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│                Animation Downloader Menu Help                 │
│                                                               │
│   This is the animation downloader menu, from here users      │
│   can select from animation archives avaliable online.        │
│   The script will download what the user selects and return   │
│   to the Boot Animation menu where they can apply them.       │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│   [Listed bootsplash files]                                   │
│       The files listed here are the online animation files    │
│       avaliable on the github. The script will handle both    │
│       downloading and unzipping of these files as needed.     │
│                                                               │
│   Help                                                        │
│       Displays relevant help information about the current    │
│       options available to the user at that time. It is not   │
│       always the same page, so check it when help is needed!  │
│                                                               │
│   Back                                                        │
│       Takes the user back to the previous menu. In this case  │
│       it leads to the ChromeOS Boot Animation main menu.      │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│     Tip: Use Shift + Up (↑) or Shift + Down (↓) to scroll!    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
"
helpmenu
}

cberemhelp(){
helpentry="
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│                    Framework Options Help                     │
│                                                               │
│   This is the framework options menu, from here users can     │
│   toggle framework options on or off easily.                  │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│                      Under Construction!                      │
│                                                               │
│   Help                                                        │
│       Displays relevant help information about the current    │
│       options available to the user at that time. It is not   │
│       always the same page, so check it when help is needed!  │
│                                                               │
│   Back                                                        │
│       Takes the user back to the previous menu. In this case  │
│       it leads to the Grub Options main menu.                 │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│     Tip: Use Shift + Up (↑) or Shift + Down (↓) to scroll!    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
"
helpmenu
}


#+===============================================================+
#|  Changelog                                                    |
#|  Add to the changelog as necessary, keep a legacy changelog   |
#+===============================================================+



#+===============================================================+
#|  Version // System Specs                                      |
#|  Everything related to the System Specs tool goes here        |
#+===============================================================+


#+===============================================================+
#|  Help glossary                                                |
#|  All $helpentries should be stored with their functions       |
#+===============================================================+

# One function to rule them all. Define $helpentry as needed
helpmenu(){
    menuheader
    echo "$helpentry"
    sleep 0.5
    returntomenu
}

# Return to the previous menu when finished
returntomenu(){
# Intentionally break formatting here for the ~ a e s t h e t i c ~
    read -rp "
           Press Enter (⏎) to return to the previous menu.
" return
    case $return in
        * ) $previousmenu ;;
    esac
}

menuheader(){
  echo "
█████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████
"
  clear
}

toolkitchoicehelp(){
menuheader
    previousmenu="toolkitchoice"
    echo "
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│                  Toolkit Options Menu Help                    │
│                                                               │
│   This is the toolkit options menu, from here users are able  │
│   to install the toolkit for easy access, download a newer    │
│   release, or even download and install the latest version.   │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│   Install Brunch Toolkit <Version number>                     │
│       This option will install the toolkit as a file to the   │
│       user's /usr/local/bin directory and creates another     │
│       directory called brunch-toolkit-assets there. This      │
│       directory contains backups for bootsplash installs,     │
│       framework options and shell extention options.          │
│                                                               │
│   Update to Brunch Toolkit <Version number>                   │
│       This option will download the most recent release of    │
│       the Brunch Toolkit from the github. The new toolkit     │
│       can be found in Downloads (Usually ~/Downloads)         │
│                                                               │
│   Update & Install <Version number>                           │
│       This option will download the most recent release of    │
│       the Brunch Toolkit from the github and install it as    │
│       described in the 'Install' section above.               │
│                                                               │
│   Help                                                        │
│       Displays relevant help information about the current    │
│       options available to the user at that time. It is not   │
│       always the same page, so check it when help is needed!  │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│     Tip: Use Shift + Up (↑) or Shift + Down (↓) to scroll!    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
"
    returntomenu
}

toolkitchoiceofflinehelp(){
menuheader
    previousmenu="toolkitchoiceoffline"
    echo "
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│                  Toolkit Options Menu Help                    │
│                                                               │
│   This is the toolkit options menu, from here users are able  │
│   to install the toolkit for easy access, download a newer    │
│   release, or even download and install the latest version.   │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│   Install Brunch Toolkit <Version number>                     │
│       This option will install the toolkit as a file to the   │
│       user's /usr/local/bin directory and creates another     │
│       directory called brunch-toolkit-assets there. This      │
│       directory contains backups for bootsplash installs,     │
│       framework options and shell extention options.          │
│                                                               │
│   Help                                                        │
│       Displays relevant help information about the current    │
│       options available to the user at that time. It is not   │
│       always the same page, so check it when help is needed!  │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│     Tip: Use Shift + Up (↑) or Shift + Down (↓) to scroll!    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
"
    returntomenu
}

#+===============================================================+
#|  $exitcode glossary                                           |
#|  List possible exit codes and their meanings here             |
#+===============================================================+

# Returns the user's terminal to the directory they were in before the script was launched
# Also returns an error message if applicable.
cleanexit() {
echo "
█████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████
  "
clear
    unmountgrub
    decodeexitcodes
    echo ""
    if [ -n "$exitmsg" ] ; then
        echo "$exitmsg"
    fi
    echo "[!] Exiting... debug log written to $downloads/toolkit.log"
    # Divider for easily reading through debug logs
    cd "$previousdir" || exit
    exit
}

# Add additional exitcodes to this function as needed (any order)
# Formatting may intentionally be broken
decodeexitcodes(){
    if [ -z "$exitcode" ] ; then
        exitcode="0"
    fi
    case $exitcode in
    # Code:  Reason:
        0 ) exitmsg="" ;;
        1 ) exitmsg="[ERROR] $0 must NOT be run as root." ;;
        2 ) exitmsg="[ERROR] Could not access $downloads." ;;
        3 ) exitmsg="[ERROR] Not a recognized Quick Start option." ;;
        4 ) exitmsg="[ERROR] That Quick Start option only works in Brunch." ;;
        5 ) exitmsg="[ERROR] Your previous boot animation could not be detected.
        If you've just updated the toolkit or haven't installed an
        animation yet, please use the toolkit's menu to set one first." ;;
        6 ) exitmsg="[ERROR] Unable to apply boot animation." ;;
        7 ) exitmsg="[ERROR] Unable to retrieve bootsplash files from the web.
        Please check your connection or provide a valid bootsplash file." ;;
        8 ) exitmsg="[ERROR] Unable to unzip bootsplash archive." ;;
        9 ) exitmsg="[ERROR] Unable to apply bootsplash animation." ;;
        10) exitmsg="[ERROR] Unable to install brunch-toolkit to /usr/local/bin." ;;
        11) exitmsg="[ERROR] Unable to claim ownership of /usr/local/bin/brunch-toolkit." ;;
        12) exitmsg="[ERROR] Unable to create assets folder in /usr/local/bin." ;;
        13) exitmsg="[ERROR] Unable to create directory /root/tmpgrub." ;;
        14) exitmsg="[ERROR] Unable to mount '$partsource'12." ;;
        15) exitmsg="[ERROR] Unable to unmount /root/tmpgrub.
        Grub operations may not work properly until the error is resolved." ;;
        16) exitmsg="[!] Arch dependencies not ready, User selected exit." ;;
        17) exitmsg="[!] Dualboot not compatible with Grub Editor, User selected exit." ;;
    esac
}

#+===============================================================+
#|  PWA exclusive scripts                                        |
#+===============================================================+

pwa-autoupdate(){
# $OPTS is defined when called, ie: brunch-toolkit $OPTS
# Do this before pwa-sharedvars
    if [ "$quickstart" == "--pwa-auto-update" ] || [ "$quickstart" == "-pwa-au" ]; then
        channel="brunch"
    elif [ "$quickstart" == "--pwa-unstable-update" ] || [ "$quickstart" == "-pwa-uu" ]; then
        channel="brunch-unstable"
    fi
# Special variable handler
    pwa-sharedvars
# Check for existing update process
    if [ "$updateinprogress" == "true" ] ; then
        echo "[Error] Update already in progress!"
        updateinprogress="false"
        exit
    fi
    updateinprogress="true"
    if (( "$currentbrunchversion" < "$latestbrunchversion" )) ; then
# Make a working directory to keep toolkit out of sight
        mkdir -p  ~/tmp/brunch-toolkit
        curdir=$(pwd)
        cd ~/tmp/brunch-toolkit
# Download latest release from $channel
        curl -L -O --progress-bar "$(curl -s https://api.github.com/repos/sebanc/$channel/releases/latest | grep 'browser_' | cut -d\" -f4)"
        updatefile="$(find *runch*tar.gz 2> /dev/null | sort -r | head -1 )"
# Call built in update command
        sudo chromeos-update -f ~/tmp/brunch-toolkit/"$updatefile"
        cd $curdir
# Clean up
        rm -rf ~/tmp/brunch-toolkit/*
        rmdir ~/tmp/brunch-toolkit
        updateinprogress="false"
        exit
    else
# Error if no need to update
        echo "[ERROR!] You already have the latest version of Brunch. ($currentbrunchversion)"
        updateinprogress="false"
        exit
    fi
}

pwa-sharedvars(){
    # Check for a stable internet connection #
        case "$(curl -s --max-time 2 -I http://google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
    # If connection is good, do nothing and proceed quietly
            [23]) : ;;
    # Error on weak or empty connection
            *) echo "[!] The network is down or very slow, unable to continue."; exit ;;
        esac
        currentbrunchversion=$(awk '{print $3}' 2> /dev/null < /etc/brunch_version)
    # Error if called on a non-brunch device
        if [ -z "$currentbrunchversion" ] ; then
                echo "[ERROR] This function only works on Brunch systems!"
                exit
        fi
    # Get latest brunch version from $channel
    if [ -z "$channel" ] ; then
        channel="brunch"
    fi
        lbv0=$(curl -s "https://api.github.com/repos/sebanc/$channel/releases/latest" | grep 'name' | cut -d\" -f4 | grep 'tar.gz')
    # Strip all of the unnecessary bits off, integers only
        lbv1=${lbv0/stable_}
        lbv2=${lbv1/unstable_}
        lbv3=${lbv2/testing_}
        latestbrunchversion=$(echo "$lbv3" | cut -d'_' -f3 | cut -d'.' -f1)
}

#+===============================================================+
#|  End of script definitions                                    |
#+===============================================================+

if [ -f $downloads/toolkit.log ] ; then
  rm -rf  $downloads/toolkit.log
fi
touch $downloads/toolkit.log
prestart | tee -a $downloads/toolkit.log
