#!/usr/bin/env bash

file="$1"
[ -f "$file" ] || { echo "Usage: itrim <mediafile>"; exit 1; }

tmp="/tmp/itrim-$UID.txt"
rm -f "$tmp"

# Launch mpv interactively
ITRIM_FILE="$tmp" mpv \
  --force-window=yes \
  --keep-open=yes \
  "$file"

# If user pressed Enter and marker was written
if [[ -s "$tmp" ]]; then
  start=$(cat "$tmp")
  echo "Trimming from $start seconds..."

  ext="${file##*.}"
  tmpout="${file}.trimtmp.$ext"

  if ffmpeg -loglevel error -y -ss "$start" -i "$file" -c copy "$tmpout"; then
    mv -f "$tmpout" "$file"
    echo "✔ Trimmed in place"
  else
    echo "✘ ffmpeg failed"
    rm -f "$tmpout"
  fi
else
  echo "✘ Cancelled"
fi

rm -f "$tmp"
