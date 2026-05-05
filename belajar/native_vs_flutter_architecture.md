# Architecture Deep-Dive: Native vs Flutter Compilation & Runtime Execution

Dokumen ini membedah spesifikasi teknis tingkat arsitek mengenai ekosistem kompilasi, *rendering pipeline*, dan model eksekusi *runtime* dari tiga tumpukan teknologi utama: iOS Native (Swift), Android Native (Kotlin), dan Flutter (Dart).

---

## 1. iOS Native Stack (Swift)
Ekosistem tumpukan vertikal yang sangat teroptimasi karena Apple menguasai perangkat keras dan perangkat lunak secara penuh.

### A. Compilation Pipeline
*   **Compiler:** Menggunakan **LLVM Toolchain** (Clang untuk *frontend*, LLVM untuk *backend*).
*   **Output:** Menerjemahkan kode Swift menjadi *LLVM Intermediate Representation* (IR) sebelum dikompilasi menjadi **ARM64 Native Machine Code** murni.
*   **Optimization:** Memiliki proses *Dead Code Elimination* dan *Inline Expansion* yang sudah berumur puluhan tahun, menghasilkan biner dengan ukuran terkecil dan performa matematis absolut.

### B. Rendering Pipeline
*   **UI Framework:** SwiftUI atau UIKit.
*   **Graphics Driver:** Menggunakan **Metal** (API tingkat rendah Apple) atau CoreGraphics. *Rendering* ditangani langsung oleh OS (Sistem Operasi tidak butuh mesin grafis eksternal karena sudah ditanam di kernel).

### C. Runtime & Memory Model
*   **Memory Management:** **ARC (Automatic Reference Counting)**. 
*   Swift **tidak menggunakan Garbage Collector**. Manajemen memori disisipkan secara statis saat *compile time*. Begitu objek UI tidak dipakai, referensinya mencapai angka 0, dan memori dibebaskan secara deterministik (tanpa *CPU pause* secara tiba-tiba).

---

## 2. Android Native Stack (Kotlin)
Ekosistem yang sangat difragmentasi, dirancang untuk berjalan di atas ribuan arsitektur SoC (System on Chip) yang berbeda.

### A. Compilation Pipeline
*   **Compiler:** Kotlin *Compiler* (`kotlinc`) menerjemahkan kode menjadi JVM Bytecode (`.class`).
*   **Dexing & Shrinking:** Mesin **D8/R8** memproses *bytecode* tersebut menjadi **Dalvik Executable (`.dex`)**. Ini BUKAN *machine code* murni, melainkan *bytecode* tingkat menengah.

### B. Rendering Pipeline
*   **UI Framework:** Jetpack Compose atau XML Android View System.
*   **Graphics Driver:** Komponen UI dirender menggunakan mesin grafis bawaan OS Android (yang ironisnya adalah **Skia**), lalu diteruskan ke GPU melalui **Vulkan** atau **OpenGL ES**.

### C. Runtime & Memory Model
*   **Execution Engine:** Menggunakan **ART (Android Runtime)**. Pada Android modern, ART menggunakan kombinasi hibrida: AOT saat instalasi aplikasi, dan JIT *Profiling* saat aplikasi berjalan (*Runtime*).
*   **Memory Management:** Menggunakan *Tracing / Generational Garbage Collector*. Mekanisme sapu bersih ini berjalan di latar belakang dan seringkali menyebabkan *Stop-The-World Pauses* (Jank/Lag kecil saat GC berjalan di tengah *render frame*).

---

## 3. Flutter Stack (Dart)
Model "Bring Your Own Engine" (Bawa Mesin Sendiri). Menolak menggunakan UI komponen bawaan OS (*Bypass UI Layer*) dan berinteraksi langsung ke API perangkat keras grafis.

### A. Compilation Pipeline
*   **Debug Mode:** Menggunakan **Dart JIT Compiler** yang berjalan di atas Dart VM untuk memungkinkan *Hot Reload* dan evaluasi dinamis.
*   **Release Mode:** Menggunakan **Dart AOT Compiler**. Mengompilasi seluruh logika UI ke bahasa mesin murni (ARM64) dalam bentuk *Shared Object* (`libapp.so`).
*   **Optimization:** Menggunakan teknik **Tree Shaking** (*Aggressive Dead Code Elimination*). *Compiler* menelusuri seluruh *Dependency Graph* dan membuang fungsi/kelas yang tidak terpanggil, menjamin ukuran `libapp.so` setara kecilnya dengan LLVM murni.

### B. Rendering Pipeline (The Impeller Bypass)
*   **UI Framework:** *The Three Trees Architecture* (Widget, Element, RenderObject). Framework ini dijalankan murni oleh kode biner Dart.
*   **Graphics Driver:** Menggunakan **Impeller** (pengganti Skia). Alih-alih menyuruh UIKit/Android View menggambar layar, Dart menyerahkan *Draw Calls* kepada Impeller (yang tertanam dalam `libflutter.so`). Impeller mem- *bypass* *layer* OS UI dan langsung berbicara dengan **Metal** (iOS) atau **Vulkan** (Android). Keunggulan Impeller: Melakukan *precompile shaders* sehingga mencegah *Shader Compilation Jank*.

### C. Runtime & Memory Model
*   **Execution Engine:** Berjalan secara *native* di CPU, namun didampingi oleh *Dart Runtime* (bagian kecil dari `libflutter.so`).
*   **Memory Management:** Menggunakan *Generational Garbage Collector* yang didesain khusus untuk *lifespan* UI Flutter. Karena *Widget* terus-menerus dihancurkan setiap 16ms, GC ini mengkategorikan *Widget* sebagai *Short-lived objects* dan menghancurkannya dalam ruang memori *Nursery* tanpa mem- *pause* *thread* utama UI. Isolasi memori per *Thread* (Isolate) menjamin tidak adanya *Global Locks*.
