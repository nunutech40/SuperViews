import 'dart:ui';

/// RAW IMPELLER/SKIA RENDER DEMO
/// 
/// Ini adalah bukti fisik bahwa Flutter itu sebenarnya cuma game engine kosong.
/// Di file ini, KITA MEM-BYPASS SEMUANYA:
/// 1. Tidak ada import package:flutter/material.dart
/// 2. Tidak ada runApp()
/// 3. Tidak ada StatelessWidget / StatefulWidget
/// 4. Tidak ada Element Tree
/// 5. Tidak ada RenderObject Tree
/// 
/// Kita ngomong LANGSUNG ke C++ Engine (Impeller/Skia) lewat jembatan dart:ui!
/// Cara jalaninnya: ganti entry point di run config ke file ini.

void main() {
  // 1. Mendaftarkan fungsi yang akan dieksekusi mesin setiap kali VSync layar memanggil frame baru.
  // Ini mirip kayak Update() loop di game engine (Unity/Unreal).
  PlatformDispatcher.instance.onBeginFrame = (Duration timeStamp) {
    
    // 2. Siapkan alat rekam (PictureRecorder) dan Kanvas (Jembatan memori ke Impeller)
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // 3. BIKIN DRAW CALL MENTAH (Ngasih tau GPU mau ngecat apa)
    // Kita bikin kotak warna merah yang tajam.
    final paint = Paint()..color = const Color(0xFFFF0000); // 0xFF = Opaque, FF0000 = Merah
    canvas.drawRect(const Rect.fromLTWH(100, 200, 200, 200), paint);

    // Bikin text mentah (Tanpa widget Text!)
    final paragraphStyle = ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: 24.0,
      textDirection: TextDirection.ltr,
    );
    final paragraphBuilder = ParagraphBuilder(paragraphStyle)
      ..pushStyle(TextStyle(color: const Color(0xFF00FF00))) // Hijau
      ..addText('Ini Raw Impeller Engine!');
    
    final paragraph = paragraphBuilder.build();
    paragraph.layout(const ParagraphConstraints(width: 300));
    canvas.drawParagraph(paragraph, const Offset(100, 450));

    // 4. Selesai melukis, simpan rekaman kanvas jadi "Picture"
    final picture = recorder.endRecording();

    // 5. Susun Scene (Kirim hasil rekaman ke layer grafis HP fisik)
    final sceneBuilder = SceneBuilder()
      ..addPicture(Offset.zero, picture);
    final scene = sceneBuilder.build();

    // 6. PERINTAHKAN MESIN C++ (IMPELLER) UNTUK TEMBAK KE GPU!
    final view = PlatformDispatcher.instance.views.first;
    view.render(scene);
  };

  // Pancing mesin (Engine) supaya nge-trigger frame pertamanya,
  // kalau nggak dipancing, layarnya bakal hitam doang nungguin VSync.
  PlatformDispatcher.instance.scheduleFrame();
}
