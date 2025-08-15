import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/models/message_template.dart';

class TemplateDialog extends StatefulWidget {
  final MessageTemplate? template;
  final Function(MessageTemplate) onSave;

  const TemplateDialog({
    super.key,
    this.template,
    required this.onSave,
  });

  @override
  State<TemplateDialog> createState() => _TemplateDialogState();
}

class _TemplateDialogState extends State<TemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  final Uuid _uuid = const Uuid();

  String _selectedCategory = TemplateCategory.custom;
  List<String> _variables = [];

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _nameController.text = widget.template!.name;
      _contentController.text = widget.template!.content;
      _selectedCategory = widget.template!.category;
      _variables = List.from(widget.template!.variables);
    }
    _contentController.addListener(_extractVariables);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _extractVariables() {
    final newVariables =
        MessageTemplate.extractVariables(_contentController.text);
    if (newVariables.toString() != _variables.toString()) {
      setState(() {
        _variables = newVariables;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
                        label: 'Template Name',
                        hint: 'Enter template name',
                        controller: _nameController,
                        validator: _validateName,
                        prefixIcon: Icons.label,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildCategoryDropdown(),
                      const SizedBox(height: AppConstants.defaultPadding),
                      CustomTextField(
                        label: 'Message Content',
                        hint:
                            'Enter message content with variables like {name}, {date}',
                        controller: _contentController,
                        maxLines: 6,
                        validator: _validateContent,
                        prefixIcon: Icons.message,
                      ),
                      if (_variables.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.defaultPadding),
                        _buildVariablesSection(),
                      ],
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
          Icons.text_snippet,
          color: AppColors.primaryBlue,
          size: 24,
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: Text(
            widget.template != null ? 'Edit Template' : 'Create Template',
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

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: Icon(Icons.category, color: AppColors.gray500),
          ),
          items: TemplateCategory.all.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(TemplateCategory.getDisplayName(category)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildVariablesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detected Variables',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'These variables will be replaced when sending messages:',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _variables.map((variable) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '{$variable}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
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
            text: widget.template != null ? 'Update' : 'Create',
            onPressed: _handleSave,
            type: ButtonType.primary,
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final template = MessageTemplate(
        id: widget.template?.id ?? _uuid.v4(),
        name: _nameController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        variables: _variables,
        isActive: widget.template?.isActive ?? true,
        createdAt: widget.template?.createdAt ?? DateTime.now(),
        updatedAt: widget.template != null ? DateTime.now() : null,
      );

      widget.onSave(template);
      Navigator.of(context).pop();
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Template name is required';
    }
    if (value.trim().length < 3) {
      return 'Template name must be at least 3 characters';
    }
    return null;
  }

  String? _validateContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message content is required';
    }
    if (value.trim().length < 10) {
      return 'Message content must be at least 10 characters';
    }
    return null;
  }
}
