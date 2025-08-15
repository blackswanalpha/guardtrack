import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/message_history.dart';

class MessageDetailsDialog extends StatelessWidget {
  final MessageHistory message;

  const MessageDetailsDialog({
    super.key,
    required this.message,
  });

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
            _buildHeader(context),
            const SizedBox(height: AppConstants.largePadding),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildRecipientInfo(),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildMessageInfo(),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildStatusInfo(),
                    if (message.templateName != null) ...[
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildTemplateInfo(),
                    ],
                    if (message.errorMessage != null) ...[
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildErrorInfo(),
                    ],
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildTimestampInfo(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: AppColors.primaryBlue,
          size: 24,
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: Text(
            'Message Details',
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

  Widget _buildRecipientInfo() {
    return _buildInfoCard(
      title: 'Recipient',
      icon: Icons.person,
      children: [
        _buildInfoRow('Name', message.recipientName),
        _buildInfoRow('Phone', message.formattedPhone),
      ],
    );
  }

  Widget _buildMessageInfo() {
    return _buildInfoCard(
      title: 'Message',
      icon: Icons.message,
      children: [
        _buildInfoRow(
            'Type', '${message.type.icon} ${message.type.displayName}'),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Content:',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.message,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo() {
    return _buildInfoCard(
      title: 'Status',
      icon: Icons.info,
      children: [
        Row(
          children: [
            Text(
              message.status.icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              message.status.displayName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: _getStatusColor(message.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTemplateInfo() {
    return _buildInfoCard(
      title: 'Template',
      icon: Icons.text_snippet,
      children: [
        _buildInfoRow('Template Name', message.templateName!),
        if (message.templateId != null)
          _buildInfoRow('Template ID', message.templateId!),
      ],
    );
  }

  Widget _buildErrorInfo() {
    return _buildInfoCard(
      title: 'Error',
      icon: Icons.error_outline,
      color: AppColors.errorRed,
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.errorRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
          ),
          child: Text(
            message.errorMessage!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.errorRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampInfo() {
    return _buildInfoCard(
      title: 'Timestamps',
      icon: Icons.schedule,
      children: [
        _buildInfoRow('Sent At', _formatDateTime(message.sentAt)),
        if (message.deliveredAt != null)
          _buildInfoRow('Delivered At', _formatDateTime(message.deliveredAt!)),
        if (message.readAt != null)
          _buildInfoRow('Read At', _formatDateTime(message.readAt!)),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color ?? AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Copy Message',
            icon: Icons.copy,
            onPressed: () => _copyMessage(context),
            type: ButtonType.outline,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: CustomButton(
            text: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            type: ButtonType.primary,
          ),
        ),
      ],
    );
  }

  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message copied to clipboard'),
        backgroundColor: AppColors.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.pending:
        return AppColors.warningYellow;
      case MessageStatus.sent:
        return AppColors.successGreen;
      case MessageStatus.delivered:
        return AppColors.primaryBlue;
      case MessageStatus.read:
        return AppColors.accentGreen;
      case MessageStatus.failed:
        return AppColors.errorRed;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(dateTime);
  }
}
