import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inq_app/models/quick_updates_model.dart';
import 'package:inq_app/services/firebase_firestore_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:inq_app/functional_supports/responsive.dart';

class UpdateSlider extends StatefulWidget {
  const UpdateSlider({super.key});

  @override
  State<UpdateSlider> createState() => _UpdateSliderState();
}

class _UpdateSliderState extends State<UpdateSlider> {
  int currentIndex = 0;
  final QuickUpdatesService _updatesService = QuickUpdatesService();
  List<QuickUpdate> updates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuickUpdates();
  }

  Future<void> _fetchQuickUpdates({int limit = 6}) async {
    try {
      final fetchedUpdates =
          await _updatesService.getQuickUpdates(limit: limit);
      setState(() {
        updates = fetchedUpdates;
        isLoading = false; // Data fetched, stop loading
      });
    } catch (e) {
      print("Error fetching updates: $e");
      setState(() {
        isLoading = false; // Stop loading in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (updates.isEmpty) {
      return const Center(child: Text('No updates available'));
    }

    double carouselHeight;
    double viewportFraction;
    bool enlargeCenterPage;

    if (ResponsiveWidget.isDesktop(context)) {
      carouselHeight = SizeConfig.height(30);
      viewportFraction = 0.3;
      enlargeCenterPage = true;
    } else if (ResponsiveWidget.isTablet(context)) {
      carouselHeight = SizeConfig.height(25);
      viewportFraction = 0.5;
      enlargeCenterPage = true;
    } else {
      // Mobile
      carouselHeight = SizeConfig.height(27);
      viewportFraction = 0.89;
      enlargeCenterPage = false;
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: carouselHeight,
            viewportFraction: viewportFraction,
            enlargeCenterPage: enlargeCenterPage,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
          items:
              updates.map((update) => _buildUpdateContainer(update)).toList(),
        ),
        SizedBox(height: SizeConfig.height(1)),
        AnimatedSmoothIndicator(
          activeIndex: currentIndex,
          count: updates.length,
          effect: WormEffect(
            activeDotColor: Colors.orange,
            dotColor: Colors.grey.shade700,
            dotHeight: SizeConfig.height(0.8),
            dotWidth: SizeConfig.width(1.6),
            spacing: SizeConfig.width(0.8),
            paintStyle: PaintingStyle.fill,
          ),
        )
      ],
    );
  }

  Widget _buildUpdateContainer(QuickUpdate update) {
    double containerHeight;
    double containerWidth;

    if (ResponsiveWidget.isDesktop(context)) {
      containerHeight = SizeConfig.height(30);
      containerWidth = SizeConfig.width(30);
    } else if (ResponsiveWidget.isTablet(context)) {
      containerHeight = SizeConfig.height(50);
      containerWidth = SizeConfig.width(50);
    } else {
      // Mobile
      containerHeight = SizeConfig.height(50);
      containerWidth = SizeConfig.width(80);
    }

    return Padding(
      padding: EdgeInsets.all(SizeConfig.width(1)),
      child: Stack(
        children: [
          Container(
            height: containerHeight,
            width: containerWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SizeConfig.width(2)),
              child: CachedNetworkImage(
                imageUrl: update.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SpinKitFadingCircle(
                  color: Colors.orange,
                  size: 50,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: SizeConfig.width(10),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: containerHeight,
            width: containerWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeConfig.width(2)),
              gradient: const LinearGradient(
                colors: [Colors.transparent, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.width(2)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    update.title,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: SizeConfig.text(4),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: SizeConfig.height(1)),
                  Text(
                    update.newsBody,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: SizeConfig.text(3),
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showDialog(context, update);
                    },
                    child: Text(
                      "read more...",
                      style: TextStyle(fontSize: SizeConfig.text(3)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showDialog(BuildContext context, QuickUpdate update) {
  showDialog(
    context: context,
    builder: (context) {
      return ResponsiveWidget(
        mobile: _buildMobileDialog(context, update),
        tablet: _buildTabletDialog(context, update),
        desktop: _buildDesktopDialog(context, update),
      );
    },
  );
}

Widget _buildMobileDialog(BuildContext context, QuickUpdate update) {
  return Padding(
    padding: EdgeInsets.symmetric(
      vertical: SizeConfig.height(7),
      horizontal: SizeConfig.width(2),
    ),
    child: _buildDialogContent(context, update),
  );
}

Widget _buildTabletDialog(BuildContext context, QuickUpdate update) {
  return Padding(
    padding: EdgeInsets.symmetric(
      vertical: SizeConfig.height(10),
      horizontal: SizeConfig.width(10),
    ),
    child: _buildDialogContent(context, update),
  );
}

Widget _buildDesktopDialog(BuildContext context, QuickUpdate update) {
  return Padding(
    padding: EdgeInsets.symmetric(
      vertical: SizeConfig.height(5),
      horizontal: SizeConfig.width(20),
    ),
    child: _buildDialogContent(context, update),
  );
}

Widget _buildDialogContent(BuildContext context, QuickUpdate update) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(SizeConfig.width(2)),
    ),
    child: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: SizeConfig.height(2)),
          Padding(
            padding: EdgeInsets.all(SizeConfig.width(1)),
            child: Container(
              height: SizeConfig.height(30),
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SizeConfig.width(2)),
                child: CachedNetworkImage(
                  imageUrl: update.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: SizeConfig.width(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: SizeConfig.height(1.5)),
          Padding(
            padding: EdgeInsets.all(SizeConfig.width(1)),
            child: Text(
              update.title,
              style: TextStyle(
                fontSize: SizeConfig.text(5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: SizeConfig.height(1.5)),
          Padding(
            padding: EdgeInsets.all(SizeConfig.width(1)),
            child: Text(
              update.newsBody,
              style: TextStyle(fontSize: SizeConfig.text(3.5)),
            ),
          ),
        ],
      ),
    ),
  );
}
