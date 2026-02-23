class SubscriptionSettingsModel {
  String? success;
  String? error;
  String? message;
  SubscriptionSettingsData? data;

  SubscriptionSettingsModel({this.success, this.error, this.message, this.data});

  SubscriptionSettingsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    data = json['data'] != null ? SubscriptionSettingsData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['error'] = error;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SubscriptionSettingsData {
  bool? isAvailable;
  String? subscriptionKmPrice;
  String? minSubscriptionDays;
  String? maxSubscriptionDays;
  String? minimumDistanceKm;

  SubscriptionSettingsData({
    this.isAvailable,
    this.subscriptionKmPrice,
    this.minSubscriptionDays,
    this.maxSubscriptionDays,
    this.minimumDistanceKm,
  });

  SubscriptionSettingsData.fromJson(Map<String, dynamic> json) {
    isAvailable = json['is_available'] ?? false;
    subscriptionKmPrice = json['subscription_km_price']?.toString() ?? '0';
    minSubscriptionDays = json['min_subscription_days']?.toString() ?? '7';
    maxSubscriptionDays = json['max_subscription_days']?.toString() ?? '365';
    minimumDistanceKm = json['minimum_distance_km']?.toString() ?? '1';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_available'] = isAvailable;
    data['subscription_km_price'] = subscriptionKmPrice;
    data['min_subscription_days'] = minSubscriptionDays;
    data['max_subscription_days'] = maxSubscriptionDays;
    data['minimum_distance_km'] = minimumDistanceKm;
    return data;
  }
}

