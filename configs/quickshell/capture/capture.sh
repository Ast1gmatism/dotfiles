#!/usr/bin/env bash

GEOM_RAW="$1"
DEST="$2"

echo "GEOM_RAW: $GEOM_RAW" >> /tmp/capture-debug.log
echo "DEST: $DEST" >> /tmp/capture-debug.log

DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
FILEPATH="$DIR/$TIMESTAMP.png"

mkdir -p "$DIR"
sleep 0.25

case "$DEST" in
    clipboard)
        if [ -n "$GEOM_RAW" ]; then
            grim -g "$GEOM_RAW" - | wl-copy
        else
            grim - | wl-copy
        fi
        ;;
    file)
        if [ -n "$GEOM_RAW" ]; then
            grim -g "$GEOM_RAW" "$FILEPATH"
        else
            grim "$FILEPATH"
        fi
        ;;
    both)
        if [ -n "$GEOM_RAW" ]; then
            grim -g "$GEOM_RAW" - | tee "$FILEPATH" | wl-copy
        else
            grim - | tee "$FILEPATH" | wl-copy
        fi
        ;;
esac

if [ $? -eq 0 ]; then
    notify-send -a "Screenshot" "Screenshot Saved"
fi