class Spot {
  late String id;
  String? ownerId;
  String? name;
  String? address;
  String? latlong;
  String? phone;
  String? imgSrcBanner;
  String? gMapsLink;
  String? website;
  String? rating;
  int? capacity;
  int? farePerDay;
  String? timeOpen;
  String? timeClose;

  Spot(
      {required this.id,
      this.ownerId,
      this.name,
      this.address,
      this.latlong,
      this.phone,
      this.imgSrcBanner,
      this.gMapsLink,
      this.website,
      this.rating,
      this.capacity,
      this.farePerDay,
      this.timeOpen,
      this.timeClose});

  Spot.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['ownerId'];
    name = json['name'];
    address = json['address'];
    latlong = json['latlong'];
    phone = json['phone'];
    imgSrcBanner = json['imgSrcBanner'];
    gMapsLink = json['gMapsLink'];
    website = json['website'];
    rating = json['rating'];
    capacity = json['capacity'];
    farePerDay = json['farePerDay'];
    timeOpen = json['timeOpen'];
    timeClose = json['timeClose'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ownerId'] = ownerId;
    data['name'] = name;
    data['address'] = address;
    data['latlong'] = latlong;
    data['phone'] = phone;
    data['imgSrcBanner'] = imgSrcBanner;
    data['gMapsLink'] = gMapsLink;
    data['website'] = website;
    data['rating'] = rating;
    data['capacity'] = capacity;
    data['farePerDay'] = farePerDay;
    data['timeOpen'] = timeOpen;
    data['timeClose'] = timeClose;
    return data;
  }
}
