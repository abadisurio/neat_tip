class Vehicle {
  late String createdAt;
  late String id;
  late String ownerId;
  late String name;
  late String plate;
  late int wheel;
  String? brand;
  String? model;
  String? imgSrcPhotos;

  Vehicle({
    required this.createdAt,
    required this.id,
    required this.ownerId,
    required this.name,
    required this.plate,
    required this.wheel,
    this.imgSrcPhotos,
    this.brand,
    this.model,
  });

  Vehicle.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    id = json['id'];
    ownerId = json['ownerId'];
    name = json['name'];
    plate = json['plate'];
    wheel = json['wheel'];
    brand = json['brand'];
    model = json['model'];
    imgSrcPhotos = json['imgSrcPhotos'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['ownerId'] = ownerId;
    data['name'] = name;
    data['imgSrcPhotos'] = imgSrcPhotos;
    data['plate'] = plate;
    data['brand'] = brand;
    data['model'] = model;
    data['wheel'] = wheel;
    return data;
  }
}
