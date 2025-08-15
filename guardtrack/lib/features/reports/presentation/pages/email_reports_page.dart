import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/services/email_template_service.dart';
import '../../../../core/utils/logger.dart';

class EmailReportsPage extends StatefulWidget {
  final UserModel user;

  const EmailReportsPage({
    super.key,
    required this.user,
  });

  @override
  State<EmailReportsPage> createState() => _EmailReportsPageState();
}

class _EmailReportsPageState extends State<EmailReportsPage> {
  final EmailTemplateService _emailService = EmailTemplateService();
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _customTitleController = TextEditingController();
  final TextEditingController _customDescriptionController =
      TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _customTitleController.dispose();
    _customDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Email Reports'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildEmailConfigCard(),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildDateSelectionCard(),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildReportActionsCard(),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildCustomReportCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: AppColors.primaryBlue,
                  size: 28,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'Email Report System',
                  style: AppTextStyles.heading3,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Send professional attendance reports and alerts via email with PDF attachments and customizable templates.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailConfigCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email Configuration',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            TextFormField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient Email (Optional)',
                hintText: 'Leave empty to use default recipient',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Date',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray300),
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                ElevatedButton(
                  onPressed: _selectDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Change'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Standard Reports',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Daily Report',
                    icon: Icons.today,
                    onPressed: _sendDailyReport,
                    type: ButtonType.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: CustomButton(
                    text: 'Weekly Summary',
                    icon: Icons.date_range,
                    onPressed: _sendWeeklyReport,
                    type: ButtonType.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            CustomButton(
              text: 'Send Attendance Alert',
              icon: Icons.warning,
              onPressed: _sendAttendanceAlert,
              type: ButtonType.secondary,
              backgroundColor: AppColors.warningAmber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomReportCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Report',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            TextFormField(
              controller: _customTitleController,
              decoration: const InputDecoration(
                labelText: 'Report Title',
                hintText: 'Enter custom report title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            TextFormField(
              controller: _customDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Report Description',
                hintText: 'Enter report description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomButton(
              text: 'Send Custom Report',
              icon: Icons.send,
              onPressed: _sendCustomReport,
              type: ButtonType.primary,
              backgroundColor: AppColors.accentGreen,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _sendDailyReport() async {
    setState(() => _isLoading = true);

    try {
      final success = await _emailService.sendDailyAttendanceReport(
        date: _selectedDate,
        recipientEmail: _recipientController.text.isNotEmpty
            ? _recipientController.text
            : null,
        additionalData: {
          'totalEmployees': 25,
          'checkedIn': 23,
          'attendanceRate': '92%',
        },
      );

      _showResultSnackBar(
        success,
        'Daily attendance report sent successfully!',
        'Failed to send daily report',
      );
    } catch (e) {
      Logger.error('Failed to send daily report: $e', tag: 'EmailReportsPage');
      _showResultSnackBar(false, '', 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendWeeklyReport() async {
    setState(() => _isLoading = true);

    try {
      final success = await _emailService.sendWeeklyAttendanceSummary(
        weekStartDate: _getWeekStart(_selectedDate),
        recipientEmail: _recipientController.text.isNotEmpty
            ? _recipientController.text
            : null,
        additionalData: {
          'weeklyAverage': '89',
          'totalDays': 7,
          'bestDay': 'Tuesday',
        },
      );

      _showResultSnackBar(
        success,
        'Weekly attendance summary sent successfully!',
        'Failed to send weekly report',
      );
    } catch (e) {
      Logger.error('Failed to send weekly report: $e', tag: 'EmailReportsPage');
      _showResultSnackBar(false, '', 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendAttendanceAlert() async {
    setState(() => _isLoading = true);

    try {
      final success = await _emailService.sendAttendanceAlert(
        alertType: 'Low Attendance Alert',
        alertMessage:
            'Attendance rate has dropped below 85% for the selected date.',
        recipientEmail: _recipientController.text.isNotEmpty
            ? _recipientController.text
            : null,
        alertData: {
          'Date': DateFormat('MMM dd, yyyy').format(_selectedDate),
          'Attendance Rate': '78%',
          'Missing Employees': '5',
          'Action Required': 'Review and follow up',
        },
      );

      _showResultSnackBar(
        success,
        'Attendance alert sent successfully!',
        'Failed to send attendance alert',
      );
    } catch (e) {
      Logger.error('Failed to send attendance alert: $e',
          tag: 'EmailReportsPage');
      _showResultSnackBar(false, '', 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendCustomReport() async {
    if (_customTitleController.text.isEmpty ||
        _customDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both title and description'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _emailService.sendCustomReport(
        reportTitle: _customTitleController.text,
        reportDescription: _customDescriptionController.text,
        recipientEmail: _recipientController.text.isNotEmpty
            ? _recipientController.text
            : null,
        customData: {
          'Generated By': widget.user.fullName,
          'Report Date': DateFormat('MMM dd, yyyy').format(_selectedDate),
          'Report Type': 'Custom Analysis',
        },
      );

      _showResultSnackBar(
        success,
        'Custom report sent successfully!',
        'Failed to send custom report',
      );

      if (success) {
        _customTitleController.clear();
        _customDescriptionController.clear();
      }
    } catch (e) {
      Logger.error('Failed to send custom report: $e', tag: 'EmailReportsPage');
      _showResultSnackBar(false, '', 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showResultSnackBar(
      bool success, String successMessage, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : errorMessage),
        backgroundColor: success ? AppColors.accentGreen : AppColors.errorRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }
}
