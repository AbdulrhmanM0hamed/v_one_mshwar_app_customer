class VehicleCategoryModel {
  String? success;
  String? error;
  String? message;
  List<VehicleData>? data;

  VehicleCategoryModel({this.success, this.error, this.message, this.data});

  VehicleCategoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <VehicleData>[];
      json['data'].forEach((v) {
        data!.add(VehicleData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['error'] = error;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VehicleData {
  String? id;
  String? libelle;
  String? description;
  String? prix;
  String? image;
  String? selectedImage;
  String? status;
  String? creer;
  String? modifier;
  String? updatedAt;
  String? deletedAt;
  String? selectedImagePath;
  String? statutCommissionPerc;
  String? commissionPerc;
  String? typePerc;
  String? deliveryCharges;
  String? minimumDeliveryCharges;
  String? minimumDeliveryChargesWithin;

  VehicleData(
      {this.id,
      this.libelle,
      this.description,
      this.prix,
      this.image,
      this.selectedImage,
      this.status,
      this.creer,
      this.modifier,
      this.updatedAt,
      this.deletedAt,
      this.selectedImagePath,
      this.statutCommissionPerc,
      this.commissionPerc,
      this.typePerc,
      this.deliveryCharges,
      this.minimumDeliveryCharges,
      this.minimumDeliveryChargesWithin});

  VehicleData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    libelle = json['libelle'].toString();
    description = json['description'] != null && json['description'] != 'null'
        ? json['description'].toString()
        : '';
    prix = json['prix'].toString();
    image = json['image'].toString();
    selectedImage = json['selected_image'].toString();
    status = json['status'].toString();
    creer = json['creer'].toString();
    modifier = json['modifier'].toString();
    updatedAt = json['updated_at'].toString();
    deletedAt = json['deleted_at'].toString();
    selectedImagePath = json['selected_image_path'].toString();
    statutCommissionPerc = json['statut_commission_perc'].toString();
    commissionPerc = json['commission_perc'].toString();
    typePerc = json['type_perc'].toString();
    deliveryCharges = json['delivery_charges'].toString();
    minimumDeliveryCharges = json['minimum_delivery_charges'].toString();
    minimumDeliveryChargesWithin =
        json['minimum_delivery_charges_within'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['libelle'] = libelle;
    data['description'] = description;
    data['prix'] = prix;
    data['image'] = image;
    data['selected_image'] = selectedImage;
    data['status'] = status;
    data['creer'] = creer;
    data['modifier'] = modifier;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['selected_image_path'] = selectedImagePath;
    data['statut_commission_perc'] = statutCommissionPerc;
    data['commission_perc'] = commissionPerc;
    data['type_perc'] = typePerc;
    data['delivery_charges'] = deliveryCharges;
    data['minimum_delivery_charges'] = minimumDeliveryCharges;
    data['minimum_delivery_charges_within'] = minimumDeliveryChargesWithin;
    return data;
  }
}

class Calculation {
  final double? km;
  final double? classicDistanceValue;
  final double? classicBaseValue;
  final double? businessDistanceValue;
  final double? businessBaseValue;

  final double? classicKm;
  final double? classicDistanceMinus;
  final double? classicDistanceValue2;

  final double? businessKm;
  final double? businessDistanceMinus;
  final double? businessDistanceValue2;

  Calculation({
    this.km,
    this.classicDistanceValue,
    this.classicBaseValue,
    this.businessDistanceValue,
    this.businessBaseValue,
    this.classicKm,
    this.classicDistanceMinus,
    this.classicDistanceValue2,
    this.businessKm,
    this.businessDistanceMinus,
    this.businessDistanceValue2,
  });

  factory Calculation.fromJson(Map<String, dynamic> json) {
    return Calculation(
      km: (json['km'] as num?)?.toDouble(),
      classicDistanceValue: (json['classicdistancevalue'] as num?)?.toDouble(),
      classicBaseValue: (json['classicbasevalue'] as num?)?.toDouble(),
      businessDistanceValue:
          (json['businessdistancevalue'] as num?)?.toDouble(),
      businessBaseValue: (json['businessbasevalue'] as num?)?.toDouble(),
      classicKm: (json['classickm'] as num?)?.toDouble(),
      classicDistanceMinus: (json['classicdistaceminus'] as num?)?.toDouble(),
      classicDistanceValue2: (json['classicdistacevalue2'] as num?)?.toDouble(),
      businessKm: (json['businesskm'] as num?)?.toDouble(),
      businessDistanceMinus: (json['businessdistaceminus'] as num?)?.toDouble(),
      businessDistanceValue2:
          (json['businessdistacevalue2'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'km': km,
      'classicdistancevalue': classicDistanceValue,
      'classicbasevalue': classicBaseValue,
      'businessdistancevalue': businessDistanceValue,
      'businessbasevalue': businessBaseValue,
      'classickm': classicKm,
      'classicdistaceminus': classicDistanceMinus,
      'classicdistacevalue2': classicDistanceValue2,
      'businesskm': businessKm,
      'businessdistaceminus': businessDistanceMinus,
      'businessdistacevalue2': businessDistanceValue2,
    };
  }
}
