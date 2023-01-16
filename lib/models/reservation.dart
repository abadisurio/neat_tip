class Reservation {
  late String id;
  late String spotId;
  late String hostUserId;
  late String customerUserId;
  String? timeCheckedIn;
  String? timeCheckedOut;
  String? note;
  int? charge;
  String? status;

  Reservation(
      {required this.id,
      required this.spotId,
      required this.hostUserId,
      required this.customerUserId,
      this.timeCheckedIn,
      this.timeCheckedOut,
      this.note,
      this.charge,
      this.status});

  Reservation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    spotId = json['spotId'];
    hostUserId = json['hostUserId'];
    customerUserId = json['customerUserId'];
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
    data['customerUserId'] = customerUserId;
    data['timeCheckedIn'] = timeCheckedIn;
    data['timeCheckedOut'] = timeCheckedOut;
    data['note'] = note;
    data['charge'] = charge;
    data['status'] = status;
    return data;
  }
}
