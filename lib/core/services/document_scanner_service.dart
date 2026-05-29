import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../theme/neu_colors.dart';

/// Document filter types available for scanned documents.
enum DocumentFilter {
  /// Original image — no processing applied
  original,

  /// Grayscale — converts to black & white tones
  grayscale,

  /// High contrast B&W — sharp document look (like CamScanner)
  documentBW,

  /// Enhanced color — brighter background, sharper text
  enhancedColor,

  /// Magic color — auto-levels with vibrant colors preserved
  magicColor,
}

/// Extension to provide Arabic labels and icons for each filter.
extension DocumentFilterExtension on DocumentFilter {
  String get arabicLabel {
    switch (this) {
      case DocumentFilter.original:
        return 'الأصلي';
      case DocumentFilter.grayscale:
        return 'رمادي';
      case DocumentFilter.documentBW:
        return 'أبيض وأسود';
      case DocumentFilter.enhancedColor:
        return 'محسّن';
      case DocumentFilter.magicColor:
        return 'ألوان ذكية';
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentFilter.original:
        return Icons.image_rounded;
      case DocumentFilter.grayscale:
        return Icons.filter_b_and_w_rounded;
      case DocumentFilter.documentBW:
        return Icons.contrast_rounded;
      case DocumentFilter.enhancedColor:
        return Icons.auto_fix_high_rounded;
      case DocumentFilter.magicColor:
        return Icons.auto_awesome_rounded;
    }
  }
}

/// Professional document scanner service.
///
/// Provides camera/gallery capture → interactive crop → document filters.
/// Designed to produce CamScanner-quality scanned documents.
class DocumentScannerService {
  DocumentScannerService._();
  static final DocumentScannerService _instance = DocumentScannerService._();
  factory DocumentScannerService() => _instance;

  final _picker = ImagePicker();

  /// Capture a single image from the camera, crop it, and apply a filter.
  ///
  /// Returns the processed [File], or null if the user cancelled.
  Future<File?> scanFromCamera({
    DocumentFilter filter = DocumentFilter.documentBW,
  }) async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (image == null) return null;

      final croppedFile = await cropImage(File(image.path));
      if (croppedFile == null) return null;

      return await applyFilter(croppedFile, filter);
    } catch (e) {
      debugPrint('DocumentScannerService.scanFromCamera error: $e');
      return null;
    }
  }

  /// Select multiple images from gallery, crop each, and apply a filter.
  ///
  /// Returns a list of processed [File]s. Empty list if cancelled.
  Future<List<File>> scanFromGallery({
    DocumentFilter filter = DocumentFilter.documentBW,
  }) async {
    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 100,
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (images.isEmpty) return [];

      final results = <File>[];
      for (final xfile in images) {
        final croppedFile = await cropImage(File(xfile.path));
        if (croppedFile != null) {
          final processed = await applyFilter(croppedFile, filter);
          if (processed != null) {
            results.add(processed);
          }
        }
      }
      return results;
    } catch (e) {
      debugPrint('DocumentScannerService.scanFromGallery error: $e');
      return [];
    }
  }

  /// Crop an image interactively using the system crop UI.
  ///
  /// Provides a professional crop interface with A4-like aspect ratios.
  Future<File?> cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'قص المستند',
            toolbarColor: NeuColors.navyDeep,
            toolbarWidgetColor: Colors.white,
            backgroundColor: NeuColors.bgColorDark,
            activeControlsWidgetColor: NeuColors.goldAccent,
            cropFrameColor: NeuColors.goldAccent,
            cropGridColor: NeuColors.goldAccent.withAlpha(80),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio3x2,
            ],
          ),
          IOSUiSettings(
            title: 'قص المستند',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio3x2,
            ],
          ),
        ],
      );

      if (croppedFile == null) return null;
      return File(croppedFile.path);
    } catch (e) {
      debugPrint('DocumentScannerService.cropImage error: $e');
      // If cropping fails, return the original image
      return imageFile;
    }
  }

  /// Apply a document enhancement filter to an image file.
  ///
  /// Returns a new [File] with the filter applied.
  Future<File?> applyFilter(File imageFile, DocumentFilter filter) async {
    if (filter == DocumentFilter.original) return imageFile;

    try {
      final bytes = await imageFile.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) return imageFile;

      img.Image processed;
      switch (filter) {
        case DocumentFilter.grayscale:
          processed = _applyGrayscale(original);
          break;
        case DocumentFilter.documentBW:
          processed = _applyDocumentBW(original);
          break;
        case DocumentFilter.enhancedColor:
          processed = _applyEnhancedColor(original);
          break;
        case DocumentFilter.magicColor:
          processed = _applyMagicColor(original);
          break;
        case DocumentFilter.original:
          return imageFile;
      }

      // Save processed image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${tempDir.path}/scanned_$timestamp.jpg';
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(
        Uint8List.fromList(img.encodeJpg(processed, quality: 92)),
      );

      return outputFile;
    } catch (e) {
      debugPrint('DocumentScannerService.applyFilter error: $e');
      return imageFile;
    }
  }

  /// Grayscale filter — simple desaturation
  img.Image _applyGrayscale(img.Image source) {
    try {
      return img.grayscale(source);
    } catch (e) {
      debugPrint('Grayscale filter error: $e');
      return source;
    }
  }

  /// Document B&W filter — high-contrast black & white for clear text.
  ///
  /// Steps: grayscale → normalize → contrast → brighten → sharpen
  img.Image _applyDocumentBW(img.Image source) {
    try {
      // Step 1: Convert to grayscale
      var result = img.grayscale(source);

      // Step 2: Normalize to use full dynamic range
      result = img.normalize(result, min: 0, max: 255);

      // Step 3: Adjust contrast for sharper text
      result = img.adjustColor(result, contrast: 1.6);

      // Step 4: Brighten background slightly
      result = img.adjustColor(result, brightness: 1.15);

      // Step 5: Sharpen for crisp text edges
      result = img.convolution(result, filter: [
        -0.5, -1, -0.5,
        -1, 7, -1,
        -0.5, -1, -0.5,
      ]);

      return result;
    } catch (e) {
      debugPrint('DocumentBW filter error: $e');
      // Fallback: return simple grayscale
      try { return img.grayscale(source); } catch (_) { return source; }
    }
  }

  /// Enhanced color filter — brighter backgrounds with vivid text.
  img.Image _applyEnhancedColor(img.Image source) {
    try {
      var result = img.adjustColor(
        source,
        contrast: 1.3,
        brightness: 1.1,
        saturation: 1.1,
      );

      // Sharpen
      result = img.convolution(result, filter: [
        0, -0.5, 0,
        -0.5, 3, -0.5,
        0, -0.5, 0,
      ]);

      return result;
    } catch (e) {
      debugPrint('EnhancedColor filter error: $e');
      return source;
    }
  }

  /// Magic color filter — auto-level with vibrant preserved colors.
  img.Image _applyMagicColor(img.Image source) {
    try {
      // Normalize to stretch histogram
      var result = img.normalize(source, min: 10, max: 245);

      // Boost contrast and saturation
      result = img.adjustColor(
        result,
        contrast: 1.4,
        brightness: 1.08,
        saturation: 1.25,
      );

      // Moderate sharpen
      result = img.convolution(result, filter: [
        0, -0.3, 0,
        -0.3, 2.2, -0.3,
        0, -0.3, 0,
      ]);

      return result;
    } catch (e) {
      debugPrint('MagicColor filter error: $e');
      return source;
    }
  }
}
