# Brunch Toolkit
Stable release channel for the Brunch Toolkit

This is my first script, expect bugs!
Special thanks to all of the helpful folks of the Brunch Discord group.
You can find me there as well:
https://discord.gg/x2EgK2M

-- Wisteria

## Disclaimer
This software is provided as-is with no warranty. I am not an expert and I am not liable for any accidental damage to your hardware or files. The toolkit has access to disks and partitions, and it can erase a disk if something goes wrong. Please send me any such bug reports.

Please do not use or showcase my script in videos, and do not use this script in any other projects. If you'd like permission to do so please contact me.

## What is Brunch?
Brunch is a framework that aims to create a generic x86_64 Chrome OS image that can be installed on non-standard hardware. I'd suggest reading up on the project at it's official source: https://github.com/sebanc/brunch

## Before you start
The Brunch Toolkit has a few dependencies. In Linux, the toolkit will usually install these itself, however Brunch users are currently required to install chromebrew or Sebanc's brunch-toolchain *before* they can use the toolkit. If you are using linux, or have already installed chromebrew or the brunch-toolchain before, you do *not* need to do this. You must only use ONE, you cannot use both. 

Check out the Chromebrew project here: https://github.com/skycocker/chromebrew
To install chromebrew: 
- Open a crosh shell with ctrl + alt + t and type "shell" at the prompt
- type: `curl -Ls git.io/vddgY | bash`
- Wait for it to install. 
This may take a few minutes, so take a moment to read over the rest of this ReadMe. When it's finished, you can begin using the Brunch Toolkit.

If you'd prefer to use the brunch-toolchain, check it out here: https://github.com/sebanc/brunch-toolchain

