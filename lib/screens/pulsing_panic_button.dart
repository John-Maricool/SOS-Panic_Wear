import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/UtilsController.dart';

class PulsingPanicButton extends StatefulWidget {
  const PulsingPanicButton({Key? key}) : super(key: key);

  @override
  _PulsingPanicButtonState createState() => _PulsingPanicButtonState();
}

class _PulsingPanicButtonState extends State<PulsingPanicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final UtilsController controller = Get.find();

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Duration of one pulse cycle
    );

    // Define the animation (scaling effect)
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Listen to changes in controller.panicOn
    controller.panicOn.listen((isPanicOn) {
      if (isPanicOn) {
        _controller.repeat(reverse: true); // Start pulsing
      } else {
        _controller.stop(); // Stop pulsing
        _controller.value = 0.0; // Reset the animation
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panic Button'),
        centerTitle: true,
        leading: null,
      ),
      body: Center(
        // Center the button on the screen
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: controller.panicOn.value ? _animation.value : 1.0,
              child: InkWell(
                onLongPress: () {
                  if (controller.panicOn.isTrue) {
                    controller.stopSendingPanic();
                  } else {
                    controller.startSendingPanic();
                  }
                },
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFE7E7EB), width: 12),
                    color: Color(0xffFF7E7B),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PANIC',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Press for 3 seconds',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
