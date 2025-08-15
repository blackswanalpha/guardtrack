import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/site_model.dart';
import '../../domain/repositories/site_repository.dart';

// Events
abstract class AssignedSitesEvent extends Equatable {
  const AssignedSitesEvent();

  @override
  List<Object?> get props => [];
}

class AssignedSitesLoadRequested extends AssignedSitesEvent {
  final String guardId;

  const AssignedSitesLoadRequested(this.guardId);

  @override
  List<Object?> get props => [guardId];
}

class AssignedSitesRefreshed extends AssignedSitesEvent {
  final String guardId;

  const AssignedSitesRefreshed(this.guardId);

  @override
  List<Object?> get props => [guardId];
}

class LoadAllSites extends AssignedSitesEvent {
  const LoadAllSites();
}

// States
abstract class AssignedSitesState extends Equatable {
  const AssignedSitesState();

  @override
  List<Object?> get props => [];
}

class AssignedSitesInitial extends AssignedSitesState {}

class AssignedSitesLoading extends AssignedSitesState {}

class AssignedSitesLoaded extends AssignedSitesState {
  final List<SiteModel> sites;
  final List<SiteModel>? allSites;

  const AssignedSitesLoaded(this.sites, {this.allSites});

  @override
  List<Object?> get props => [sites, allSites];
}

class AssignedSitesError extends AssignedSitesState {
  final String message;

  const AssignedSitesError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AssignedSitesBloc extends Bloc<AssignedSitesEvent, AssignedSitesState> {
  final SiteRepository _siteRepository;

  AssignedSitesBloc({
    required SiteRepository siteRepository,
  })  : _siteRepository = siteRepository,
        super(AssignedSitesInitial()) {
    on<AssignedSitesLoadRequested>(_onAssignedSitesLoadRequested);
    on<AssignedSitesRefreshed>(_onAssignedSitesRefreshed);
    on<LoadAllSites>(_onLoadAllSites);
  }

  Future<void> _onAssignedSitesLoadRequested(
    AssignedSitesLoadRequested event,
    Emitter<AssignedSitesState> emit,
  ) async {
    emit(AssignedSitesLoading());

    try {
      final sites = await _siteRepository.getAssignedSites(event.guardId);
      Logger.info('Loaded ${sites.length} assigned sites',
          tag: 'AssignedSitesBloc');
      emit(AssignedSitesLoaded(sites));
    } catch (e) {
      Logger.error('Failed to load assigned sites',
          tag: 'AssignedSitesBloc', error: e);
      emit(AssignedSitesError('Failed to load sites: ${e.toString()}'));
    }
  }

  Future<void> _onAssignedSitesRefreshed(
    AssignedSitesRefreshed event,
    Emitter<AssignedSitesState> emit,
  ) async {
    try {
      final sites = await _siteRepository.getAssignedSites(event.guardId);
      Logger.info('Refreshed ${sites.length} assigned sites',
          tag: 'AssignedSitesBloc');
      emit(AssignedSitesLoaded(sites));
    } catch (e) {
      Logger.error('Failed to refresh assigned sites',
          tag: 'AssignedSitesBloc', error: e);
      emit(AssignedSitesError('Failed to refresh sites: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAllSites(
    LoadAllSites event,
    Emitter<AssignedSitesState> emit,
  ) async {
    emit(AssignedSitesLoading());

    try {
      final allSites = await _siteRepository.getAllSites();
      Logger.info('Loaded ${allSites.length} total sites',
          tag: 'AssignedSitesBloc');
      emit(AssignedSitesLoaded(const [], allSites: allSites));
    } catch (e) {
      Logger.error('Failed to load all sites',
          tag: 'AssignedSitesBloc', error: e);
      emit(AssignedSitesError('Failed to load sites: ${e.toString()}'));
    }
  }
}

// Extension to get sites from any AssignedSitesState
extension AssignedSitesStateExtension on AssignedSitesState {
  List<SiteModel> get sites {
    if (this is AssignedSitesLoaded) {
      return (this as AssignedSitesLoaded).sites;
    }
    return [];
  }
}
