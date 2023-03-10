import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:neat_tip/models/spot.dart';

class ExploreSpot extends StatefulWidget {
  const ExploreSpot({super.key});

  @override
  State<ExploreSpot> createState() => _ExploreSpotState();
}

final List<Spot> dummySpots = [
  Spot(
      id: 'sdasda',
      name: 'Kurnia Motor',
      latlong: '-6.219469,106.952594',
      rating: '4.8',
      address:
          'Jl. Raya St. Cakung, Bintara, Kec. Cakung, Kota Jakarta Timur, Daerah Khusus Ibukota Jakarta 13950',
      imgSrcBanner:
          'https://awsimages.detik.net.id/community/media/visual/2018/09/06/01d01855-20f9-4dad-88c7-adf3eb913e94.jpeg?w=700&q=90'),
  Spot(
      id: 'rwerewr',
      name: 'Penitipan Motor Himas Parkir',
      latlong: '-6.3691692,106.8323381',
      rating: '3.8',
      address: 'JRJM+C2C, Pondok Cina, Beji, Depok City, West Java 16424',
      imgSrcBanner:
          'https://lh3.googleusercontent.com/p/AF1QipOjwPOvyur9-svdDgsRXQ6RDXk0wu6QD1YjWf3N=s1360-w1360-h1020'),
];

class _ExploreSpotState extends State<ExploreSpot> {
  // LocationData? _currentLocation;
  Location location = Location();

  final LatLng _initialcameraposition = const LatLng(-6.1753924, 106.8249641);
  late GoogleMapController _controller;
  final Location _location = Location();
  late StreamSubscription<LocationData> _locationSubscription;
  final Set<Marker> _markers = {};
  List<Spot>? _spots;
  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void _onMapCreated(GoogleMapController cntlr) async {
    _controller = cntlr;
    final initalLocation = await _location.getLocation();
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                initalLocation.latitude! - 0.0025, initalLocation.longitude!),
            zoom: 15),
      ),
    );
    _locationSubscription = _location.onLocationChanged.listen((l) {
      // _currentLocation = l;
    });

    await _loadSpots();
    await _loadMarkers();
    // _locationSubscription.
  }

  // _initCamera() {
  //   _controller.animateCamera(
  //     CameraUpdate.newCameraPosition(
  //       CameraPosition(
  //           target: LatLng(l.latitude! - 0.0025, l.longitude!), zoom: 15),
  //     ),
  //   );
  // }

  _loadSpots() {
    setState(() {
      _spots = dummySpots;
    });
  }

  _loadMarkers() async {
    for (var element in _spots!) {
      final latlong = element.latlong.split(',');
      final latlong2 =
          LatLng(double.parse(latlong[0]), double.parse(latlong[1]));
      final placeIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(48, 48)), 'assets/pin.png');
      setState(() {
        _markers.add(Marker(
          onTap: () => _controller
              .animateCamera(CameraUpdate.newLatLngZoom(latlong2, 15)),
          icon: placeIcon,
          markerId: MarkerId(element.id),
          position: latlong2,
          // icon: BitmapDescriptor.,
          infoWindow: InfoWindow(
              title: element.name,
              snippet: '500m ★${element.rating ?? '4.8'}',
              onTap: () {
                Navigator.pushNamed(context, '/spot_detail',
                    arguments: element.id);
              }),
        ));
      });
    }
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(

        // padding: EdgeInsets.only(
        //   bottom: MediaQuery.of(context).size.height - 700,
        // ),
        initialCameraPosition:
            CameraPosition(target: _initialcameraposition, zoom: 15),
        mapType: MapType.normal,
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,

        // markers: Set<Marker>.of(markers.values),
        markers: _markers);
  }
}
