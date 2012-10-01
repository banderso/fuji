#!/bin/sh
# fuji
# 
# Script to download a playlist segments from youtube and convert them into a
# single audio file. Implemented with the idea to be run via CRON once a day.
#
# youtube-dl and ffmpeg are required to be installed.
# 

# The location of youtube-dl
YTDL=/opt/bin/youtube-dl

# Standard options for youtube-dl
OPTS="-q -i -A"

# Playlist options for youtube-dl
PLOPTS="--playlist-end 100"

# Audio options for youtube-dl
AOPTS="--extract-audio --audio-format mp3 --audio-quality 320k"

# The url of the playlist to download
URL="http://www.youtube.com/playlist?list=UUoQBJMzcwmXrRSHBFAlTsIw"

# The name to give the resulting file
FNAME=`date "+%y-%m-%d"`

# Regex for titles to download
REGEX='.*'`date "+\(%y\/%m\/%d\)"`'$'

# The audio file to place between each audio file from youtube.
# Should be placed in the work directory.
GAP=../gap.mp3

# Audio file to play when done.
# Should be placed in the work directory.
CHIME=../ATOS-3.mp3

# The working directory.
WORKDIR="$HOME/Documents/fuji"

# Check for the work directory and create it if necessary.
if [ ! -d $WORKDIR ]; then
	mkdir $WORKDIR
fi

# The full path to the directory for today.
FULLPATH=$WORKDIR/$FNAME

# Check for today's directory and create it if necessary.
if [ ! -d $FULLPATH ]; then
	mkdir $FULLPATH
fi

# Change to today's directory.
cd $FULLPATH

# Download and process youtube files.
$YTDL $OPTS $PLOPTS --match-title "$REGEX" $AOPTS $URL

# Build concat list.
CONCAT=""
for i in `ls -1ct`; do
	if [ "$CONCAT" == "" ]; then
		CONCAT=$CONCAT$i
	elif [ -f $GAP ]; then
		CONCAT=$CONCAT\|$GAP\|$i
	else
		CONCAT=$CONCAT\|$i
	fi
done

# Build single audio file.
ffmpeg -loglevel panic -i concat:$CONCAT -acodec copy $FNAME.mp3

# Check for successful creation of audio file.
if [ -f $FNAME.mp3 ]; then
	mv $FNAME.mp3 ../$FNAME.mp3

    # Clean up.
	cd ../
	rm -rf ./$FNAME

    # Play chime if file exists.
	if [ -f $CHIME ]; then
		# afplay is specific to OS X
		afplay $CHIME
	fi
fi
