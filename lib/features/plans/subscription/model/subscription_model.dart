class SubscriptionListModel {
  String? success;
  String? error;
  String? message;
  List<SubscriptionData>? data;

  SubscriptionListModel({this.success, this.error, this.message, this.data});

  SubscriptionListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SubscriptionData>[];
      json['data'].forEach((v) {
        data!.add(SubscriptionData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> d = <String, dynamic>{};
    d['success'] = success;
    d['error'] = error;
    d['message'] = message;
    if (data != null) {
      d['data'] = data!.map((v) => v.toJson()).toList();
    }
    return d;
  }
}

class SubscriptionResponseModel {
  String? success;
  String? error;
  String? message;
  SubscriptionData? data;

  SubscriptionResponseModel(
      {this.success, this.error, this.message, this.data});

  SubscriptionResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    data =
        json['data'] != null ? SubscriptionData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> d = <String, dynamic>{};
    d['success'] = success;
    d['error'] = error;
    d['message'] = message;
    if (data != null) {
      d['data'] = data!.toJson();
    }
    return d;
  }
}

class SubscriptionData {
  String? id;
  String? userId;
  String? tripType;
  String? homeAddress;
  String? homeLatitude;
  String? homeLongitude;
  String? destinationAddress;
  String? destinationLatitude;
  String? destinationLongitude;
  String? distanceKm;
  String? subscriptionKmPrice;
  String? singleTripPrice;
  String? totalPrice;
  String? startDate;
  String? endDate;
  String? totalDays;
  List<int>? workingDays;
  String? morningPickupTime;
  String? returnPickupTime;
  String? totalTrips;
  String? completedTrips;
  String? remainingTrips;
  String? cancelledTrips;
  String? customerName;
  String? customerPhone;
  String? passengerName;
  String? passengerPhone;
  String? specialInstructions;
  String? paymentMethod;
  String? paymentStatus;
  String? transactionId;
  String? status;
  DriverInfo? driver;
  String? createdAt;
  List<SubscriptionRideData>? rides;

  SubscriptionData({
    this.id,
    this.userId,
    this.tripType,
    this.homeAddress,
    this.homeLatitude,
    this.homeLongitude,
    this.destinationAddress,
    this.destinationLatitude,
    this.destinationLongitude,
    this.distanceKm,
    this.subscriptionKmPrice,
    this.singleTripPrice,
    this.totalPrice,
    this.startDate,
    this.endDate,
    this.totalDays,
    this.workingDays,
    this.morningPickupTime,
    this.returnPickupTime,
    this.totalTrips,
    this.completedTrips,
    this.remainingTrips,
    this.cancelledTrips,
    this.customerName,
    this.customerPhone,
    this.passengerName,
    this.passengerPhone,
    this.specialInstructions,
    this.paymentMethod,
    this.paymentStatus,
    this.transactionId,
    this.status,
    this.driver,
    this.createdAt,
    this.rides,
  });

  SubscriptionData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userId = json['user_id']?.toString();
    tripType = json['trip_type'];
    homeAddress = json['home_address'];
    homeLatitude = json['home_latitude']?.toString();
    homeLongitude = json['home_longitude']?.toString();
    destinationAddress = json['destination_address'];
    destinationLatitude = json['destination_latitude']?.toString();
    destinationLongitude = json['destination_longitude']?.toString();
    distanceKm = json['distance_km']?.toString();
    subscriptionKmPrice = json['subscription_km_price']?.toString();
    singleTripPrice = json['single_trip_price']?.toString();
    totalPrice = json['total_price']?.toString();
    startDate = json['start_date'];
    endDate = json['end_date'];
    totalDays = json['total_days']?.toString();
    workingDays = json['working_days'] != null
        ? List<int>.from(json['working_days'])
        : null;
    morningPickupTime = json['morning_pickup_time'];
    returnPickupTime = json['return_pickup_time'];
    totalTrips = json['total_trips']?.toString();
    completedTrips = json['completed_trips']?.toString();
    remainingTrips = json['remaining_trips']?.toString();
    cancelledTrips = json['cancelled_trips']?.toString();
    customerName = json['customer_name'];
    customerPhone = json['customer_phone'];
    passengerName = json['passenger_name'];
    passengerPhone = json['passenger_phone'];
    specialInstructions = json['special_instructions'];
    paymentMethod = json['payment_method'];
    paymentStatus = json['payment_status'];
    transactionId = json['transaction_id'];
    status = json['status'];
    driver =
        json['driver'] != null ? DriverInfo.fromJson(json['driver']) : null;
    createdAt = json['created_at'];
    if (json['rides'] != null) {
      rides = <SubscriptionRideData>[];
      json['rides'].forEach((v) {
        rides!.add(SubscriptionRideData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['trip_type'] = tripType;
    data['home_address'] = homeAddress;
    data['home_latitude'] = homeLatitude;
    data['home_longitude'] = homeLongitude;
    data['destination_address'] = destinationAddress;
    data['destination_latitude'] = destinationLatitude;
    data['destination_longitude'] = destinationLongitude;
    data['distance_km'] = distanceKm;
    data['subscription_km_price'] = subscriptionKmPrice;
    data['single_trip_price'] = singleTripPrice;
    data['total_price'] = totalPrice;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['total_days'] = totalDays;
    data['working_days'] = workingDays;
    data['morning_pickup_time'] = morningPickupTime;
    data['return_pickup_time'] = returnPickupTime;
    data['total_trips'] = totalTrips;
    data['completed_trips'] = completedTrips;
    data['remaining_trips'] = remainingTrips;
    data['cancelled_trips'] = cancelledTrips;
    data['customer_name'] = customerName;
    data['customer_phone'] = customerPhone;
    data['passenger_name'] = passengerName;
    data['passenger_phone'] = passengerPhone;
    data['special_instructions'] = specialInstructions;
    data['payment_method'] = paymentMethod;
    data['payment_status'] = paymentStatus;
    data['transaction_id'] = transactionId;
    data['status'] = status;
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    data['created_at'] = createdAt;
    if (rides != null) {
      data['rides'] = rides!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
      case 'pending':
        return 'Pending Payment';
      case 'pending_approval':
        return 'Pending Approval';
      case 'paused':
        return 'Paused';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      case 'expired':
        return 'Expired';
      default:
        return status ?? 'Unknown';
    }
  }

  String get tripTypeDisplay {
    return tripType == 'two_way' ? 'Two Way (Round Trip)' : 'One Way';
  }

  List<String> get workingDaysNames {
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    if (workingDays == null) return [];
    return workingDays!.map((d) => dayNames[d]).toList();
  }
}

class DriverInfo {
  String? id;
  String? name;
  String? phone;
  String? photo;

  DriverInfo({this.id, this.name, this.phone, this.photo});

  DriverInfo.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name'];
    phone = json['phone'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['photo'] = photo;
    return data;
  }
}

class SubscriptionRideData {
  String? id;
  String? subscriptionId;
  String? rideDate;
  String? rideDirection;
  String? directionText;
  String? scheduledPickupTime;
  String? pickupAddress;
  String? pickupLatitude;
  String? pickupLongitude;
  String? dropoffAddress;
  String? dropoffLatitude;
  String? dropoffLongitude;
  String? status;
  DriverInfo? driver;

  SubscriptionRideData({
    this.id,
    this.subscriptionId,
    this.rideDate,
    this.rideDirection,
    this.directionText,
    this.scheduledPickupTime,
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffAddress,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.status,
    this.driver,
  });

  SubscriptionRideData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    subscriptionId = json['subscription_id']?.toString();
    rideDate = json['ride_date'];
    rideDirection = json['ride_direction'];
    directionText = json['direction_text'];
    scheduledPickupTime = json['scheduled_pickup_time'];
    pickupAddress = json['pickup_address'];
    pickupLatitude = json['pickup_latitude']?.toString();
    pickupLongitude = json['pickup_longitude']?.toString();
    dropoffAddress = json['dropoff_address'];
    dropoffLatitude = json['dropoff_latitude']?.toString();
    dropoffLongitude = json['dropoff_longitude']?.toString();
    status = json['status'];
    driver =
        json['driver'] != null ? DriverInfo.fromJson(json['driver']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['subscription_id'] = subscriptionId;
    data['ride_date'] = rideDate;
    data['ride_direction'] = rideDirection;
    data['direction_text'] = directionText;
    data['scheduled_pickup_time'] = scheduledPickupTime;
    data['pickup_address'] = pickupAddress;
    data['pickup_latitude'] = pickupLatitude;
    data['pickup_longitude'] = pickupLongitude;
    data['dropoff_address'] = dropoffAddress;
    data['dropoff_latitude'] = dropoffLatitude;
    data['dropoff_longitude'] = dropoffLongitude;
    data['status'] = status;
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    return data;
  }

  String get statusDisplay {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'pending':
        return 'Pending';
      case 'driver_arrived':
        return 'Driver Arrived';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no_show':
        return 'No Show';
      case 'skipped':
        return 'Skipped';
      default:
        return status ?? 'Unknown';
    }
  }
}

class SubscriptionPriceModel {
  String? success;
  String? error;
  String? message;
  SubscriptionPriceData? data;

  SubscriptionPriceModel({this.success, this.error, this.message, this.data});

  SubscriptionPriceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    data = json['data'] != null
        ? SubscriptionPriceData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> d = <String, dynamic>{};
    d['success'] = success;
    d['error'] = error;
    d['message'] = message;
    if (data != null) {
      d['data'] = data!.toJson();
    }
    return d;
  }
}

class SubscriptionPriceData {
  String? distanceKm;
  String? kmPrice;
  String? singleTripPrice;
  String? totalTrips;
  String? totalPrice;
  String? totalDays;
  String? tripType;
  // ✅ Zone pricing fields
  String? zoneFare;
  String? pickupZoneFare;
  String? dropoffZoneFare;
  String? kmFare;
  String? pickupZoneName;
  String? dropoffZoneName;

  SubscriptionPriceData({
    this.distanceKm,
    this.kmPrice,
    this.singleTripPrice,
    this.totalTrips,
    this.totalPrice,
    this.totalDays,
    this.tripType,
    this.zoneFare,
    this.pickupZoneFare,
    this.dropoffZoneFare,
    this.kmFare,
    this.pickupZoneName,
    this.dropoffZoneName,
  });

  SubscriptionPriceData.fromJson(Map<String, dynamic> json) {
    distanceKm = json['distance_km']?.toString();
    kmPrice = json['km_price']?.toString();
    singleTripPrice = json['single_trip_price']?.toString();
    totalTrips = json['total_trips']?.toString();
    totalPrice = json['total_price']?.toString();
    totalDays = json['total_days']?.toString();
    tripType = json['trip_type'];
    // ✅ Zone pricing fields
    zoneFare = json['zone_fare']?.toString();
    pickupZoneFare = json['pickup_zone_fare']?.toString();
    dropoffZoneFare = json['dropoff_zone_fare']?.toString();
    kmFare = json['km_fare']?.toString();
    pickupZoneName = json['pickup_zone_name'];
    dropoffZoneName = json['dropoff_zone_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance_km'] = distanceKm;
    data['km_price'] = kmPrice;
    data['single_trip_price'] = singleTripPrice;
    data['total_trips'] = totalTrips;
    data['total_price'] = totalPrice;
    data['total_days'] = totalDays;
    data['trip_type'] = tripType;
    return data;
  }
}
