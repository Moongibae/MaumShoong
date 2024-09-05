import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'FamilyRolesChck.dart';
import 'dart:core';

class CustomProfilePage extends StatefulWidget {
  final String UID;
  CustomProfilePage({required this.UID});
  @override
  _CustomProfilePageState createState() => _CustomProfilePageState();
}

class CustomProfileView extends StatelessWidget {
  final String UID;
  CustomProfileView({required this.UID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset("assets/images/Back.svg"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('회원가입'),
      ),
      body: CustomProfilePage(UID: UID),
    );
  }
}

class _CustomProfilePageState extends State<CustomProfilePage> {
  final PageController _pageController = PageController(viewportFraction: 0.3);
  int _currentPage = 0;
  final double _circleDiameter = 200.0;
  final double _inactiveScaleFactor = 0.65;
  final double _activeScaleFactor = 0.9;
  final double _inactiveOpacity = 0.7;
  TextEditingController _monthController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();
  bool _isButtonEnabled = false;
  final whiteYellow = const Color(0xFFFFE8C0);

  bool checkMale = false;
  bool checkFemale = false;
  String year = '';
  String month = '';

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_updateButtonState);
    _monthController.addListener(_updateButtonState);
    _yearController.addListener(_updateButtonState);
    _updateButtonState();
    print("UID: ${widget.UID}");
  }

  void _updateButtonState() {
    bool isEnabled = _nicknameController.text.length >= 2 &&
        (checkMale || checkFemale) &&
        _yearController.text.length == 4 &&
        _monthController.text.isNotEmpty;

    setState(() {
      _isButtonEnabled = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 올라와도 화면 레이아웃이 재조정되지 않음
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(
                  height: 200,
                  child: Center(
                    child: SizedBox(
                      height: _circleDiameter * _activeScaleFactor,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (notification is ScrollUpdateNotification &&
                              _pageController.position.hasContentDimensions) {
                            setState(() {
                              _currentPage =
                                  _pageController.page?.round() ?? _currentPage;
                            });
                          }
                          return true;
                        },
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (value) {
                            setState(() {
                              _currentPage = value;
                            });
                          },
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final scale = _calculateScale(index);
                            final opacity = _calculateOpacity(index);
                            return Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity,
                                child: Container(
                                  width: _circleDiameter,
                                  height: _circleDiameter,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.17),
                                        blurRadius: 6,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: _buildProfileImage(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '닉네임',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 35,
                      height: 45,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15.5),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4C000000),
                            blurRadius: 2,
                            offset: Offset(0, 0),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: TextField(
                        cursorColor: const Color(0xFFF1614F),
                        controller: _nicknameController,
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        onChanged: (value) {
                          setState(() {
                            _isButtonEnabled =
                                (_nicknameController.text.length >= 2 &&
                                    (checkMale || checkFemale) &&
                                    _yearController.text.length == 4 &&
                                    !_monthController.text.isEmpty);
                          });

                          if (value.length > 4) {
                            setState(() {
                              _nicknameController.text = value.substring(0, 4);
                              _nicknameController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: _nicknameController.text.length));
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: '닉네임을 입력하세요. (최소 2자 입력)',
                          hintStyle: TextStyle(
                            color: Color(0xFFBDBDBD),
                            fontSize: 15,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.5),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          '성별',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          '*추천 마음 표현 개발을 위해 사용됩니다.',
                          style: TextStyle(
                            color: Color(0xFF535353),
                            fontSize: 10,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            height: 0.30,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  checkMale = true;
                                  checkFemale = false;
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: checkMale != true
                                        ? const Color(0xFFE6E6E6)
                                        : Colors.black,
                                    width: checkMale == true ? 5.0 : 1.5,
                                  ),
                                ),
                                child: Container(),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              "남",
                              style: TextStyle(
                                fontFamily: "Pretendard",
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  checkMale = false;
                                  checkFemale = true;
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: checkFemale != true
                                        ? const Color(0xFFE6E6E6)
                                        : Colors.black,
                                    width: checkFemale == true ? 5.0 : 1.5,
                                  ),
                                ),
                                child: Container(),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              "여",
                              style: TextStyle(
                                fontFamily: "Pretendard",
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(flex: 1),
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 1.7),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          '출생년도',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          '*추천 마음 표현 개발을 위해 사용됩니다.',
                          style: TextStyle(
                            color: Color(0xFF535353),
                            fontSize: 10,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            height: 0.30,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        boxShadow: [
                                          BoxShadow(
                                            color: year.length < 4 &&
                                                    year.isNotEmpty
                                                ? Colors.red.withOpacity(0.2)
                                                : Colors.black.withOpacity(0.2),
                                            blurRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15, top: 0),
                                              child: TextField(
                                                cursorColor:
                                                    const Color(0xFFF1614F),
                                                controller: _yearController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: "0000",
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 9.0),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                onTapOutside: (event) =>
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus(),
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      4),
                                                ],
                                                onChanged: (newValue) {
                                                  int currentYear =
                                                      DateTime.now().year;

                                                  if (int.tryParse(newValue) !=
                                                          null &&
                                                      int.parse(newValue) >
                                                          currentYear) {
                                                    setState(() {
                                                      _yearController.text =
                                                          currentYear
                                                              .toString();
                                                      _yearController
                                                              .selection =
                                                          TextSelection
                                                              .fromPosition(
                                                                  TextPosition(
                                                        offset: _yearController
                                                            .text.length,
                                                      ));
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          const Row(
                                            children: [
                                              Text(
                                                "년",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Container(
                                      width: 80,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 1,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15, top: 0),
                                              child: TextField(
                                                cursorColor:
                                                    const Color(0xFFF1614F),
                                                controller: _monthController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: "00",
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 9.0),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                onTapOutside: (event) =>
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus(),
                                                textInputAction:
                                                    TextInputAction.done,
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      2),
                                                ],
                                                onChanged: (newValue) {
                                                  if (int.tryParse(newValue) !=
                                                          null &&
                                                      int.parse(newValue) >
                                                          12) {
                                                    setState(() {
                                                      _monthController.text =
                                                          "12";
                                                    });
                                                  } else if (newValue.length >
                                                      2) {
                                                    setState(() {
                                                      _monthController.text =
                                                          newValue.substring(
                                                              0, 2);
                                                    });
                                                  } else if (int.tryParse(
                                                              newValue) !=
                                                          null &&
                                                      newValue == "00") {
                                                    setState(() {
                                                      _monthController.text =
                                                          "12";
                                                    });
                                                  }

                                                  if (newValue.length == 2) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          const Row(
                                            children: [
                                              Text(
                                                "월",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0, // 하단에 고정
              left: 0,
              right: 0,
              child: SizedBox(
                width: screenWidth - 22,
                height: 65,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        if (_nicknameController.text.length >= 2 &&
                            (checkMale || checkFemale) &&
                            _yearController.text.length == 4 &&
                            !_monthController.text.isEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FamilyRolesCheck(
                                nickname: _nicknameController.text,
                                checkMale: checkMale,
                                checkFemale: checkFemale,
                                year: _yearController.text,
                                month: _monthController.text,
                                ProfileIndex: _currentPage,
                                UID: widget.UID,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: screenWidth - 22, // 버튼의 너비를 조정할 수 있습니다.
                        decoration: BoxDecoration(
                          color: _isButtonEnabled
                              ? whiteYellow
                              : Colors.grey, // 버튼 배경색
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        child: Text(
                          "다음",
                          style: TextStyle(
                            color:
                                _isButtonEnabled ? Colors.black : Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateScale(int index) {
    if (_pageController.hasClients &&
        _pageController.position.hasContentDimensions &&
        _pageController.page != null) {
      final page = _pageController.page!;
      final difference = (index - page).abs();
      return (1 - difference).clamp(_inactiveScaleFactor, _activeScaleFactor);
    } else {
      return _inactiveScaleFactor;
    }
  }

  double _calculateOpacity(int index) {
    if (_pageController.hasClients &&
        _pageController.position.hasContentDimensions &&
        _pageController.page != null) {
      final page = _pageController.page!;
      final difference = (index - page).abs();
      return (1 - difference).clamp(_inactiveOpacity, 1.0);
    } else {
      return _inactiveOpacity;
    }
  }

  Widget _buildProfileImage(int index) {
    String assetName;
    switch (index) {
      case 0:
        assetName = 'assets/images/GreenHeart.svg';
        break;
      case 1:
        assetName = 'assets/images/BlueHeart.svg';
        break;
      case 2:
        assetName = 'assets/images/OrangeHeart.svg';
        break;
      case 3:
        assetName = 'assets/images/PinkHeart.svg';
        break;
      case 4:
        assetName = 'assets/images/PurpleHeart.svg';
        break;
      default:
        return Container();
    }
    return SvgPicture.asset(
      assetName,
      width: _circleDiameter,
      height: _circleDiameter,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
