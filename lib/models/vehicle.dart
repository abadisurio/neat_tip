class Vehicle {
  late String createdAt;
  late String id;
  late String ownerId;
  late String plate;
  late String brand;
  late String model;
  late String ownerName;
  late String imgSrcPhotos;
  late int wheel;

  Vehicle({
    required this.createdAt,
    required this.id,
    required this.ownerId,
    required this.plate,
    required this.brand,
    required this.model,
    required this.ownerName,
    required this.imgSrcPhotos,
    required this.wheel,
  });

  Vehicle.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    id = json['id'];
    ownerId = json['ownerId'];
    ownerName = json['ownerName'];
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
    data['ownerName'] = ownerName;
    data['imgSrcPhotos'] = imgSrcPhotos;
    data['plate'] = plate;
    data['brand'] = brand;
    data['model'] = model;
    data['wheel'] = wheel;
    return data;
  }
}
