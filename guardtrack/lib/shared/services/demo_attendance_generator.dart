import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import '../models/site_model.dart';

class DemoAttendanceGenerator {
  static const Uuid _uuid = Uuid();
  static final Random _random = Random();

  // Generate 20 demo sites
  static List<SiteModel> generateDemoSites() {
    final sites = <SiteModel>[];
    final siteNames = [
      'Westgate Mall', 'KICC Tower', 'Nairobi Hospital', 'University of Nairobi',
      'Kenyatta Hospital', 'Times Tower', 'Sarit Centre', 'Village Market',
      'Two Rivers Mall', 'Garden City Mall', 'Prestige Plaza', 'ABC Place',
      'Yaya Centre', 'Junction Mall', 'Thika Road Mall', 'Nextgen Mall',
      'Galleria Mall', 'Karen Hospital', 'Aga Khan Hospital', 'Muthaiga Golf Club'
    ];

    // Nairobi coordinates range
    final baseLatitude = -1.2921;
    final baseLongitude = 36.8219;

    for (int i = 0; i < 20; i++) {
      final site = SiteModel(
        id: _uuid.v4(),
        name: siteNames[i],
        address: '${siteNames[i]}, Nairobi, Kenya',
        latitude: baseLatitude + (_random.nextDouble() - 0.5) * 0.1, // ±0.05 degrees
        longitude: baseLongitude + (_random.nextDouble() - 0.5) * 0.1,
        allowedRadius: 50.0 + _random.nextDouble() * 100, // 50-150 meters
        isActive: true,
        description: 'Security site at ${siteNames[i]}',
        contactPerson: 'Site Manager ${i + 1}',
        contactPhone: '+25470${_random.nextInt(9000000) + 1000000}',
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
        shiftStartTime: '06:00',
        shiftEndTime: '18:00',
        assignedGuardIds: [], // Will be populated later
      );
      sites.add(site);
    }

    return sites;
  }

  // Generate 100 demo employees (guards)
  static List<UserModel> generateDemoEmployees() {
    final employees = <UserModel>[];
    final firstNames = [
      'John', 'Mary', 'Peter', 'Grace', 'David', 'Sarah', 'Michael', 'Jane',
      'James', 'Lucy', 'Daniel', 'Faith', 'Samuel', 'Rose', 'Joseph', 'Ann',
      'Paul', 'Catherine', 'Mark', 'Elizabeth', 'Matthew', 'Margaret', 'Luke',
      'Joyce', 'Stephen', 'Susan', 'Andrew', 'Nancy', 'Philip', 'Helen'
    ];
    
    final lastNames = [
      'Kamau', 'Wanjiku', 'Mwangi', 'Njeri', 'Kiprotich', 'Akinyi', 'Ochieng',
      'Wambui', 'Mutua', 'Nyong\'o', 'Kiplagat', 'Adhiambo', 'Macharia', 'Wairimu',
      'Kiptoo', 'Atieno', 'Githinji', 'Wanjiru', 'Rotich', 'Awino', 'Mbugua',
      'Njoki', 'Cheruiyot', 'Akoth', 'Njenga', 'Wangari', 'Lagat', 'Apiyo'
    ];

    for (int i = 0; i < 100; i++) {
      final firstName = firstNames[_random.nextInt(firstNames.length)];
      final lastName = lastNames[_random.nextInt(lastNames.length)];
      final phoneNumber = '0${7 + _random.nextInt(2)}${_random.nextInt(90000000) + 10000000}';
      
      final employee = UserModel(
        id: _uuid.v4(),
        email: '${firstName.toLowerCase()}.${lastName.toLowerCase()}@guardtrack.com',
        phone: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        role: UserRole.guard,
        isActive: _random.nextDouble() > 0.05, // 95% active
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
        assignedSiteIds: [], // Will be assigned to sites
      );
      employees.add(employee);
    }

    return employees;
  }

  // Assign employees to sites (5 employees per site on average)
  static void assignEmployeesToSites(List<UserModel> employees, List<SiteModel> sites) {
    final employeesPerSite = employees.length ~/ sites.length; // 5 employees per site
    
    for (int siteIndex = 0; siteIndex < sites.length; siteIndex++) {
      final startIndex = siteIndex * employeesPerSite;
      final endIndex = (siteIndex == sites.length - 1) 
          ? employees.length 
          : startIndex + employeesPerSite;
      
      final siteEmployees = employees.sublist(startIndex, endIndex);
      final guardIds = siteEmployees.map((e) => e.id).toList();
      
      // Update site with assigned guard IDs
      sites[siteIndex] = sites[siteIndex].copyWith(assignedGuardIds: guardIds);
      
      // Update employees with assigned site IDs
      for (int empIndex = startIndex; empIndex < endIndex; empIndex++) {
        employees[empIndex] = employees[empIndex].copyWith(
          assignedSiteIds: [sites[siteIndex].id],
        );
      }
    }
  }

