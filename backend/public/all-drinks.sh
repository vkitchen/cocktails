#!/usr/bin/env bash

echo "[" > all.json
for f in drinks/*; do
	cat "$f" >> all.json
	echo "," >> all.json
done
# https://stackoverflow.com/questions/4881930/remove-the-last-line-from-a-file-in-bash
# better not to write it but oh well
sed -i '' -e '$ d' all.json
echo "]" >> all.json
