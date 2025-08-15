import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/site_model.dart';
import '../../../../shared/models/attendance_model.dart';
import '../../../../shared/services/location_service.dart';
import '../../../../shared/services/geofencing_service.dart';
import '../../../../shared/services/attendance_service.dart';
import '../../domain/repositories/site_repository.dart';

// Events
abstract class CheckInEvent extends Equatable {
  const CheckInEvent();

  @override
  List<Object?> get props => [];
}

class CheckInInitialized extends CheckInEvent {
  final String guardId;

  const CheckInInitialized(this.guardId);

  @override
  List<Object?> get props => [guardId];
}

class LocationRefreshed extends CheckInEvent {}

class CheckInRefreshed extends CheckInEvent {}

class SiteSelected extends CheckInEvent {
  final SiteModel site;

  const SiteSelected(this.site);

  @override
  List<Object?> get props => [site];
}

class CheckInRequested extends CheckInEvent {
  final String siteId;
  final String guardId;

  const CheckInRequested({
    required this.siteId,
    required this.guardId,
  });

  @override
  List<Object?> get props => [siteId, guardId];
}

class CheckOutRequested extends CheckInEvent {
  final String siteId;
  final String guardId;

  const CheckOutRequested({
    required this.siteId,
    required this.guardId,
  });

  @override
  List<Object?> get props => [siteId, guardId];
}

class PhotoCaptureRequested extends CheckInEvent {
  final String siteId;
  final String guardId;

  const PhotoCaptureRequested({
    required this.siteId,
    required this.guardId,
  });

  @override
  List<Object?> get props => [siteId, guardId];
}

// States
abstract class CheckInState extends Equatable {
  final Position? currentPosition;
  final double? locationAccuracy;
  final bool isLocationEnabled;
  final List<SiteModel> assignedSites;
  final SiteModel? selectedSite;
  final AttendanceModel? currentAttendance;
  final File? capturedPhoto;
  final bool requiresPhoto;

  const CheckInState({
    this.currentPosition,
    this.locationAccuracy,
    this.isLocationEnabled = false,
    this.assignedSites = const [],
    this.selectedSite,
    this.currentAttendance,
    this.capturedPhoto,
    this.requiresPhoto = true,
  });

  @override
  List<Object?> get props => [
        currentPosition,
        locationAccuracy,
        isLocationEnabled,
        assignedSites,
        selectedSite,
        currentAttendance,
        capturedPhoto,
        requiresPhoto,
      ];
}

class CheckInInitial extends CheckInState {}

class CheckInLoading extends CheckInState {
  const CheckInLoading({
    super.currentPosition,
    super.locationAccuracy,
    super.isLocationEnabled,
    super.assignedSites,
    super.selectedSite,
    super.currentAttendance,
    super.capturedPhoto,
    super.requiresPhoto,
  });
}

class CheckInLoaded extends CheckInState {
  const CheckInLoaded({
    super.currentPosition,
    super.locationAccuracy,
    super.isLocationEnabled,
    super.assignedSites,
    super.selectedSite,
    super.currentAttendance,
    super.capturedPhoto,
    super.requiresPhoto,
  });
}

class CheckInSuccess extends CheckInState {
  final String arrivalCode;

  const CheckInSuccess({
    required this.arrivalCode,
    super.currentPosition,
    super.locationAccuracy,
    super.isLocationEnabled,
    super.assignedSites,
    super.selectedSite,
    super.currentAttendance,
    super.capturedPhoto,
    super.requiresPhoto,
  });

  @override
  List<Object?> get props => [arrivalCode, ...super.props];
}

class PhotoCaptureRequired extends CheckInState {
  const PhotoCaptureRequired({
    super.currentPosition,
    super.locationAccuracy,
    super.isLocationEnabled,
    super.assignedSites,
    super.selectedSite,
    super.currentAttendance,
    super.capturedPhoto,
    super.requiresPhoto,
  });
}

class CheckInError extends CheckInState {
  final String message;

  const CheckInError({
    required this.message,
    super.currentPosition,
    super.locationAccuracy,
    super.isLocationEnabled,
    super.assignedSites,
    super.selectedSite,
    super.currentAttendance,
    super.capturedPhoto,
    super.requiresPhoto,
  });

  @override
  List<Object?> get props => [message, ...super.props];
}

// BLoC
class CheckInBloc extends Bloc<CheckInEvent, CheckInState> {
  final LocationService _locationService;
  final GeofencingService _geofencingService;
  final AttendanceService _attendanceService;
  final SiteRepository _siteRepository;

