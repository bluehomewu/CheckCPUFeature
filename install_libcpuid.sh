#!/usr/bin/env bash
# install_libcpuid.sh
# 用途：
#   - 預設：檢查 libcpuid 版本，若 <0.8.0 則手動編譯安裝；>=0.8.0 則跳過。
#   - 加上 -f 或 --force：不論版本，一律手動 (重新) 編譯安裝 v0.8.0。

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

manual_install() {
    echo "==> 開始手動編譯安裝 libcpuid v0.8.0"
    sudo apt-get update
    sudo apt-get install -y git autoconf automake libtool pkg-config build-essential wget tar

    TMPDIR=$(mktemp -d)
    echo "下載 libcpuid-0.8.0 原始碼至 $TMPDIR"
    wget -qO "${TMPDIR}/libcpuid-0.8.0.tar.gz" \
        https://github.com/anrieff/libcpuid/releases/download/v0.8.0/libcpuid-0.8.0.tar.gz

    tar -xzf "${TMPDIR}/libcpuid-0.8.0.tar.gz" -C "${TMPDIR}"
    cd "${TMPDIR}/libcpuid-0.8.0"

    echo "執行 ./configure --prefix=/usr"
    ./configure --prefix=/usr
    echo "執行 make"
    make -j"$(nproc)"
    echo "執行 sudo make install"
    sudo make install
    sudo ldconfig

    cd - >/dev/null
    rm -rf "$TMPDIR"
    echo "==> libcpuid v0.8.0 安裝完成"
}

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTION]
  -f, --force    強制 (重新) 手動編譯安裝 libcpuid v0.8.0
  -h, --help     顯示此說明
無參數時，執行以下流程：
  1. 透過 pkg-config 檢查 libcpuid 版本
  2. 若未安裝，apt 安裝 libcpuid-dev 測試版本
  3. 若版本 <0.8.0，手動編譯安裝 v0.8.0；否則跳過安裝
EOF
    exit 1
}

# 參數解析
FORCE_INSTALL=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force)
            FORCE_INSTALL=1
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ $FORCE_INSTALL -eq 1 ]]; then
    echo "==> 強制 (重新) 安裝模式 開始"
    manual_install
    exit 0
fi

echo "==> 檢查 libcpuid 是否已安裝 (透過 pkg-config)"
if pkg-config --exists libcpuid; then
    version=$(pkg-config --modversion libcpuid)
    echo "找到 libcpuid 版本：$version"
    # 以 sort -V 比較版本
    if [[ "$(printf '%s\n' "0.8.0" "$version" | sort -V | head -n1)" = "0.8.0" ]]; then
        echo "版本已 ≥ 0.8.0，無需安裝。"
        exit 0
    else
        echo "版本 < 0.8.0，將進行手動編譯安裝。"
        manual_install
        exit 0
    fi
else
    echo "libcpuid 未安裝，先透過 apt 安裝 libcpuid-dev 以測試版本…"
    sudo apt-get update
    sudo apt-get install -y libcpuid-dev

    if pkg-config --exists libcpuid; then
        version=$(pkg-config --modversion libcpuid)
    else
        version="0"
    fi
    echo "apt 安裝後 libcpuid 版本：$version"

    if [[ "$(printf '%s\n' "0.8.0" "$version" | sort -V | head -n1)" = "0.8.0" ]]; then
        echo "版本已 ≥ 0.8.0，apt 版足夠使用。"
        exit 0
    else
        echo "版本 < 0.8.0，將進行手動編譯安裝。"
        manual_install
        exit 0
    fi
fi
