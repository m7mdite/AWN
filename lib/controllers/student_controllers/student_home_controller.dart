import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class StudentHomeController extends GetxController {
  void toAiChatPage();
}

class StudentHomeControllerImp extends StudentHomeController {

 
  var currentPage = 0;
  late PageController pageController;
  Timer? _autoScrollTimer;
  @override
  void onInit() {
    pageController = PageController(viewportFraction: 0.8);

    _startAutoScroll();
    super.onInit();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!pageController.hasClients) {
        return; 
      }
      if (currentPage < 3) {
       
        currentPage++;
      } else {
        currentPage = 0;
      }
      pageController.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 1800),
        curve: Curves.easeInOut,
      );
      update();
    });
  }

  @override
  void onClose() {
    _autoScrollTimer?.cancel();
    pageController.dispose();
    super.onClose();
  }
   @override
  toAiChatPage() {
    Get.toNamed("/aiChat", arguments: {
      "role": "student"
    });
  }
}
