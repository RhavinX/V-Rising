#!/bin/bash

serverhome=/home/VRisingServer
data=/data

echo "Setting timezone to $TZ"
echo $TZ > /etc/timezone 2>&1
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime 2>&1
dpkg-reconfigure -f noninteractive tzdata 2>&1

term_handler() {
	echo "Shutting down Server"

	PID=$(pgrep -f "^${s}/VRisingServer.exe")
	if [[ -z $PID ]]; then
		echo "Could not find VRisingServer.exe pid. Assuming server is dead..."
	else
		kill -n 15 "$PID"
		wait "$PID"
	fi
	wineserver -k
	sleep 1
	exit
}

trap 'term_handler' SIGTERM

echo " "
echo "Updating/installing V-Rising Dedicated Server files..."
echo " "
/usr/bin/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$serverhome" +login anonymous +app_update 1829350 validate +quit

if ! grep -q 'avx[^ ]*' /proc/cpuinfo; then
	unsupported_file="VRisingServer_Data/Plugins/x86_64/lib_burst_generated.dll"
	echo "AVX or AVX2 not supported; Check if unsupported ${unsupported_file} exists"
	if [ -f "${s}/${unsupported_file}" ]; then
		echo "Renaming ${unsupported_file} to fix issues..."
		mv "${s}/${unsupported_file}" "${s}/${unsupported_file}.bak"
	fi
fi

if [ -z "$WORLDNAME" ]; then
 WORLDNAME="world1"
fi

echo "Setting WORLDNAME to ${WORLDNAME}"

mkdir -p "$data/Saves" "$data/Settings" 2>&1
if [ ! -f "$data/Settings/ServerGameSettings.json" ]; then
        echo "$data/Settings/ServerGameSettings.json not found. Copying default file."
        cp "$serverhome/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$data/Settings" 2>&1
fi
if [ ! -f "$data/Settings/ServerHostSettings.json" ]; then
        echo "$data/Settings/ServerHostSettings.json not found. Copying default file."
        cp "$serverhome/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$data/Settings" 2>&1
fi
if [ ! -f "$data/Settings/adminlist.txt" ]; then
        echo "$data/Settings/adminlist.txt not found. Copying default file."
        cp "$serverhome/VRisingServer_Data/StreamingAssets/Settings/adminlist.txt" "$data/Settings" 2>&1
fi
if [ ! -f "$data/Settings/banlist.txt" ]; then
        echo "$data/Settings/banlist.txt not found. Copying default file."
        cp "$serverhome/VRisingServer_Data/StreamingAssets/Settings/banlist.txt" "$data/Settings" 2>&1
fi

cd "$serverhome" || {
	echo "Failed to cd to $serverhome"
	exit 1
}

echo "Starting V Rising Dedicated Server"
if [ -e /tmp/.X0-lock ]; then
	rm -f /tmp/.X0-lock 2>&1
fi

wine64 winecfg
sleep 5 # Sleep is important
Xvfb :0 -screen 0 1024x768x16 &
# Use WINEDEBUG=-all to disable all messages or fixme-all to disable fixmes
v() {
	DISPLAY=:0.0 WINEDEBUG=-all wine64 $serverhome/VRisingServer.exe -persistentDataPath "$data" -saveName "$WORLDNAME" 2>&1 &
}
v
# Gets the PID of the last command
ServerPID=$!
wait $ServerPID
