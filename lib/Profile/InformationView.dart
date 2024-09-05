import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maumshoong/ViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../SignIn_SignUp/SignInView.dart';
import 'dart:math' as math;

class InformationView extends StatefulWidget {
  @override
  _InformationViewState createState() => _InformationViewState();
}

class _InformationViewState extends State<InformationView>
    with TickerProviderStateMixin {
  ViewModel viewModel = ViewModel();
  bool isLoading = true;
  late AnimationController _animationController;

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

  Future<void> initializeData() async {
    await viewModel.initUserData();
    print('유저 정보: ${viewModel.familyInviteCode}');
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut(); // FirebaseAuth에서 로그아웃
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false); // SharedPreferences 업데이트
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SignInView()),
          (Route<dynamic> route) => false); // 로그인 화면으로 이동
    } catch (e) {
      print("로그아웃 오류: $e");
    }
  }

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
    viewModel.initUserData().then((_) {
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
    double screenWidth = MediaQuery.of(context).size.width;
    const Color whiteYellow = Color(0xFFFFE8C0);
    const privacyURL =
        "https://observant-gasoline-c62.notion.site/c972ee106ab043c0a1f7b0ba8bf3d13e?pvs=4";
    const ServiceURL = "https://smore.im/form/fZqa2cTJRm";
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String? userUID = FirebaseAuth.instance.currentUser?.uid;
    bool isLoginFailed = false;

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
    }

    return Scaffold(
      backgroundColor: whiteYellow,
      appBar: AppBar(
        backgroundColor: whiteYellow,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: screenWidth - 30,
              height: 300,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x2B000000),
                    blurRadius: 8,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth - 100,
                    height: 5,
                    child: Row(
                      children: [
                        const Text(
                          '우리 가족 코드',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            height: 0.10,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            _copyTextToClipboard(
                                viewModel.familyInviteCode.toString(),
                                viewModel);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('가족 초대코드가 복사되었습니다.')),
                            );
                          },
                          child: Row(
                            children: [
                              Transform.scale(
                                scale: 3,
                                child: SvgPicture.asset(
                                  'assets/images/Copy.svg',
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                viewModel.familyInviteCode.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontFamily: 'Pretendard',
                                  height: 0.10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: screenWidth - 100,
                    child: const Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: screenWidth - 100,
                    child: const Row(
                      children: [
                        Text(
                          '앱 버전',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            height: 0.10,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '1.1.4',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontFamily: 'Pretendard',
                            height: 0.10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: screenWidth - 100,
                    child: const Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      _launchURL(ServiceURL);
                      print("click!");
                    },
                    child: SizedBox(
                      width: screenWidth - 100,
                      height: 5,
                      child: Row(
                        children: [
                          const Text(
                            '서비스 문의',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              height: 0.10,
                            ),
                          ),
                          const Spacer(),
                          Transform.scale(
                            scale: 3,
                            child: SvgPicture.asset(
                              'assets/images/Move.svg',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: screenWidth - 100,
                    child: const Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      print("click!");
                      _launchURL(privacyURL);
                    },
                    child: SizedBox(
                      width: screenWidth - 100,
                      height: 5,
                      child: Row(
                        children: [
                          const Text(
                            '개인정보 처리 방침',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              height: 0.10,
                            ),
                          ),
                          const Spacer(),
                          Transform.scale(
                            scale: 3,
                            child: SvgPicture.asset(
                              'assets/images/Move.svg',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: SingleChildScrollView(
                              child: Container(
                                width: screenWidth - 30,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 23),
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '로그아웃',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontFamily: 'SF Pro Text',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      '정말 로그아웃 하시겠습니까?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontFamily: 'SF Pro Text',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 110, // 버튼 너비 조정
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // 대화 상자 닫기
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFFFE8BE),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(23),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '취소',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                  fontFamily: 'SF Pro Text',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 20), // 버튼 사이 간격 조절
                                        SizedBox(
                                          width: 110, // 동일한 너비로 버튼 조정
                                          child: TextButton(
                                            onPressed: () {
                                              // 로그아웃 로직 추가
                                              _handleLogout();
                                              print("로그아웃 클릭됨!");

                                              Navigator.of(context)
                                                  .pop(); // 대화 상자 닫기
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SignInView(),
                                                  fullscreenDialog: true,
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFFFE8BE),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(23),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '로그아웃',
                                                style: TextStyle(
                                                  color: Color(0xFFF74C37),
                                                  fontSize: 17,
                                                  fontFamily: 'SF Pro Text',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: screenWidth / 2.25,
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.white.withOpacity(0.800000011920929),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      child: Text(
                                        '로그아웃',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w500,
                                          height: 0.10,
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
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      String email = '';
                      String password = '';

                      showDialog(
                        context: context,
                        barrierDismissible: isLoading ? false : true,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(23),
                                ),
                                child: SingleChildScrollView(
                                  child: Container(
                                    width: screenWidth - 30,
                                    height: 400,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 23),
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
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Column(
                                            children: [
                                              Column(
                                                children: [
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth - 30,
                                                    child: const Text(
                                                      '정말 회원탈퇴 하시겠습니까?',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontFamily:
                                                            'SF Pro Text',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 0.08,
                                                        letterSpacing: -0.41,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 25),
                                                  SizedBox(
                                                    width: screenWidth - 30,
                                                    child: const Text(
                                                      '계정과 관련된 모든 데이터가 삭제됩니다.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13,
                                                        fontFamily:
                                                            'SF Pro Text',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 0.11,
                                                        letterSpacing: -0.08,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 25),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '이메일',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w600,
                                                  height: 0.10,
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Container(
                                                width: screenWidth - 30,
                                                height: 34,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 2),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: ShapeDecoration(
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            23),
                                                  ),
                                                  shadows: [
                                                    BoxShadow(
                                                      color: isLoginFailed
                                                          ? const Color(
                                                              0x4CF84C37)
                                                          : const Color(
                                                              0x4C000000),
                                                      blurRadius: 2,
                                                      offset:
                                                          const Offset(0, 0),
                                                      spreadRadius: 0,
                                                    )
                                                  ],
                                                ),
                                                child: TextField(
                                                  cursorColor:
                                                      const Color(0xFFF1614F),
                                                  onChanged: (value) {
                                                    email =
                                                        value; // 사용자가 입력한 값을 저장
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: '이메일 입력',
                                                    border: InputBorder
                                                        .none, // 텍스트 필드의 외곽선 없애기
                                                    contentPadding: EdgeInsets
                                                        .zero, // 내부 여백 없애기
                                                    isDense:
                                                        true, // 밀도를 조정하여 텍스트 필드의 높이 조정
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.7,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 25),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '비밀번호',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w600,
                                                  height: 0.10,
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Container(
                                                width: screenWidth - 30,
                                                height: 34,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 2),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: ShapeDecoration(
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            23),
                                                  ),
                                                  shadows: [
                                                    BoxShadow(
                                                      color: isLoginFailed
                                                          ? const Color(
                                                              0x4CF84C37)
                                                          : const Color(
                                                              0x4C000000),
                                                      blurRadius: 2,
                                                      offset:
                                                          const Offset(0, 0),
                                                      spreadRadius: 0,
                                                    )
                                                  ],
                                                ),
                                                child: TextField(
                                                  cursorColor:
                                                      const Color(0xFFF1614F),
                                                  obscureText: true,
                                                  onChanged: (value) {
                                                    password =
                                                        value; // 사용자가 입력한 값을 저장
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: '비밀번호 입력',
                                                    border: InputBorder
                                                        .none, // 텍스트 필드의 외곽선 없애기
                                                    contentPadding: EdgeInsets
                                                        .zero, // 내부 여백 없애기
                                                    isDense:
                                                        true, // 밀도를 조정하여 텍스트 필드의 높이 조정
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.7,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 25),
                                          if (isLoginFailed)
                                            const Center(
                                              child: Text(
                                                '이메일 또는 비밀번호를 다시 확인해주세요. ',
                                                style: TextStyle(
                                                  color: Color(0xFFF74C37),
                                                  fontSize: 10,
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w400,
                                                  height: 0.30,
                                                ),
                                              ),
                                            )
                                          else if (isLoading)
                                            const Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                          const SizedBox(height: 25),
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: screenWidth / 3.2,
                                                  height: 34,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 2),
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color:
                                                        const Color(0xFFFFE8BE),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              23),
                                                    ),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      if (isLoading == false)
                                                        Navigator.of(context)
                                                            .pop();
                                                    },
                                                    child: const Text(
                                                      '취소',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontFamily:
                                                            'SF Pro Text',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 0.08,
                                                        letterSpacing: -0.41,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Container(
                                                  width: screenWidth / 3.2,
                                                  height: 34,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 2),
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color:
                                                        const Color(0xFFFFE8BE),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              23),
                                                    ),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      isLoginFailed = false;
                                                      if (isLoading == false)
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                      // 제공된 자격 증명으로 사용자 인증을 시도합니다.
                                                      bool isAuthenticated =
                                                          await authenticateUser(
                                                              email, password);

                                                      if (isAuthenticated) {
                                                        // 인증이 성공하면, 사용자 삭제 및 로그아웃을 진행합니다.
                                                        DeleteUser(
                                                            email, password);
                                                        DocumentReference
                                                            docRef = firestore
                                                                .collection(
                                                                    'users')
                                                                .doc(viewModel
                                                                    .userUID
                                                                    .toString());

                                                        if ((await docRef
                                                                    .get())[
                                                                'isInFamily'] ==
                                                            false) {
                                                          DocumentReference
                                                              familyData =
                                                              firestore
                                                                  .collection(
                                                                      'families')
                                                                  .doc(viewModel
                                                                      .familyInviteCode
                                                                      .toString());
                                                          await familyData
                                                              .delete();
                                                        } else if ((await docRef
                                                                    .get())[
                                                                'isInFamily'] ==
                                                            true) {
                                                          DocumentReference
                                                              familyData =
                                                              firestore
                                                                  .collection(
                                                                      'families')
                                                                  .doc(viewModel
                                                                      .familyInviteCode
                                                                      .toString());

                                                          await familyData
                                                              .update({
                                                            'members': FieldValue
                                                                .arrayRemove(
                                                                    [userUID])
                                                          });
                                                        }

                                                        await docRef.delete();

                                                        _handleLogout();
                                                        print("로그아웃!");

                                                        Navigator.of(context)
                                                            .pop(); // 현재 다이얼로그를 닫습니다.
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        SignInView()));
                                                      } else {
                                                        // 인증에 실패한 경우, 즉시 UI를 업데이트하여 오류 메시지를 표시합니다.
                                                        // 초기 setState 호출을 대체하는 부분입니다.
                                                        if (mounted) {
                                                          setState(() {
                                                            isLoginFailed =
                                                                true; // 인증 실패 메시지를 표시합니다.
                                                            // isLoading = false; // 필요한 경우 로딩 상태를 관리합니다.
                                                          });
                                                        }
                                                      }
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    },
                                                    child: const Text(
                                                      '삭제',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFFF74C37),
                                                        fontSize: 17,
                                                        fontFamily:
                                                            'SF Pro Text',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        height: 0.08,
                                                        letterSpacing: -0.41,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      width: screenWidth / 2.25,
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      child: SizedBox(
                                        width: 128,
                                        child: Text(
                                          '회원탈퇴',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFFF66F70),
                                            fontSize: 17,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w500,
                                            height: 0.10,
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> DeleteUser(String email, String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);

    if (user != null) {
      try {
        // 사용자 재인증
        await user.reauthenticateWithCredential(credential);
        // 재인증 후 사용자 계정 삭제 로직
        await user.delete();
        print("User account deleted successfully");
        // 사용자 로그아웃 및 로컬 상태 업데이트 로직
      } catch (error) {
        print("Error re-authenticating user: $error");
      }
    }
  }

  Future<bool> authenticateUser(String email, String password) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      // Firebase에 로그인 시도
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // 로그인 성공 시 true 반환
      return true;
    } catch (error) {
      // 에러 발생 시 false 반환
      print(error.toString());

      return false;
    }
  }
}

void _copyTextToClipboard(String text, ViewModel viewModel) {
  Clipboard.setData(ClipboardData(text: viewModel.familyInviteCode.toString()));
}

void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    await launch(url);
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
