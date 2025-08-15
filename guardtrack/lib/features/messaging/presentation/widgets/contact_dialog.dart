import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/models/whatsapp_contact.dart';

class ContactDialog extends StatefulWidget {
  final WhatsAppContact? contact;
  final Function(WhatsAppContact) onSave;

  const ContactDialog({
    super.key,
    this.contact,
    required this.onSave,
  });

  @override
  State<ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<ContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final Uuid _uuid = const Uuid();
  
  List<String> _selectedGroups = [];
  final List<String> _availableGroups = [
    'Security Guards',
    'Supervisors',
    'Emergency Contacts',
    'Management',
    'Clients',
    'Vendors',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _phoneController.text = widget.contact!.phoneNumber;
      _emailController.text = widget.contact!.email ?? '';
      _companyController.text = widget.contact!.company ?? '';
      _positionController.text = widget.contact!.position ?? '';
      _selectedGroups = List.from(widget.contact!.groups);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: AppConstants.largePadding),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        label: 'Name *',
                        hint: 'Enter contact name',
                        controller: _nameController,
                        validator: _validateName,
                        prefixIcon: Icons.person,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      CustomTextField(
                        label: 'Phone Number *',
                        hint: 'Enter phone number with country code',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhoneNumber,
                        prefixIcon: Icons.phone,
                        helperText: 'Include country code (e.g., +1234567890)',
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter email address (optional)',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        prefixIcon: Icons.email,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      CustomTextField(
                        label: 'Company',
                        hint: 'Enter company name (optional)',
                        controller: _companyController,
                        prefixIcon: Icons.business,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      CustomTextField(
                        label: 'Position',
                        hint: 'Enter job position (optional)',
                        controller: _positionController,
                        prefixIcon: Icons.work,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildGroupsSection(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.person_add,
          color: AppColors.primaryBlue,
          size: 24,
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: Text(
            widget.contact != null ? 'Edit Contact' : 'Add Contact',
            style: AppTextStyles.heading3,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Groups',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray300),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select groups for this contact:',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _availableGroups.map((group) {
                  final isSelected = _selectedGroups.contains(group);
                  return FilterChip(
                    label: Text(group),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedGroups.add(group);
                        } else {
                          _selectedGroups.remove(group);
                        }
                      });
                    },
                    selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                    checkmarkColor: AppColors.primaryBlue,
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? AppColors.primaryBlue : AppColors.gray700,
                    ),
                  );
                }).toList(),
              ),
              if (_selectedGroups.isNotEmpty) ...[
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  'Selected: ${_selectedGroups.join(', ')}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
            type: ButtonType.outline,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: CustomButton(
            text: widget.contact != null ? 'Update' : 'Add',
            onPressed: _handleSave,
            type: ButtonType.primary,
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final contact = WhatsAppContact(
        id: widget.contact?.id ?? _uuid.v4(),
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        company: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
        position: _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
        groups: _selectedGroups,
        isActive: widget.contact?.isActive ?? true,
        createdAt: widget.contact?.createdAt ?? DateTime.now(),
        updatedAt: widget.contact != null ? DateTime.now() : null,
      );

      widget.onSave(contact);
      Navigator.of(context).pop();
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleanNumber = value.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanNumber.length < 10 || cleanNumber.length > 15) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}
