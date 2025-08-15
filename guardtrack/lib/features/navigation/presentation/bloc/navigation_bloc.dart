import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class NavigationTabChanged extends NavigationEvent {
  final int index;

  const NavigationTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}

// States
abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object?> get props => [];
}

class NavigationInitial extends NavigationState {
  final int selectedIndex;

  const NavigationInitial({this.selectedIndex = 0});

  @override
  List<Object?> get props => [selectedIndex];
}

class NavigationTabSelected extends NavigationState {
  final int selectedIndex;

  const NavigationTabSelected(this.selectedIndex);

  @override
  List<Object?> get props => [selectedIndex];
}

// BLoC
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationInitial()) {
    on<NavigationTabChanged>(_onNavigationTabChanged);
  }

  void _onNavigationTabChanged(
    NavigationTabChanged event,
    Emitter<NavigationState> emit,
  ) {
    emit(NavigationTabSelected(event.index));
  }
}

// Extension to get selectedIndex from any NavigationState
extension NavigationStateExtension on NavigationState {
  int get selectedIndex {
    if (this is NavigationInitial) {
      return (this as NavigationInitial).selectedIndex;
    } else if (this is NavigationTabSelected) {
      return (this as NavigationTabSelected).selectedIndex;
    }
    return 0;
  }
}
