#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <JavaFileName>"
    exit 1
fi

filename=$(basename "$1" .java)
echo $filename

output_dir="/tmp/java"

if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
    echo "Created directory: $output_dir"
fi

javac -d "$output_dir" "$1"
if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi


package=$(grep -oP '^package\s+\K[^\s;]+' "$1")

if [ -z "$package" ]; then
    echo "enter input"
    java -cp "$output_dir" "$filename"
    echo "done"
else
    echo "enter input"
    java -cp "$output_dir" "$package.$filename"
     echo "done"
fi
