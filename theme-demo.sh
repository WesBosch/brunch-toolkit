#!/bin/bash

if [ -z $DOWNLOADS ] ; then
    downloads="$HOME/Downloads"
else
    downloads="$DOWNLOADS"
fi

readonly toolkitversion="Grub Theme Tool Demo"
readonly discordinvite="https://discord.gg/x2EgK2M"
readonly userid=`id -u $USERNAME`

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

vanity(){
clear
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
Loading $toolkitversion...
"
fi
}

prestart(){
plate="startup" ; vanity
    checkforroot
    checkforsystemtype
    checkfordualboot
    checkonlinestatus
    mountgrub
    clear
    demomenu
}

checkonlinestatus() {
    case "$(curl -s --max-time 2 -I http://google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
        [23]) echo "[o] Toolkit Online, internet features enabled.";;
               *) clear ; echo "[x] This demo requires a stable internet connection." ; exit ;;
        esac
}

checkfordualboot(){
    source=$(rootdev -d)
    if (expr match "$source" ".*[0-9]$" >/dev/null); then
        partsource="$source"p
    else
        partsource="$source"
    fi
    if [[ "$source" =~ .*"loop".* ]] ; then
        clear
        echo "[x] Demo is for singleboot users only."
        exit
    fi
}

checkforroot(){
    if [ $userid -eq 0 ] ; then
        clear
        echo "[x] Do not run as root."
        exit
    fi
}

checkforsystemtype(){
    currentrelease=$(cat /etc/brunch_version 2>/dev/null)
    if [ -z "$currentrelease" ] ; then
        clear
        echo "[x] Demo is for Brunch only."
        exit
    else
        echo "[o] Launching in Brunch Mode."
    fi
}

