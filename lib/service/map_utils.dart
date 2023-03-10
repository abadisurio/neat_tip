import 'dart:developer';

import 'package:map_launcher/map_launcher.dart';
import 'package:neat_tip/models/spot.dart';

class MapUtils {
  MapUtils._();
  static List<AvailableMap>? _availableMaps;
  static Future<void> initialize() async {
    _availableMaps = await MapLauncher.installedMaps;

    if (_availableMaps != null) {
      log('$_availableMaps'); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]
      await _availableMaps!.first.showMarker(
        coords: Coords(37.759392, -122.5107336),
        title: "Ocean Beach",
      );
    }
  }

  static Future<void> openSpot(Spot spot) async {
    final latlong2 = spot.latlong.split(',');
    // String finishQuery = '@$latitude,$longitude';
    // final uri = Uri.https('www.google.com', '/maps', {'q': latlong});
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri, mode: LaunchMode.externalApplication);
    // } else {
    //   throw 'Could not open the map.';
    // }
    if ((await MapLauncher.isMapAvailable(MapType.google) != null)) {
      await MapLauncher.showMarker(
          mapType: MapType.google,
          coords: Coords(double.parse(latlong2[0]), double.parse(latlong2[1])),
          title: spot.name != null
              ? 'Neat Tip ${spot.name}'
              : 'Penitipan Neat Tip');
    }
  }
}
