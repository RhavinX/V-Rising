#!/bin/bash

s=/home/VRisingServer
d=/data
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

mkdir -p /root/.steam 2>/dev/null
chmod -R 777 /root/.steam 2>/dev/null

echo " "
if ! grep -o 'avx[^ ]*' /proc/cpuinfo; then
	unsupported_file="VRisingServer_Data/Plugins/x86_64/lib_burst_generated.dll"
	echo "AVX or AVX2 not supported; Check if unsupported ${unsupported_file} exists"
	if [ -f "${s}/${unsupported_file}" ]; then
		echo "Changing ${unsupported_file} as attempt to fix issues..."
		mv "${s}/${unsupported_file}" "${s}/${unsupported_file}.bak"
	fi
fi

if [ -z "$WORLDNAME" ]; then
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

cd "$s" || {
	echo "Failed to cd to $s"
	exit 1
}
echo "Starting V Rising Dedicated Server"
echo "Trying to remove /tmp/.X0-lock"
rm -f /tmp/.X0-lock 2>&1

# Added from https://github.com/ldeazevedo/docker-vrising/blob/main/start.sh
echo "Generating initial Wine configuration..."
wine64 winecfg
sleep 5

echo " "
echo "Starting Xvfb"
Xvfb :0 -screen 0 1024x768x16 & \
echo "Launching wine64 V Rising"
echo " "
v() {
	DISPLAY=:0.0 wine64 /home/VRisingServer/VRisingServer.exe -persistentDataPath "$d" -saveName "$WORLDNAME" 2>&1 &
}
v
# Gets the PID of the last command
ServerPID=$!
wait $ServerPID
