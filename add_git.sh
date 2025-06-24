#!/bin/bash

# --- 配置區 ---
# 主儲存庫的名稱 (將會被創建為一個新目錄)
MAIN_REPO_NAME="vnpy_lib"

# 主儲存庫的遠端 URL (可選，如果沒有，腳本會先在本地創建)
# 如果您還沒有遠端儲存庫，可以先留空
MAIN_REMOTE_URL="git@github.com:mathidot/vnpy_lib.git"

# 排除的目錄列表 (如果某些子目錄有 .git 但您不想作為子模組添加，請在此列出)
EXCLUDE_DIRS=(".git" "$MAIN_REPO_NAME" "node_modules" "build" "dist")
# --- 配置區結束 ---


echo "--- 開始自動設置 Git 子模組 ---"

# 獲取腳本運行目錄的絕對路徑 (這是運行腳本的地方，不是最終的主倉庫目錄)
SCRIPT_DIR=$(pwd)

# === 初始化主儲存庫部分 ===

# 1. 創建並進入主儲存庫目錄
if [ -d "$MAIN_REPO_NAME" ]; then
    echo "錯誤：主儲存庫目錄 '$MAIN_REPO_NAME' 已存在。請移除或更改 MAIN_REPO_NAME。"
    echo "如果您想在現有 '$MAIN_REPO_NAME' 中添加子模組，請先 'cd $MAIN_REPO_NAME' 再執行腳本。"
    exit 1
fi

mkdir "$MAIN_REPO_NAME"
cd "$MAIN_REPO_NAME"
echo "已進入主儲存庫目錄: $(pwd)"

# 2. 初始化主儲存庫
echo "初始化主儲存庫..."
git init
if [ $? -ne 0 ]; then
    echo "錯誤：Git 初始化失敗。"
    exit 1
fi
git branch -M main # 設置主分支為 main
git commit --allow-empty -m "Initial commit for main repository" # 創建一個空提交，以便後續添加遠端

# 3. 添加主儲存庫遠端 (如果已配置)
if [ -n "$MAIN_REMOTE_URL" ]; then
    echo "添加主儲存庫遠端: $MAIN_REMOTE_URL"
    git remote add origin "$MAIN_REMOTE_URL"
    if [ $? -ne 0 ]; then
        echo "警告：添加主儲存庫遠端失敗。您可能需要手動處理。"
    fi
fi

# === 初始化主儲存庫部分結束 ===

echo "掃描 '$SCRIPT_DIR' 下的子目錄以查找獨立 Git 儲存庫..."

# 儲存要添加的子模組列表
declare -a SUBMODULES_TO_ADD

# 遍歷腳本運行目錄下的所有一級子目錄
for dir in "$SCRIPT_DIR"/*/; do
    dir_name=$(basename "$dir")

    # 檢查是否在排除列表中
    EXCLUDED=false
    for exclude_dir in "${EXCLUDE_DIRS[@]}"; do
        if [ "$dir_name" == "$exclude_dir" ]; then
            EXCLUDED=true
            break
        fi
    done
    if [ "$EXCLUDED" == true ]; then
        echo "跳過排除目錄: $dir_name (在排除列表中)"
        continue
    fi

    # 檢查子目錄是否是一個 Git 儲存庫
    if [ -d "$dir/.git" ]; then
        echo "發現獨立 Git 儲存庫: $dir_name"

        # 嘗試獲取子儲存庫的遠端 URL
        pushd "$dir" > /dev/null # 進入子目錄但不打印棧信息
        SUBMODULE_URL=$(git config --get remote.origin.url 2>/dev/null)
        popd > /dev/null # 返回到主儲存庫目錄

        if [ -n "$SUBMODULE_URL" ]; then
            SUBMODULES_TO_ADD+=("$SUBMODULE_URL $dir_name")
            echo "  其遠端 URL 為: $SUBMODULE_URL"
        else
            echo "  警告：子儲存庫 '$dir_name' 沒有配置 'origin' 遠端 URL，將跳過。請手動檢查或配置其遠端。"
        fi
    else
        echo "跳過目錄: $dir_name (不是一個獨立Git儲存庫或不包含.git資料夾)"
    fi
done

# 實際添加子模組
if [ ${#SUBMODULES_TO_ADD[@]} -eq 0 ]; then
    echo "沒有找到需要添加的子模組。"
else
    for submodule_entry in "${SUBMODULES_TO_ADD[@]}"; do
        IFS=' ' read -r SUBMODULE_URL SUBMODULE_PATH <<< "$submodule_entry"

        # === 新增的檢查邏輯 ===
        # 檢查子模組的路徑是否已經存在於主儲存庫的工作目錄或 Git 索引中
        if [ -d "$SUBMODULE_PATH" ] || git ls-files --cached --error-unmatch "$SUBMODULE_PATH" &>/dev/null; then
            echo "跳過子模組 '$SUBMODULE_PATH'：路徑已存在於工作目錄或 Git 索引中。"
            continue # 跳過當前循環，處理下一個子模組
        fi
        # === 新增的檢查邏輯結束 ===

        echo "添加子模組: $SUBMODULE_PATH (來自 $SUBMODULE_URL)..."
        git submodule add "$SUBMODULE_URL" "$SUBMODULE_PATH"
        if [ $? -ne 0 ]; then
            echo "錯誤：添加子模組 '$SUBMODULE_PATH' 失敗。請檢查 URL 或網路連接，或手動清理衝突。"
            # 這裡不 exit 1，允許其他子模組繼續添加
        else
            echo "子模組 '$SUBMODULE_PATH' 已成功添加。"
        fi
    done
fi


echo "提交所有子模組的添加操作..."
# 這裡只添加有變化的文件，避免在沒有添加新子模組時出現提交失敗
git add .
git commit -m "Add all automatically detected submodules"
if [ $? -ne 0 ]; then
    echo "警告：提交子模組失敗。可能沒有變化或有衝突需要手動解決。"
    # 這裡不 exit 1，允許腳本完成，但提示用戶檢查
fi

echo "--- Git 子模組自動設置完成 ---"
echo "現在您可以執行 'git push -u origin main' 將主儲存庫推送到遠端。"
echo "要克隆此主儲存庫並初始化子模組，請使用 'git clone --recursive <MAIN_REMOTE_URL>'"
echo "如果已克隆，要初始化子模組，請使用 'git submodule update --init --recursive'"
