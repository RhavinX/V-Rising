#!/bin/bash

s=/home/VRisingServer
d=/data

/usr/bin/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$s" +login anonymous +app_update 1829350 validate +quit

if [ -z $WORLDNAME ]; then
 WORLDNAME="world1"
fi

mkdir -p "$d/Saves" "$d/Settings" 2>&1
if [ ! -f "$d/Settings/ServerGameSettings.json" ]; then
        echo "$d/Settings/ServerGameSettings.json not found. Copying default file."
        cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$d/Settings" 2>&1
fi
if [ ! -f "$d/Settings/ServerHostSettings.json" ]; then
        echo "$p/Settings/ServerHostSettings.json not found. Copying default file."
        cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$d/Settings" 2>&1
fi
if [ ! -f "$d/Settings/adminlist.txt" ]; then
        echo "$d/Settings/adminlist.txt not found. Copying default file."
        cp "$s/VRisingServer_Data/StreamingAssets/Settings/adminlist.txt" "$d/Settings" 2>&1
fi
if [ ! -f "$d/Settings/banlist.txt" ]; then
        echo "$d/Settings/banlist.txt not found. Copying default file."
        cp "$s/VRisingServer_Data/StreamingAssets/Settings/banlist.txt" "$d/Settings" 2>&1
fi

cd "$s"
rm -f /tmp/.X0-lock 2>&1
Xvfb :0 -screen 0 1024x768x16 & \
DISPLAY=:0.0 wine64 /home/VRisingServer/VRisingServer.exe -persistentDataPath "$d" -saveName "$WORLDNAME" 2>&1
