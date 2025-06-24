#!/bin/bash

echo "--- 開始刪除所有一級子目錄中的 .github 文件夾 ---"
echo "警告：此操作不可逆，將永久刪除子儲存庫的 Git 歷史記錄。"
read -p "您確定要繼續嗎？ (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "操作已取消。"
    exit 0
fi

# 獲取當前腳本運行目錄的絕對路徑
CURRENT_DIR=$(pwd)

echo "掃描當前目錄 '$CURRENT_DIR' 下的子目錄..."

# 遍歷當前目錄下的所有一級子目錄
for dir in "$CURRENT_DIR"/*/; do
    # 獲取目錄名稱
    dir_name=$(basename "$dir")

    # 檢查子目錄中是否存在 .git 文件夾
    if [ -d "$dir/.github" ]; then
        echo "發現 '$dir_name' 包含 .git 文件夾，正在刪除..."
        rm -rf "$dir/.github"
        if [ $? -eq 0 ]; then
            echo "成功刪除 '$dir_name/.github'"
        else
            echo "錯誤：無法刪除 '$dir_name/.github'。請檢查權限。"
        fi
    else
        echo "跳過 '$dir_name'：不包含 .github 文件夾。"
    fi
done

echo "--- .github 文件夾刪除完成 ---"
