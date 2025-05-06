#!/bin/bash

input_file="$HOME/.config/neofetch/pngs/jotaro_kujo_base.png"
overlay_file="$HOME/.config/neofetch/pngs/jotaro_kujo_overlay.png"
output_file="$HOME/.config/neofetch/pngs/current.png"

palette_colors="/tmp/palette.txt"
palette_image="/tmp/palette.png"
alpha_image="/tmp/alpha_channel.png"
remapped_image="/tmp/remapped_image_no_alpha.png"

swww_cache="$HOME/.cache/thumbnails/neofetch/cachedswwwquery"

current_swww=$(swww query | sed -n 's/.*currently displaying: image: //p' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [[ -f "$swww_cache" ]]; then
  cached_swww=$(cat "$swww_cache" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  if [[ "$current_swww" == "$cached_swww" ]]; then
    exit 0
  fi
fi

magick "$current_swww" -resize 100x100^ -gravity center -extent 100x100 -colors 50 -unique-colors txt:- | \
  grep -oP '#[0-9A-Fa-f]{6}' > "$palette_colors"
echo "#000000" >> "$palette_colors" 
magick -size "$(wc -l < $palette_colors)x1" \
  $(awk '{print "xc:" $1}' "$palette_colors") +append "$palette_image"
magick "$input_file" -alpha extract "$alpha_image"
magick "$input_file" +dither -remap "$palette_image" -alpha off "$remapped_image"
magick "$remapped_image" "$alpha_image" -alpha off -compose CopyOpacity -composite "$output_file"
magick "$output_file" "$overlay_file" -alpha Set -compose Over -composite "$output_file"

rm "$palette_colors" "$alpha_image" "$remapped_image" "$palette_image"
rm -f ~/.cache/thumbnails/neofetch/*

echo "$current_swww" > "$swww_cache"
