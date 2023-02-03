import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ExploreSpot extends StatefulWidget {
  const ExploreSpot({super.key});

  @override
  State<ExploreSpot> createState() => _ExploreSpotState();
}

class _ExploreSpotState extends State<ExploreSpot> {
  LocationData? currentLocation;
  Location location = Location();

  final LatLng _initialcameraposition = const LatLng(20.5937, 78.9629);
  late GoogleMapController _controller;
  final Location _location = Location();
  Set<Marker> markers = {};
  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void _onMapCreated(GoogleMapController cntlr) {
    markers.add(const Marker(
      markerId: MarkerId('shelter_4n3ou24'),
      position: LatLng(37.4209983, -122.080),
      // icon: BitmapDescriptor.,
      infoWindow: InfoWindow(
        title: 'Shelter Ami',
        snippet: 'Komplek Asri',
      ),
    ));
    markers.add(const Marker(
      markerId: MarkerId('shelter_fvbf489'),
      position: LatLng(37.4202983, -122.085),
      // icon: BitmapDescriptor.,
      infoWindow: InfoWindow(
        title: 'Shelter Afiyah',
        snippet: 'TPI',
      ),
    ));
    setState(() {
      markers = markers;
    });
    _controller = cntlr;
    _location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(l.latitude! - 0.0025, l.longitude!), zoom: 15),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    location.onLocationChanged.listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      log("${cLoc.longitude} ${cLoc.latitude}");
      currentLocation = cLoc;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        // padding: EdgeInsets.only(
        //   bottom: MediaQuery.of(context).size.height - 700,
        // ),
        initialCameraPosition: CameraPosition(target: _initialcameraposition),
        mapType: MapType.normal,
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        // markers: Set<Marker>.of(markers.values),
        markers: markers);
  }
}
