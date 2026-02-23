import 'dart:async';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'splash_screen.dart';

class ServerDownScreen extends StatefulWidget {
  const ServerDownScreen({super.key});

  static const Key widgetKey = ValueKey('ServerDownScreen');

  @override
  State<ServerDownScreen> createState() => _ServerDownScreenState();
}

class _ServerDownScreenState extends State<ServerDownScreen>
    with AutomaticKeepAliveClientMixin {
  Timer? _serverCheckTimer;
  bool _isNavigating = false;
  bool _isInitialized = false;

  static const IconData documentIcon = Iconsax.document_text;

  Widget? _cachedContent;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Dismiss any existing toasts/loaders on server down screen
    EasyLoading.dismiss();
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startServerHealthCheck();
        // Periodically dismiss toasts to prevent them from showing
        _periodicToastDismiss();
      }
    });
  }

  /// Periodically dismiss toasts to prevent them from showing during server down screen
  void _periodicToastDismiss() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted || _isNavigating) {
        timer.cancel();
        return;
      }
      EasyLoading.dismiss();
    });
  }

  void _startServerHealthCheck() {
    _serverCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkServerSilently(timer);
    });
  }

  void _checkServerSilently(Timer timer) async {
    if (!mounted || _isNavigating) {
      if (!mounted) {
        timer.cancel();
      }
      return;
    }

    try {
      debugPrint('🔄 Server down screen: Checking server health...');
      final response = await http
          .get(Uri.parse('${API.baseUrl}settings'), headers: API.authheader)
          .timeout(const Duration(seconds: 5));

      debugPrint('📡 Server down screen: Response ${response.statusCode}');
      if ((response.statusCode == 200 || response.statusCode == 401) &&
          mounted &&
          !_isNavigating) {
        debugPrint('✅ Server is back UP! Navigating to SplashScreen');
        _isNavigating = true;
        timer.cancel();
        Get.offAll(
          () => const SplashScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      } else {
        debugPrint('❌ Server still down (status: ${response.statusCode})');
      }
    } catch (e) {
      // Silent error handling - don't rebuild screen
      debugPrint('❌ Server down screen: Server still unreachable - $e');
    }
  }

  @override
  void dispose() {
    _serverCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _cachedContent ??= _buildContent();
    return Scaffold(body: _cachedContent!);
  }

  Widget _buildContent() {
    return Stack(
      children: [
        _buildGradientBackground(),
        _buildDecorativeElements(),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _buildStaticIcon(),
                    const SizedBox(height: 32),
                    CustomText(
                      text: 'Server Unavailable',
                      size: 22,
                      weight: FontWeight.bold,
                      color: AppThemeData.grey900,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    CustomText(
                      text:
                          'We\'re unable to connect to our servers right now. Our team has been notified and is working to resolve the issue.',
                      size: 14,
                      weight: FontWeight.w400,
                      color: AppThemeData.grey400,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildTipsSection(),
                    const SizedBox(height: 32),
                    _buildSubmitReportButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientBackground() {
    return Container(decoration: const BoxDecoration(color: Colors.white));
  }

  Widget _buildDecorativeElements() {
    return const SizedBox.shrink(); // Remove decorative elements
  }

  Widget _buildStaticIcon() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppThemeData.error200.withValues(alpha: 0.15),
            AppThemeData.error200.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppThemeData.error200.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          ),
          Icon(Iconsax.warning_2, color: AppThemeData.error200, size: 70),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppThemeData.error200.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppThemeData.error200.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.info_circle,
              color: AppThemeData.error200,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'What\'s happening?',
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppThemeData.grey900,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text:
                      'Our servers are temporarily unavailable. Please check back later.',
                  size: 12,
                  weight: FontWeight.w400,
                  color: AppThemeData.grey400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeData.grey200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.info_circle, color: AppThemeData.error200, size: 20),
              const SizedBox(width: 8),
              CustomText(
                text: 'While you wait',
                size: 14,
                weight: FontWeight.w600,
                color: AppThemeData.grey900,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            icon: Iconsax.wifi,
            text: 'Check your internet connection',
          ),
          const SizedBox(height: 8),
          _buildTipItem(
            icon: Iconsax.clock,
            text: 'Try again in a few minutes',
          ),
          const SizedBox(height: 8),
          _buildTipItem(
            icon: Iconsax.notification,
            text: 'We\'ll notify you when service is restored',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppThemeData.grey400),
        const SizedBox(width: 12),
        Expanded(
          child: CustomText(
            text: text,
            size: 12,
            weight: FontWeight.w400,
            color: AppThemeData.grey400,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitReportButton() {
    return CustomButton(
      btnName: 'Submit Report',
      buttonColor: AppThemeData.error200,
      ontap: () {
        _handleSubmitReport();
      },
      boxShadow: [
        BoxShadow(
          color: AppThemeData.error200.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  void _handleSubmitReport() {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppThemeData.error200.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  documentIcon,
                  color: AppThemeData.error200,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              CustomText(
                text: 'Report Submitted',
                size: 18,
                weight: FontWeight.bold,
                color: AppThemeData.grey900,
                align: TextAlign.center,
              ),
              const SizedBox(height: 8),
              CustomText(
                text:
                    'Thank you for reporting this issue. Our team will investigate and work to resolve it as soon as possible.',
                size: 14,
                weight: FontWeight.w400,
                color: AppThemeData.grey400,
                align: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                btnName: 'Close',
                buttonColor: AppThemeData.error200,
                ontap: () => Get.back<void>(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
