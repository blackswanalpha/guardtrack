import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/message_template.dart';

class TemplateSelector extends StatelessWidget {
  final List<MessageTemplate> templates;
  final MessageTemplate? selectedTemplate;
  final Function(MessageTemplate) onTemplateSelected;
  final VoidCallback? onCreateTemplate;
  final Function(MessageTemplate)? onEditTemplate;

  const TemplateSelector({
    super.key,
    required this.templates,
    this.selectedTemplate,
    required this.onTemplateSelected,
    this.onCreateTemplate,
    this.onEditTemplate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.text_snippet,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Text(
                    'Message Templates',
                    style: AppTextStyles.heading4,
                  ),
                ],
              ),
              if (onCreateTemplate != null)
                IconButton(
                  onPressed: onCreateTemplate,
                  icon: Icon(
                    Icons.add,
                    color: AppColors.primaryBlue,
                  ),
                  tooltip: 'Create Template',
                ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          if (templates.isEmpty) _buildEmptyState() else _buildTemplateList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        children: [
          Icon(
            Icons.text_snippet,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No templates available',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Create your first template to get started',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList() {
    // Group templates by category
    final groupedTemplates = <String, List<MessageTemplate>>{};
    for (final template in templates) {
      if (!groupedTemplates.containsKey(template.category)) {
        groupedTemplates[template.category] = [];
      }
      groupedTemplates[template.category]!.add(template);
    }

    return Column(
      children: groupedTemplates.entries.map((entry) {
        return _buildCategorySection(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildCategorySection(
      String category, List<MessageTemplate> templates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
          child: Text(
            TemplateCategory.getDisplayName(category),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
        ),
        ...templates.map((template) => _buildTemplateItem(template)),
        const SizedBox(height: AppConstants.defaultPadding),
      ],
    );
  }

  Widget _buildTemplateItem(MessageTemplate template) {
    final isSelected = selectedTemplate?.id == template.id;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Material(
        color: isSelected
            ? AppColors.primaryBlue.withOpacity(0.1)
            : AppColors.gray50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: InkWell(
          onTap: () => onTemplateSelected(template),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.gray800,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        template.content,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (template.variables.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.smallPadding),
                        Wrap(
                          spacing: 4,
                          children: template.variables.map((variable) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
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
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    if (onEditTemplate != null) ...[
                      const SizedBox(height: AppConstants.smallPadding),
                      IconButton(
                        onPressed: () => onEditTemplate!(template),
                        icon: Icon(
                          Icons.edit,
                          color: AppColors.gray500,
                          size: 18,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
