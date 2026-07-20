import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' show Rect;

import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_litert/flutter_litert.dart';

/// Hasil 5 dari 6 fitur wajah (eye_type tetap manual sesuai Tabel 2.1
/// laporan -- lipatan kelopak mata sulit diturunkan dari landmark 2D).
class FaceFeatures {
  final String faceShape; // dari MobileNetV2 (.tflite)
  final String noseShape; // dari rasio landmark
  final String lipShape; // dari rasio landmark
  final String eyebrowShape; // dari rasio landmark
  final String skinTone; // dari sampling pixel + CIELAB

  FaceFeatures({
    required this.faceShape,
    required this.noseShape,
    required this.lipShape,
    required this.eyebrowShape,
    required this.skinTone,
  });
}

class FaceAnalysisException implements Exception {
  final String message;
  FaceAnalysisException(this.message);
  @override
  String toString() => message;
}

class FaceAnalysisService {
  static const List<String> _faceShapeClasses = [
    'Heart',
    'Oblong',
    'Oval',
    'Round',
    'Square',
  ];

  // NOTE: Angka threshold di bawah ini mengikuti Tabel 2.1 laporan capstone.
  // Sesuai catatan laporan sendiri, threshold ini WAJIB dikalibrasi ulang
  // dengan sampel wajah ber-ground-truth dari makeup artist sebelum dipakai
  // sebagai keputusan final produksi -- ini baru titik awal yang masuk akal.
  static const double _noseFlatMax = 1.2;
  static const double _noseSharpMin = 1.6;
  static const double _lipThinMax = 0.25;
  static const double _lipThickMin = 0.40;
  static const double _eyebrowStraightMax = 0.10;
  static const double _eyebrowHighArchMin = 0.20;

  static Interpreter? _interpreter;
  static List<String>? _labels;

  static Future<void> _ensureModelLoaded() async {
    _interpreter ??= await Interpreter.fromAsset(
      'assets/models/face_shape_model.tflite',
    );
    if (_labels == null) {
      final raw = await rootBundle.loadString(
        'assets/models/face_shape_labels.txt',
      );
      _labels = raw
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  /// Decode file gambar + "bake" orientasi EXIF ke piksel asli. Dipanggil
  /// terpisah oleh [detectSingleFace] dan [analyzeFeatures] pada file yang
  /// SAMA -- karena fungsi ini deterministik, hasilnya identik di kedua
  /// pemanggilan, sehingga koordinat landmark dari [detectSingleFace] tetap
  /// valid dipakai ulang di [analyzeFeatures] meski gambar di-decode ulang.
  static Future<img.Image> _loadOriented(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw FaceAnalysisException('Gagal membaca file gambar.');
    }
    return img.bakeOrientation(decoded);
  }

  static Future<String> _writeTempJpg(img.Image image) async {
    final path =
        '${Directory.systemTemp.path}/face_analysis_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(path).writeAsBytes(img.encodeJpg(image, quality: 95));
    return path;
  }

  /// Validasi "Foto Valid?" (dipanggil segera setelah foto diambil, sebelum
  /// pindah layar). Melempar [FaceAnalysisException] kalau tidak ada wajah
  /// terdeteksi. Mengembalikan [Face] untuk dipakai ulang oleh
  /// [analyzeFeatures] supaya deteksi wajah tidak dijalankan dua kali.
  static Future<Face> detectSingleFace(String imagePath) async {
    final options = FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: false,
      performanceMode: FaceDetectorMode.accurate,
    );
    final faceDetector = FaceDetector(options: options);

    try {
      // FIX PENTING: foto dari kamera (terutama kamera depan) sering punya
      // EXIF orientation berbeda dari foto galeri, dan itu menyebabkan
      // deteksi wajah gagal khusus untuk foto kamera meski wajah jelas
      // terlihat. Solusinya: normalisasi orientasi SENDIRI di Dart dulu
      // (bake EXIF ke piksel asli), baru kirim file HASIL NORMALISASI itu
      // ke ML Kit -- bukan file mentah dari kamera/galeri.
      final oriented = await _loadOriented(imagePath);
      final normalizedPath = await _writeTempJpg(oriented);

      final inputImage = InputImage.fromFilePath(normalizedPath);
      final faces = await faceDetector.processImage(inputImage);

      unawaited(File(normalizedPath).delete().catchError((_) => File(normalizedPath)));

      if (faces.isEmpty) {
        throw FaceAnalysisException(
          'Wajah tidak terdeteksi. Pastikan wajah menghadap kamera secara '
          'frontal dengan pencahayaan cukup, dan tidak ada aksesoris yang '
          'menutupi wajah.',
        );
      }
      // Ambil wajah dengan bounding box terbesar kalau ada lebih dari satu.
      return faces.reduce(
        (a, b) => (a.boundingBox.width * a.boundingBox.height) >
                (b.boundingBox.width * b.boundingBox.height)
            ? a
            : b,
      );
    } finally {
      await faceDetector.close();
    }
  }

