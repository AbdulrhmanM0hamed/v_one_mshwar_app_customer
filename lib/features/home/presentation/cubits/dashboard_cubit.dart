import 'package:flutter_bloc/flutter_bloc.dart';

/// State for dashboard/bottom nav selection
class DashboardState {
  final int selectedIndex;
  const DashboardState({this.selectedIndex = 0});

  DashboardState copyWith({int? selectedIndex}) {
    return DashboardState(selectedIndex: selectedIndex ?? this.selectedIndex);
  }
}

/// Cubit to manage the selected tab index in BottomNavBar.
/// Replaces the old GetX DashBoardController.selectedDrawerIndex usage.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({int initialIndex = 0})
    : super(DashboardState(selectedIndex: initialIndex));

  void updateIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }
}
