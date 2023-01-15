class Vehicle {
  late String id;
  late String name;
  late String plate;
  late int wheel;

  Vehicle(
      {required this.id,
      required this.name,
      required this.plate,
      required this.wheel});

  Vehicle.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    plate = json['plate'];
    wheel = json['wheel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['plate'] = plate;
    data['wheel'] = wheel;
    return data;
  }
}
