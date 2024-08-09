#!/bin/bash

# 指定当前目录路径
CURRENT_DIR=$(pwd)
SCRIPT_NAME=$(basename "$0")

echo "Step 1: Creating 'todo' and 'todelete' directories"
# 新建 todo 和 todelete 目录
mkdir -p "$CURRENT_DIR/todo"
mkdir -p "$CURRENT_DIR/todelete"
echo "Step 1: 'todo' and 'todelete' directories created"
echo "--------------------------------------------"

# 定义扩展名列表，用于识别视频文件
VIDEO_EXTENSIONS="mp4 mkv avi mov flv wmv m4v webm mpeg mpg"

# 判断一个文件是否为视频文件
is_video_file() {
    local filename=$1
    local extension="${filename##*.}"
    for ext in $VIDEO_EXTENSIONS; do
        if [[ "$ext" == "$extension" ]]; then
            return 0
        fi
    done
    return 1
}

# 定义移动并重命名函数，处理文件名冲突
move_with_rename() {
    local src=$1
    local dest_dir=$2
    local base_name=$(basename "$src")
    local dest="$dest_dir/$base_name"

    # 如果目标文件已存在，则添加编号后缀
    if [[ -e "$dest" ]]; then
        local counter=1
        local filename="${base_name%.*}"
        local extension="${base_name##*.}"
        while [[ -e "$dest_dir/$filename-$counter.$extension" ]]; do
            ((counter++))
        done
        dest="$dest_dir/$filename-$counter.$extension"
    fi

    mv "$src" "$dest"
    echo "Moved: $src -> $dest"
}

echo "Step 2: Moving video files and directories"
# 遍历当前目录的一级子目录和文件
for item in "$CURRENT_DIR"/*; do
    if [[ "$item" == "$CURRENT_DIR/todo" || "$item" == "$CURRENT_DIR/todelete" ]]; then
        continue
    fi

    if [[ "$(basename "$item")" == "$SCRIPT_NAME" ]]; then
        # 忽略本脚本自身
        continue
    fi

    if [[ -f "$item" ]]; then
        if is_video_file "$item"; then
            echo "Moving video file: $item to 'todo'"
            mv "$item" "$CURRENT_DIR/todo/"
        else
            move_with_rename "$item" "$CURRENT_DIR/todelete"
        fi
    elif [[ -d "$item" ]]; then
        empty_directory=true
        for subitem in "$item"/*; do
            empty_directory=false
            if [[ -f "$subitem" ]]; then
                if is_video_file "$subitem"; then
                    echo "Moving video file: $subitem to 'todo'"
                    mv "$subitem" "$CURRENT_DIR/todo/"
                else
                    move_with_rename "$subitem" "$CURRENT_DIR/todelete"
                fi
            elif [[ -d "$subitem" ]]; then
                move_with_rename "$subitem" "$CURRENT_DIR/todelete"
            fi
        done

        if [ "$empty_directory" = true ]; then
            move_with_rename "$item" "$CURRENT_DIR/todelete"
        else
            echo "Moving directory: $item to 'todelete'"
            move_with_rename "$item" "$CURRENT_DIR/todelete"
        fi
    fi
done
echo "Step 2: Video files and directories moved"
echo "--------------------------------------------"

echo "Step 3: Renaming video files in 'todo'"
# 重命名 todo 目录下的文件
for path in "$CURRENT_DIR/todo/"*; do
    base="$(basename "$path")"
    ext="${base##*.}"
    filename="${base%.*}"

    if [[ "$filename" =~ ^([^@]+@)?([a-zA-Z]+)-([0-9]+)(-.*)?$ ]]; then
        newname="${BASH_REMATCH[2]}-${BASH_REMATCH[3]}"
        newname="$(echo "$newname" | tr 'a-z' 'A-Z')"

        newpath="$CURRENT_DIR/todo/$newname.$ext"

        if [[ "$path" == "$newpath" ]]; then
            echo "Skipping: $path (already correct name)"
        elif [[ -e "$newpath" ]]; then
            echo "Skipping: $newpath (name conflict exists)"
        else
            mv "$path" "$newpath"
            echo "Renamed: $path -> $newpath"
        fi
    else
        echo "Skipping: $path (name format not matched)"
    fi
done
echo "Step 3: Renaming process completed"
echo "--------------------------------------------"

echo "Step 4: Creating directories in 'todo' and moving files"
# 在 todo 目录中新建与文件同名的目录，并移动文件到相应的目录中
for path in "$CURRENT_DIR/todo/"*; do
    if [[ -f "$path" ]]; then
        base="$(basename "$path")"
        filename="${base%.*}"
        
        echo "Creating directory: $CURRENT_DIR/todo/$filename and moving file $path"
        mkdir -p "$CURRENT_DIR/todo/$filename"
        mv "$path" "$CURRENT_DIR/todo/$filename/"
    fi
done
echo "Step 4: Directories created and files moved"
echo "--------------------------------------------"

echo "Script execution completed successfully."