  /// Ekstraksi 5 fitur (face_shape, nose_shape, lip_shape, eyebrow_shape,
  /// skin_tone) memakai [face] yang SUDAH didapat dari [detectSingleFace]
  /// (tidak deteksi wajah lagi dari nol).
  static Future<FaceFeatures> analyzeFeatures({
    required String imagePath,
    required Face face,
  }) async {
    await _ensureModelLoaded();

    // Decode ulang file yang SAMA dengan bake-orientation yang SAMA persis
    // seperti saat detectSingleFace() -- deterministik, jadi koordinat
    // landmark di `face` tetap sinkron dengan piksel gambar ini.
    final oriented = await _loadOriented(imagePath);

    final faceShape = await _classifyFaceShape(oriented, face.boundingBox);
    final noseShape = _classifyNoseShape(face);
    final lipShape = _classifyLipShape(face);
    final eyebrowShape = _classifyEyebrowShape(face);
    final skinTone = _classifySkinTone(oriented, face);

    return FaceFeatures(
      faceShape: faceShape,
      noseShape: noseShape,
      lipShape: lipShape,
      eyebrowShape: eyebrowShape,
      skinTone: skinTone,
    );
  }

  // ── MobileNetV2: klasifikasi bentuk wajah ─────────────────────────────
  static Future<String> _classifyFaceShape(img.Image original, Rect box) async {
    // Crop dengan margin 0.25 di semua sisi, MENIRU PERSIS proses crop_face()
    // di script training (train_face_shape_v3.py).
    const margin = 0.25;
    final w = box.width;
    final h = box.height;
    final x1 = (box.left - margin * w).clamp(0, original.width.toDouble());
    final y1 = (box.top - margin * h).clamp(0, original.height.toDouble());
    final x2 = (box.right + margin * w).clamp(0, original.width.toDouble());
    final y2 = (box.bottom + margin * h).clamp(0, original.height.toDouble());

    final cropped = img.copyCrop(
      original,
      x: x1.round(),
      y: y1.round(),
      width: (x2 - x1).round().clamp(1, original.width),
      height: (y2 - y1).round().clamp(1, original.height),
    );
    final resized = img.copyResize(cropped, width: 224, height: 224);

    // Normalisasi rescale=1./255 sesuai ImageDataGenerator saat training.
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );

    final output =
        List.generate(1, (_) => List.filled(_faceShapeClasses.length, 0.0));
    _interpreter!.run(input, output);

