import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import '../../core/errors/exceptions.dart' as app_exceptions;
import '../../core/utils/logger.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;

  // Initialize cameras
  Future<void> initializeCameras() async {
    try {
      // Ensure that plugin services are initialized
      WidgetsFlutterBinding.ensureInitialized();
      _cameras = await availableCameras();
    } catch (e) {
      throw const app_exceptions.CameraException(
          message: 'Failed to initialize cameras');
    }
  }

  // Check camera permission
  Future<bool> checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      throw app_exceptions.CameraPermissionException(
          message: 'Failed to check camera permission: $e');
    }
  }

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      throw app_exceptions.CameraPermissionException(
          message: 'Failed to request camera permission: $e');
    }
  }

  // Check and request camera permissions
  Future<bool> ensureCameraPermissions() async {
    try {
      if (await checkCameraPermission()) {
        return true;
      }

      final granted = await requestCameraPermission();
      if (!granted) {
        throw const app_exceptions.CameraPermissionException(
          message:
              'Camera permission denied. Please grant camera access to take photos.',
        );
      }

      return true;
    } catch (e) {
      if (e is app_exceptions.CameraPermissionException) {
        rethrow;
      }
      throw const app_exceptions.CameraPermissionException(
          message: 'Error checking camera permissions');
    }
  }

  // Take photo with camera
  Future<File> takePhoto() async {
    try {
      await ensureCameraPermissions();

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo == null) {
        throw const app_exceptions.CameraException(
            message: 'No photo was taken');
      }

      return File(photo.path);
    } catch (e) {
      if (e is app_exceptions.CameraException ||
          e is app_exceptions.CameraPermissionException) {
        rethrow;
      }
      throw const app_exceptions.CameraException(
          message: 'Failed to take photo');
    }
  }

  // Pick photo from gallery
  Future<File> pickFromGallery() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo == null) {
        throw const app_exceptions.CameraException(
            message: 'No photo was selected');
      }

      return File(photo.path);
    } catch (e) {
      if (e is app_exceptions.CameraException) {
        rethrow;
      }
      throw const app_exceptions.CameraException(
          message: 'Failed to pick photo from gallery');
    }
  }

  // Show photo source selection dialog
  Future<File?> showPhotoSourceDialog(BuildContext context) async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Photo Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (source == null) return null;

      switch (source) {
        case ImageSource.camera:
          return await takePhoto();
        case ImageSource.gallery:
          return await pickFromGallery();
      }
    } catch (e) {
      if (e is app_exceptions.CameraException ||
          e is app_exceptions.CameraPermissionException) {
        rethrow;
      }
      throw const app_exceptions.CameraException(
          message: 'Failed to get photo');
    }
  }

  // Initialize camera controller for custom camera UI
  Future<CameraController> initializeCameraController({
    CameraLensDirection direction = CameraLensDirection.back,
  }) async {
    try {
      await ensureCameraPermissions();

      if (_cameras == null) {
        await initializeCameras();
      }

      if (_cameras == null || _cameras!.isEmpty) {
        throw const app_exceptions.CameraException(
            message: 'No cameras available');
      }

      // Find camera with specified direction
      CameraDescription? selectedCamera;
      for (final camera in _cameras!) {
        if (camera.lensDirection == direction) {
          selectedCamera = camera;
          break;
        }
      }

      selectedCamera ??= _cameras!.first;

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      return _cameraController!;
    } catch (e) {
      if (e is app_exceptions.CameraException ||
          e is app_exceptions.CameraPermissionException) {
        rethrow;
      }
      throw const app_exceptions.CameraException(
          message: 'Failed to initialize camera controller');
    }
  }

  // Take photo with camera controller
  Future<File> takePhotoWithController() async {
    try {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        throw const app_exceptions.CameraException(
            message: 'Camera not initialized');
      }

      final XFile photo = await _cameraController!.takePicture();
      return File(photo.path);
    } catch (e) {
      if (e is app_exceptions.CameraException) {
        rethrow;
      }
      throw const app_exceptions.CameraException(
          message: 'Failed to take photo with controller');
    }
  }

  // Dispose camera controller
  Future<void> disposeCameraController() async {
    try {
      await _cameraController?.dispose();
      _cameraController = null;
    } catch (e) {
      // Log error but don't throw
      Logger.warning('Error disposing camera controller',
          tag: 'CameraService', error: e);
    }
  }

  // Get available cameras
  List<CameraDescription> get cameras => _cameras ?? [];

  // Check if camera is initialized
  bool get isCameraInitialized =>
      _cameraController?.value.isInitialized ?? false;

  // Get camera controller
  CameraController? get cameraController => _cameraController;

  // Validate image file
  bool isValidImageFile(File file) {
    try {
      final extension = file.path.split('.').last.toLowerCase();
      return ['jpg', 'jpeg', 'png'].contains(extension);
    } catch (e) {
      return false;
    }
  }

  // Get image file size in MB
  double getImageSizeInMB(File file) {
    try {
      final bytes = file.lengthSync();
      return bytes / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }

  // Compress image if needed
  Future<File> compressImageIfNeeded(File file,
      {double maxSizeMB = 5.0}) async {
    try {
      final currentSize = getImageSizeInMB(file);

      if (currentSize <= maxSizeMB) {
        return file;
      }

      // For now, return original file
      // TODO: Implement actual image compression
      return file;
    } catch (e) {
      throw const app_exceptions.CameraException(
          message: 'Failed to compress image');
    }
  }

  // Upload photo to server
  Future<String> uploadPhoto(
    File photoFile, {
    String? attendanceId,
    ProgressCallback? onProgress,
  }) async {
    try {
      // Validate file
      if (!isValidImageFile(photoFile)) {
        throw const app_exceptions.CameraException(
            message: 'Invalid image file format');
      }

      // Check file size
      if (getImageSizeInMB(photoFile) > 10) {
        throw const app_exceptions.CameraException(
            message: 'Image file too large (max 10MB)');
      }

      // TODO: Implement actual photo upload to server
      // For now, return a mock URL
      await Future.delayed(const Duration(seconds: 2));
      return 'https://example.com/photos/${DateTime.now().millisecondsSinceEpoch}.jpg';
    } catch (e) {
      if (e is app_exceptions.NetworkException ||
          e is app_exceptions.CameraException) {
        rethrow;
      }
      throw const app_exceptions.CameraException(
          message: 'Failed to upload photo');
    }
  }

  // Delete local photo file
  Future<void> deleteLocalPhoto(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Log error but don't throw
      Logger.warning('Failed to delete local photo',
          tag: 'CameraService', error: e);
    }
  }

  // Dispose resources
  void dispose() {
    disposeCameraController();
  }
}
