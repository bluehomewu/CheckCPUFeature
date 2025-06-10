# Check CPU Feature Tool
## 介紹
CheckCPUFeature 是一個用於檢查 CPU 特性（指令集）的小工具，基於 libcpuid 實現。它可以幫助開發者快速瞭解目前系統平台的 CPU 架構和特性。

## 功能
- 檢查 CPU 型號
- 顯示 CPU 支援的指令集

## 使用方法
1. 檢查是否已經安裝 libcpuid
2. 編譯並執行 `detect_with_libcpuid.o`

### Help
如需更多幫助，請參考以下命令：
```bash
./RunMe.sh -h
```

### 執行
```bash
./RunMe.sh
```

## Credits
- [libcpuid](https://github.com/anrieff/libcpuid)
