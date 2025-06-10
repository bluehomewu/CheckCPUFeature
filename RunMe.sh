#!/usr/bin/env bash
# RunMe.sh
# 1. 執行 libcpuid 安裝程式
# 2. 編譯 detect_with_libcpuid.cpp
# 3. 執行 detect_with_libcpuid.o

set -euo pipefail

# 1. 執行 libcpuid 安裝 (可傳遞 -f 參數強制手動安裝)
if [[ -x ./install_libcpuid.sh ]]; then
    echo "==> 安裝/檢查 libcpuid"
    bash ./install_libcpuid.sh "$@"
else
    echo "Error: 找不到 install_libcpuid.sh，請放在相同目錄後再執行此腳本。"
    exit 1
fi


# echo 空白行
echo ""
# 2. 編譯 detect_with_libcpuid.cpp
SRC="detect_with_libcpuid.cpp"
OUT="detect_with_libcpuid.o"
if [[ ! -f "$SRC" ]]; then
    echo "Error: 找不到 $SRC，請確保它存在於當前目錄。"
    exit 1
fi
echo "==> 編譯 $SRC → $OUT"
g++ -std=c++17 -O2 \
    -Wno-deprecated-declarations \
    `pkg-config --cflags libcpuid` \
    "$SRC" \
    `pkg-config --libs libcpuid` \
    -o "$OUT"

# 3. 執行編譯後的可執行檔
echo "==> 執行 $OUT"
./"$OUT"
