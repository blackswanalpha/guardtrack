import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: AppConstants.largePadding),
            _buildForm(),
            const SizedBox(height: AppConstants.largePadding),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline,
            color: AppColors.primaryBlue,
            size: 30,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Text(
          'Change Password',
          style: AppTextStyles.heading3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Enter your current password and choose a new one',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'Current Password',
            hint: 'Enter your current password',
            controller: _currentPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            validator: _validateCurrentPassword,
            enabled: !_isLoading,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'New Password',
            hint: 'Enter your new password',
            controller: _newPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock,
            validator: _validateNewPassword,
            enabled: !_isLoading,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Confirm New Password',
            hint: 'Confirm your new password',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock,
            validator: _validateConfirmPassword,
            enabled: !_isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Cancel',
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            type: ButtonType.outline,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: CustomButton(
            text: 'Change Password',
            onPressed: _isLoading ? null : _handleChangePassword,
            isLoading: _isLoading,
            type: ButtonType.primary,
          ),
        ),
      ],
    );
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    
    if (value == _currentPasswordController.text) {
      return 'New password must be different from current password';
    }
    
    // Basic password strength validation
    if (!_isPasswordStrong(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }
    
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  bool _isPasswordStrong(String password) {
    // Check for at least one uppercase letter, one lowercase letter, and one number
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    
    return hasUppercase && hasLowercase && hasNumber;
  }

  void _handleChangePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Implement actual password change logic
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully'),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to change password: $e'),
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
  }
}
