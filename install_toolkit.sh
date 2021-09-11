#!/bin/bash

sudo mkdir -p ~/tmp/brunch-workspace
sudo chown -R $USER ~/tmp/brunch-workspace


echo "Downloading the Brunch Toolkit, please wait..."
curl -l https://raw.githubusercontent.com/WesBosch/brunch-toolkit/main/brunch-toolkit -o ~/tmp/brunch-workspace/brunch-toolkit
sudo install -Dt /usr/local/bin -m 755 ~/tmp/brunch-workspace/brunch-toolkit && echo "Brunch Toolkit installed!" || echo "Failed to install Brunch Toolkit."
