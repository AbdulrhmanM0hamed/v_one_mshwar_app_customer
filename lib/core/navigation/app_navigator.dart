import 'package:flutter/material.dart';
import 'package:v_one_mshwar_app_customer/common/screens/botton_nav_bar.dart';
import 'package:v_one_mshwar_app_customer/features/ride/chat/view/conversation_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/ride_model.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/ride_details.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/route_view_screen.dart';

/// Centralized navigation helper using navigatorKey.
/// All navigation from notifications/services goes through here.
class AppNavigator {
  final GlobalKey<NavigatorState> navigatorKey;

  AppNavigator(this.navigatorKey);

  NavigatorState? get _nav => navigatorKey.currentState;
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate to BottomNavBar with a specific tab index
  void toBottomNav({int initialIndex = 0}) {
    _nav?.push(
      MaterialPageRoute(
        builder: (_) => BottomNavBar(initialIndex: initialIndex),
      ),
    );
  }

  /// Navigate to ConversationScreen with chat arguments
  void toConversation({
    required int receiverId,
    required int orderId,
    required String receiverName,
    required String receiverPhoto,
  }) {
    _nav?.push(
      MaterialPageRoute(
        builder: (_) => ConversationScreen(),
        settings: RouteSettings(
          arguments: {
            'receiverId': receiverId,
            'orderId': orderId,
            'receiverName': receiverName,
            'receiverPhoto': receiverPhoto,
          },
        ),
      ),
    );
  }

  /// Navigate to RouteViewScreen with ride data
  void toRouteView({required RideData rideData, required String type}) {
    _nav?.push(
      MaterialPageRoute(
        builder: (_) => const RouteViewScreen(),
        settings: RouteSettings(arguments: {'type': type, 'data': rideData}),
      ),
    );
  }

  /// Navigate to TripHistoryScreen with ride data
  void toTripHistory({required RideData rideData}) {
    _nav?.push(
      MaterialPageRoute(
        builder: (_) => TripHistoryScreen(),
        settings: RouteSettings(arguments: {"rideData": rideData}),
      ),
    );
  }
}
