#!/bin/bash

file=$1

[ ! -f "$file" ] && echo "File \"$file\" does not exist." && exit 1

size1=$(stat --printf="%s" "$file")
sleep 1
size2=$(stat --printf="%s" "$file")

[ "$size2" -gt "$size1" ]
