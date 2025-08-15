import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../bloc/messaging_bloc.dart';
import '../bloc/messaging_event.dart';
import '../bloc/messaging_state.dart';
import '../widgets/template_selector.dart';
import '../widgets/contact_picker.dart';
import '../widgets/message_history_widget.dart';

class TestMessagePage extends StatefulWidget {
  final UserModel user;

  const TestMessagePage({
    super.key,
    required this.user,
  });

  @override
  State<TestMessagePage> createState() => _TestMessagePageState();
}

class _TestMessagePageState extends State<TestMessagePage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();

  final _messageFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _subjectFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Pre-fill with sample data for testing
    _messageController.text = 'Hello! This is a test message from GuardTrack.';
    _phoneController.text = '+1234567890';
    _emailController.text = 'test@example.com';
    _subjectController.text = 'GuardTrack Test Message';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _subjectFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: BlocListener<MessagingBloc, MessagingState>(
        listener: _handleMessagingStateChange,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppConstants.largePadding),
                  _buildMessageSection(),
                  const SizedBox(height: AppConstants.largePadding),
                  _buildWhatsAppSection(),
                  const SizedBox(height: AppConstants.largePadding),
                  _buildEmailSection(),
                  const SizedBox(height: AppConstants.largePadding * 2),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Test Message'),
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildHeader() {
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
        children: [
          Icon(
            Icons.message_outlined,
            size: 48,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Test Messaging',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Send test messages via WhatsApp and Email',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
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
          Text(
            'Message Content',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Message',
            hint: 'Enter your test message...',
            controller: _messageController,
            focusNode: _messageFocusNode,
            maxLines: 4,
            validator: _validateMessage,
            prefixIcon: Icons.message,
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppSection() {
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
                Icons.phone,
                color: AppColors.accentGreen,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'WhatsApp Message',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Phone Number',
            hint: 'Enter phone number with country code',
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.phone,
            validator: _validatePhoneNumber,
            prefixIcon: Icons.phone,
            helperText: 'Include country code (e.g., +1234567890)',
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSection() {
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
                Icons.email,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'Email Message',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Email Address',
            hint: 'Enter recipient email address',
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            prefixIcon: Icons.email,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Subject',
            hint: 'Enter email subject',
            controller: _subjectController,
            focusNode: _subjectFocusNode,
            validator: _validateSubject,
            prefixIcon: Icons.subject,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<MessagingBloc, MessagingState>(
      builder: (context, state) {
        final isLoading = state is MessagingLoading;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Send WhatsApp',
                    icon: Icons.phone,
                    onPressed: isLoading ? null : _handleSendWhatsApp,
                    type: ButtonType.primary,
                    backgroundColor: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: CustomButton(
                    text: 'Send Email',
                    icon: Icons.email,
                    onPressed: isLoading ? null : _handleSendEmail,
                    type: ButtonType.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomButton(
              text: 'Open Email Client',
              icon: Icons.open_in_new,
              onPressed: isLoading ? null : _handleOpenEmailClient,
              type: ButtonType.outline,
            ),
            if (isLoading) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      child: Text(
                        (state as MessagingLoading).message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _handleMessagingStateChange(BuildContext context, MessagingState state) {
    if (state is WhatsAppMessageSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WhatsApp opened for ${state.phoneNumber}'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 3),
        ),
      );
      context.read<MessagingBloc>().add(const ResetMessagingState());
    } else if (state is EmailMessageSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email sent to ${state.email}'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 3),
        ),
      );
      context.read<MessagingBloc>().add(const ResetMessagingState());
    } else if (state is MessagingError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.message),
              if (state.details != null) ...[
                const SizedBox(height: 4),
                Text(
                  state.details!,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 5),
        ),
      );
      context.read<MessagingBloc>().add(const ResetMessagingState());
    }
  }

  void _handleSendWhatsApp() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<MessagingBloc>().add(
            SendWhatsAppMessage(
              phoneNumber: _phoneController.text.trim(),
              message: _messageController.text.trim(),
            ),
          );
    }
  }

  void _handleSendEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<MessagingBloc>().add(
            SendEmailMessage(
              email: _emailController.text.trim(),
              subject: _subjectController.text.trim(),
              body: _messageController.text.trim(),
            ),
          );
    }
  }

  void _handleOpenEmailClient() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<MessagingBloc>().add(
            SendEmailViaClient(
              email: _emailController.text.trim(),
              subject: _subjectController.text.trim(),
              body: _messageController.text.trim(),
            ),
          );
    }
  }

  String? _validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message is required';
    }
    if (value.trim().length < 5) {
      return 'Message must be at least 5 characters';
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
      return 'Email address is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validateSubject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Subject is required';
    }
    if (value.trim().length < 3) {
      return 'Subject must be at least 3 characters';
    }
    return null;
  }
}
