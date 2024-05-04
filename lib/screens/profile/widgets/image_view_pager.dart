
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';

class ImageViewPager extends StatefulWidget {
  final List<dynamic> imageList;
  final int currentPosition;
  const ImageViewPager({Key? key, required this.imageList,
    required this.currentPosition,}) : super(key: key);

  @override
  State<ImageViewPager> createState() => _ImageViewPagerState();

}

class _ImageViewPagerState extends State<ImageViewPager> {
  final CarouselController _controller = CarouselController();
  int _current = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _current = widget.imageList.length>2?3:0;
    _current = widget.currentPosition;
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: white,
        appBar: const AppBarX(
          title: '',
        ),
        body: Column(
            children: [
              Expanded(
                child: CarouselSlider.builder(
                  carouselController: _controller,
                  itemCount: widget.imageList.length,
                  itemBuilder:(BuildContext context, int itemIndex,int a){
                    return Row(
                      children: [
                        CachedNetworkImage(
                          width: MediaQuery.of(context).size.width,
                          imageUrl: widget.imageList[itemIndex].toString(),

                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Container(
                            color: Colors.grey,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                      initialPage: widget.currentPosition,
                      height: MediaQuery.of(context).size.height,
                      autoPlay: false,
                      enableInfiniteScroll: false,
                      scrollPhysics: const BouncingScrollPhysics(),
                      viewportFraction:1,
                      // enlargeCenterPage: false,
                      aspectRatio: 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }
                  ),
                ),
              ),
              if(widget.imageList.length >1)Padding(
                padding: const EdgeInsets.all(15.0),
                child: DotsIndicator(
                  dotsCount: widget.imageList.length,
                  position: _current.toDouble(),
                  decorator: const DotsDecorator(
                      color: Colors.black12, // Inactive color
                      activeColor: Colors.black,
                      spacing: EdgeInsets.all(4),
                      size: Size.square(6.0)
                  ),
                ),
              ),            ]
        ),
      ),
    );
  }
}
