#!/bin/bash

# 保存初始目录
INITIAL_DIR=$(pwd)

# 读取git_repo.txt文件中的git仓库地址
FILE="git_repo.txt"

# 确保文件存在
if [[ ! -f "$FILE" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] 文件 $FILE 不存在"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] 开始处理 $FILE 中的仓库地址"

# 遍历每一行，即每一个git仓库地址
while IFS= read -r REPO; do
    # 使用正则表达式检测并跳过空行或仅包含空白字符的行
    if [[ "$REPO" =~ ^[[:space:]]*$ ]]; then
        continue
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] 处理仓库地址: $REPO"

    # 去掉地址协议部分，提取路径部分
    PATH_PART=$(echo "$REPO" | sed 's#.*:##;s#.git$##')
    
    # 使用斜杠分割路径部分
    IFS='/' read -ra ADDR <<< "$PATH_PART"
    
    # 移除末尾的项目名以得到目录路径
    DIR_PATH=""
    for ((i = 0; i < ${#ADDR[@]} - 1; i++)); do
        if [[ $i -gt 0 ]]; then
            DIR_PATH+="/"
        fi
        DIR_PATH+="${ADDR[$i]}"
        if [[ ! -d "$DIR_PATH" ]]; then
            mkdir "$DIR_PATH"
            echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] 创建目录: $DIR_PATH"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] 目录已存在: $DIR_PATH"
        fi
    done

    # 项目名
    REPO_NAME="${ADDR[-1]}"

    # 进入最终的目标目录
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] 进入目录: $DIR_PATH"
    cd "$DIR_PATH"
    
    # 检查是否已经存在仓库目录
    if [[ -d "$REPO_NAME" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] 仓库 $REPO_NAME 已存在，进入仓库执行更新"
        cd "$REPO_NAME"
        git checkout master
        git pull origin master
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] 仓库 $REPO_NAME 已更新到最新代码"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] 克隆仓库 $REPO"
        git clone "$REPO"
        cd "$REPO_NAME"
        git checkout master
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] 仓库 $REPO_NAME 克隆并切换到 master 分支"
    fi

    # 返回初始的工作目录
    cd "$INITIAL_DIR"

done < "$FILE"

echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] 所有仓库地址处理完毕"