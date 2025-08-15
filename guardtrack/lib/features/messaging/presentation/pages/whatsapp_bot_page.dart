import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/message_template.dart';
import '../../../../shared/models/whatsapp_contact.dart';
import '../../../../shared/models/message_history.dart';
import '../../../../shared/services/whatsapp_bot_service.dart';
import '../../../../shared/services/auto_message_service.dart';
import '../../../../shared/services/whatsapp_cloud_api_service.dart';
import '../widgets/template_selector.dart';
import '../widgets/contact_picker.dart';
import '../widgets/message_history_widget.dart';
import '../widgets/template_dialog.dart';
import '../widgets/contact_dialog.dart';
import '../widgets/message_details_dialog.dart';

class WhatsAppBotPage extends StatefulWidget {
  final UserModel user;

  const WhatsAppBotPage({
    super.key,
    required this.user,
  });

  @override
  State<WhatsAppBotPage> createState() => _WhatsAppBotPageState();
}

class _WhatsAppBotPageState extends State<WhatsAppBotPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  final WhatsAppBotService _botService = WhatsAppBotService();
  final AutoMessageService _autoMessageService = AutoMessageService();
  final WhatsAppCloudApiService _cloudApiService = WhatsAppCloudApiService();
  final Uuid _uuid = const Uuid();

  late TabController _tabController;

  List<MessageTemplate> _templates = [];
  List<WhatsAppContact> _contacts = [];
  List<MessageHistory> _messageHistory = [];
  List<WhatsAppContact> _selectedContacts = [];
  MessageTemplate? _selectedTemplate;

  bool _isLoading = false;
  bool _isBulkMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final templates = await _botService.getTemplates();
      final contacts = await _botService.getContacts();
      final history = await _botService.getMessageHistory(limit: 50);

      setState(() {
        _templates = templates;
        _contacts = contacts;
        _messageHistory = history;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSendMessageTab(),
                      _buildTemplatesTab(),
                      _buildContactsTab(),
                      _buildHistoryTab(),
                      _buildSettingsTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('WhatsApp Bot'),
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(_isBulkMode ? Icons.person : Icons.group),
          onPressed: () {
            setState(() {
              _isBulkMode = !_isBulkMode;
              _selectedContacts.clear();
            });
          },
          tooltip: _isBulkMode ? 'Single Mode' : 'Bulk Mode',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.gray600,
        indicatorColor: AppColors.primaryBlue,
        tabs: const [
          Tab(icon: Icon(Icons.send), text: 'Send'),
          Tab(icon: Icon(Icons.text_snippet), text: 'Templates'),
          Tab(icon: Icon(Icons.contacts), text: 'Contacts'),
          Tab(icon: Icon(Icons.history), text: 'History'),
          Tab(icon: Icon(Icons.settings), text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildSendMessageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeIndicator(),
            const SizedBox(height: AppConstants.defaultPadding),
            if (_templates.isNotEmpty) ...[
              TemplateSelector(
                templates: _templates,
                selectedTemplate: _selectedTemplate,
                onTemplateSelected: _onTemplateSelected,
                onCreateTemplate: () => _showCreateTemplateDialog(),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
            ],
            _buildMessageSection(),
            const SizedBox(height: AppConstants.defaultPadding),
            if (_isBulkMode) ...[
              ContactPicker(
                contacts: _contacts,
                selectedContacts: _selectedContacts,
                onContactsChanged: (contacts) {
                  setState(() => _selectedContacts = contacts);
                },
                onAddContact: () => _showAddContactDialog(),
              ),
            ] else ...[
              _buildSingleRecipientSection(),
            ],
            const SizedBox(height: AppConstants.largePadding),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: TemplateSelector(
        templates: _templates,
        selectedTemplate: _selectedTemplate,
        onTemplateSelected: (template) {
          setState(() => _selectedTemplate = template);
          _tabController.animateTo(0); // Go back to send tab
        },
        onCreateTemplate: () => _showCreateTemplateDialog(),
        onEditTemplate: (template) => _showEditTemplateDialog(template),
      ),
    );
  }

  Widget _buildContactsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: ContactPicker(
        contacts: _contacts,
        selectedContacts: _selectedContacts,
        onContactsChanged: (contacts) {
          setState(() => _selectedContacts = contacts);
        },
        onAddContact: () => _showAddContactDialog(),
        allowMultipleSelection: true,
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: MessageHistoryWidget(
        messages: _messageHistory,
        onRefresh: _loadData,
        onMessageTap: (message) => _showMessageDetails(message),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConfigurationStatus(),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildAutoMessageSettings(),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildConfigurationStatus() {
    final config = _cloudApiService.getConfigurationStatus();
    final isConfigured = config['isConfigured'] as bool;

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
            children: [
              Icon(
                isConfigured ? Icons.check_circle : Icons.warning,
                color: isConfigured
                    ? AppColors.successGreen
                    : AppColors.warningYellow,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'WhatsApp Cloud API Status',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: isConfigured
                  ? AppColors.successGreen.withOpacity(0.1)
                  : AppColors.warningYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: isConfigured
                    ? AppColors.successGreen.withOpacity(0.3)
                    : AppColors.warningYellow.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      config['hasAccessToken'] ? Icons.check : Icons.close,
                      color: config['hasAccessToken']
                          ? AppColors.successGreen
                          : AppColors.errorRed,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Access Token: ${config['hasAccessToken'] ? 'Configured' : 'Missing'}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isConfigured ? Icons.check : Icons.close,
                      color: isConfigured
                          ? AppColors.successGreen
                          : AppColors.errorRed,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Phone Number ID: ${isConfigured ? 'Configured' : 'Needs Setup'}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                if (!isConfigured) ...[
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'To enable real WhatsApp sending, please update the Phone Number ID in whatsapp_cloud_api_service.dart',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warningYellow.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoMessageSettings() {
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
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'Auto-Message Settings',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
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
                  'Startup Message Configuration',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  'From: ${AutoMessageService.defaultSenderNumber}',
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  'To: ${AutoMessageService.defaultPhoneNumber}',
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  'Template: ${AutoMessageService.defaultTemplateName} (${AutoMessageService.defaultTemplateLanguage})',
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  'Fallback Message: "${AutoMessageService.defaultMessage}"',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  'This message is automatically sent when the app starts (once per day).',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          FutureBuilder<bool>(
            future: _autoMessageService.isAutoMessageEnabled(),
            builder: (context, snapshot) {
              final isEnabled = snapshot.data ?? true;
              return SwitchListTile(
                title: Text(
                  'Enable Auto-Message',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  isEnabled
                      ? 'Auto-message will be sent on app startup'
                      : 'Auto-message is disabled',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                value: isEnabled,
                onChanged: (value) async {
                  await _autoMessageService.setAutoMessageEnabled(value);
                  setState(() {}); // Refresh the UI
                  _showSuccessSnackBar(
                      value ? 'Auto-message enabled' : 'Auto-message disabled');
                },
                activeColor: AppColors.accentGreen,
              );
            },
          ),
          const SizedBox(height: AppConstants.smallPadding),
          FutureBuilder<DateTime?>(
            future: _autoMessageService.getLastSentDate(),
            builder: (context, snapshot) {
              final lastSent = snapshot.data;
              if (lastSent != null) {
                return Container(
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.gray600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last sent: ${_formatDateTime(lastSent)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
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
            children: [
              Icon(
                Icons.flash_on,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'Quick Actions',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Send Now',
                  icon: Icons.send,
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    final success = await _autoMessageService.sendMessageNow();
                    setState(() => _isLoading = false);

                    if (success) {
                      _showSuccessSnackBar('Auto-message sent successfully!');
                    } else {
                      _showErrorSnackBar('Failed to send auto-message');
                    }
                  },
                  type: ButtonType.primary,
                  backgroundColor: AppColors.accentGreen,
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: CustomButton(
                  text: 'Reset',
                  icon: Icons.refresh,
                  onPressed: () async {
                    final success = await _autoMessageService.reset();
                    if (success) {
                      setState(() {}); // Refresh UI
                      _showSuccessSnackBar('Auto-message system reset');
                    } else {
                      _showErrorSnackBar('Failed to reset auto-message system');
                    }
                  },
                  type: ButtonType.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Send Now: Immediately send the auto-message\nReset: Clear the last sent date to allow sending again',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: _isBulkMode
            ? AppColors.accentGreen.withOpacity(0.1)
            : AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: _isBulkMode ? AppColors.accentGreen : AppColors.primaryBlue,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isBulkMode ? Icons.group : Icons.person,
            color: _isBulkMode ? AppColors.accentGreen : AppColors.primaryBlue,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            _isBulkMode ? 'Bulk Messaging Mode' : 'Single Message Mode',
            style: AppTextStyles.bodyMedium.copyWith(
              color:
                  _isBulkMode ? AppColors.accentGreen : AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (_isBulkMode && _selectedContacts.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_selectedContacts.length} selected',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageSection() {
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
            children: [
              Icon(
                Icons.message,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'Message Content',
                style: AppTextStyles.heading4,
              ),
              const Spacer(),
              if (_selectedTemplate != null)
                TextButton.icon(
                  onPressed: () => setState(() => _selectedTemplate = null),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear Template'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gray600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Message',
            hint: _selectedTemplate != null
                ? 'Template: ${_selectedTemplate!.name}'
                : 'Enter your message...',
            controller: _messageController,
            maxLines: 4,
            validator: _validateMessage,
            prefixIcon: Icons.message,
          ),
          if (_selectedTemplate != null &&
              _selectedTemplate!.variables.isNotEmpty) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Template Variables:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _selectedTemplate!.variables.map((variable) {
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
        ],
      ),
    );
  }

  Widget _buildSingleRecipientSection() {
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
            children: [
              Icon(
                Icons.person,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'Recipient',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Name',
            hint: 'Enter recipient name',
            controller: _nameController,
            validator: _validateName,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Phone Number',
            hint: 'Enter phone number with country code',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: _validatePhoneNumber,
            prefixIcon: Icons.phone,
            helperText: 'Include country code (e.g., +1234567890)',
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return CustomButton(
      text: _isBulkMode
          ? 'Send to ${_selectedContacts.length} Contacts'
          : 'Send WhatsApp Message',
      icon: Icons.send,
      onPressed: _isLoading ? null : _handleSendMessage,
      type: ButtonType.primary,
      backgroundColor: AppColors.accentGreen,
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_tabController.index == 1) {
      return FloatingActionButton(
        onPressed: () => _showCreateTemplateDialog(),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add),
      );
    } else if (_tabController.index == 2) {
      return FloatingActionButton(
        onPressed: () => _showAddContactDialog(),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.person_add),
      );
    }
    return null;
  }

  // Event handlers
  void _onTemplateSelected(MessageTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _messageController.text = template.content;
    });
  }

  Future<void> _handleSendMessage() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      String message = _messageController.text.trim();

      // Replace template variables if template is selected
      if (_selectedTemplate != null) {
        final variableValues = <String, String>{
          'name': _isBulkMode ? '{name}' : _nameController.text.trim(),
          'date': DateTime.now().toString().split(' ')[0],
          'time': TimeOfDay.now().format(context),
        };
        message = _selectedTemplate!.generateMessage(variableValues);
      }

      if (_isBulkMode) {
        if (_selectedContacts.isEmpty) {
          _showErrorSnackBar('Please select at least one contact');
          return;
        }

        final results = await _botService.sendBulkMessages(
          contacts: _selectedContacts,
          message: message,
          templateId: _selectedTemplate?.id,
          templateName: _selectedTemplate?.name,
        );

        final successCount = results.values.where((success) => success).length;
        final totalCount = results.length;

        _showSuccessSnackBar(
            'Sent $successCount/$totalCount messages successfully');
      } else {
        final success = await _botService.sendWhatsAppMessage(
          phoneNumber: _phoneController.text.trim(),
          message: message,
          recipientName: _nameController.text.trim(),
          templateId: _selectedTemplate?.id,
          templateName: _selectedTemplate?.name,
        );

        if (success) {
          _showSuccessSnackBar('WhatsApp opened successfully');
          _clearForm();
        } else {
          _showErrorSnackBar('Failed to open WhatsApp');
        }
      }

      // Refresh history
      await _loadData();
    } catch (e) {
      _showErrorSnackBar('Error sending message: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _messageController.clear();
    _phoneController.clear();
    _nameController.clear();
    setState(() {
      _selectedTemplate = null;
      _selectedContacts.clear();
    });
  }

  // Dialog methods
  void _showCreateTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => TemplateDialog(
        onSave: (template) async {
          final success = await _botService.saveTemplate(template);
          if (success) {
            _showSuccessSnackBar('Template created successfully');
            await _loadData();
          } else {
            _showErrorSnackBar('Failed to create template');
          }
        },
      ),
    );
  }

  void _showEditTemplateDialog(MessageTemplate template) {
    showDialog(
      context: context,
      builder: (context) => TemplateDialog(
        template: template,
        onSave: (updatedTemplate) async {
          final success = await _botService.saveTemplate(updatedTemplate);
          if (success) {
            _showSuccessSnackBar('Template updated successfully');
            await _loadData();
          } else {
            _showErrorSnackBar('Failed to update template');
          }
        },
      ),
    );
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => ContactDialog(
        onSave: (contact) async {
          final success = await _botService.saveContact(contact);
          if (success) {
            _showSuccessSnackBar('Contact added successfully');
            await _loadData();
          } else {
            _showErrorSnackBar('Failed to add contact');
          }
        },
      ),
    );
  }

  void _showMessageDetails(MessageHistory message) {
    showDialog(
      context: context,
      builder: (context) => MessageDetailsDialog(message: message),
    );
  }

  // Validation methods
  String? _validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message is required';
    }
    if (value.trim().length < 5) {
      return 'Message must be at least 5 characters';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
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

  // Utility methods
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
