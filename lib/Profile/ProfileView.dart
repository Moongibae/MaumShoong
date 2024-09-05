import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'InformationView.dart';
import 'MessageInformation.dart';
import 'package:maumshoong/ViewModel.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:math';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool profileEdit = false;
  final double _circleDiameter = 200.0;
  final double _inactiveScaleFactor = 0.65;
  final double _activeScaleFactor = 0.9;
  final double _inactiveOpacity = 0.7;
  final PageController _pageController = PageController(viewportFraction: 0.3);
  int _currentPage = 0;
  List<int> selectedIndexes = [];
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _leftTextColor;
  late Animation<Color?> _rightTextColor;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  ViewModel viewModel = ViewModel();
  bool isSwitch = false;
  Map<String, int>? UserData;
  late QuerySnapshot<Object?>? messageData;
  List<String> message = [];
  List<String> LikeMessage = [];
  List<String> LikeMessageWriter = [];
  List<String> LikeMessageId = [];
  bool isLoading = false;
  double ProgressState = 0.0;
  String selectedLoadingMessage = "";
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
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 105.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    selectedLoadingMessage =
        dailyMessages[Random().nextInt(dailyMessages.length)];
    _leftTextColor = ColorTween(
      begin: Colors.white,
      end: Colors.black,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rightTextColor = ColorTween(
      begin: Colors.black,
      end: Colors.white,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      setState(() {
        isLoading = true;
      });
      await viewModel.initUserData();
      setState(() {
        ProgressState += 0.2;
      });
      print('유저 정보: ${viewModel.familyInviteCode}');
      UserData = await viewModel.getUserData();
      setState(() {
        ProgressState += 0.2;
      });
      messageData = await viewModel.getMessages();
      print('메시지 데이터: ${messageData.toString()}');
      setState(() {
        ProgressState += 0.2;
      });
      message = messageData!.docs.map((e) => e['message'] as String).toList();
      setState(() {
        ProgressState += 0.2;
      });
      LikeMessage = messageData!.docs
          .where((doc) => doc['like'] as bool)
          .map((e) => e['message'] as String)
          .toList();
      LikeMessageWriter = messageData!.docs
          .where((doc) => doc['like'] as bool)
          .map((e) => e['sender'] as String)
          .toList();
      _currentPage = UserData?.values.first ?? 0;
      LikeMessageId = messageData!.docs
          .where((doc) => doc['like'] as bool)
          .map((e) => e.id.toString())
          .toList();
      setState(() {
        ProgressState += 0.2;
      });
    } catch (e) {
      print(e);
    }
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    const Color whiteYellow = Color(0xFFFFE8C0);
    var appBar = AppBar(
      backgroundColor: whiteYellow,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            setState(() {
              if (profileEdit) {
                if (_pageController.page == null ||
                    _pageController.page?.round() != _currentPage) {
                  _currentPage = 0;
                  _pageController.jumpToPage(_currentPage);
                }
              }
              profileEdit = !profileEdit;
              if (!profileEdit) {
                updateProfile(_currentPage);
              }
            });
          },
          child: Text(
            profileEdit ? "변경할래요" : "프로필 수정",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        )
      ],
    );

    if (isLoading) {
      return Scaffold(
        backgroundColor: whiteYellow,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                child: Image.asset(
              'assets/images/LoadingImage.png',
              width: 120,
              height: 120,
            )),
            const SizedBox(height: 25),
            SizedBox(
                width: 200,
                height: 10,
                child: LinearPercentIndicator(
                  width: 200.0,
                  animation: true,
                  animationDuration: 100,
                  lineHeight: 10.0,
                  percent: ProgressState,
                  animateFromLastPercent: true,
                  progressColor: const Color(0xFFF84C37),
                  barRadius: const Radius.circular(10),
                )),
            const SizedBox(height: 25),
            SizedBox(
              width: screenWidth - 220,
              child: Text(
                selectedLoadingMessage,
                style: const TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )),
      );
    }

    return Scaffold(
      backgroundColor: whiteYellow,
      appBar: appBar,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: Center(
                child: SizedBox(
                  height: _circleDiameter * _activeScaleFactor,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (notification is ScrollUpdateNotification &&
                          _pageController.position.hasContentDimensions) {
                        setState(() {
                          _currentPage = _pageController.page?.round() ?? 0;
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
                      itemCount: profileEdit ? 5 : 1,
                      itemBuilder: (context, index) {
                        if (!profileEdit) {
                          return Container(
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
                            child: _buildProfileImage(_currentPage),
                          );
                        } else {
                          final scale = _calculateScale(index);
                          final opacity = _calculateOpacity(index);
                          return GestureDetector(
                            onTap: () {
                              if (profileEdit) {
                                setState(() {
                                  if (selectedIndexes.contains(index)) {
                                    selectedIndexes.remove(index);
                                  } else {
                                    selectedIndexes.add(index);
                                  }
                                });
                              }
                            },
                            child: Transform.scale(
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
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              UserData?.keys.first ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 0.07,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 90,
              height: 34,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4C000000),
                    blurRadius: 2,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InformationView()),
                  );
                },
                child: const Text(
                  '정보 보기',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 0.13,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Stack(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(37),
                        topRight: Radius.circular(37),
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x2B000000),
                        blurRadius: 8,
                        offset: Offset(0, 0),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isSwitch = !isSwitch;
                              if (_controller.isCompleted) {
                                _controller.reverse();
                              } else {
                                _controller.forward();
                              }
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                width: 230,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(23),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  return Positioned(
                                    left: _animation.value,
                                    child: Container(
                                      width: 125,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF66F70),
                                        borderRadius: BorderRadius.circular(23),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned.fill(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: AnimatedBuilder(
                                        animation: _leftTextColor,
                                        builder: (context, child) {
                                          return Text(
                                            '좋아요한 마음 표현',
                                            style: TextStyle(
                                              color: _leftTextColor.value,
                                              fontSize: 10,
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w900,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 30),
                                      child: AnimatedBuilder(
                                        animation: _rightTextColor,
                                        builder: (context, child) {
                                          return Text(
                                            '받은 마음 표현',
                                            style: TextStyle(
                                              color: _rightTextColor.value,
                                              fontSize: 10,
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w900,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      if (isSwitch == true)
                        if (LikeMessage.isNotEmpty)
                          SizedBox(
                            width: screenWidth,
                            height: screenHeight - 400,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var index = 0;
                                      index < message.length;
                                      index++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 7),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MessageInformation(
                                                        messageId: messageData
                                                                ?.docs[index].id
                                                                .toString() ??
                                                            "")),
                                          );
                                        },
                                        child: Container(
                                          width: screenWidth - 60,
                                          height: 65,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 25,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(23),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x4C000000),
                                                blurRadius: 2,
                                                offset: Offset(0, 0),
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Transform.scale(
                                                        scale: 0.9,
                                                        child: SvgPicture.asset(
                                                          "assets/images/Tape.svg",
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 14,
                                                                top: 4),
                                                        child: Text(
                                                          "To. ${viewModel.getUserData()?.keys.first.toString()}",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    'From. ${messageData?.docs[index]['sender']}',
                                                    style: const TextStyle(
                                                      color: Color(0xFFABB0BC),
                                                      fontSize: 16,
                                                      fontFamily: 'Pretendard',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 0.12,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: Text(
                                                      message[index],
                                                      style: const TextStyle(
                                                          fontSize: 11),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 150)
                                ],
                              ),
                            ),
                          ),
                      if (LikeMessage.isEmpty && isSwitch == true)
                        SizedBox(
                          height: screenHeight / 2.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/EmptyHeart.svg',
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(height: 20),
                              const SizedBox(
                                width: 342,
                                child: Text(
                                  '아직 받은 마음 표현가 없어요.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    height: 1.12,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      if (isSwitch == false)
                        if (LikeMessage.isNotEmpty)
                          SizedBox(
                            width: screenWidth,
                            height: screenHeight - 400,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var index = 0;
                                      index < LikeMessage.length;
                                      index++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 7),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MessageInformation(
                                                      messageId:
                                                          LikeMessageId[index]),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: screenWidth - 60,
                                          height: 65,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 25,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(23),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x4C000000),
                                                blurRadius: 2,
                                                offset: Offset(0, 0),
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Transform.scale(
                                                        scale: 0.9,
                                                        child: SvgPicture.asset(
                                                          "assets/images/Tape.svg",
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 14,
                                                                top: 4),
                                                        child: Text(
                                                          "To. ${viewModel.getUserData()?.keys.first.toString()}",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    'From. ${LikeMessageWriter[index]}',
                                                    style: const TextStyle(
                                                      color: Color(0xFFABB0BC),
                                                      fontSize: 16,
                                                      fontFamily: 'Pretendard',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 0.12,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: Text(
                                                      LikeMessage[index],
                                                      style: const TextStyle(
                                                          fontSize: 11),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 150)
                                ],
                              ),
                            ),
                          ),
                      if (LikeMessage.isEmpty && isSwitch == false)
                        SizedBox(
                          height: screenHeight / 2.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/EmptyHeart.svg',
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(height: 20),
                              const SizedBox(
                                width: 342,
                                child: Text(
                                  '좋아요를 누른 마음 표현가 없어요\n기분이 좋아지는 마음 표현에 좋아요를 눌러봐요!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    height: 1.12,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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

  Future<void> updateProfile(int profile) async {
    await firestore
        .collection('users')
        .doc(viewModel.userUID)
        .update({'profile': profile});
  }
}