  CheckInBloc({
    required LocationService locationService,
    required GeofencingService geofencingService,
    required AttendanceService attendanceService,
    required SiteRepository siteRepository,
  })  : _locationService = locationService,
        _geofencingService = geofencingService,
        _attendanceService = attendanceService,
        _siteRepository = siteRepository,
        super(CheckInInitial()) {
    on<CheckInInitialized>(_onCheckInInitialized);
    on<LocationRefreshed>(_onLocationRefreshed);
    on<CheckInRefreshed>(_onCheckInRefreshed);
    on<SiteSelected>(_onSiteSelected);
    on<PhotoCaptureRequested>(_onPhotoCaptureRequested);
    on<CheckInRequested>(_onCheckInRequested);
    on<CheckOutRequested>(_onCheckOutRequested);
  }

  Future<void> _onCheckInInitialized(
    CheckInInitialized event,
    Emitter<CheckInState> emit,
  ) async {
    emit(const CheckInLoading());

    try {
      // Initialize location service
      await _locationService.initialize();

      // Get current location
      final position = await _locationService.getCurrentPosition();
      final accuracy = position.accuracy;
      final isLocationEnabled = await _locationService.isLocationEnabled();

      // Load assigned sites
      final sites = await _siteRepository.getAssignedSites(event.guardId);

      // Get current attendance status
      final currentAttendance =
          await _attendanceService.getCurrentAttendance(event.guardId);

      Logger.info('Check-in initialized', tag: 'CheckInBloc');

      emit(CheckInLoaded(
        currentPosition: position,
        locationAccuracy: accuracy,
        isLocationEnabled: isLocationEnabled,
        assignedSites: sites,
        currentAttendance: currentAttendance,
      ));
    } catch (e) {
      Logger.error('Failed to initialize check-in',
          tag: 'CheckInBloc', error: e);
      emit(CheckInError(
        message: 'Failed to initialize: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLocationRefreshed(
    LocationRefreshed event,
    Emitter<CheckInState> emit,
  ) async {
    try {
      final position = await _locationService.getCurrentPosition();
      final accuracy = position.accuracy;
      final isLocationEnabled = await _locationService.isLocationEnabled();

      emit(CheckInLoaded(
        currentPosition: position,
        locationAccuracy: accuracy,
        isLocationEnabled: isLocationEnabled,
        assignedSites: state.assignedSites,
        selectedSite: state.selectedSite,
        currentAttendance: state.currentAttendance,
      ));
    } catch (e) {
      Logger.error('Failed to refresh location', tag: 'CheckInBloc', error: e);
      emit(CheckInError(
        message: 'Failed to get location: ${e.toString()}',
        currentPosition: state.currentPosition,
        locationAccuracy: state.locationAccuracy,
        isLocationEnabled: state.isLocationEnabled,
        assignedSites: state.assignedSites,
        selectedSite: state.selectedSite,
        currentAttendance: state.currentAttendance,
      ));
    }
  }

  Future<void> _onCheckInRefreshed(
    CheckInRefreshed event,
    Emitter<CheckInState> emit,
  ) async {
    // Refresh both location and sites data
    add(LocationRefreshed());
  }

  void _onSiteSelected(
    SiteSelected event,
    Emitter<CheckInState> emit,
  ) {
    emit(CheckInLoaded(
      currentPosition: state.currentPosition,
      locationAccuracy: state.locationAccuracy,
      isLocationEnabled: state.isLocationEnabled,
      assignedSites: state.assignedSites,
      selectedSite: event.site,
      currentAttendance: state.currentAttendance,
      capturedPhoto: state.capturedPhoto,
      requiresPhoto: state.requiresPhoto,
    ));
  }

  void _onPhotoCaptureRequested(
    PhotoCaptureRequested event,
    Emitter<CheckInState> emit,
  ) {
    // Validate location and geofence before allowing photo capture
    if (state.currentPosition == null) {
      emit(CheckInError(
        message: 'Location not available. Please enable GPS and try again.',
        currentPosition: state.currentPosition,
        locationAccuracy: state.locationAccuracy,
        isLocationEnabled: state.isLocationEnabled,
        assignedSites: state.assignedSites,
        selectedSite: state.selectedSite,
        currentAttendance: state.currentAttendance,
        capturedPhoto: state.capturedPhoto,
        requiresPhoto: state.requiresPhoto,
      ));
      return;
    }

    final site = state.selectedSite;
    if (site == null) {
      emit(CheckInError(
        message: 'No site selected',
        currentPosition: state.currentPosition,
        locationAccuracy: state.locationAccuracy,
        isLocationEnabled: state.isLocationEnabled,
        assignedSites: state.assignedSites,
        selectedSite: state.selectedSite,
        currentAttendance: state.currentAttendance,
        capturedPhoto: state.capturedPhoto,
        requiresPhoto: state.requiresPhoto,
      ));
      return;
    }

    emit(PhotoCaptureRequired(
      currentPosition: state.currentPosition,
      locationAccuracy: state.locationAccuracy,
      isLocationEnabled: state.isLocationEnabled,
      assignedSites: state.assignedSites,
      selectedSite: state.selectedSite,
      currentAttendance: state.currentAttendance,
      capturedPhoto: state.capturedPhoto,
      requiresPhoto: state.requiresPhoto,
    ));
  }

  Future<void> _onCheckInRequested(
    CheckInRequested event,
    Emitter<CheckInState> emit,
  ) async {
    emit(CheckInLoading(
      currentPosition: state.currentPosition,
      locationAccuracy: state.locationAccuracy,
      isLocationEnabled: state.isLocationEnabled,
      assignedSites: state.assignedSites,
      selectedSite: state.selectedSite,
      currentAttendance: state.currentAttendance,
    ));

    try {
      // Validate location
      if (state.currentPosition == null) {
        throw Exception('Location not available');
      }

      // Validate geofence
      final site = state.selectedSite!;
      final isWithinGeofence = await _geofencingService.isWithinGeofence(
        state.currentPosition!,
        site.latitude,
        site.longitude,
        site.geofenceRadius,
      );

      if (!isWithinGeofence) {
        throw Exception('You are not within the site area');
      }

      // Perform check-in
      final arrivalCode = await _attendanceService.checkIn(
        guardId: event.guardId,
        siteId: event.siteId,
        latitude: state.currentPosition!.latitude,
        longitude: state.currentPosition!.longitude,
        accuracy: state.currentPosition!.accuracy,
      );

      Logger.info('Check-in successful', tag: 'CheckInBloc');

      emit(CheckInSuccess(
        arrivalCode: arrivalCode,
        currentPosition: state.currentPosition,
        locationAccuracy: state.locationAccuracy,
        isLocationEnabled: state.isLocationEnabled,
        assignedSites: state.assignedSites,
        selectedSite: state.selectedSite,
      ));
    } catch (e) {
      Logger.error('Check-in failed', tag: 'CheckInBloc', error: e);
      emit(CheckInError(
        message: e.toString(),
        currentPosition: state.currentPosition,
        locationAccuracy: state.locationAccuracy,
        isLocationEnabled: state.isLocationEnabled,
        assignedSites: state.assignedSites,
        selectedSite: state.selectedSite,
        currentAttendance: state.currentAttendance,
      ));
    }
  }

  Future<void> _onCheckOutRequested(
    CheckOutRequested event,
    Emitter<CheckInState> emit,
  ) async {
    emit(CheckInLoading(
      currentPosition: state.currentPosition,
      locationAccuracy: state.locationAccuracy,
      isLocationEnabled: state.isLocationEnabled,
      assignedSites: state.assignedSites,
      selectedSite: state.selectedSite,
      currentAttendance: state.currentAttendance,
    ));

    try {
      // Validate location
      if (state.currentPosition == null) {
        throw Exception('Location not available');
      }

      // Perform check-out
      await _attendanceService.checkOut(
        guardId: event.guardId,
        siteId: event.siteId,
        latitude: state.currentPosition!.latitude,
        longitude: state.currentPosition!.longitude,
        accuracy: state.currentPosition!.accuracy,
      );

      Logger.info('Check-out successful', tag: 'CheckInBloc');

      emit(CheckInSuccess(
        arrivalCode: 'Check-out completed',
        currentPosition: state.currentPosition,
        locationAccuracy: state.locationAccuracy,
        isLocationEnabled: state.isLocationEnabled,
        assignedSites: state.assignedSites,
        selectedSite: state.selectedSite,
      ));
    } catch (e) {
      Logger.error('Check-out failed', tag: 'CheckInBloc', error: e);
      emit(CheckInError(
        message: e.toString(),
        currentPosition: state.currentPosition,
        locationAccuracy: state.locationAccuracy,
        isLocationEnabled: state.isLocationEnabled,
        assignedSites: state.assignedSites,
        selectedSite: state.selectedSite,
        currentAttendance: state.currentAttendance,
      ));
    }
  }
}