To install the brunch-toolchain:
- Downloads the lastest release: https://github.com/sebanc/brunch-toolchain/releases/latest
- Open a crosh shell with ctrl + alt + t and type "shell" at the prompt
- Type: `sudo rm -r /usr/local/*`   (This step removes ALL data in /usr/local! Backup custom scripts if you have any!)
- Type: `sudo chown -R 1000:1000 /usr/local`
- Type: `tar zxf ~/Downloads/brunch_toolchain_version.tar.gz -C /usr/local`  (Hint: replace brunch_toolchain_version.tar.gz with it's actual filename)
- Type: `start-toolchain`
This may take a few minutes, so take a moment to read over the rest of this ReadMe. When it's finished, you can begin using the Brunch Toolkit.

Note: If you're using Brunch, you must be in Dev Mode to use this script. That *shouldn't* be an issue as Dev Mode is enabled by default, but if you've disabled dev mode, be aware that you will not be able to use this script until Dev Mode is enabled again.

## Important notes about the brunch-toolchain - Please Read
*Switching dependencies may erase backups!* This means that switching from Chromebrew to the brunch-toolchain *will* erase any custom installed scripts and brunch-toolkit backup files. If you have any toolkit backup files (grub, bootsplash, shell tools, etc) you may want to backup your files before installing the brunch-toolchain
If you want to switch from chromebrew to Sebanc's brunch-toolchain:
- Open a crosh shell with ctrl + alt + t and type "shell" at the prompt
- Type: `mkdir ~/tmp`
- Type: `mv -f /usr/local/bin/brunch* ~/tmp`
- At this point, you can follow the steps to install the brunch-toolchain. *Wait until the installation is done before continuing!*
- Type: `mv -f ~/tmp/* /usr/local/bin`
- Type: `rmdir ~/tmp`
Now all your files have been returned and should be usable without reinstalling.

## How to Use
If you're using Brunch already, please read the above section. The script will not work correctly on Brunch systems without chromebrew or the brunch-toolchain installed!
- Download the brunch-toolkit-*version*.sh file from the releases tab https://github.com/WesBosch/brunch-toolkit/releases/latest
- Open a terminal with ctrl + alt + t (For brunch users, type "shell" at the prompt)
- Type: `cd ~/Downloads` 
- Type: `bash brunch-toolkit-version.sh`  (Hint: replace brunch-toolkit-version.sh with it's actual filename)
- Follow the on screen prompts. If something requires that you download a file, the script will probably offer to do it for you.

Note: The toolkit relies on ~/Downloads being avaliable (except in WSL) if you use an alternate download location, the toolkit may not work properly. In most cases the script will correct itself, but I strongly suggest running the script from the ~/Downloads folder whenever you use it (Unless you choose to install it to your Brunch system)

## Usage
This script is designed to make installing and updating brunch easy for users that are not comfortable with the command line. If you already know what you're doing, some tasks may be faster to so manually. The toolkit will provide easy to follow prompts and present options whenever necessary for the user to select from. Some features require update files, recoveries or bootsplash archives to be in the ~/Downloads folder. It is not required to unzip anything, the toolkit will do that. If no usable files are found, the user will be able to download them. (if there is a suitable internet connection)

It is not a perfect script, if you find any issues please report them. It is difficult to account for every possible situation, but I've made an attempt to cover most of them. This toolkit is intended to be used on devices running Sebanc's Brunch framework, though it has some limited functionality on standard *buntu* and debian based linux distros.

## Features
Brunch exclusive features:
- Update existing Brunch installation
- Update existing Chrome OS & Brunch installations
- Modify the Chrome OS start up animation
- Install the Brunch Toolkit for easy access

Brunch, Linux & WSL compatible features:
- Check user's CPU for Brunch compatibility
- Suggest usable recoveries based on user's hardware
- Install Brunch to disk or partition

## Debug Tools
Below is a list of debug options and menu shortcuts that can be used. 
Add either the *--long* or *-s* (short) version of a debug option to the end of the brunch-toolkit command to use them.
Commands labeled "Brunch exclusive" will only work if the toolkit is used in Brunch.

    --bootsplash (-b)
        Brunch Exclusive
        Skips the main menu and starts the boot animation changer.

    --brunch (-br)
        Brunch Exclusive
        Skips the main menu and starts the Brunch update function.

    --changelog (-c)
        Displays a changelog for the last several updates of this script

    --chrome (-cr)
        Brunch Exclusive
        Skips the main menu and starts the Chrome & Brunch update function.

    --compatibility (-k)
        Displays helpful info about CPU compatibility.
        This option should work on most linux distros.

    --debug (-d)
        Tests the script without allowing updates or installs.
        File operations and downloads will still happen.
        
    --grub (-g)
        Brunch Exclusive
        Allows the user to install and modify framework options in grub
        This is a potentially dangerous hidden option and must be called manually

    --help (-h)
        Displays this page.
        Run the program without command line arguments for normal usage.

    --install (-n)
        Skips the main menu and starts the Brunch install function.
    
    --legacychangelog (-lc)
        Displays the entire changlog of this script.
        
    --offline (-o)
        Disables all internet functions of the tooklit.
        It will not prompt for an internet connection at all.
        Useful if you know you don't need to download anything.

    --quick (-q)
        Brunch Exclusive
        This is an experimental quick update process.
        Only use this if you know what you're doing!
        The toolkit will update Brunch WITHOUT prompts using the
        brunch file in ~/Downloads. (It will only look for one)
        If the latest release does not match the file it auto-downloads it.
        If there are no brunch files it auto-downloads the latest.
        If there are multiple files it will exit quick mode.
        This is only meant to be used with one update file present.
    
    --quickbootsplash (-qb)
        Brunch Exclusive
        Checks for a previously installed boot animation, and resets the current one.
        This is useful for when an update returns the animation to the default.
    
    --quickignore (-qi)
        Brunch Exclusive
        Same as --quick but ignores the current version check,
        allows users to update into the release they are already on.
        
    --shell (-s)
        Brunch Exclusive
        Allows the user to install and modify crosh shell tools for brunch.
        
    --updatetoolkit (-u)
        Brunch Exclusive
        Allows the user to download and install the newest brunch toolkit release.

    --version (-v)
        Displays useful system information including:
        The version of the toolkit you're using
        The kernel used by your system
        Which version of Chrome OS you're on
        Which version of Brunch you're on
        Which recoveries are supported or recomended
