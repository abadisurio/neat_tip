import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:neat_tip/models/vehicle.dart';
import 'package:path_provider/path_provider.dart';

class VehicleItem extends StatelessWidget {
  final Vehicle vehicle;
  const VehicleItem({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final firstName = vehicle.imgSrcPhotos.split(',').first;
    // log('firstName $firstName');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        height: 100,
                        width: 100,
                      ),
                      if (firstName != '')
                        FutureBuilder(future: () async {
                          if (firstName.contains('http')) {
                            log('gapakedonlot');
                            return CachedNetworkImage(
                              imageUrl: firstName,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            );
                          } else {
                            final appDir = await getTemporaryDirectory();
                            final file = File(
                                '${appDir.path}${Platform.isIOS ? '/camera/pictures' : ''}/$firstName');
                            return Image.file(
                              file,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            );
                          }

                          // log('${appDir.path}/$firstName');
                        }(), builder: ((context, snapshot) {
                          //  if (cover.existsSync())
                          if (snapshot.data != null) {
                            return snapshot.data!;
                          }
                          return const SizedBox();
                        }))
                      else
                        Transform.scale(
                            scale: 1.1, child: Image.asset('assets/vario.png')),
                      // CachedNetworkImage(
                      //   imageUrl:
                      //       "https://ik.imagekit.io/zlt25mb52fx/ahmcdn/uploads/product/feature/fa-clickable-feature-motor-700x700pxl-ys-1-26092022-061617.jpg",
                      //   placeholder: (context, url) =>
                      //       const CircularProgressIndicator(),
                      //   errorWidget: (context, url, error) =>
                      //       const Icon(Icons.error),
                      // ),
                      // const Image(
                      //     image: CachedNetworkImageProvider(
                      //         "https://ik.imagekit.io/zlt25mb52fx/ahmcdn/uploads/product/feature/fa-clickable-feature-motor-700x700pxl-ys-1-26092022-061617.jpg"))
                      // Image.network(
                      //     "https://ik.imagekit.io/zlt25mb52fx/ahmcdn/uploads/product/feature/fa-clickable-feature-motor-700x700pxl-ys-1-26092022-061617.jpg"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListTile(
              isThreeLine: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Text(
                        vehicle.plate,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade100),
                      )),
                  Text(
                    ' ${vehicle.brand} ${vehicle.model}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    ' Milik ${vehicle.ownerName}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
              subtitle: Text(
                ' roda ${vehicle.wheel}',
                maxLines: 1,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }
}
