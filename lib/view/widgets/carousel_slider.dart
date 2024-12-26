import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MySlider extends StatelessWidget {
  MySlider({super.key});

  final CarouselController cc = Get.put(CarouselController());

  final RxList slides = [].obs;

  void getImgList() {
    FirebaseFirestore.instance
        .collection("App")
        .doc('carousel_slider')
        .get()
        .then(
      (value) {
        slides.value = value.data()!['slides'];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    getImgList();
    return Obx(
      () => slides.isNotEmpty
          ? CarouselSlider.builder(
              itemCount: slides.length,
              itemBuilder: (context, index, realIndex) => InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(slides[index]['action_url']);
                  if (await canLaunchUrl(url)) {
                    launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: Card(
                  elevation: 2.5,
                  margin: const EdgeInsets.all(4.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          slides[index]['img_url'],
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              options: CarouselOptions(
                height: 90.0,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.85,
              ),
            )
          : const SizedBox(
              height: 90,
              width: double.infinity,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
