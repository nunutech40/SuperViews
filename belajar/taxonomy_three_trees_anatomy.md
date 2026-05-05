# Anatomi Mutlak 3 Kasta UI di Dalam "The Three Trees"

Sesuai permintaan, ini adalah rontgen arsitektur level *Hardcore*. Kita membedah bagaimana 3 Kasta UI (Layout, Gravitasi, Atom) memiliki bentuk tulang punggung yang **berbeda total** saat mereka turun ke level `Element` dan `RenderObject`.

---

## 1. Anatomi Kasta Pengatur Ruang (Layout)
**Sifat Asli:** Mereka punya BANYAK anak (`children: []`).
**Rahasia Mesin:** Di level mesin, mereka berubah wujud menjadi `MultiChildRenderObjectElement` dan menggunakan logika *Flexbox* atau *Stacking* untuk membagi sisa ruang.
*Contoh Kasus: `Column` yang memegang 2 anak.*

```mermaid
graph TD
    classDef widget fill:#e1f5fe,stroke:#01579b,stroke-width:2px;
    classDef element fill:#fff9c4,stroke:#f57f17,stroke-width:2px;
    classDef render fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px;

    %% WIDGET TREE
    subgraph WIDGET_TREE [Kertas Blueprint]
        W1["Column"]:::widget
        W1 --> W2["Widget Anak A"]:::widget
        W1 --> W3["Widget Anak B"]:::widget
    end

    %% ELEMENT TREE
    subgraph ELEMENT_TREE [Mandor / Memory]
        E1["MultiChildRenderObjectElement<br>(Mandor Banyak Anak)"]:::element
        E1 --> E2["Element Anak A"]:::element
        E1 --> E3["Element Anak B"]:::element
    end

    %% RENDER OBJECT TREE
    subgraph RENDEROBJECT_TREE [Bangunan Fisik]
        R1["RenderFlex<br>(Tugasnya murni ngitung Flexbox X/Y)"]:::render
        R1 --> R2["RenderBox A"]:::render
        R1 --> R3["RenderBox B"]:::render
    end

    W1 -.->|"Dipegang oleh"| E1
    E1 ===>|"Menyuruh"| R1
```

---

## 2. Anatomi Kasta Gravitasi & Constraint
**Sifat Asli:** Mereka CUMA punya SATU anak (`child:`). Tugas mereka hanya mencekik leher anaknya (mengurangi ukuran) atau menarik anaknya ke sudut tertentu.
**Rahasia Mesin:** Di level mesin, mereka adalah `SingleChildRenderObjectElement`. Fisiknya menggunakan kotak pelapis (*ProxyBox* / *ShiftedBox*).
*Contoh Kasus: `Center` yang memegang 1 anak.*

```mermaid
graph TD
    classDef widget fill:#e1f5fe,stroke:#01579b,stroke-width:2px;
    classDef element fill:#fff9c4,stroke:#f57f17,stroke-width:2px;
    classDef render fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px;

    %% WIDGET TREE
    subgraph WIDGET_TREE [Kertas Blueprint]
        W1["Center<br>(Gravitasi)"]:::widget
        W1 --> W2["Widget Anak Tunggal"]:::widget
    end

    %% ELEMENT TREE
    subgraph ELEMENT_TREE [Mandor / Memory]
        E1["SingleChildRenderObjectElement<br>(Mandor Anak Tunggal)"]:::element
        E1 --> E2["Element Anak Tunggal"]:::element
    end

    %% RENDER OBJECT TREE
    subgraph RENDEROBJECT_TREE [Bangunan Fisik]
        R1["RenderPositionedBox<br>(Menyuntikkan gaya tarik tengah ke kotak di bawahnya)"]:::render
        R1 --> R2["RenderBox Anak Tunggal"]:::render
    end

    W1 -.->|"Dipegang oleh"| E1
    E1 ===>|"Menyuruh"| R1
```

---

## 3. Anatomi Kasta Atom & Molekul (Batu Bata Fisik)
**Sifat Asli:** Mereka MANDUL (TIDAK punya anak). Merekalah ujung tombak yang benar-benar memegang kuas cat untuk melukis ke layar.
**Rahasia Mesin:** Di level mesin, mereka adalah **Daun Terakhir** (`LeafRenderObjectElement`). RenderObject mereka langsung ngobrol ke mesin C++ Impeller untuk menyalakan lampu *pixel*.
*Contoh Kasus: `ColoredBox` (Warna Merah).*

```mermaid
graph TD
    classDef widget fill:#e1f5fe,stroke:#01579b,stroke-width:2px;
    classDef element fill:#fff9c4,stroke:#f57f17,stroke-width:2px;
    classDef render fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px;

    %% WIDGET TREE
    subgraph WIDGET_TREE [Kertas Blueprint]
        W1["ColoredBox<br>color: red"]:::widget
    end

    %% ELEMENT TREE
    subgraph ELEMENT_TREE [Mandor / Memory]
        E1["LeafRenderObjectElement<br>(Mandor Daun Terakhir / Mandul)"]:::element
    end

    %% RENDER OBJECT TREE
    subgraph RENDEROBJECT_TREE [Bangunan Fisik]
        R1["RenderColoredBox<br>(Tugas murni: Perintahkan Impeller<br>cetak warna RGB merah)"]:::render
    end

    W1 -.->|"Dipegang oleh"| E1
    E1 ===>|"Menyuruh"| R1
```

---

## Rangkuman Otak Cerdas (Cheat Sheet)

Kalau Bos lagi ngebedah kodingan orang atau bikin arsitektur, ingat selalu bentuk anatomi di atas:

1.  **Pengatur Ruang (`MultiChild...`)**: Tugas *RenderObject*-nya berat di **Matematika Koordinat** (ngitung *Flex*, pembagian rasio layar), tapi dia nggak ngecat apa-apa.
2.  **Gravitasi (`SingleChild...`)**: Tugas *RenderObject*-nya murni ngakalin **BoxConstraints** (Batas Min/Max Width/Height) sebelum diteruskan ke anak semata wayangnya.
3.  **Atom (`Leaf...`)**: Tugas *RenderObject*-nya murni **Fisika Cahaya/Warna** (Panggil `canvas.drawRect` atau `canvas.drawText`). Nggak ada lagi hitung-hitungan anak.
