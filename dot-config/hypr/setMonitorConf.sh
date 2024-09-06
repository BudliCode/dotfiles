#! /bin/bash

ln -sf ~/.config/hypr/monitorSetups/$(uname --nodename).conf ~/.config/hypr/monitorSetup.conf
hyprctl reload
