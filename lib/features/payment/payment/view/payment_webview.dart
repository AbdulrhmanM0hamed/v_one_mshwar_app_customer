import 'dart:developer';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  double progress = 0;
  bool _paymentResultHandled = false; // Prevent duplicate handling

  final InAppWebViewSettings settings = InAppWebViewSettings(
    // Enable JavaScript
    javaScriptEnabled: true,
    // Allow mixed content (HTTP and HTTPS)
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    // Enable DOM storage
    domStorageEnabled: true,
    // Enable database storage
    databaseEnabled: true,
    // Allow file access
    allowFileAccess: true,
    // Support zoom
    supportZoom: true,
    // Enable wide viewport
    useWideViewPort: true,
    // Load with overview mode
    loadWithOverviewMode: true,
    // iOS specific settings for banking pages
    allowsInlineMediaPlayback: true,
    allowsBackForwardNavigationGestures: true,
    allowsLinkPreview: false, // Disable link preview to avoid issues
    isFraudulentWebsiteWarningEnabled: false,
    // Allow universal access
    allowUniversalAccessFromFileURLs: true,
    allowFileAccessFromFileURLs: true,
    // iOS cookie settings - important for banking
    sharedCookiesEnabled: true,
    // Enable 3rd party cookies for bank redirects
    thirdPartyCookiesEnabled: true,
    // Cache settings
    cacheEnabled: true,
    clearCache: false,
    // Use default user agent to match Safari behavior
    userAgent: null, // Let the system use default Safari user agent
    // Important for form submissions
    javaScriptCanOpenWindowsAutomatically: true,
    // Allow navigation gestures for better UX
    allowsAirPlayForMediaPlayback: true,
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel Payment?'),
            content: const Text('Are you sure you want to cancel the payment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  Get.back(result: 'false');
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: widget.title,
          onBackPressed: () async {
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Payment?'),
                content: const Text(
                  'Are you sure you want to cancel the payment?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                      Get.back(result: 'false');
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );
            if (shouldPop ?? false) {
              Get.back(result: false);
            }
          },
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: settings,
              onWebViewCreated: (controller) {
                webViewController = controller;
                log('WebView created');
              },
              onLoadStart: (controller, url) {
                showLog('🔵 Load started: $url');
                if (mounted) {
                  setState(() {
                    isLoading = true;
                  });
                }
                // Don't check for payment result here - wait for page to fully load
              },
              onLoadStop: (controller, url) async {
                showLog('🔵 Load stopped: $url');
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }

                // Check for payment result ONLY after page fully loads
                if (url != null) {
                  _checkPaymentResult(url.toString(), fromLoadStop: true);
                }
              },
              onProgressChanged: (controller, progressValue) {
                if (mounted) {
                  setState(() {
                    progress = progressValue / 100;
                  });
                }
              },
              onReceivedError: (controller, request, error) {
                log('WebView error: ${error.description}');
              },
              onConsoleMessage: (controller, consoleMessage) {
                log('Console: ${consoleMessage.message}');
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url?.toString() ?? '';
                showLog('🔵 Navigation requested: $url');

                // Don't cancel navigation - let all pages load
                // We'll handle the result in onLoadStop to ensure page fully loads
                // This is important for KNET because some bank pages need to complete their JavaScript
                return NavigationActionPolicy.ALLOW;
              },
            ),
            if (isLoading)
              Column(
                children: [
                  LinearProgressIndicator(value: progress),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool _checkPaymentResult(String url, {bool fromLoadStop = false}) {
    // Prevent duplicate handling
    if (_paymentResultHandled) {
      showLog("Payment result already handled, skipping: $url");
      return false;
    }

    showLog(
      "🔵 iOS: Checking payment result for URL: $url (fromLoadStop: $fromLoadStop)",
    );

    try {
      final uri = Uri.parse(url);
      final lowerUrl = url.toLowerCase();

      // IMPORTANT: Skip intermediate bank processing pages
      // These pages don't have the final result yet
      if (lowerUrl.contains('kpay.com.kw/kpg/paymentrouter.htm') ||
          lowerUrl.contains('kpay.com.kw/kpg/paymentpage.htm') ||
          lowerUrl.contains('knet.com.kw') ||
          lowerUrl.contains('/3dsecure') ||
          lowerUrl.contains('/otp') ||
          lowerUrl.contains('/verify')) {
        showLog(
          "🟡 Skipping intermediate bank page - waiting for final result",
        );
        return false;
      }

      final queryParams = uri.queryParameters;
      showLog("🔵 Query params: $queryParams");

      // Only process if this is a return URL from UPayments or our callback
      final isReturnUrl =
          lowerUrl.contains('pay.upayments.com/api/v1/kib-return-url') ||
          lowerUrl.contains('upayments.com/en') ||
          lowerUrl.contains(API.baseUrl) ||
          lowerUrl.contains('check-requete') ||
          queryParams.containsKey('kib_return_url') ||
          queryParams.containsKey('result') ||
          queryParams.containsKey('transaction_id');

      if (!isReturnUrl) {
        showLog("Not a payment return URL, waiting...");
        return false;
      }

      // Check for direct result parameter
      if (queryParams.containsKey('result')) {
        final result = queryParams['result']?.toUpperCase();
        showLog("Found direct result: $result");
        _handlePaymentResult(url, result);
        return true;
      }

      // Check for kib_return_url parameter (iOS specific for KNET)
      if (queryParams.containsKey('kib_return_url')) {
        final kibReturnUrl = queryParams['kib_return_url'];
        showLog("Found kib_return_url: $kibReturnUrl");
        if (kibReturnUrl != null && kibReturnUrl.isNotEmpty) {
          // URL decode the kib_return_url
          final decodedKibUrl = Uri.decodeComponent(kibReturnUrl);
          showLog("Decoded kib_return_url: $decodedKibUrl");

          final kibUri = Uri.tryParse(decodedKibUrl);
          if (kibUri != null && kibUri.queryParameters.containsKey('result')) {
            final result = kibUri.queryParameters['result']?.toUpperCase();
            showLog("Found result in kib_return_url: $result");
            _handlePaymentResult(url, result);
            return true;
          }
        }
      }

      // Check URL patterns in decoded URL
      final decodedUrl = Uri.decodeComponent(lowerUrl);
      if (decodedUrl.contains('result=captured') ||
          decodedUrl.contains('result=success')) {
        showLog("Found CAPTURED in URL pattern");
        _handlePaymentResult(url, 'CAPTURED');
        return true;
      }

      if (decodedUrl.contains('result=failed') ||
          decodedUrl.contains('result=canceled') ||
          decodedUrl.contains('result=canceld') ||
          url.startsWith('https://error.com')) {
        showLog("Found FAILED in URL pattern");
        _handlePaymentResult(url, 'FAILED');
        return true;
      }

      // If we're on UPayments return URL but couldn't detect result, assume success
      if (lowerUrl.contains('pay.upayments.com') &&
          !decodedUrl.contains('error')) {
        showLog(
          "On UPayments return URL without explicit result - returning URL for processing",
        );
        _handlePaymentResult(url, null);
        return true;
      }
    } catch (e) {
      showLog("Error checking payment result: $e");
    }

    return false;
  }

  void _handlePaymentResult(String url, String? result) {
    // Prevent duplicate handling
    if (_paymentResultHandled) {
      showLog("Payment result already handled, ignoring duplicate call");
      return;
    }
    _paymentResultHandled = true;

    showLog("Handling payment result: $result");

    if (result == 'SUCCESS' || result == 'CAPTURED') {
      showLog("✅ Payment SUCCESS - returning URL");
      Get.back(result: url);
    } else if (result == 'FAILED' ||
        result == 'CANCELED' ||
        result == 'CANCELD' ||
        result == 'NOT CAPTURED') {
      showLog("❌ Payment FAILED - returning false");
      Get.back(result: 'false');
    } else {
      // Unknown result - return URL for further processing
      showLog("⚠️ Unknown result - returning URL for processing");
      Get.back(result: url);
    }
  }
}
