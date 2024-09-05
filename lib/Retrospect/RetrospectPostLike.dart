import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'RetrospectPostHate.dart';
import 'package:maumshoong/ViewModel.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class RetrospectPostLike extends StatefulWidget {
  @override
  _RetrospectPostLike createState() => _RetrospectPostLike();
}

class _RetrospectPostLike extends State<RetrospectPostLike>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _leftTextColor;
  late Animation<Color?> _rightTextColor;
  late PageController _pageControllerLike;
  late PageController _pageController;
  bool isSwitch = false;
  int _currentPageWishList = 0;
  int _currentPageRecommended = 0;
  final TextEditingController _controllerSituation = TextEditingController();
  final TextEditingController _controllerWhen = TextEditingController();
  final TextEditingController _controllerFeeling = TextEditingController();
  List<String> dropdownList = [];
  String selectedDropdown = '';
  ViewModel viewModel = ViewModel();
  bool isLoading = true;
  late QuerySnapshot<Object?>? messageData;
  late List<MessageItem> messages;
  late List<MessageItem> LikeMessages = [];
  late AnimationController _animationController;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animationController.repeat();

    _pageController = PageController();
    _pageControllerLike = PageController();

    _pageControllerLike.addListener(() {
      int nextPage = _pageControllerLike.page!.round();
      if (_currentPageWishList != nextPage) {
        setState(() {
          _currentPageWishList = nextPage;
        });
      }
    });

    _pageController.addListener(() {
      int nextPage = _pageController.page!.round();
      if (_currentPageRecommended != nextPage) {
        setState(() {
          _currentPageRecommended = nextPage;
        });
      }
    });

    initializeData().then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> initializeData() async {
    await viewModel.initUserData();
    dropdownList = (await viewModel.getFamilyData()).keys.toList();
    dropdownList.remove(viewModel.userData!['userId']);
    selectedDropdown = dropdownList.isNotEmpty ? dropdownList[0] : '';

    QuerySnapshot<Object?>? snapshot = await firestore
        .collection('families')
        .doc(viewModel.familyInviteCode)
        .collection('Messages')
        .doc(viewModel.userData!['userId'])
        .collection('messages')
        .get();

    if (snapshot.docs.isNotEmpty) {
      List<MessageItem> loadedMessages = snapshot.docs.map((docSnapshot) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        return MessageItem(
          id: docSnapshot.id,
          color: data['color'] ?? '',
          emoji: data['emoji'] ?? '',
          like: data['like'] ?? false,
          message: data['message'] ?? '',
          SelectedWritingPad: data['SelectedWritingPad'] ?? '',
          read: data['read'] ?? false,
          sender: data['sender'] ?? '',
          timestamp: data['timestamp'] ?? '',
        );
      }).toList();

      setState(() {
        isLoading = false;
        messages = loadedMessages
            .where((message) => message.message.isNotEmpty)
            .toList();
        LikeMessages =
            messages.where((message) => message.like == true).toList();
      });
    } else {
      setState(() {
        isLoading = false;
        messages = [];
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _pageControllerLike.dispose();
    _pageController.dispose();
    super.dispose();
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
    const Color whiteYellow = Color(0xFFFFF6E5);
    double screenWidth = MediaQuery.of(context).size.width;

    Map<String, Color> colors = {
      "Pink": const Color(0xFFFFA4C2),
      "Red": const Color(0xFFFF6250),
      "Yellow": const Color(0xFFFFC621),
      "Green": const Color(0xFF00AF7B),
      "Blue": const Color(0xFF4D80BD),
    };

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
                dailyMessages[math.Random().nextInt(dailyMessages.length)],
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
              onPressed: _controllerSituation.text.isEmpty ||
                      _controllerWhen.text.isEmpty ||
                      _controllerFeeling.text.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RetrospectPostHate(
                            from: selectedDropdown,
                            situation: _controllerSituation.text,
                            when: _controllerWhen.text,
                            feeling: _controllerFeeling.text,
                            messages: messages,
                            LikeMessages: LikeMessages,
                            dropdownList: dropdownList,
                          ),
                        ),
                      );
                      HapticFeedback.mediumImpact();
                    },
              child: Text(
                '다음',
                style: TextStyle(
                  color: _controllerSituation.text.isEmpty ||
                          _controllerWhen.text.isEmpty ||
                          _controllerFeeling.text.isEmpty
                      ? Colors.grey
                      : Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: 350,
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
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
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF66F70),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x4C000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '1',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 49,
                                top: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x4C000000),
                                        blurRadius: 2,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '2',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFBABABA),
                                        fontSize: 17,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 98,
                                top: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x4C000000),
                                        blurRadius: 2,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '3',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFBABABA),
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
                        const SizedBox(height: 20),
                        const Text(
                          '한 달 동안 받았던 마음 표현 중 \n가장 좋았던 것은?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                          indent: (screenWidth - 50) / 10,
                          endIndent: (screenWidth - 50) / 10,
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSwitch = !isSwitch;
                            });

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (isSwitch) {
                                if (_pageController.positions.isNotEmpty) {
                                  _pageController
                                      .jumpToPage(_currentPageRecommended);
                                }
                              } else {
                                if (_pageControllerLike.positions.isNotEmpty) {
                                  _pageControllerLike
                                      .jumpToPage(_currentPageWishList);
                                }
                              }
                            });

                            if (_controller.isCompleted) {
                              _controller.reverse();
                            } else {
                              _controller.forward();
                            }
                          },
                          child: Stack(
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
                        const SizedBox(height: 10),
                        if (isSwitch == false)
                          if (LikeMessages.isNotEmpty)
                            SizedBox(
                              child: Column(
                                children: [
                                  Center(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const PageScrollPhysics(),
                                      controller: _pageControllerLike,
                                      child: Row(
                                        children: List.generate(
                                          LikeMessages.length,
                                          (index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 10),
                                              child: Container(
                                                width: screenWidth - 60,
                                                height: 62,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 25,
                                                        vertical: 10),
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
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (LikeMessages[index]
                                                        .emoji
                                                        .isNotEmpty) ...[
                                                      Container(
                                                        width: 42,
                                                        height: 42,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: colors[
                                                              LikeMessages[
                                                                      index]
                                                                  .color],
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            LikeMessages[index]
                                                                .emoji,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Pretendard',
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                    ],
                                                    Expanded(
                                                      child: Text(
                                                        LikeMessages[index]
                                                            .message,
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                      '${_currentPageWishList + 1}/${LikeMessages.length}'),
                                ],
                              ),
                            ),
                        if (LikeMessages.isEmpty && isSwitch == false)
                          const SizedBox(
                            child: Column(
                              children: [
                                SizedBox(height: 35),
                                Text(
                                  '좋아요한 마음 표현이 없습니다.',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 35),
                              ],
                            ),
                          ),
                        if (isSwitch == true)
                          if (messages.isNotEmpty)
                            SizedBox(
                              child: Column(
                                children: [
                                  Center(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const PageScrollPhysics(),
                                      controller: _pageController,
                                      child: Row(
                                        children: List.generate(
                                          messages.length,
                                          (index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 10),
                                              child: Container(
                                                width: screenWidth - 60,
                                                height: 62,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 25,
                                                        vertical: 10),
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
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (messages[index]
                                                        .emoji
                                                        .isNotEmpty) ...[
                                                      Container(
                                                        width: 42,
                                                        height: 42,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: colors[
                                                              messages[index]
                                                                  .color],
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            messages[index]
                                                                .emoji,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Pretendard',
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                    ],
                                                    Expanded(
                                                      child: Text(
                                                        messages[index].message,
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                      '${_currentPageRecommended + 1}/${messages.length}'),
                                ],
                              ),
                            ),
                        if (messages.isEmpty && isSwitch == true)
                          const SizedBox(
                            child: Column(
                              children: [
                                SizedBox(height: 35),
                                Text(
                                  '받은 마음 표현이 없어요',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 35),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 270,
                  width: screenWidth - 30,
                  padding: const EdgeInsets.all(5),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23),
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
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: calculateTextWidth(
                                    selectedDropdown,
                                    const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 15,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ) +
                                  50,
                              height: 31,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFFF6E5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      23), // Container의 모서리 곡률
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
                              child: PopupMenuButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15), // 드롭다운 메뉴의 모서리 곡률 조정
                                ),
                                color: whiteYellow, // 드롭다운 메뉴의 배경색
                                itemBuilder: (BuildContext context) {
                                  return dropdownList.map((String item) {
                                    return PopupMenuItem<String>(
                                      child: Text(
                                        '$item',
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontSize: 15,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      value: item,
                                    );
                                  }).toList();
                                },
                                onSelected: (select) {
                                  setState(() {
                                    selectedDropdown = select as String;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    selectedDropdown,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 15,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            const Text(
                              '로부터',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 0.13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: _controllerSituation.text.isEmpty
                                  ? calculateTextWidth(
                                        "마음 표현를 받은 상황을 작성해주세요.",
                                        const TextStyle(
                                          color: Color(0xFF8E8E8E),
                                          fontSize: 15,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ) +
                                      35
                                  : calculateTextWidth(
                                        _controllerSituation.text,
                                        const TextStyle(
                                          color: Color(0xFF8E8E8E),
                                          fontSize: 15,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ) +
                                      50,
                              height: 31,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFFF6E5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(23),
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
                              child: Transform.translate(
                                offset: const Offset(0, -10),
                                child: TextField(
                                  cursorColor: const Color(0xFFF1614F),
                                  onChanged: (_) {
                                    setState(() {});
                                  },
                                  controller: _controllerSituation,
                                  decoration: const InputDecoration(
                                    hintText: '마음 표현를 받은 상황을 작성해주세요.',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF8E8E8E),
                                      fontSize: 15,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    counterText: "", // 글자수 카운터를 숨김
                                  ),
                                  maxLength: 15, // 입력 글자수를 15자로 제한
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF8E8E8E),
                                    fontSize: 15,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            const Text(
                              '때',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 0.13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: _controllerWhen.text.isEmpty
                                  ? calculateTextWidth(
                                        "어떤 마음 표현를 받았는지 작성해주세요.",
                                        const TextStyle(
                                          color: Color(0xFF8E8E8E),
                                          fontSize: 15,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ) +
                                      35
                                  : calculateTextWidth(
                                        _controllerWhen.text,
                                        const TextStyle(
                                          color: Color(0xFF8E8E8E),
                                          fontSize: 15,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ) +
                                      50,
                              height: 31,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFFF6E5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(23),
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
                              child: Transform.translate(
                                offset: const Offset(0, -10),
                                child: TextField(
                                  cursorColor: const Color(0xFFF1614F),
                                  onChanged: (_) {
                                    setState(() {});
                                  },
                                  controller: _controllerWhen,
                                  decoration: const InputDecoration(
                                    hintText: '어떤 마음 표현를 받았는지 작성해주세요.',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF8E8E8E),
                                      fontSize: 15,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    counterText: "", // 글자수 카운터를 숨김
                                  ),
                                  maxLength: 20, // 입력 글자수를 20자로 제한
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF8E8E8E),
                                    fontSize: 15,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Text(
                              '라는 마음 표현를 들어서',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 0.13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: _controllerFeeling.text.isEmpty
                                  ? calculateTextWidth(
                                        "느낌이 들었어요.",
                                        const TextStyle(
                                          color: Color(0xFF8E8E8E),
                                          fontSize: 15,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ) +
                                      35
                                  : calculateTextWidth(
                                        _controllerFeeling.text,
                                        const TextStyle(
                                          color: Color(0xFF8E8E8E),
                                          fontSize: 15,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ) +
                                      50,
                              height: 31,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFFF6E5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(23),
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
                              child: Transform.translate(
                                offset: const Offset(0, -10),
                                child: TextField(
                                  cursorColor: const Color(0xFFF1614F),
                                  onChanged: (_) {
                                    setState(() {});
                                  },
                                  controller: _controllerFeeling,
                                  decoration: const InputDecoration(
                                    hintText: '느낌이 들었어요.',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF8E8E8E),
                                      fontSize: 15,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    counterText: "", // 글자수 카운터를 숨김
                                  ),
                                  maxLength: 20, // 입력 글자수를 20자로 제한
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF8E8E8E),
                                    fontSize: 15,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Text(
                              '느낌이 들었어요.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 0.13,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  double calculateTextWidth(String text, TextStyle textStyle) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width + 20;
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
        Color(0xFFFF6250),
        Color(0xFFFFE8BE),
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
