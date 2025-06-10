#include <iostream>
#include <libcpuid.h>  // libcpuid 主標頭

/*
- 安裝環境依賴項
sudo apt-get update                                              
sudo apt-get install git autoconf automake libtool pkg-config build-essential -y
- 手動安裝 libcpuid v0.8.0
1. 下載 libcpuid 源碼：
wget https://github.com/anrieff/libcpuid/releases/download/v0.8.0/libcpuid-0.8.0.tar.gz
2. 解壓縮：
tar zxvf libcpuid-0.8.0.tar.gz
3. 進入目錄：
cd libcpuid-0.8.0
4. 編譯和安裝：
./configure --prefix=/usr
make
sudo make install
sudo ldconfig
5. 確認安裝：
pkg-config --modversion libcpuid

- 手動安裝 libcpuid v0.8.0 的原因是因為 Ubuntu-22.04 apt 源提供的 libcpuid 版本是 v0.5.1，這個版本不支援 AMD 的 AVX512 指令集，至少要 v0.7.0 才支援偵測 AMD CPU 的 AVX512。
*/

int main() {
    // 1. 確認是否支援 CPUID
    if (!cpuid_present()) {
        std::cerr << "Error: CPUID instruction is not supported on this CPU.\n";
        return 1;
    }
    // 

    // 2. 取得原始 CPUID 資料
    struct cpu_raw_data_t raw;
    if (cpuid_get_raw_data(&raw) < 0) {
        std::cerr << "Error obtaining raw CPUID data: " 
                  << cpuid_error() << "\n";
        return 1;
    }
    // 

    // 3. 解碼至高階資料結構
    struct cpu_id_t data;
    if (cpu_identify(&raw, &data) < 0) {
        std::cerr << "Error identifying CPU: " 
                  << cpuid_error() << "\n";
        return 1;
    }
    // 

    // 4. 列印基本 CPU 資訊
    std::cout << "Vendor      : " << data.vendor_str << "\n"
              << "Brand       : " << data.brand_str  << "\n"
              << "CPU Codename: " << data.cpu_codename << "\n"
              << "Family      : " << data.family
              << " (ext: "   << data.ext_family << ")\n"
              << "Model       : " << data.model
              << " (ext: "   << data.ext_model  << ")\n"
              << "Stepping    : " << data.stepping  << "\n\n";
    // 

    // 5. 列舉所有支援的指令集
    std::cout << "=== Supported CPU Features ===\n";
    for (int i = 0; i < CPU_FLAGS_MAX; ++i) {
        if (data.flags[i]) {
            // 將枚舉值轉為對應字串，如 "sse2", "avx2"…
            std::cout << cpu_feature_str((cpu_feature_t)i) << "\n";
        }
    }
    // 

    return 0;
}
