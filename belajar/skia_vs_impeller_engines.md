# Sejarah & Pertarungan Mesin Grafis: Skia vs Impeller vs Dunia

Dokumen ini membedah arsitektur, sejarah, dan pertarungan antara mesin grafis (Graphics Engine) yang menjadi nyawa dari aplikasi Flutter, serta perbandingannya dengan mesin raksasa lain di dunia teknologi.

> **Koreksi Istilah:** Namanya **Skia**, bukan Skylar ya Bos! 😂

---

## 1. Skia (Sang Veteran Serba Bisa)

### A. Sejarah & Tujuan
Skia adalah mesin grafis 2D legendaris yang mulai dikembangkan di awal tahun 2000-an dan diakuisisi oleh Google pada tahun 2005. 
*   **Tujuan Awal:** Didesain sebagai mesin "Sapu Jagat" (*general-purpose*) yang bisa menggambar teks dan bentuk 2D di platform apapun (Web, Desktop, OS). 
*   **Portofolio:** Skia adalah mesin di balik kesuksesan **Google Chrome** (merender halaman web), OS Android itu sendiri (merender komponen UI bawaan), dan Mozilla Firefox. Saat Flutter pertama kali dibuat, tim Google tentu saja memilih Skia karena sudah teruji.

### B. Cara Kerja & Kelemahan Fatal
Skia sangat fleksibel karena ia meracik instruksi cahaya/warna GPU (disebut **Shader**) secara dinamis alias *mendadak di tengah jalan* (JIT / Runtime).
*   **Kelebihan:** Sangat matang (umurnya 20 tahun lebih), fitur melukisnya paling komplit di dunia, dan ukuran *file*-nya sangat padat.
*   **Kekurangan (Penyakit Jank):** Karena Skia meracik *Shader* secara dadakan, saat Flutter butuh menggambar animasi baru (terutama di arsitektur Apple Metal), Skia harus mem-*pause* layar (nge-lag) selama sekian ratus milidetik untuk meracik rumusnya. Ini yang disebut **Shader Compilation Jank**. Di dunia *Mobile* modern yang menuntut 120 FPS, sifat "meracik mendadak" ini adalah dosa besar.

---

## 2. Impeller (Pasukan Khusus Pembunuh Jank)

### A. Sejarah & Tujuan
Karena Skia terlalu besar dan umurnya sudah tua, sangat sulit mengubah pondasi inti Skia tanpa merusak Google Chrome. Akhirnya, pada tahun 2021, tim Google memutuskan untuk membangun mesin grafis baru **dari nol murni**.
*   **Tujuan:** Diciptakan 100% **HANYA** untuk melayani arsitektur Flutter. Impeller tidak dirancang untuk Web Browser atau OS lain. Fokus tunggalnya adalah: Mengirim jutaan pixel ke GPU dengan kecepatan penuh tanpa lag di iOS dan Android modern.

### B. Cara Kerja & Keunggulan
Alih-alih meracik rumus di tengah jalan, Impeller melakukan kompilasi semua resep *Shader* **di awal (Pre-compiled / AOT Shaders)** saat *developer* melakukan *Build APK/IPA*.
*   **Kelebihan Mutlak:** Mengeliminasi 100% *Shader Compilation Jank*. Animasi akan berjalan sangat mulus (120 FPS) sejak sentuhan detik pertama. Impeller juga dirancang spesifik untuk arsitektur GPU terkini seperti **Metal** (Apple) dan **Vulkan** (Android) tanpa terbebani kode *legacy* jadul seperti OpenGL.
*   **Kekurangan:** 
    1. Usianya masih bayi (Rilis stabil di iOS baru di Flutter 3.10), jadi terkadang masih ada *bug visual* minor di OS Android.
    2. Ukuran *binary* aplikasi sedikit lebih besar, karena *file* harus menampung seluruh kemungkinan resep *Shader* yang sudah di-*compile* dari pabrik.

---

## 3. Perbandingan dengan Engine Grafis Lain di Dunia

Bagaimana posisi Skia dan Impeller jika diadu dengan mesin-mesin grafis lain yang menguasai dunia?

### A. CoreGraphics / Quartz 2D (Milik Apple)
*   **Fokus:** Mesin eksklusif murni bawaan iOS dan macOS.
*   **Karakteristik:** Sangat, sangat mulus dan sangat dioptimasi untuk baterai iPhone. 
*   **Kelemahan:** Sistem tertutup (*Vendor-locked*). Kode gambar yang ditulis di CoreGraphics tidak akan pernah bisa dijalankan di Android atau Windows.

### B. WebRender (Milik Mozilla / Firefox)
*   **Fokus:** Mesin modern yang ditulis menggunakan bahasa **Rust**. 
*   **Karakteristik:** Memiliki filosofi yang sangat mirip dengan Impeller. WebRender mencoba memindahkan sebanyak mungkin tugas melukis 2D dari CPU langsung ke GPU (*Hardware Accelerated*). Ini adalah alasan kenapa Firefox modern sekarang sangat cepat.

### C. Cairo (Sang Legenda Linux)
*   **Fokus:** Mesin *Open Source* legendaris yang menjadi nyawa grafis dari sistem operasi Linux (dipakai oleh GNOME dan GTK).
*   **Karakteristik:** Fokus pada akurasi warna dan cetak (PDF). Namun, usianya sangat tua dan lebih banyak mengandalkan tenaga CPU murni (*Software Rendering*) dibanding GPU. Sangat berat jika dipakai untuk animasi UI 120 FPS modern.

### D. Unreal Engine / Unity (Sang Monster 3D)
*   **Fokus:** Mesin *Game* 3D kelas berat.
*   **Karakteristik:** Mengobrol langsung ke GPU menggunakan C++ untuk merender jutaan poligon 3D (*Genshin Impact, PUBG*).
*   **Kelemahan untuk UI:** Mengapa Flutter tidak pakai Unity aja sekalian? Karena mesin 3D ini "merender layar secara paksa" setiap 16ms tanpa peduli layar sedang diam atau bergerak. Memakai *Game Engine* untuk aplikasi *News App* atau *Chatting* akan membuat baterai HP habis dalam waktu 1 jam. Flutter (Impeller) cukup pintar untuk hanya merender ulang (*Rebuild*) kotak pixel yang berubah saja.

---

**Kesimpulan:**
Impeller adalah **puncak evolusi** dari penderitaan *developer mobile*. Google rela membakar miliaran dolar untuk meninggalkan kenyamanan Skia, murni demi mengamankan tahta Flutter sebagai *Framework Cross-Platform* dengan performa paling setara dengan Native!
