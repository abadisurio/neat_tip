import 'package:floor/floor.dart';

@entity
class Reservation {
  @primaryKey
  late String id;
  late String spotId;
  late String hostUserId;
  late String plateNumber;
  String? spotName;
  String? customerId;
  String? timeCheckedIn;
  String? timeCheckedOut;
  String? note;
  int? charge;
  String? status;

  Reservation(
      {required this.id,
      required this.spotId,
      required this.hostUserId,
      required this.plateNumber,
      this.spotName,
      this.customerId,
      this.timeCheckedIn,
      this.timeCheckedOut,
      this.note,
      this.charge,
      this.status});

  Reservation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    spotId = json['spotId'];
    customerId = json['customerId'];
    spotName = json['spotName'];
    customerId = json['customerId'];
    hostUserId = json['hostUserId'];
    plateNumber = json['plateNumber'];
    timeCheckedIn = json['timeCheckedIn'];
    timeCheckedOut = json['timeCheckedOut'];
    note = json['note'];
    charge = json['charge'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['spotId'] = spotId;
    data['hostUserId'] = hostUserId;
    data['customerId'] = customerId;
    data['spotName'] = spotName;
    data['customerId'] = customerId;
    data['plateNumber'] = plateNumber;
    data['timeCheckedIn'] = timeCheckedIn;
    data['timeCheckedOut'] = timeCheckedOut;
    data['note'] = note;
    data['charge'] = charge;
    data['status'] = status;
    return data;
  }
}
