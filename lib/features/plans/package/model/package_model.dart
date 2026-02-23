/// Model for available packages (from admin)
class PackageModel {
  String? success;
  String? error;
  String? message;
  List<PackageData>? data;

  PackageModel({this.success, this.error, this.message, this.data});

  PackageModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error']?.toString();
    message = json['message'];
    if (json['data'] != null) {
      data = <PackageData>[];
      json['data'].forEach((v) {
        data!.add(PackageData.fromJson(v));
      });
    }
  }
}

class PackageData {
  String? id;
  String? name;
  String? description;
  String? pricePerKm;
  String? totalKm;
  String? totalPrice;
  String?
      validity; // Date until package is available for purchase (null = always)

  PackageData({
    this.id,
    this.name,
    this.description,
    this.pricePerKm,
    this.totalKm,
    this.totalPrice,
    this.validity,
  });

  PackageData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name'];
    description = json['description'];
    pricePerKm = json['price_per_km']?.toString();
    totalKm = json['total_km']?.toString();
    totalPrice = json['total_price']?.toString();
    validity = json['validity'];
  }

  /// Get formatted price
  String get formattedPrice => '${totalPrice ?? '0.000'} KWD';

  /// Get formatted KM
  String get formattedKm => '${totalKm ?? '0'} KM';

  /// Get price per km display
  String get pricePerKmDisplay => '${pricePerKm ?? '0.000'} KWD/KM';
}

/// Model for user's purchased packages
class UserPackageModel {
  String? success;
  String? error;
  String? message;
  List<UserPackageData>? data;

  UserPackageModel({this.success, this.error, this.message, this.data});

  UserPackageModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error']?.toString();
    message = json['message'];
    if (json['data'] != null) {
      data = <UserPackageData>[];
      json['data'].forEach((v) {
        data!.add(UserPackageData.fromJson(v));
      });
    }
  }
}

/// User's purchased package - no time expiry, valid until KMs consumed
class UserPackageData {
  String? id;
  String? userId;
  String? packageId;
  String? packageName;
  String? pricePerKm;
  String? totalKm;
  String? remainingKm;
  String? usedKm;
  String? totalPrice;
  String? purchasedAt;
  String? lastUsedAt;
  String? status;
  String? paymentStatus;
  String? paymentMethod;
  String? transactionId;
  String? usagePercentage;
  String? remainingPercentage;
  bool? isUsable;
  bool? isConsumed;

  UserPackageData({
    this.id,
    this.userId,
    this.packageId,
    this.packageName,
    this.pricePerKm,
    this.totalKm,
    this.remainingKm,
    this.usedKm,
    this.totalPrice,
    this.purchasedAt,
    this.lastUsedAt,
    this.status,
    this.paymentStatus,
    this.paymentMethod,
    this.transactionId,
    this.usagePercentage,
    this.remainingPercentage,
    this.isUsable,
    this.isConsumed,
  });

  UserPackageData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userId = json['user_id']?.toString();
    packageId = json['package_id']?.toString();
    packageName = json['package_name'];
    pricePerKm = json['price_per_km']?.toString();
    totalKm = json['total_km']?.toString();
    remainingKm = json['remaining_km']?.toString();
    usedKm = json['used_km']?.toString();
    totalPrice = json['total_price']?.toString();
    purchasedAt = json['purchased_at'];
    lastUsedAt = json['last_used_at'];
    status = json['status'];
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    transactionId = json['transaction_id'];
    usagePercentage = json['usage_percentage']?.toString();
    remainingPercentage = json['remaining_percentage']?.toString();
    isUsable = json['is_usable'];
    isConsumed = json['is_consumed'];
  }

  /// Get formatted remaining KM
  String get formattedRemainingKm => '${remainingKm ?? '0'} KM';

  /// Get formatted total KM
  String get formattedTotalKm => '${totalKm ?? '0'} KM';

  /// Get usage progress (0.0 - 1.0)
  double get usageProgress {
    final used = double.tryParse(usedKm ?? '0') ?? 0;
    final total = double.tryParse(totalKm ?? '0') ?? 0;
    if (total <= 0) return 0;
    return used / total;
  }

  /// Get remaining progress (0.0 - 1.0)
  double get remainingProgress => 1.0 - usageProgress;

  /// Check if package is active
  bool get isActive => status == 'active' && paymentStatus == 'paid';

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
      case 'consumed':
        return 'Fully Used';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status?.toUpperCase() ?? 'Unknown';
    }
  }
}

/// Response model for single user package
class UserPackageResponseModel {
  String? success;
  String? error;
  String? message;
  UserPackageData? data;

  UserPackageResponseModel({this.success, this.error, this.message, this.data});

  UserPackageResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error']?.toString();
    message = json['message'];
    if (json['data'] != null) {
      data = UserPackageData.fromJson(json['data']);
    }
  }
}

/// Response model for wallet payment
class PackageWalletPaymentResponse {
  String? success;
  String? error;
  String? message;
  UserPackageData? userPackage;
  String? newWalletBalance;
  String? transactionId;

  PackageWalletPaymentResponse({
    this.success,
    this.error,
    this.message,
    this.userPackage,
    this.newWalletBalance,
    this.transactionId,
  });

  PackageWalletPaymentResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error']?.toString();
    message = json['message'];
    if (json['data'] != null) {
      if (json['data']['user_package'] != null) {
        userPackage = UserPackageData.fromJson(json['data']['user_package']);
      }
      newWalletBalance = json['data']['new_wallet_balance']?.toString();
      transactionId = json['data']['transaction_id'];
    }
  }
}