mountgrub(){
    sudo mkdir -p /root/tmpgrub
    echo "[o] Mounting partition12, please wait..."
    sudo mount "$partsource"12 /root/tmpgrub
    echo "[o] Partition mounted successfully."
    grubmounted="true"
    installedtheme=$(ls /root/tmpgrub/efi/boot/*.theme | cut -d'.' -f1 | cut -d'/' -f6)
    if [[ -z "$installedtheme" ]] ; then
    installedtheme="false"
    fi
    echo "[o] Preparing menu, please wait..."
    sleep 0.5
}

displaywarning(){
themenotification=$(echo "Current Theme: $installedtheme" | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
printf "\n│\033[7m░░░░░░░░░░░░░░░░░░░░░░░░   Attention   ░░░░░░░░░░░░░░░░░░░░░░░░\033[27m│\n"
echo "│                                                               │
│  This is an experimental script that edits grub, be careful!  │
│                                                               │
└───────────────────────────────────────────────────────────────┘"

echo "┌───────────────────────────────────────────────────────────────┐"
if [[ "$installedtheme" != "false" ]] ; then
echo "|$themenotification|"
fi
echo "│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
       Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
"
sleep 0.5
}

demomenu(){
    displaywarning
    if [[ "$installedtheme" == "false" ]] ; then
    thememenuopts=("Install Theme" "Edit Grub" "Rescue Grub" "Quit")
    else
    thememenuopts=("Change Theme" "Remove Theme" "Edit Grub" "Rescue Grub" "Quit")
    fi
    case `select_opt "${thememenuopts[@]}"` in
        *) thememenuchoice="${thememenuopts[$?]}" ; echo "[o] User selected: $thememenuchoice" ;;
    esac
    if [[ -z "$thememenuchoice" ]] ; then
        echo "[x] Invalid Option"
    elif [[ "$thememenuchoice" == "Install Theme" ]] ; then
        clear
        installtheme
    elif [[ "$thememenuchoice" == "Change Theme" ]] ; then
        clear
        changetheme
    elif [[ "$thememenuchoice" == "Remove Theme" ]] ; then
        clear
        removetheme
    elif [[ "$thememenuchoice" == "Rescue Grub" ]] ; then
        clear
        rescuegrub
    elif [[ "$thememenuchoice" == "Edit Grub" ]] ; then
        newgrubeditor
    elif [[ "$thememenuchoice" == "Quit" ]] ; then
        safeexit
    fi
}

rescuegrub(){
nuclearopts=("Rescue" "Back" "Quit")
printf "\n│\033[7m░░░░░░░░░░░░░░░░░░░░░░░░   Attention   ░░░░░░░░░░░░░░░░░░░░░░░░\033[27m│\n"
echo "│                                                               │
│  Ideally you should never need this option. This option will  │
│  remove any grub themes and reset your grub.cfg to a default  │
│  state. This should only be used if your grub.bak was erased  │
│  or overwritten by a bug. Please report any bugs that caused  │
│  this scenario to me (Wisteria) on telegram or discord.       │
│                                                               │
└───────────────────────────────────────────────────────────────┘"

echo "┌───────────────────────────────────────────────────────────────┐
│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
       Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
"
sleep 0.5
        case `select_opt ${nuclearopts[@]}` in
            *) nuke=${nuclearopts[$?]} ; echo "[o] User selected: $nuke" ;;
        esac
        if [[ "$nuke" == "Back" ]] ; then
            clear
            demomenu
        elif [[ "$nuke" == "Quit" ]] ; then
            safeexit
        elif [[ "$nuke" == "Rescue" ]] ; then
            clear
            expertnuke
        fi
}

expertnuke(){
    mkdir -p ~/tmp/brunch-toolkit
    curl -l https://raw.githubusercontent.com/WesBosch/brunch-toolkit/main/grub.defaults -o ~/tmp/brunch-toolkit/grub.defaults
    sudo rm -rf /root/tmpgrub/efi/boot/*.theme
    sudo rm -rf /root/tmpgrub/efi/boot/unicode.pf2
    sudo rm -rf /root/tmpgrub/efi/boot/grub.cfg
    sudo rm -rf /root/tmpgrub/efi/boot/themes
    sudo rm -rf /root/tmpgrub/efi/boot/x86_64-efi
    sudo rm -rf /root/tmpgrub/efi/boot/grub.bak
    sudo cp ~/tmp/brunch-toolkit/grub.defaults /root/tmpgrub/efi/boot/grub.cfg
    rm -rf ~/tmp/brunch-toolkit
    installedtheme="false"
    warning=$(echo "Grub defaults have been restored." | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
    clear
    printf "\n│\033[7m░░░░░░░░░░░░░░░░░░░░░░░░ Notifications ░░░░░░░░░░░░░░░░░░░░░░░░\033[27m│\n"
    echo "│                                                               │"
    echo "|$warning|"
    echo "│                                                               │
└───────────────────────────────────────────────────────────────┘
    "
    sleep 0.5
    read -rp "
           Press Enter (⏎) to return to the previous menu.
    " return
    case $return in
        * ) clear ; demomenu ;;
    esac
}

removetheme(){
        sudo rm -rf /root/tmpgrub/efi/boot/*.theme
        sudo rm -rf /root/tmpgrub/efi/boot/unicode.pf2
        sudo rm -rf /root/tmpgrub/efi/boot/grub.cfg
        sudo rm -rf /root/tmpgrub/efi/boot/themes
        sudo rm -rf /root/tmpgrub/efi/boot/x86_64-efi
        sudo mv /root/tmpgrub/efi/boot/grub.bak /root/tmpgrub/efi/boot/grub.cfg
    installedtheme="false"
    warning=$(echo "Grub themes have been removed." | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
    clear
printf "\n│\033[7m░░░░░░░░░░░░░░░░░░░░░░░░ Notifications ░░░░░░░░░░░░░░░░░░░░░░░░\033[27m│\n"
echo "│                                                               │"
echo "|$warning|"
echo "│                                                               │
└───────────────────────────────────────────────────────────────┘
"
sleep 0.5
read -rp "
       Press Enter (⏎) to return to the previous menu.
" return
case $return in
    * ) clear ; demomenu ;;
esac
}

installtheme(){
    mkdir -p ~/tmp/brunch-toolkit
    curl -l https://raw.githubusercontent.com/WesBosch/brunch-toolkit/main/grub-themes.zip -o ~/tmp/brunch-toolkit/grub-themes.zip
    cirdir=$(pwd)
    cd ~/tmp/brunch-toolkit
    bsdtar -xvf ~/tmp/brunch-toolkit/grub-themes.zip --exclude "*_MACOSX*" | pv -s $(du -sb ~/tmp/brunch-toolkit | awk '{print $1}')
    cd $curdir
    sudo mv /root/tmpgrub/efi/boot/grub.cfg /root/tmpgrub/efi/boot/grub.bak
    sleep 0.5
    rm ~/tmp/brunch-toolkit/grub-themes.zip
    sudo cp -r ~/tmp/brunch-toolkit/* /root/tmpgrub/efi/boot
    sudo touch /root/tmpgrub/efi/boot/brunch.theme
    rm -rf ~/tmp/brunch-toolkit
    installedtheme="brunch"
    warning=$(echo "Your theme has been changed to $installedtheme" | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')

printf "\n│\033[7m░░░░░░░░░░░░░░░░░░░░░░░░ Notifications ░░░░░░░░░░░░░░░░░░░░░░░░\033[27m│\n"
echo "│                                                               │"
echo "|$warning|"
echo "│                                                               │
└───────────────────────────────────────────────────────────────┘
"
sleep 0.5
read -rp "
       Press Enter (⏎) to return to the previous menu.
" return
case $return in
    * ) clear ; demomenu ;;
esac
}

safeexit(){
    if [ "$grubmounted" == "true" ] ; then
        echo "[!] Unmounting partition12, please wait..."
        sudo umount /root/tmpgrub
        echo "[o] Unmounted successfully."
    fi
    clear
    exit
}

newgrubeditor(){
    if [[ "$installedtheme" == "false" ]] ; then
        sudo nano /root/tmpgrub/efi/boot/grub.cfg
    else
        sudo nano /root/tmpgrub/efi/boot/grub.bak
    fi
    clear
    demomenu
}

changetheme(){
avaliablethemes=($(ls /root/tmpgrub/efi/boot/themes))
avaliablethemes+=("Back" "Quit")
themenotification=$(echo "Current Theme: $installedtheme" | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
    if [[ -n "$warning" ]] ; then
printf "\n│\033[7m░░░░░░░░░░░░░░░░░░░░░░░░ Notifications ░░░░░░░░░░░░░░░░░░░░░░░░\033[27m│\n"
echo "│                                                               │"
echo "|$warning|"
echo "│                                                               │
└───────────────────────────────────────────────────────────────┘"
fi
warning=
echo "
┌───────────────────────────────────────────────────────────────┐
|$themenotification|
│           Please select one of the following options          │
└───────────────────────────────────────────────────────────────┘
       Arrow Keys Up/Down (↑/↓)  Press Enter (⏎) to select.
"
    case `select_opt "${avaliablethemes[@]}"` in
        *) selectedtheme=${avaliablethemes[$?]} ; echo "[o] User selected: $selectedtheme" ;;
    esac
    if [[ "$selectedtheme" == "Back" ]] ; then
        clear
        demomenu
    elif [[ "$selectedtheme" == "Quit" ]] ; then
        safeexit
    elif [[ "$selectedtheme" == "$installedtheme" ]] ; then
        clear
        warning=$(echo "You're already using $installedtheme" | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
        changetheme
    else
        changethemesub
    fi
}

changethemesub(){
    sudo sed -i "s/custom=$installedtheme/custom=$selectedtheme/g" /root/tmpgrub/efi/boot/grub.cfg
    sudo mv  /root/tmpgrub/efi/boot/$installedtheme.theme /root/tmpgrub/efi/boot/$selectedtheme.theme
    warning=$(echo "Your theme has been changed to $selectedtheme" | awk '{ z = 63 - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }')
    installedtheme="$selectedtheme"
    clear
    changetheme
}

prestart
