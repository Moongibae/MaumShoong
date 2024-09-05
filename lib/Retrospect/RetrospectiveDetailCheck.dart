import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dotted_line/dotted_line.dart';
import 'RetrospectiveJournal.dart';
import 'RetrospectPostLike.dart';
import 'package:maumshoong/ViewModel.dart';
import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/services.dart';

class RetrospectiveDetailCheck extends StatefulWidget {
  final String Date;

  @override
  RetrospectiveDetailCheck({
    Key? key,
    required this.Date,
  }) : super(key: key);

  _RetrospectiveDetailCheck createState() => _RetrospectiveDetailCheck();
}

class _RetrospectiveDetailCheck extends State<RetrospectiveDetailCheck>
    with TickerProviderStateMixin {
  PageController _pageController = PageController();
  int _currentPageIndex = 0;
  bool isLoading = false;
  bool canRetrospect = false;
  final ViewModel viewModel = ViewModel();
  late AnimationController _animationController;

  Map<String, List<String>> LikeData = {};

  Map<String, List<String>> HateData = {};

  Map<String, List<String>> NeedData = {};

  List<String> dailyMessages = [
    "마음 표현을 안하는 것은 세상에서 제일 위험하대요! 😱",
    "앵무새 기법을 아시나요? 상대방의 말을 한 번 더 되풀이한 뒤 내 말을 시작해보세요.",
    "나 전달법 : 지금 나의 감정을 솔직하게 전달하는 것도 소통에 도움이 돼요.",
    "오늘은 가족들과 따뜻한 포옹을 나눠보는 것 어때요?",
    "때로는 아무런 조건 없이, 존재 자체로 가족에게 사랑을 표현해주세요",
    "그럴거야. 보단 그랬구나.하는 날들이 늘어갈 수 있도록 우리 물어봐요",
    "오늘도 화이팅!",
    "오늘 가족과 함께한 순간을 기억해 보세요📸",
    "가족과 함께 선물 같은 순간을 느껴보세요⊹﻿𓈒𓏸 𓂂",
    "가족에게 감사 인사를 전해볼까요?",
    "오늘 하루 우리 가족은 어떻게 보냈을까요?",
    "자신의 경험을 나누면 상대방과 더 가까워진대요..",
    "오늘은 긍정적인 표현을 시도해 보는 것 어때요?",
    "내가 경청하는 것을 상대방이 잘 알 수 있도록 고개를 끄덕여봐요😊",
    "가족에게 격려를 보내보세요!",
    "“나는”이라는 표현을 사용하면 상대방이 존중받는다고 느낀대요. “나는 이렇게 느끼고 있어.”",
    "비난하는 표현보다는 함께 어떻게 문제를 해결할 수 있을지 생각해 볼까요?",
    "가족과 함께 시간을 보내봐요☁️ミ✲",
    "서로에게 칭찬을 건네봐요ミ★",
    "가족은 언제나 내 편이에요💞",
    "가족이지만 나와는 다른 사람이에요. 서로를 존중해 봐요🌈",
    "사랑한다고 표현해 봐요❤️",
    "오늘도 마음 표현를 보내볼까요?",
    "부드럽게 말해볼까요?",
    "상대방의 말에 귀 기울여 봐요👂",
    "이해가 잘되지 않는다면 지나치지 말고 한 번 물어보세요! 의외의 답을 들을 수도..!",
    "서로를 이해해 봐요❀्",
    "미안한 마음이 있다면 전해볼까요?",
    "사랑을 표현하는 것도 연습이 필요해요👯",
    "가족에게 응원의 메시지를 남겨보세요!",
    "가족과 함께 식사해요🍚",
    "오늘 가족에게 고마웠던 순간이 무엇이었나요?",
    "나를 구체적으로 표현해 봐요💬",
    "우리 가족의 관심사를 알아봐요🕵️",
    "오늘 일어났던 재밌는 일을 이야기해 봐요🗣️",
    "나는 우리 가족에게 어떤 말을 가장 많이 하고 있나요?",
    "나는 가족에게 어떻게 사랑을 표현하고 있나요?",
    "가족과 함께하는 지금이 정말 소중해요💎",
    "안녕하세요! 반가워요 :)",
    "가족과 가장 가까이서 지내지만 서로의 마음은 잘 모르고 있을지도 몰라요🙊"
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animationController.repeat();
    setState(() {
      isLoading = true;
    });
    initializeData().then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> initializeData() async {
    await viewModel.initUserData();
    canRetrospect = await viewModel.RetrospectAlarm();
    LikeData = await ImportRetrospectiveData('Like');
    HateData = await ImportRetrospectiveData('Hate');
    NeedData = await ImportRetrospectiveData('Need');
  }

  Widget buildGradientCircularProgressIndicator() {
    return RotationTransition(
      turns: _animationController,
      child: GradientCircularProgressIndicator(
        radius: 50,
        strokeWidth: 10.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const whiteYellow = Color(0xFFFFE8C0);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Scaffold(
        backgroundColor: whiteYellow,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  buildGradientCircularProgressIndicator(),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: SvgPicture.asset("assets/images/LoadingLogo.svg"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: screenWidth - 70,
              child: Text(
                dailyMessages[Random().nextInt(dailyMessages.length)],
                style: const TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: whiteYellow,
        appBar: AppBar(
          backgroundColor: whiteYellow,
          leading: IconButton(
            icon: SvgPicture.asset('assets/images/Back.svg'),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RetrospectiveJournal(),
                  ),
                );
                HapticFeedback.lightImpact();
              },
              child: SvgPicture.asset('assets/images/Menu.svg'),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: SizedBox(
                          width: 130,
                          height: 32,
                          child: Stack(
                            children: [
                              const Positioned.fill(
                                child: Center(
                                  child: DottedLine(
                                    direction: Axis.horizontal,
                                    lineLength: double.infinity,
                                    lineThickness: 2.0,
                                    dashLength: 4.0,
                                    dashColor: Color(0xFFBABABA),
                                    dashRadius: 0.0,
                                    dashGapLength: 3.0,
                                    dashGapColor: Colors.transparent,
                                    dashGapRadius: 0.0,
                                  ),
                                ),
                              ),
                              // 첫 번째 원
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPageIndex == 0
                                        ? const Color(
                                            0xFFF66F70) // 현재 페이지일 때 빨간색
                                        : Colors.white, // 나머지 페이지일 때 흰색
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x4C000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '1',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _currentPageIndex == 0
                                            ? Colors.white // 현재 페이지일 때 흰색
                                            : const Color(
                                                0xFFBABABA), // 나머지 페이지일 때 검은색
                                        fontSize: 17,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // 두 번째 원
                              Positioned(
                                left: 49,
                                top: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPageIndex == 1
                                        ? const Color(
                                            0xFFF66F70) // 현재 페이지일 때 빨간색
                                        : Colors.white, // 나머지 페이지일 때 흰색
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x4C000000),
                                        blurRadius: 2,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '2',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _currentPageIndex == 1
                                            ? Colors.white // 현재 페이지일 때 흰색
                                            : const Color(
                                                0xFFBABABA), // 나머지 페이지일 때 검은색
                                        fontSize: 17,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // 세 번째 원
                              Positioned(
                                left: 98,
                                top: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPageIndex == 2
                                        ? const Color(
                                            0xFFF66F70) // 현재 페이지일 때 빨간색
                                        : Colors.white, // 나머지 페이지일 때 흰색
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x4C000000),
                                        blurRadius: 2,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '3',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _currentPageIndex == 2
                                            ? Colors.white // 현재 페이지일 때 흰색
                                            : const Color(
                                                0xFFBABABA), // 나머지 페이지일 때 검은색
                                        fontSize: 17,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: screenHeight - 105,
                    child: PageView(
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                      children: [
                        buildPage(screenWidth - 30, LikeData, 'Like'),
                        buildPage(screenWidth - 30, HateData, 'Hate'),
                        buildPage(screenWidth - 30, NeedData, 'Need'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (canRetrospect == false)
              Align(
                alignment: const Alignment(0, 0.85),
                child: Container(
                  decoration: BoxDecoration(
                    color: whiteYellow,
                    borderRadius: BorderRadius.circular(25.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.17),
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RetrospectPostLike(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 30),
                      backgroundColor: whiteYellow,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "📝 회고 남길래요",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }

  Widget buildPage(
      double ScreenWidth, Map<String, List<String>> Data, String Type) {
    return SizedBox(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: ScreenWidth,
                        height: Data.isEmpty
                            ? 300
                            : Type == 'Hate'
                                ? Data.keys.length * 480.0 + 50.0
                                : Data.keys.length * 430.0 + 50.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(23),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x2B000000),
                              blurRadius: 8,
                              offset: Offset(0, 0),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 30),
                          if (Type == 'Like' && Data.isNotEmpty)
                            SizedBox(
                              width: ScreenWidth - 30,
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '한 달 동안 받았던 마음표현 중\n가장 좋았던 것은?',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w800,
                                    height: 1.10,
                                  ),
                                ),
                              ),
                            ),
                          if (Type == 'Hate' && Data.isNotEmpty)
                            SizedBox(
                              width: ScreenWidth - 30,
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '한 달 동안 받았던 마음 표현 중\n가장 아쉬웠던 것은?',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w800,
                                    height: 1.10,
                                  ),
                                ),
                              ),
                            ),
                          if (Type == 'Need' && Data.isNotEmpty)
                            SizedBox(
                              width: ScreenWidth - 30,
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '한 달 동안 마음표현이\n필요했던 상황은?',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w800,
                                    height: 1.10,
                                  ),
                                ),
                              ),
                            ),
                          if (Data.isEmpty)
                            Column(
                              children: [
                                SvgPicture.asset(
                                    'assets/images/EmptyHeart.svg'),
                                const SizedBox(height: 20),
                                const Text(
                                  '아직 작성된 회고가 없어요\n한 달 동안 주고받은 마음 표현를 \n회고해 봐요!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),
                          ...List.generate(
                            Data.keys.length,
                            (i) => SizedBox(
                              width: ScreenWidth - 30,
                              height: Type == 'Hate' ? 450 : 400,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: ScreenWidth - 30,
                                    height: Type == 'Hate' ? 450 : 400,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      width: 42,
                                                      height: 42,
                                                      decoration:
                                                          const ShapeDecoration(
                                                        color: Color.fromARGB(
                                                            255, 255, 255, 255),
                                                        shape: OvalBorder(),
                                                        shadows: [
                                                          BoxShadow(
                                                            color: Color(
                                                                0x2B000000),
                                                            blurRadius: 8,
                                                            offset:
                                                                Offset(0, 0),
                                                            spreadRadius: 0,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    _buildProfileImage(
                                                        int.parse(Data.values
                                                            .elementAt(i)
                                                            .elementAt(0))),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                Data.keys.elementAt(i),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Color(0xFF424242),
                                                  fontSize: 17,
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w500,
                                                  height: 0.10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Container(
                                                height:
                                                    Type == 'Hate' ? 350 : 300,
                                                width: ScreenWidth - 30,
                                                padding:
                                                    const EdgeInsets.all(10),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: ShapeDecoration(
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            23),
                                                  ),
                                                  shadows: const [
                                                    BoxShadow(
                                                      color: Color(0x4C000000),
                                                      blurRadius: 2,
                                                      offset: Offset(0, 0),
                                                      spreadRadius: 0,
                                                    )
                                                  ],
                                                ),
                                                child: SizedBox(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (Data.values
                                                              .elementAt(i)
                                                              .elementAt(5) !=
                                                          "회고 내용을 가져올 수 없습니다.")
                                                        const Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              '나는',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 15,
                                                                fontFamily:
                                                                    'Pretendard',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                height: 0.13,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      if (Data.values
                                                              .elementAt(i)
                                                              .elementAt(5) !=
                                                          "회고 내용을 가져올 수 없습니다.")
                                                        const SizedBox(
                                                            height: 20),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width:
                                                                calculateTextWidth(
                                                              Data.values
                                                                  .elementAt(i)
                                                                  .elementAt(1),
                                                              const TextStyle(
                                                                color: Color(
                                                                    0xFF8E8E8E),
                                                                fontSize: 15,
                                                                fontFamily:
                                                                    'Pretendard',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                height: 0.13,
                                                              ),
                                                            ),
                                                            height: 30,
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            decoration:
                                                                ShapeDecoration(
                                                              color: const Color(
                                                                  0xFFFFF6E5),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            23),
                                                              ),
                                                              shadows: const [
                                                                BoxShadow(
                                                                  color: Color(
                                                                      0x4C000000),
                                                                  blurRadius: 2,
                                                                  offset:
                                                                      Offset(
                                                                          0, 0),
                                                                  spreadRadius:
                                                                      0,
                                                                )
                                                              ],
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  Data.values
                                                                      .elementAt(
                                                                          i)
                                                                      .elementAt(
                                                                          1),
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Color(
                                                                        0xFF8E8E8E),
                                                                    fontSize:
                                                                        15,
                                                                    fontFamily:
                                                                        'Pretendard',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    height:
                                                                        0.13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 20),
                                                          const Text(
                                                            '로부터',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Pretendard',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              height: 0.13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width:
                                                                calculateTextWidth(
                                                              Data.values
                                                                  .elementAt(i)
                                                                  .elementAt(2),
                                                              const TextStyle(
                                                                color: Color(
                                                                    0xFF8E8E8E),
                                                                fontSize: 15,
                                                                fontFamily:
                                                                    'Pretendard',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                height: 0.13,
                                                              ),
                                                            ),
                                                            height: Data.values
                                                                    .elementAt(
                                                                        i)
                                                                    .elementAt(
                                                                        2)
                                                                    .contains(
                                                                        '\n')
                                                                ? 60
                                                                : 30,
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            decoration:
                                                                ShapeDecoration(
                                                              color: const Color(
                                                                  0xFFFFF6E5),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            23),
                                                              ),
                                                              shadows: const [
                                                                BoxShadow(
                                                                  color: Color(
                                                                      0x4C000000),
                                                                  blurRadius: 2,
                                                                  offset:
                                                                      Offset(
                                                                          0, 0),
                                                                  spreadRadius:
                                                                      0,
                                                                )
                                                              ],
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  Data.values
                                                                      .elementAt(
                                                                          i)
                                                                      .elementAt(
                                                                          2),
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Color(
                                                                        0xFF8E8E8E),
                                                                    fontSize:
                                                                        15,
                                                                    fontFamily:
                                                                        'Pretendard',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    height: 1.2,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 20),
                                                          const Text(
                                                            '때,',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Pretendard',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              height: 0.13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      if (Data.values
                                                              .elementAt(i)
                                                              .elementAt(5) !=
                                                          "회고 내용을 가져올 수 없습니다.")
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              width:
                                                                  calculateTextWidth(
                                                                Data.values
                                                                    .elementAt(
                                                                        i)
                                                                    .elementAt(
                                                                        2),
                                                                const TextStyle(
                                                                  color: Color(
                                                                      0xFF8E8E8E),
                                                                  fontSize: 15,
                                                                  fontFamily:
                                                                      'Pretendard',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 0.13,
                                                                ),
                                                              ),
                                                              height: Data
                                                                      .values
                                                                      .elementAt(
                                                                          i)
                                                                      .elementAt(
                                                                          2)
                                                                      .contains(
                                                                          '\n')
                                                                  ? 60
                                                                  : 30,
                                                              clipBehavior: Clip
                                                                  .antiAlias,
                                                              decoration:
                                                                  ShapeDecoration(
                                                                color: const Color(
                                                                    0xFFFFF6E5),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              23),
                                                                ),
                                                                shadows: const [
                                                                  BoxShadow(
                                                                    color: Color(
                                                                        0x4C000000),
                                                                    blurRadius:
                                                                        2,
                                                                    offset:
                                                                        Offset(
                                                                            0,
                                                                            0),
                                                                    spreadRadius:
                                                                        0,
                                                                  )
                                                                ],
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    Data.values
                                                                        .elementAt(
                                                                            i)
                                                                        .elementAt(
                                                                            5),
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Color(
                                                                          0xFF8E8E8E),
                                                                      fontSize:
                                                                          15,
                                                                      fontFamily:
                                                                          'Pretendard',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      height:
                                                                          1.2,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      if (Data.values
                                                              .elementAt(i)
                                                              .elementAt(5) !=
                                                          "회고 내용을 가져올 수 없습니다.")
                                                        const SizedBox(
                                                            height: 20),
                                                      if (Data.values
                                                              .elementAt(i)
                                                              .elementAt(5) !=
                                                          "회고 내용을 가져올 수 없습니다.")
                                                        const Text(
                                                          '라는 표현을 받고 싶었어요.',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                            fontFamily:
                                                                'Pretendard',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            height: 0.13,
                                                          ),
                                                        ),
                                                      if (Data.values
                                                              .elementAt(i)
                                                              .elementAt(5) ==
                                                          "회고 내용을 가져올 수 없습니다.")
                                                        Container(
                                                          width: calculateTextWidth(
                                                              Data.values
                                                                  .elementAt(i)
                                                                  .elementAt(3),
                                                              const TextStyle(
                                                                  color: Color(
                                                                      0xFF8E8E8E),
                                                                  fontSize: 15,
                                                                  fontFamily:
                                                                      'Pretendard',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height:
                                                                      0.13)),
                                                          height: 30,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration:
                                                              ShapeDecoration(
                                                            color: const Color(
                                                                0xFFFFF6E5),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          23),
                                                            ),
                                                            shadows: const [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0x4C000000),
                                                                blurRadius: 2,
                                                                offset: Offset(
                                                                    0, 0),
                                                                spreadRadius: 0,
                                                              )
                                                            ],
                                                          ),
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  Data.values
                                                                      .elementAt(
                                                                          i)
                                                                      .elementAt(
                                                                          3),
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Color(
                                                                        0xFF8E8E8E),
                                                                    fontSize:
                                                                        15,
                                                                    fontFamily:
                                                                        'Pretendard',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    height:
                                                                        0.13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      if (Data.values
                                                              .elementAt(i)
                                                              .elementAt(5) ==
                                                          "회고 내용을 가져올 수 없습니다.")
                                                        const SizedBox(
                                                            height: 20),
                                                      if (Data.values
                                                              .elementAt(i)
                                                              .elementAt(5) ==
                                                          "회고 내용을 가져올 수 없습니다.")
                                                        const Text(
                                                          '라는 마음 표현를 들어서',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                            fontFamily:
                                                                'Pretendard',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            height: 0.13,
                                                          ),
                                                        ),
                                                      if (Data.values
                                                              .elementAt(i)
                                                              .elementAt(5) ==
                                                          "회고 내용을 가져올 수 없습니다.")
                                                        const SizedBox(
                                                            height: 20),
                                                      if (Data.values
                                                              .elementAt(i)
                                                              .elementAt(5) ==
                                                          "회고 내용을 가져올 수 없습니다.")
                                                        SizedBox(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                width: calculateTextWidth(
                                                                    Data.values
                                                                        .elementAt(
                                                                            i)
                                                                        .elementAt(
                                                                            4),
                                                                    const TextStyle(
                                                                        color: Color(
                                                                            0xFF8E8E8E),
                                                                        fontSize:
                                                                            15,
                                                                        fontFamily:
                                                                            'Pretendard',
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        height:
                                                                            0.13)),
                                                                height: 30,
                                                                clipBehavior: Clip
                                                                    .antiAlias,
                                                                decoration:
                                                                    ShapeDecoration(
                                                                  color: const Color(
                                                                      0xFFFFF6E5),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            23),
                                                                  ),
                                                                  shadows: const [
                                                                    BoxShadow(
                                                                      color: Color(
                                                                          0x4C000000),
                                                                      blurRadius:
                                                                          2,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              0),
                                                                      spreadRadius:
                                                                          0,
                                                                    )
                                                                  ],
                                                                ),
                                                                child: Center(
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        Data.values
                                                                            .elementAt(i)
                                                                            .elementAt(4),
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Color(0xFF8E8E8E),
                                                                          fontSize:
                                                                              15,
                                                                          fontFamily:
                                                                              'Pretendard',
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          height:
                                                                              0.13,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      if (Data.values
                                                              .elementAt(i)
                                                              .elementAt(5) ==
                                                          "회고 내용을 가져올 수 없습니다.")
                                                        const SizedBox(
                                                            height: 20),
                                                      if (Data.values
                                                              .elementAt(i)
                                                              .elementAt(5) ==
                                                          "회고 내용을 가져올 수 없습니다.")
                                                        const Text(
                                                          '느낌이 들었어요.',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                            fontFamily:
                                                                'Pretendard',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            height: 0.13,
                                                          ),
                                                        ),
                                                      if (Type == 'Hate')
                                                        Column(
                                                          children: [
                                                            const SizedBox(
                                                                height: 20),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Text(
                                                                  '다음에는',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        15,
                                                                    fontFamily:
                                                                        'Pretendard',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    height:
                                                                        0.13,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 15),
                                                                Container(
                                                                  width: calculateTextWidth(
                                                                      Data.values
                                                                          .elementAt(
                                                                              i)
                                                                          .elementAt(
                                                                              6),
                                                                      const TextStyle(
                                                                          color: Color(
                                                                              0xFF8E8E8E),
                                                                          fontSize:
                                                                              15,
                                                                          fontFamily:
                                                                              'Pretendard',
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          height:
                                                                              0.13)),
                                                                  height: 30,
                                                                  clipBehavior:
                                                                      Clip.antiAlias,
                                                                  decoration:
                                                                      ShapeDecoration(
                                                                    color: const Color(
                                                                        0xFFFFF6E5),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              23),
                                                                    ),
                                                                    shadows: const [
                                                                      BoxShadow(
                                                                        color: Color(
                                                                            0x4C000000),
                                                                        blurRadius:
                                                                            2,
                                                                        offset: Offset(
                                                                            0,
                                                                            0),
                                                                        spreadRadius:
                                                                            0,
                                                                      )
                                                                    ],
                                                                  ),
                                                                  child: Center(
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          Data.values
                                                                              .elementAt(i)
                                                                              .elementAt(6),
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Color(0xFF8E8E8E),
                                                                            fontSize:
                                                                                15,
                                                                            fontFamily:
                                                                                'Pretendard',
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            height:
                                                                                0.13,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }

  double calculateTextWidth(String text, TextStyle textStyle) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width + 30;
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
      width: 42,
      height: 42,
    );
  }

  Future<Map<String, List<String>>> ImportRetrospectiveData(
      String State) async {
    Map<String, List<String>> Data = {};

    // Assuming getFamilyProfiles returns a map where keys correspond to userIds and values to their respective profile indices
    Map<String, int> familyProfiles = await getFamilyProfiles();

    QuerySnapshot DataSnapshot = await FirebaseFirestore.instance
        .collection('families')
        .doc(viewModel.familyInviteCode)
        .collection('Retrospective')
        .doc(widget.Date)
        .collection(State)
        .get();

    for (var doc in DataSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String writer = data['writer'];

      int profileIndex = familyProfiles[writer] ?? 0;

      Data[writer] = [
        profileIndex.toString(),
        data['from'] ?? '회고 내용을 가져올 수 없습니다.',
        data['situation'] ?? '회고 내용을 가져올 수 없습니다.',
        data['stroke'] ?? '회고 내용을 가져올 수 없습니다.',
        data['feeling'] ?? '회고 내용을 가져올 수 없습니다.',
        data['need'] ?? "회고 내용을 가져올 수 없습니다.",
        data['Next'] ?? '회고 내용을 가져올 수 없습니다.',
      ];
    }

    return Data;
  }

  Future<Map<String, int>> getFamilyProfiles() async {
    Map<String, int> profiles = {};

    if (viewModel.familyInviteCode != null) {
      var membersSnapshot = await FirebaseFirestore.instance
          .collection('families')
          .doc(viewModel.familyInviteCode)
          .get();

      List<dynamic> members = membersSnapshot['members'];

      for (var memberId in members) {
        var memberData = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();

        profiles[memberData['userId']] = memberData['profile'];
      }
    }

    return profiles;
  }
}

class GradientCircularProgressIndicator extends StatelessWidget {
  final double radius;
  final double strokeWidth;

  GradientCircularProgressIndicator({
    required this.radius,
    this.strokeWidth = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromRadius(radius),
      painter: _GradientCircularProgressPainter(
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final double strokeWidth;

  _GradientCircularProgressPainter({required this.strokeWidth});

  double _degreeToRad(double degree) => degree * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    double offset = strokeWidth / 2;
    Rect rect = Offset(offset, offset) &
        Size(size.width - strokeWidth, size.height - strokeWidth);

    Paint gradientPaint = Paint()
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    gradientPaint.shader = const SweepGradient(
      colors: [
        Color(0xFFFF6250), // 진한 부분
        Color(0xFFFFE8BE), // 그라데이션으로 연해지는 부분
      ],
      startAngle: 0.0,
      endAngle: 2 * math.pi,
    ).createShader(rect);

    Paint roundedStartPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFFF6250);

    Paint roundedEndPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFFFE8BE);

    canvas.drawArc(rect, 0.0, 1.75 * math.pi, false, gradientPaint);
    canvas.drawArc(rect, 0.0, 0.01, false, roundedStartPaint);
    canvas.drawArc(rect, 1.75 * math.pi - 0.01, 0.01, false, roundedEndPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