    final probs = output[0];
    var bestIdx = 0;
    var bestVal = probs[0];
    for (var i = 1; i < probs.length; i++) {
      if (probs[i] > bestVal) {
        bestVal = probs[i];
        bestIdx = i;
      }
    }
    final labels = _labels;
    if (labels != null && labels.length == _faceShapeClasses.length) {
      return labels[bestIdx];
    }
    return _faceShapeClasses[bestIdx];
  }

  // ── Rasio hidung: tinggi (bridge->tip) / lebar (nostril) ─────────────
  static String _classifyNoseShape(Face face) {
    final bridge = face.contours[FaceContourType.noseBridge]?.points;
    final bottom = face.contours[FaceContourType.noseBottom]?.points;

    if (bridge == null || bridge.isEmpty || bottom == null || bottom.isEmpty) {
      return 'Sedang'; // fallback netral kalau contour tidak terdeteksi
    }

    final top = bridge.first;
    final tip = bridge.last;
    final height = _distance(top, tip);

    final leftMost = bottom.reduce((a, b) => a.x < b.x ? a : b);
    final rightMost = bottom.reduce((a, b) => a.x > b.x ? a : b);
    final width = _distance(leftMost, rightMost);

    if (width == 0) return 'Sedang';
    final ratio = height / width;

    if (ratio < _noseFlatMax) return 'Pesek';
    if (ratio > _noseSharpMin) return 'Mancung';
    return 'Sedang';
  }

  // ── Rasio bibir: tinggi (upper->lower) / lebar (corner-to-corner) ────
  static String _classifyLipShape(Face face) {
    final upperTop = face.contours[FaceContourType.upperLipTop]?.points;
    final lowerBottom = face.contours[FaceContourType.lowerLipBottom]?.points;
    final leftMouth = face.landmarks[FaceLandmarkType.leftMouth]?.position;
    final rightMouth = face.landmarks[FaceLandmarkType.rightMouth]?.position;

    if (upperTop == null ||
        upperTop.isEmpty ||
        lowerBottom == null ||
        lowerBottom.isEmpty ||
        leftMouth == null ||
        rightMouth == null) {
      return 'Sedang';
    }

    final upperMid = upperTop[upperTop.length ~/ 2];
    final lowerMid = lowerBottom[lowerBottom.length ~/ 2];
    final height = _distance(upperMid, lowerMid);
    final width = _distance(leftMouth, rightMouth);

    if (width == 0) return 'Sedang';
    final ratio = height / width;

    if (ratio < _lipThinMax) return 'Tipis';
    if (ratio > _lipThickMin) return 'Tebal';
    return 'Sedang';
  }

  // ── Rasio alis: tinggi arch (baseline->titik tertinggi) / panjang alis ─
  static String _classifyEyebrowShape(Face face) {
    final leftTop = face.contours[FaceContourType.leftEyebrowTop]?.points;
    final rightTop = face.contours[FaceContourType.rightEyebrowTop]?.points;

    final ratios = <double>[];
    for (final points in [leftTop, rightTop]) {
      if (points == null || points.length < 3) continue;
      final start = points.first;
      final end = points.last;
      final baselineLength = _distance(start, end);
      if (baselineLength == 0) continue;

      var maxDist = 0.0;
      for (final p in points) {
        final d = _perpendicularDistance(p, start, end);
        if (d > maxDist) maxDist = d;
      }
      ratios.add(maxDist / baselineLength);
    }

    if (ratios.isEmpty) return 'Soft Arch';
    final avgRatio = ratios.reduce((a, b) => a + b) / ratios.length;

    if (avgRatio < _eyebrowStraightMax) return 'Lurus';
    if (avgRatio > _eyebrowHighArchMin) return 'High Arch';
    return 'Soft Arch';
  }

  // ── Skin tone: sampling pixel dahi & pipi -> rata-rata -> CIELAB L* ──
  static String _classifySkinTone(img.Image original, Face face) {
    final samples = <List<int>>[];

    final leftCheek = face.landmarks[FaceLandmarkType.leftCheek]?.position;
    final rightCheek = face.landmarks[FaceLandmarkType.rightCheek]?.position;
    if (leftCheek != null) {
      samples.addAll(_samplePatch(original, leftCheek.x, leftCheek.y));
    }
    if (rightCheek != null) {
      samples.addAll(_samplePatch(original, rightCheek.x, rightCheek.y));
    }

    final eyebrowTop = face.contours[FaceContourType.leftEyebrowTop]?.points;
    if (eyebrowTop != null && eyebrowTop.isNotEmpty) {
      final box = face.boundingBox;
      final foreheadX = box.left + box.width / 2;
      final eyebrowY = eyebrowTop.map((p) => p.y).reduce((a, b) => a < b ? a : b);
      final foreheadY = (eyebrowY - 0.12 * box.height).round();
      samples.addAll(_samplePatch(original, foreheadX.round(), foreheadY));
    }

    if (samples.isEmpty) return 'Medium'; // fallback aman kalau semua gagal

    final avgR = samples.map((s) => s[0]).reduce((a, b) => a + b) / samples.length;
    final avgG = samples.map((s) => s[1]).reduce((a, b) => a + b) / samples.length;
    final avgB = samples.map((s) => s[2]).reduce((a, b) => a + b) / samples.length;

    final lStar = _rgbToLStar(avgR, avgG, avgB);

    // NOTE: threshold L* berikut estimasi awal, BELUM dikalibrasi dengan
    // ground truth makeup artist (BAB 2.7 laporan) -- wajib divalidasi
    // ulang sebelum dipakai sebagai keputusan final produksi.
    if (lStar >= 70) return 'Very Fair';
    if (lStar >= 55) return 'Fair';
    if (lStar >= 40) return 'Medium';
    return 'Dark';
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  static List<List<int>> _samplePatch(img.Image image, int cx, int cy, {int radius = 5}) {
    final result = <List<int>>[];
    for (var dy = -radius; dy <= radius; dy += radius) {
      for (var dx = -radius; dx <= radius; dx += radius) {
        final x = (cx + dx).clamp(0, image.width - 1);
        final y = (cy + dy).clamp(0, image.height - 1);
        final pixel = image.getPixel(x, y);
        result.add([pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()]);
      }
    }
    return result;
  }

  static double _distance(Point p1, Point p2) {
    final dx = (p1.x - p2.x).toDouble();
    final dy = (p1.y - p2.y).toDouble();
    return sqrt(dx * dx + dy * dy);
  }

  static double _perpendicularDistance(Point p, Point lineStart, Point lineEnd) {
    final x0 = p.x.toDouble();
    final y0 = p.y.toDouble();
    final x1 = lineStart.x.toDouble();
    final y1 = lineStart.y.toDouble();
    final x2 = lineEnd.x.toDouble();
    final y2 = lineEnd.y.toDouble();

    final numerator = ((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1).abs();
    final denominator = sqrt(pow(y2 - y1, 2) + pow(x2 - x1, 2));
    if (denominator == 0) return 0;
    return numerator / denominator;
  }

  /// Konversi sRGB (0-255) -> CIELAB, kembalikan L* saja (lightness).
  static double _rgbToLStar(double r, double g, double b) {
    double toLinear(double c) {
      final cs = c / 255.0;
      return cs <= 0.04045 ? cs / 12.92 : pow((cs + 0.055) / 1.055, 2.4).toDouble();
    }

    final rl = toLinear(r);
    final gl = toLinear(g);
    final bl = toLinear(b);

    final y = 0.2126729 * rl + 0.7151522 * gl + 0.0721750 * bl;

    const yn = 1.0;
    final yr = y / yn;
    final fy = yr > 0.008856 ? pow(yr, 1 / 3).toDouble() : (7.787 * yr + 16 / 116);

    return (116 * fy - 16).clamp(0, 100);
  }
}