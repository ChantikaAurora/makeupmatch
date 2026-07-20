/// Hasil ekstraksi 6 fitur wajah on-device (Bab 3 & Tabel 2.1 laporan).
///
/// Semua nilai string di sini HARUS persis sama (termasuk kapitalisasi)
/// dengan `VALID_VALUES` di `routes/recommend.py` pada backend, karena
/// langsung dikirim sebagai payload JSON ke `/api/recommend`.
class FaceFeatures {
  final String faceShape; // Heart / Oblong / Oval / Round / Square
  final String noseShape; // Pesek / Sedang / Mancung
  final String lipShape; // Tipis / Sedang / Tebal
  final String eyebrowShape; // Lurus / Soft Arch / High Arch
  final String skinTone; // Very Fair / Fair / Medium / Dark

  /// Skor kepercayaan klasifikasi bentuk wajah dari MobileNetV2 (0-1),
  /// disimpan agar bisa ditampilkan di UI ("Bentuk Wajah: Oval (92%)") atau
  /// dipakai untuk memutuskan kapan menawarkan opsi "koreksi manual".
  final double faceShapeConfidence;

  /// Rasio mentah hasil perhitungan landmark, disimpan untuk keperluan
  /// debug/kalibrasi ulang threshold Tabel 2.1 (tidak dikirim ke backend).
  final double noseRatio;
  final double lipRatio;
  final double eyebrowRatio;
  final double skinToneLValue;

  const FaceFeatures({
    required this.faceShape,
    required this.noseShape,
    required this.lipShape,
    required this.eyebrowShape,
    required this.skinTone,
    required this.faceShapeConfidence,
    required this.noseRatio,
    required this.lipRatio,
    required this.eyebrowRatio,
    required this.skinToneLValue,
  });

  @override
  String toString() =>
      'FaceFeatures(faceShape: $faceShape ($faceShapeConfidence), '
      'noseShape: $noseShape (ratio=$noseRatio), '
      'lipShape: $lipShape (ratio=$lipRatio), '
      'eyebrowShape: $eyebrowShape (ratio=$eyebrowRatio), '
      'skinTone: $skinTone (L*=$skinToneLValue))';
}
