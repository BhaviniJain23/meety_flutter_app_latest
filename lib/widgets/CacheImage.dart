// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:shimmer/shimmer.dart';

class CacheImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BorderRadius? radius;
  final bool showShadow;
  final bool showShimmer;
  final BoxFit? boxFit;

  const CacheImage(
      {Key? key,
      required this.imageUrl,
      this.height,
      this.boxFit,
      this.width,
      this.showShadow = false,
      this.showShimmer = false,
      this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container();
    } else {
      var image = CachedNetworkImage(
        key: Key(imageUrl.trim()),
        imageUrl: imageUrl.trim().toString(),
        fit: boxFit ?? BoxFit.cover,
        height: height ?? 35,
        width: width ?? 35,
        imageBuilder: (showShadow)
            ? (context, imageProvider) => ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                    ).createShader(
                        Rect.fromLTRB(0, -140, rect.width, rect.height + 50));
                  },
                  blendMode: BlendMode.darken,
                  child: ClipRRect(
                    borderRadius: radius ?? BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                )
            : null,
        placeholder: (showShimmer)
            ? (context, error) => Shimmer.fromColors(
                baseColor: const Color(0xEFC9C9C9),
                highlightColor: Colors.grey[100]!,
                enabled: true,
                child: Container(
                  height: height ?? 40,
                  width: width ?? 40,
                  decoration: BoxDecoration(
                    borderRadius: radius ?? BorderRadius.circular(20),
                    color: grey,
                  ),
                ))
            : null,
        errorWidget: (context, error, issue) {
          return Container(
            height: height ?? 40,
            width: width ?? 40,
            decoration: BoxDecoration(
              borderRadius: radius ?? BorderRadius.circular(20),
              color: grey,
            ),
          );
        },
      );

      return radius != null
          ? ClipRRect(borderRadius: radius!, child: image)
          : image;
    }
  }
}
