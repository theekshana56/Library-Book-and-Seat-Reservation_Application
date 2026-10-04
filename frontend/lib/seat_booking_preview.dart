import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'seat_booking/screens/seat_map_screen.dart';

void main() {
  runApp(const SeatBookingPreviewApp());
}

class SeatBookingPreviewApp extends StatelessWidget {
  const SeatBookingPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Enables scrolling with touch, mouse and trackpad.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),

      home: const SeatMapScreen(),
    );
  }
}