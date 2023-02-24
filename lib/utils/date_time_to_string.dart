import 'dart:developer';

import 'package:intl/intl.dart';

String dateTimeToString(String stringISO8601) {
  final date = DateTime.parse(stringISO8601);
  final difference = DateTime.now().difference(date);
  String formatted;
  if (difference.inDays == 0) {
    log('hari ini');
    formatted = 'Hari ini ${DateFormat('H.MM', 'id_ID').format(date)}';
  } else if (difference.inDays == 1) {
    log('Kemarin');
    formatted = 'Kemarin';
  } else {
    log('Dah lama');
    formatted = DateFormat('EEEE d HH', 'id_ID').format(date);
  }
  log('formatted $formatted');
  //
  return formatted;
}
