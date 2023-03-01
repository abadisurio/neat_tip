import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neat_tip/models/spot.dart';
import 'package:neat_tip/screens/customer/explore_spot.dart';
import 'package:neat_tip/service/map_utils.dart';
import 'package:skeletons/skeletons.dart';

class SpotDetail extends StatefulWidget {
  final String spotId;
  const SpotDetail({Key? key, required this.spotId}) : super(key: key);

  @override
  State<SpotDetail> createState() => _SpotDetailState();
}

class _SpotDetailState extends State<SpotDetail> {
  late String _spotId;
  Spot? _spot;

  _openDirection() {
    // final latlong = _spot!.latlong;
    MapUtils.openSpot(_spot!);
  }

  @override
  void initState() {
    _spot = dummySpots[1];
    setState(() {
      _spotId = widget.spotId;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tempat Penitipan'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _spot == null ? null : _openDirection,
        child: const Icon(Icons.directions),
      ),
      body: _spot == null
          ? SkeletonListView()
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage(
                      imageUrl: _spot!.imgSrcBanner!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _spot!.name!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        // ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //         backgroundColor: Colors.yellow.shade700),
                        //     onPressed: _spot == null ? null : _openDirection,
                        //     child: const Text('Arahkan'))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          _spot!.rating!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('${'⭐️' * 5} (2)')
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(_spot!.farePerDay ?? 5000)} per Hari',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _spot!.address ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(
                    height: 500,
                    child: SkeletonListView(),
                  )
                ]),
    );
  }
}
