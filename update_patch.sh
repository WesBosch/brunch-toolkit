#!/bin/bash
sudo mkdir -p /var/brunch/toolkit || echo "Failed to create workspace."
sudo chown -R $USER /var/brunch || echo "Failed to take ownership of workspace" 
current_brunch_version=$(cat /etc/brunch_version 2>/dev/null |  cut -d' ' -f3 )

if (( $current_brunch_version < 20210822 )) ; then
echo "Downloading patched update script, please wait..."
curl -l https://raw.githubusercontent.com/WesBosch/brunch-toolkit/main/chromeos-update -o /var/brunch/toolkit/chromeos-update || echo "Failed to download patched update script."
sudo cp /var/brunch/toolkit/chromeos-update /usr/sbin/chromeos-update && echo "Patched update script installed!" || echo "Failed to copy patched update script."
else
echo "Your Brunch release is $current_brunch_version and may not need patched."
fi 
sudo rm /var/brunch/toolkit/chromeos-update || echo "Failed to clean up workspace."
