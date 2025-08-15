import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../shared/models/site_model.dart';
import '../../../../shared/services/location_service.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

class RefreshDashboardData extends DashboardEvent {}

class RefreshLocation extends DashboardEvent {}

class UpdateLocation extends DashboardEvent {
  final Position position;

  const UpdateLocation(this.position);

  @override
  List<Object?> get props => [position];
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<SiteModel> assignedSites;
  final Position? currentPosition;
  final bool canCheckIn;
  final bool canCheckOut;
  final String? currentSiteId;

  const DashboardLoaded({
    required this.assignedSites,
    this.currentPosition,
    required this.canCheckIn,
    required this.canCheckOut,
    this.currentSiteId,
  });

  @override
  List<Object?> get props => [
        assignedSites,
        currentPosition,
        canCheckIn,
        canCheckOut,
        currentSiteId,
      ];

  DashboardLoaded copyWith({
    List<SiteModel>? assignedSites,
    Position? currentPosition,
    bool? canCheckIn,
    bool? canCheckOut,
    String? currentSiteId,
  }) {
    return DashboardLoaded(
      assignedSites: assignedSites ?? this.assignedSites,
      currentPosition: currentPosition ?? this.currentPosition,
      canCheckIn: canCheckIn ?? this.canCheckIn,
      canCheckOut: canCheckOut ?? this.canCheckOut,
      currentSiteId: currentSiteId ?? this.currentSiteId,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final LocationService _locationService = LocationService();

  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<RefreshLocation>(_onRefreshLocation);
    on<UpdateLocation>(_onUpdateLocation);
  }

  void _onLoadDashboardData(LoadDashboardData event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    
    try {
      // Get current location
      Position? currentPosition;
      try {
        currentPosition = await _locationService.getCurrentPosition();
      } catch (e) {
        // Try to get last known position if current fails
        currentPosition = await _locationService.getLastKnownPosition();
      }

      // TODO: Load assigned sites from repository
      final assignedSites = _getMockSites();

      // TODO: Check current check-in status
      final canCheckIn = true; // Mock value
      final canCheckOut = false; // Mock value
      final currentSiteId = null; // Mock value

      emit(DashboardLoaded(
        assignedSites: assignedSites,
        currentPosition: currentPosition,
        canCheckIn: canCheckIn,
        canCheckOut: canCheckOut,
        currentSiteId: currentSiteId,
      ));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard data: $e'));
    }
  }

  void _onRefreshDashboardData(RefreshDashboardData event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      
      try {
        // Get fresh location
        Position? currentPosition;
        try {
          currentPosition = await _locationService.getCurrentPosition();
        } catch (e) {
          currentPosition = currentState.currentPosition;
        }

        // TODO: Refresh assigned sites from repository
        final assignedSites = _getMockSites();

        // TODO: Refresh check-in status
        final canCheckIn = true;
        final canCheckOut = false;
        final currentSiteId = null;

        emit(DashboardLoaded(
          assignedSites: assignedSites,
          currentPosition: currentPosition,
          canCheckIn: canCheckIn,
          canCheckOut: canCheckOut,
          currentSiteId: currentSiteId,
        ));
      } catch (e) {
        emit(DashboardError('Failed to refresh dashboard data: $e'));
      }
    } else {
      add(LoadDashboardData());
    }
  }

  void _onRefreshLocation(RefreshLocation event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      
      try {
        final currentPosition = await _locationService.getCurrentPosition();
        
        emit(currentState.copyWith(currentPosition: currentPosition));
      } catch (e) {
        // Don't emit error for location refresh, just keep current state
        // Could show a snackbar or toast instead
      }
    }
  }

  void _onUpdateLocation(UpdateLocation event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(currentPosition: event.position));
    }
  }

  // Mock data - replace with actual repository calls
  List<SiteModel> _getMockSites() {
    return [
      SiteModel(
        id: '1',
        name: 'Downtown Office Complex',
        address: '123 Business Street, Downtown',
        latitude: -1.2921,
        longitude: 36.8219,
        allowedRadius: 100.0,
        isActive: true,
        description: 'Main office building security',
        contactPerson: 'John Manager',
        contactPhone: '+254700000001',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        assignedGuardIds: ['guard1'],
      ),
      SiteModel(
        id: '2',
        name: 'Westlands Shopping Mall',
        address: '456 Mall Avenue, Westlands',
        latitude: -1.2676,
        longitude: 36.8108,
        allowedRadius: 150.0,
        isActive: true,
        description: 'Shopping mall main entrance',
        contactPerson: 'Jane Supervisor',
        contactPhone: '+254700000002',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        assignedGuardIds: ['guard1'],
      ),
      SiteModel(
        id: '3',
        name: 'Industrial Park Gate',
        address: '789 Industrial Road, Embakasi',
        latitude: -1.3197,
        longitude: 36.8947,
        allowedRadius: 75.0,
        isActive: true,
        description: 'Main gate security checkpoint',
        contactPerson: 'Bob Security',
        contactPhone: '+254700000003',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        assignedGuardIds: ['guard1'],
      ),
    ];
  }
}
