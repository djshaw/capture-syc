#!/bin/bash

sudo apt update
sudo apt install --assume-yes \
                 python3-pip \
                 vim
sudo pip3 install --break-system-packages --requirement requirements.txt
