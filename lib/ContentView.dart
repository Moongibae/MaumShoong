import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home.dart';
import 'Profile/ProfileView.dart';
import 'FamilyLink/CreateView.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(ContentView());
}

class ContentView extends StatefulWidget {
  @override
  _ContentViewState createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
      home: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            Home(),
            CreateView(),
            ProfileView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          selectedLabelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          showUnselectedLabels: true,
          showSelectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  _selectedIndex == 0
                      ? SvgPicture.asset("assets/images/Home.fill.svg")
                      : SvgPicture.asset("assets/images/Home.svg"),
                  const SizedBox(height: 5),
                ],
              ),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  _selectedIndex == 1
                      ? SvgPicture.asset("assets/images/Create.fill.svg")
                      : SvgPicture.asset("assets/images/Create.svg"),
                  const SizedBox(height: 5),
                ],
              ),
              label: '가족 연결',
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  _selectedIndex == 2
                      ? SvgPicture.asset("assets/images/Profile.fill.svg")
                      : SvgPicture.asset("assets/images/Profile.svg"),
                  const SizedBox(height: 5),
                ],
              ),
              label: '마이페이지',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            _pageController.jumpToPage(index);
            HapticFeedback.mediumImpact();
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
