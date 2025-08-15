import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../core/utils/logger.dart';
import '../../core/errors/exceptions.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import '../models/site_model.dart';
import 'database_service.dart';

class PDFReportService {
  static final PDFReportService _instance = PDFReportService._internal();
  factory PDFReportService() => _instance;
  PDFReportService._internal();

  final DatabaseService _databaseService = DatabaseService();

  /// Generate PDF report for daily attendance
  Future<File> generateDailyAttendancePDF({DateTime? date}) async {
    try {
      final reportDate = date ?? DateTime.now();
      final startOfDay =
          DateTime(reportDate.year, reportDate.month, reportDate.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      Logger.info('Generating PDF report for ${_formatDate(reportDate)}',
          tag: 'PDFReportService');

      // Get attendance data
      final attendanceRecords =
          await _getAttendanceForDate(startOfDay, endOfDay);
      final allEmployees = await _databaseService.getUsers();
      final allSites = await _databaseService.getSites();

      final activeEmployees = allEmployees
          .where((e) => e.role == UserRole.guard && e.isActive)
          .toList();

      // Process attendance data
      final employeeAttendance = <String, List<AttendanceModel>>{};
      final siteAttendance = <String, List<AttendanceModel>>{};

      for (final attendance in attendanceRecords) {
        if (attendance.isCheckIn) {
          employeeAttendance
              .putIfAbsent(attendance.guardId, () => [])
              .add(attendance);
          siteAttendance
              .putIfAbsent(attendance.siteId, () => [])
              .add(attendance);
        }
      }

      // Calculate statistics
      final totalActiveEmployees = activeEmployees.length;
      final uniqueEmployeesCheckedIn = employeeAttendance.keys.length;
      final totalCheckIns = attendanceRecords.where((a) => a.isCheckIn).length;
      final attendanceRate = totalActiveEmployees > 0
          ? (uniqueEmployeesCheckedIn / totalActiveEmployees) * 100
          : 0.0;

      // Create PDF document
      final pdf = pw.Document();

      // Add pages to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              _buildHeader(reportDate),
              pw.SizedBox(height: 20),
              _buildSummarySection(
                totalActiveEmployees,
                uniqueEmployeesCheckedIn,
                totalCheckIns,
                attendanceRate,
              ),
              pw.SizedBox(height: 20),
              _buildEmployeeAttendanceSection(
                  employeeAttendance, allEmployees, allSites),
              pw.SizedBox(height: 20),
              _buildAbsentEmployeesSection(activeEmployees, employeeAttendance),
              pw.SizedBox(height: 20),
              _buildSiteAttendanceSection(
                  siteAttendance, allSites, allEmployees),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ];
          },
        ),
      );

      // Save PDF to file
      final output = await getTemporaryDirectory();
      final fileName =
          'guardtrack_attendance_${_formatDateForFile(reportDate)}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      Logger.info('PDF report generated: ${file.path}',
          tag: 'PDFReportService');
      return file;
    } catch (e) {
      Logger.error('Failed to generate PDF report: $e',
          tag: 'PDFReportService');
      throw NetworkException(message: 'Failed to generate PDF report: $e');
    }
  }

  /// Get attendance records for a specific date range
  Future<List<AttendanceModel>> _getAttendanceForDate(
      DateTime startDate, DateTime endDate) async {
    try {
      // Get all users first to query their attendance
      final allUsers = await _databaseService.getUsers();
      final guardUsers =
          allUsers.where((user) => user.role == UserRole.guard).toList();

      final allAttendance = <AttendanceModel>[];

      // Get attendance for each guard in the date range
      for (final guard in guardUsers) {
        final guardAttendance = await _databaseService.getAttendanceInDateRange(
          guard.id,
          startDate,
          endDate,
        );
        allAttendance.addAll(guardAttendance);
      }

      return allAttendance;
    } catch (e) {
      Logger.error('Failed to get attendance for date: $e',
          tag: 'PDFReportService');
      return [];
    }
  }

  /// Build PDF header
  pw.Widget _buildHeader(DateTime date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'GuardTrack',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Text(
                  'Secure Arrival. Verified Presence.',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Daily Attendance Report',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  _formatDate(date),
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: PdfColors.blue800),
      ],
    );
  }

  /// Build summary section
  pw.Widget _buildSummarySection(
    int totalEmployees,
    int checkedInEmployees,
    int totalCheckIns,
    double attendanceRate,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ATTENDANCE SUMMARY',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            _buildSummaryCard(
                'Total Active Employees', totalEmployees.toString()),
            pw.SizedBox(width: 20),
            _buildSummaryCard(
                'Employees Checked In', checkedInEmployees.toString()),
            pw.SizedBox(width: 20),
            _buildSummaryCard('Total Check-ins', totalCheckIns.toString()),
            pw.SizedBox(width: 20),
            _buildSummaryCard(
                'Attendance Rate', '${attendanceRate.toStringAsFixed(1)}%'),
          ],
        ),
      ],
    );
  }

  /// Build summary card
  pw.Widget _buildSummaryCard(String title, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build employee attendance section
  pw.Widget _buildEmployeeAttendanceSection(
    Map<String, List<AttendanceModel>> employeeAttendance,
    List<UserModel> allEmployees,
    List<SiteModel> allSites,
  ) {
    if (employeeAttendance.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'EMPLOYEE CHECK-INS',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('No check-ins recorded for this date.'),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'EMPLOYEE CHECK-INS',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Employee Name', isHeader: true),
                _buildTableCell('Site', isHeader: true),
                _buildTableCell('Check-in Time', isHeader: true),
                _buildTableCell('Status', isHeader: true),
              ],
            ),
            // Data rows
            ...employeeAttendance.entries.expand((entry) {
              final employee = allEmployees.firstWhere(
                (e) => e.id == entry.key,
                orElse: () => UserModel(
                  id: entry.key,
                  email: 'unknown@example.com',
                  firstName: 'Unknown',
                  lastName: 'Employee',
                  role: UserRole.guard,
                  isActive: true,
                  createdAt: DateTime.now(),
                ),
              );

              return entry.value.map((attendance) {
                final site = allSites.firstWhere(
                  (s) => s.id == attendance.siteId,
                  orElse: () => SiteModel(
                    id: attendance.siteId,
                    name: 'Unknown Site',
                    address: '',
                    latitude: 0.0,
                    longitude: 0.0,
                    allowedRadius: 100.0,
                    isActive: true,
                    createdAt: DateTime.now(),
                  ),
                );

                return pw.TableRow(
                  children: [
                    _buildTableCell(employee.fullName),
                    _buildTableCell(site.name),
                    _buildTableCell(_formatTime(attendance.timestamp)),
                    _buildTableCell(_getStatusText(attendance.status)),
                  ],
                );
              });
            }).toList(),
          ],
        ),
      ],
    );
  }

  /// Build absent employees section
  pw.Widget _buildAbsentEmployeesSection(
    List<UserModel> activeEmployees,
    Map<String, List<AttendanceModel>> employeeAttendance,
  ) {
    final absentEmployees = activeEmployees
        .where((employee) => !employeeAttendance.containsKey(employee.id))
        .toList();

    if (absentEmployees.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ABSENT EMPLOYEES',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              border: pw.Border.all(color: PdfColors.green200),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              '✓ All active employees checked in today!',
              style: pw.TextStyle(
                color: PdfColors.green800,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ABSENT EMPLOYEES',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.red800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.red50,
            border: pw.Border.all(color: PdfColors.red200),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: absentEmployees.map((employee) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text(
                  '• ${employee.fullName} (${employee.email})',
                  style: pw.TextStyle(color: PdfColors.red800),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build site attendance section
  pw.Widget _buildSiteAttendanceSection(
    Map<String, List<AttendanceModel>> siteAttendance,
    List<SiteModel> allSites,
    List<UserModel> allEmployees,
  ) {
    if (siteAttendance.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SITE ATTENDANCE',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('No site check-ins recorded for this date.'),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SITE ATTENDANCE SUMMARY',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(4),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Site Name', isHeader: true),
                _buildTableCell('Check-ins', isHeader: true),
                _buildTableCell('Employees', isHeader: true),
              ],
            ),
            // Data rows
            ...siteAttendance.entries.map((entry) {
              final site = allSites.firstWhere(
                (s) => s.id == entry.key,
                orElse: () => SiteModel(
                  id: entry.key,
                  name: 'Unknown Site',
                  address: '',
                  latitude: 0.0,
                  longitude: 0.0,
                  allowedRadius: 100.0,
                  isActive: true,
                  createdAt: DateTime.now(),
                ),
              );

              final employeeNames = entry.value
                  .map((attendance) {
                    final employee = allEmployees.firstWhere(
                      (e) => e.id == attendance.guardId,
                      orElse: () => UserModel(
                        id: attendance.guardId,
                        email: 'unknown@example.com',
                        firstName: 'Unknown',
                        lastName: 'Employee',
                        role: UserRole.guard,
                        isActive: true,
                        createdAt: DateTime.now(),
                      ),
                    );
                    return employee.fullName;
                  })
                  .toSet()
                  .join(', ');

              return pw.TableRow(
                children: [
                  _buildTableCell(site.name),
                  _buildTableCell(entry.value.length.toString()),
                  _buildTableCell(employeeNames),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  /// Build table cell
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.blue800 : PdfColors.black,
        ),
      ),
    );
  }

  /// Build footer
  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated by GuardTrack System',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              'Generated on: ${_formatDateTime(DateTime.now())}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Get status text for attendance
  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.pending:
        return 'Pending';
      case AttendanceStatus.verified:
        return 'Verified';
      case AttendanceStatus.rejected:
        return 'Rejected';
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  /// Format date for filename
  String _formatDateForFile(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format time for display
  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Format date and time for display
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
}
