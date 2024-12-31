#!/bin/bash

TARGET_DIR="."
IGNORE_PATTERN=""
MIN_SIZE="0"
SORT_BY="size" # or "count"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            TARGET_DIR="$2"
            shift 2
            ;;
        -i|--ignore)
            IGNORE_PATTERN="$2"
            shift 2
            ;;
        -m|--min-size)
            MIN_SIZE="$2"
            shift 2
            ;;
        -s|--sort)
            SORT_BY="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-d|--dir DIR] [-i|--ignore PATTERN] [-m|--min-size SIZE] [-s|--sort TYPE]"
            echo "Options:"
            echo "  -d, --dir DIR       Target directory (default: current directory)"
            echo "  -i, --ignore PATTERN Ignore pattern (e.g., 'node_modules|.git')"
            echo "  -m, --min-size SIZE Minimum file size to include (e.g., '1M', '500K')"
            echo "  -s, --sort TYPE     Sort by 'size' or 'count' (default: size)"
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR does not exist"
    exit 1
fi

# Create temporary file
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Function to convert size to bytes
to_bytes() {
    local size="$1"
    local number="${size%[KMGTkmgt]*}"
    local unit="${size##*[0-9]}"
    case "$unit" in
        [Kk]) echo "$number * 1024" | bc ;;
        [Mm]) echo "$number * 1024 * 1024" | bc ;;
        [Gg]) echo "$number * 1024 * 1024 * 1024" | bc ;;
        [Tt]) echo "$number * 1024 * 1024 * 1024 * 1024" | bc ;;
        *) echo "$number" ;;
    esac
}

# Convert MIN_SIZE to bytes
MIN_SIZE_BYTES=$(to_bytes "$MIN_SIZE")

# Function to format size
format_size() {
    local size="$1"
    if [ "$size" -gt $((1024*1024*1024*1024)) ]; then
        echo "$(echo "scale=2; $size/1024/1024/1024/1024" | bc)T"
    elif [ "$size" -gt $((1024*1024*1024)) ]; then
        echo "$(echo "scale=2; $size/1024/1024/1024" | bc)G"
    elif [ "$size" -gt $((1024*1024)) ]; then
        echo "$(echo "scale=2; $size/1024/1024" | bc)M"
    elif [ "$size" -gt 1024 ]; then
        echo "$(echo "scale=2; $size/1024" | bc)K"
    else
        echo "${size}B"
    fi
}

echo "Analyzing directory: $TARGET_DIR"
echo "Collecting statistics..."

# Find all files and process them
if [ -n "$IGNORE_PATTERN" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        find "$TARGET_DIR" -type f ! -path "*/$IGNORE_PATTERN/*" -exec stat -f "%z %N" {} \;
    else
        find "$TARGET_DIR" -type f ! -path "*/$IGNORE_PATTERN/*" -printf "%s %f\n"
    fi
else
    if [[ "$OSTYPE" == "darwin"* ]]; then
        find "$TARGET_DIR" -type f -exec stat -f "%z %N" {} \;
    else
        find "$TARGET_DIR" -type f -printf "%s %f\n"
    fi
fi | while read -r size filename; do
    # Extract just the filename from the full path for macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        filename=$(basename "$filename")
    fi
    
    if [ "$size" -ge "$MIN_SIZE_BYTES" ]; then
        ext="${filename##*.}"
        if [ "$filename" = "$ext" ]; then
            ext="no_extension"
        fi
        # Convert extension to lowercase using tr instead of ${ext,,}
        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
        echo "$ext" "$size"
    fi
done > "$TEMP_FILE"

# Process and display results
echo -e "\nFile Extension Statistics:"
echo "=========================="
echo -e "Extension\tCount\tTotal Size"
echo "------------------------"

if [ "$SORT_BY" = "size" ]; then
    sort_field=3
else
    sort_field=2
fi

awk '
    {
        count[$1]++
        size[$1]+=$2
    }
    END {
        for (ext in count) {
            printf "%s\t%d\t%d\n", ext, count[ext], size[ext]
        }
    }
' "$TEMP_FILE" | sort -k"$sort_field"nr | while read -r ext count size; do
    printf "%-12s\t%5d\t%s\n" "$ext" "$count" "$(format_size "$size")"
done

# Display total statistics
total_count=$(awk '{sum += 1} END {print sum}' "$TEMP_FILE")
total_size=$(awk '{sum += $2} END {print sum}' "$TEMP_FILE")
echo -e "\nTotal Statistics:"
echo "================="
echo "Total Files: $total_count"
echo "Total Size:  $(format_size "$total_size")" 