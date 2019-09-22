#!/usr/bin/env bash

api='public/api/v1'
declare -a files
files=($api/drinks/*)
pos=$(( ${#files[@]} - 1 ))
last=${files[$pos]}

echo "[" > "$api/drinks.json"
for f in "${files[@]}"; do
	cat "$f" >> "$api/drinks.json"
	if [[ "$f" != "$last" ]]; then
		echo "," >> "$api/drinks.json"
	fi
done
echo "]" >> "$api/drinks.json"
