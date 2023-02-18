import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {
  const Carousel({Key? key}) : super(key: key);

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 1.78,
            viewportFraction: 1,
            scrollDirection: Axis.vertical,
            enlargeCenterPage: true,
          ),
          // items: const [],
          items: [1, 2, 3, 4, 5].map((i) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                height: double.infinity,
                fit: BoxFit.cover,
                imageUrl:
                    'https://images.squarespace-cdn.com/content/v1/53fe73e3e4b051bac9406675/1517605854354-3H036ZYJ7E22GKDR24JV/Spotify+Ad+1.png',
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