  // Generate realistic attendance records for a specific date
  static List<AttendanceModel> generateAttendanceForDate({
    required DateTime date,
    required List<UserModel> employees,
    required List<SiteModel> sites,
    double attendanceRate = 0.85, // 85% attendance rate
  }) {
    final attendanceRecords = <AttendanceModel>[];
    
    for (final site in sites) {
      final siteEmployees = employees.where((e) => 
        e.assignedSiteIds?.contains(site.id) ?? false
      ).toList();
      
      for (final employee in siteEmployees) {
        // Random chance of attendance
        if (_random.nextDouble() < attendanceRate) {
          // Generate check-in time (between 6:00 AM and 9:00 AM)
          final checkInHour = 6 + _random.nextInt(3);
          final checkInMinute = _random.nextInt(60);
          final checkInTime = DateTime(
            date.year, date.month, date.day, 
            checkInHour, checkInMinute
          );
          
          // Check-in record
          final checkIn = AttendanceModel(
            id: _uuid.v4(),
            guardId: employee.id,
            siteId: site.id,
            type: AttendanceType.checkIn,
            status: AttendanceStatus.verified,
            arrivalCode: _generateArrivalCode(),
            latitude: site.latitude + (_random.nextDouble() - 0.5) * 0.001,
            longitude: site.longitude + (_random.nextDouble() - 0.5) * 0.001,
            accuracy: 5.0 + _random.nextDouble() * 10,
            timestamp: checkInTime,
            notes: _random.nextDouble() > 0.7 ? 'All clear at site' : null,
            createdAt: checkInTime,
          );
          attendanceRecords.add(checkIn);
          
          // Generate check-out (80% chance)
          if (_random.nextDouble() < 0.8) {
            final checkOutHour = 17 + _random.nextInt(3); // 5:00 PM - 7:59 PM
            final checkOutMinute = _random.nextInt(60);
            final checkOutTime = DateTime(
              date.year, date.month, date.day,
              checkOutHour, checkOutMinute
            );
            
            final checkOut = AttendanceModel(
              id: _uuid.v4(),
              guardId: employee.id,
              siteId: site.id,
              type: AttendanceType.checkOut,
              status: AttendanceStatus.verified,
              arrivalCode: _generateArrivalCode(),
              latitude: site.latitude + (_random.nextDouble() - 0.5) * 0.001,
              longitude: site.longitude + (_random.nextDouble() - 0.5) * 0.001,
              accuracy: 5.0 + _random.nextDouble() * 10,
              timestamp: checkOutTime,
              notes: _random.nextDouble() > 0.8 ? 'Shift completed successfully' : null,
              createdAt: checkOutTime,
            );
            attendanceRecords.add(checkOut);
          }
        }
      }
    }
    
    return attendanceRecords;
  }

  // Generate attendance for multiple days
  static List<AttendanceModel> generateAttendanceForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required List<UserModel> employees,
    required List<SiteModel> sites,
    double attendanceRate = 0.85,
  }) {
    final allAttendance = <AttendanceModel>[];
    
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Skip weekends (optional)
      if (currentDate.weekday != DateTime.saturday && currentDate.weekday != DateTime.sunday) {
        final dayAttendance = generateAttendanceForDate(
          date: currentDate,
          employees: employees,
          sites: sites,
          attendanceRate: attendanceRate,
        );
        allAttendance.addAll(dayAttendance);
      }
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return allAttendance;
  }

  static String _generateArrivalCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  // Generate summary statistics
  static Map<String, dynamic> generateAttendanceStats({
    required List<AttendanceModel> attendanceRecords,
    required List<UserModel> employees,
    required List<SiteModel> sites,
  }) {
    final checkIns = attendanceRecords.where((a) => a.isCheckIn).toList();
    final checkOuts = attendanceRecords.where((a) => a.isCheckOut).toList();
    
    final siteStats = <String, Map<String, int>>{};
    for (final site in sites) {
      final siteCheckIns = checkIns.where((a) => a.siteId == site.id).length;
      final siteCheckOuts = checkOuts.where((a) => a.siteId == site.id).length;
      siteStats[site.name] = {
        'checkIns': siteCheckIns,
        'checkOuts': siteCheckOuts,
        'assignedEmployees': site.assignedGuardIds?.length ?? 0,
      };
    }
    
    return {
      'totalEmployees': employees.length,
      'totalSites': sites.length,
      'totalCheckIns': checkIns.length,
      'totalCheckOuts': checkOuts.length,
      'attendanceRate': checkIns.length / employees.length,
      'siteStats': siteStats,
    };
  }
}
