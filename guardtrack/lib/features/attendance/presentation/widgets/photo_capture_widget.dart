import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/services/camera_service.dart';

class PhotoCaptureWidget extends StatefulWidget {
  final Function(File) onPhotoTaken;
  final String? existingPhotoPath;

  const PhotoCaptureWidget({
    super.key,
    required this.onPhotoTaken,
    this.existingPhotoPath,
  });

  @override
  State<PhotoCaptureWidget> createState() => _PhotoCaptureWidgetState();
}

class _PhotoCaptureWidgetState extends State<PhotoCaptureWidget> {
  final CameraService _cameraService = CameraService();
  File? _capturedPhoto;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingPhotoPath != null) {
      final file = File(widget.existingPhotoPath!);
      if (file.existsSync()) {
        _capturedPhoto = file;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildPhotoArea(),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.camera_alt,
          color: AppColors.primaryBlue,
          size: 24,
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Text(
          'Attendance Photo',
          style: AppTextStyles.heading4,
        ),
        const Spacer(),
        if (_capturedPhoto != null)
          Icon(
            Icons.check_circle,
            color: AppColors.accentGreen,
            size: 20,
          ),
      ],
    );
  }

  Widget _buildPhotoArea() {
    if (_capturedPhoto != null && _capturedPhoto!.existsSync()) {
      return _buildPhotoPreview();
    } else {
      return _buildPhotoPlaceholder();
    }
  }

  Widget _buildPhotoPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Stack(
          children: [
            Image.file(
              _capturedPhoto!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: AppConstants.smallPadding,
              right: AppConstants.smallPadding,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: _removePhoto,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppColors.gray200,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'No photo taken',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the camera button to take a photo',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_capturedPhoto != null) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Retake Photo',
              icon: Icons.camera_alt,
              type: ButtonType.outline,
              onPressed: _isLoading ? null : _takePhoto,
              isLoading: _isLoading,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: CustomButton(
              text: 'Use Photo',
              icon: Icons.check,
              type: ButtonType.primary,
              onPressed: _isLoading ? null : _usePhoto,
            ),
          ),
        ],
      );
    } else {
      return CustomButton(
        text: 'Take Photo',
        icon: Icons.camera_alt,
        onPressed: _isLoading ? null : _takePhoto,
        isLoading: _isLoading,
      );
    }
  }

  void _takePhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photo = await _cameraService.showPhotoSourceDialog(context);
      if (photo != null) {
        setState(() {
          _capturedPhoto = photo;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _capturedPhoto = null;
    });
  }

  void _usePhoto() {
    if (_capturedPhoto != null) {
      widget.onPhotoTaken(_capturedPhoto!);
    }
  }
}
