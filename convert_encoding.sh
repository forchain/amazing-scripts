#!/bin/bash

# Default values
FROM_ENCODING="gb2312"
TO_ENCODING="utf-8"
FILE_TYPES=("cs")
TARGET_DIR="."

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--from)
            FROM_ENCODING="$2"
            shift 2
            ;;
        -t|--to)
            TO_ENCODING="$2"
            shift 2
            ;;
        -d|--dir)
            TARGET_DIR="$2"
            shift 2
            ;;
        -e|--extensions)
            IFS=',' read -ra FILE_TYPES <<< "$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-f|--from FROM_ENCODING] [-t|--to TO_ENCODING] [-d|--dir TARGET_DIR] [-e|--extensions ext1,ext2,...]"
            echo "Default values:"
            echo "  FROM_ENCODING: gb2312"
            echo "  TO_ENCODING: utf-8"
            echo "  TARGET_DIR: current directory"
            echo "  FILE_TYPES: txt,md,json,yml,yaml,xml,csv"
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Check if iconv is installed
if ! command -v iconv &> /dev/null; then
    echo "Error: iconv is not installed. Please install it first."
    exit 1
fi

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR does not exist"
    exit 1
fi

# Convert function
convert_file() {
    local file="$1"
    local temp_file="${file}.temp"
    
    echo "Converting: $file"
    if iconv -f "$FROM_ENCODING" -t "$TO_ENCODING" "$file" > "$temp_file"; then
        mv "$temp_file" "$file"
        echo "Successfully converted $file"
    else
        rm -f "$temp_file"
        echo "Failed to convert $file"
        return 1
    fi
}

# Build find command for specified extensions
FIND_EXPR=()
for ext in "${FILE_TYPES[@]}"; do
    FIND_EXPR+=(-o -name "*.$ext")
done

# Remove the first "-o" from the expression
unset 'FIND_EXPR[0]'

# Find and convert files
find "$TARGET_DIR" \( "${FIND_EXPR[@]}" \) -type f | while read -r file; do
    convert_file "$file"
done

echo "Conversion complete!" 