import 'package:flutter/material.dart';
import '../Utils/border.dart';
import '../Utils/styles.dart';
import '../login/auth/auth.dart';

class BeginScreen extends StatelessWidget {
  const BeginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.blueGrey[500],
      child: SafeArea(
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(
                'assets/pic1.png',
                width: width,
              ),
              const Text(
                'Đưa trò chơi vào\nthói quen hàng ngày của bạn',
                style: textStyle1,
                textAlign: TextAlign.center,
              ),
              const Text(
                'Những trò chơi hay nhất, được cá nhân hóa\ntheo sở thích chơi trò chơi của bạn',
                textAlign: TextAlign.center,
                style: textStyle11,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.007,
                    ),
                    margin: EdgeInsets.all(width * 0.01),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[500],
                      borderRadius: getBorderRadiusWidget(context, 1),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.07,
                  vertical: height * 0.04,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: getShapeWidget(context, 1),
                    backgroundColor: Colors.blueGrey[500],
                    padding: EdgeInsets.symmetric(vertical: height * 0.01),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const AuthPage()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Get Started',
                          style: textStyle8,
                        ),
                        Icon(
                          Icons.arrow_circle_right_rounded,
                          color: Colors.white,
                          size: width * 0.1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
