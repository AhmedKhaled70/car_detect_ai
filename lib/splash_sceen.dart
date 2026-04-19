import 'package:flutter/material.dart';

class splashScreen extends StatelessWidget {
  static const String RouteName = 'splash screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body:  Stack(
          children: [
            Center(
              child: Image.asset('assets/images/car_icon1.jpg',height: 250,),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Text(' Supervised by SHA.',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20
                    )),
              ),
            ),
          ],
        ));
  }
}