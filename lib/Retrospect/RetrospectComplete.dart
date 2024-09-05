import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maumshoong/ContentView.dart';

void main() {
  runApp(RetrospectComplete());
}

class RetrospectComplete extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const Color whiteYellow = Color(0xFFFFE8C0);

    return MaterialApp(
      home: Scaffold(
        backgroundColor: whiteYellow,
        appBar: AppBar(
          leading: IconButton(
            icon: SvgPicture.asset('assets/images/Back.svg'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContentView(),
              ),
            ),
          ),
          backgroundColor: whiteYellow,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/images/BigHeart.svg"),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    '회고를 추가하였습니다! \n대단해요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
