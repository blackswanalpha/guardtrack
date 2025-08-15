import 'package:flutter/material.dart';
import 'shared/services/smtp_email_service.dart';
import 'shared/services/email_test_service.dart';
import 'core/config/email_config.dart';

/// Simple widget to test email functionality
class EmailTestWidget extends StatefulWidget {
  const EmailTestWidget({Key? key}) : super(key: key);

  @override
  State<EmailTestWidget> createState() => _EmailTestWidgetState();
}

class _EmailTestWidgetState extends State<EmailTestWidget> {
  final SMTPEmailService _emailService = SMTPEmailService();
  final EmailTestService _testService = EmailTestService();
  String _status = 'Ready to test email';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📧 Email Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Configuration Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚙️ Email Configuration',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Sender: ${EmailConfig.senderEmail}'),
                    Text('Recipient: ${EmailConfig.recipientEmail}'),
                    Text('SMTP: ${EmailConfig.smtpHost}:${EmailConfig.smtpPort}'),
                    Text(
                      'Status: ${EmailConfig.isConfigured() ? "✅ Configured" : "❌ Not Configured"}',
                      style: TextStyle(
                        color: EmailConfig.isConfigured() ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Test Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_isLoading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testConfiguration,
              icon: const Icon(Icons.settings),
              label: const Text('Test Configuration'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testSimpleEmail,
              icon: const Icon(Icons.email),
              label: const Text('Send Test Email'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testDailyReport,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Send Daily Report'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runAllTests,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run All Tests'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConfiguration() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing configuration...';
    });

    try {
      await _testService.testEmailSetup();
      setState(() {
        _status = '✅ Configuration test completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Configuration test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSimpleEmail() async {
    setState(() {
      _isLoading = true;
      _status = 'Sending test email...';
    });

    try {
      await _testService.testCustomEmail();
      setState(() {
        _status = '✅ Test email sent successfully! Check your inbox.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Test email failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDailyReport() async {
    setState(() {
      _isLoading = true;
      _status = 'Generating and sending daily report...';
    });

    try {
      await _testService.testDailyReport();
      setState(() {
        _status = '✅ Daily report sent successfully! Check your inbox for PDF attachment.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Daily report failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isLoading = true;
      _status = 'Running all email tests...';
    });

    try {
      await _testService.runAllTests();
      setState(() {
        _status = '✅ All tests completed successfully! Check your email inbox.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Some tests failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
