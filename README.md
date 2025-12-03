# Attention! 
This toolkit is not currently being maintained, and is not expected to work properly with changes that have been made to ChromeOS over the last several years. I am leaving this repo here for archival purposes but you really shouldn't use this program anymore. 

- Peace, Love, and all of the above
  Wisteria


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
Brunch is a framework that aims to create a generic x86_64 Chrome OS image that can be installed on non-standard hardware. I'd suggest reading up on the project at its official source: https://github.com/sebanc/brunch

## How to Use
- Open a terminal with CTRL + ALT + T (For brunch users, type "shell" at the prompt)
- Type: `bash <(curl -s https://raw.githubusercontent.com/WesBosch/brunch-toolkit/main/install_toolkit.sh)` 
- The toolkit can now be launched with `brunch-toolkit` and updated using the steps above or through its own menu.
- Follow the on-screen prompts. If something requires that you download a file, the script will probably offer to do it for you.

## Usage
This script is designed to make installing and updating brunch easy for users that are not comfortable with the command line. If you already know what you're doing, some tasks may be faster to so manually. The toolkit will provide easy to follow prompts and present options whenever necessary for the user to select from. Some advanced features require update files, recoveries or boot splash archives to be in the ~/Downloads folder. It is not required to unzip anything, the toolkit will do that. If no usable files are found, the user will be able to download them. (if there is a suitable internet connection)

It is not a perfect script, if you find any issues, please report them. It is difficult to account for every possible situation, but I've made an attempt to cover most of them. This toolkit is intended to be used on devices running Sebanc's Brunch framework, though it has some limited functionality on standard **buntu* and Debian-based Linux distros.

## Features
Brunch exclusive features:
- Update existing Brunch installation
- Modify the Chrome OS start up animation
- Modify the Brunch boot splash
- Modify the Grub theme (for USB and Singleboot users)
- Modify Framework Options
- Swap between different kernels
- Install the Brunch Toolchain or Brioche
- Generate a compatibility report

Brunch, Linux & WSL compatible features:
- Check user's CPU for Brunch compatibility
- Suggest usable recoveries based on user's hardware
- Install Brunch to disk or partition
