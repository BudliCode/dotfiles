#! /bin/bash
status=$(playerctl loop)
echo $status

if [ $status = 'None' ]; then
	playerctl loop Playlist
elif [ $status = 'Playlist' ]; then
	playerctl loop Track
elif [ $status = 'Track' ]; then
	playerctl loop None
fi
