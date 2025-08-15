import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/models/attendance_model.dart';
import '../../../../shared/models/site_model.dart';
import '../pages/attendance_history_page.dart';

// Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendanceHistory extends AttendanceEvent {}

class RefreshAttendanceHistory extends AttendanceEvent {}

class FilterAttendanceHistory extends AttendanceEvent {
  final String searchQuery;
  final AttendanceFilter filter;
  final DateTimeRange? dateRange;

  const FilterAttendanceHistory({
    required this.searchQuery,
    required this.filter,
    this.dateRange,
  });

  @override
  List<Object?> get props => [searchQuery, filter, dateRange];
}

class CreateAttendance extends AttendanceEvent {
  final AttendanceModel attendance;

  const CreateAttendance(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

// States
abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceHistoryLoaded extends AttendanceState {
  final List<AttendanceModel> attendanceList;
  final List<AttendanceModel> filteredList;
  final Map<String, SiteModel> sites;

  const AttendanceHistoryLoaded({
    required this.attendanceList,
    required this.filteredList,
    required this.sites,
  });

  @override
  List<Object?> get props => [attendanceList, filteredList, sites];

  AttendanceHistoryLoaded copyWith({
    List<AttendanceModel>? attendanceList,
    List<AttendanceModel>? filteredList,
    Map<String, SiteModel>? sites,
  }) {
    return AttendanceHistoryLoaded(
      attendanceList: attendanceList ?? this.attendanceList,
      filteredList: filteredList ?? this.filteredList,
      sites: sites ?? this.sites,
    );
  }
}

class AttendanceCreated extends AttendanceState {
  final AttendanceModel attendance;

  const AttendanceCreated(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc() : super(AttendanceInitial()) {
    on<LoadAttendanceHistory>(_onLoadAttendanceHistory);
    on<RefreshAttendanceHistory>(_onRefreshAttendanceHistory);
    on<FilterAttendanceHistory>(_onFilterAttendanceHistory);
    on<CreateAttendance>(_onCreateAttendance);
  }

  void _onLoadAttendanceHistory(
      LoadAttendanceHistory event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());

    try {
      // TODO: Load from repository
      final attendanceList = _getMockAttendanceList();
      final sites = _getMockSites();

      emit(AttendanceHistoryLoaded(
        attendanceList: attendanceList,
        filteredList: attendanceList,
        sites: sites,
      ));
    } catch (e) {
      emit(AttendanceError('Failed to load attendance history: $e'));
    }
  }

  void _onRefreshAttendanceHistory(
      RefreshAttendanceHistory event, Emitter<AttendanceState> emit) async {
    if (state is AttendanceHistoryLoaded) {
      try {
        // TODO: Refresh from repository
        final attendanceList = _getMockAttendanceList();
        final sites = _getMockSites();

        emit(AttendanceHistoryLoaded(
          attendanceList: attendanceList,
          filteredList: attendanceList,
          sites: sites,
        ));
      } catch (e) {
        emit(AttendanceError('Failed to refresh attendance history: $e'));
      }
    } else {
      add(LoadAttendanceHistory());
    }
  }

  void _onFilterAttendanceHistory(
      FilterAttendanceHistory event, Emitter<AttendanceState> emit) {
    if (state is AttendanceHistoryLoaded) {
      final currentState = state as AttendanceHistoryLoaded;

      List<AttendanceModel> filteredList = currentState.attendanceList;

      // Apply search filter
      if (event.searchQuery.isNotEmpty) {
        filteredList = filteredList.where((attendance) {
          final site = currentState.sites[attendance.siteId];
          final siteName = site?.name.toLowerCase() ?? '';
          final code = attendance.arrivalCode.toLowerCase();
          final query = event.searchQuery.toLowerCase();

          return siteName.contains(query) || code.contains(query);
        }).toList();
      }

      // Apply status filter
      switch (event.filter) {
        case AttendanceFilter.checkIn:
          filteredList = filteredList.where((a) => a.isCheckIn).toList();
          break;
        case AttendanceFilter.checkOut:
          filteredList = filteredList.where((a) => a.isCheckOut).toList();
          break;
        case AttendanceFilter.verified:
          filteredList = filteredList.where((a) => a.isVerified).toList();
          break;
        case AttendanceFilter.pending:
          filteredList = filteredList.where((a) => a.isPending).toList();
          break;
        case AttendanceFilter.rejected:
          filteredList = filteredList.where((a) => a.isRejected).toList();
          break;
        case AttendanceFilter.all:
          // No additional filtering
          break;
      }

      // Apply date range filter
      if (event.dateRange != null) {
        filteredList = filteredList.where((attendance) {
          final date = attendance.timestamp;
          return date.isAfter(
                  event.dateRange!.start.subtract(const Duration(days: 1))) &&
              date.isBefore(event.dateRange!.end.add(const Duration(days: 1)));
        }).toList();
      }

      // Sort by timestamp (newest first)
      filteredList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(currentState.copyWith(filteredList: filteredList));
    }
  }

  void _onCreateAttendance(
      CreateAttendance event, Emitter<AttendanceState> emit) async {
    try {
      // TODO: Save to repository
      emit(AttendanceCreated(event.attendance));

      // Refresh the list
      add(LoadAttendanceHistory());
    } catch (e) {
      emit(AttendanceError('Failed to create attendance record: $e'));
    }
  }

  // Mock data - replace with actual repository calls
  List<AttendanceModel> _getMockAttendanceList() {
    final now = DateTime.now();

    return [
      AttendanceModel(
        id: '1',
        guardId: 'guard1',
        siteId: '1',
        type: AttendanceType.checkIn,
        status: AttendanceStatus.verified,
        arrivalCode: 'ABC123',
        latitude: -1.2921,
        longitude: 36.8219,
        accuracy: 15.0,
        timestamp: now.subtract(const Duration(hours: 2)),
        photoUrl: 'https://example.com/photo1.jpg',
        verifiedBy: 'admin1',
        verifiedAt: now.subtract(const Duration(hours: 1)),
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AttendanceModel(
        id: '2',
        guardId: 'guard1',
        siteId: '2',
        type: AttendanceType.checkIn,
        status: AttendanceStatus.pending,
        arrivalCode: 'DEF456',
        latitude: -1.2676,
        longitude: 36.8108,
        accuracy: 8.0,
        timestamp: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AttendanceModel(
        id: '3',
        guardId: 'guard1',
        siteId: '1',
        type: AttendanceType.checkOut,
        status: AttendanceStatus.verified,
        arrivalCode: 'GHI789',
        latitude: -1.2921,
        longitude: 36.8219,
        accuracy: 12.0,
        timestamp: now.subtract(const Duration(days: 2)),
        verifiedBy: 'admin1',
        verifiedAt: now.subtract(const Duration(days: 2, hours: 1)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  Map<String, SiteModel> _getMockSites() {
    return {
      '1': SiteModel(
        id: '1',
        name: 'Downtown Office Complex',
        address: '123 Business Street, Downtown',
        latitude: -1.2921,
        longitude: 36.8219,
        allowedRadius: 100.0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      '2': SiteModel(
        id: '2',
        name: 'Westlands Shopping Mall',
        address: '456 Mall Avenue, Westlands',
        latitude: -1.2676,
        longitude: 36.8108,
        allowedRadius: 150.0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    };
  }
}
