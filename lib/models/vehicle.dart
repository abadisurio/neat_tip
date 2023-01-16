class Vehicle {
  late String createdAt;
  late String id;
  late String ownerId;
  late String name;
  late String plate;
  late int wheel;
  String? imgSrcPhotos;

  Vehicle(
      {required this.createdAt,
      required this.id,
      required this.ownerId,
      required this.name,
      required this.plate,
      this.imgSrcPhotos,
      required this.wheel});

  Vehicle.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    id = json['id'];
    ownerId = json['ownerId'];
    name = json['name'];
    plate = json['plate'];
    imgSrcPhotos = json['imgSrcPhotos'];
    wheel = json['wheel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['ownerId'] = ownerId;
    data['name'] = name;
    data['imgSrcPhotos'] = imgSrcPhotos;
    data['plate'] = plate;
    data['wheel'] = wheel;
    return data;
  }
}
