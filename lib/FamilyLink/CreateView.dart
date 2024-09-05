import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maumshoong/ViewModel.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'CreateNewName.dart';
import 'CreateComplete.dart';
import 'dart:math' as math;

class CreateView extends StatefulWidget {
  @override
  _CreateViewState createState() => _CreateViewState();
}

class _CreateViewState extends State<CreateView> with TickerProviderStateMixin {
  bool showFamilyCode = false;
  bool isLoading = false;
  final ViewModel viewModel = ViewModel();
  String familyInviteCode = "";
  String NewFamilyInviteCode = "";
  late bool isInfamily;
  bool _foundnotfamilyinvitecode = false;
  bool _ExcessOfMembers = false;
  bool _MyNickname = false;
  bool _error = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
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
    super.dispose();
  }

  Future<void> initializeData() async {
    print("가족 멤버: ${viewModel.getFamilyMembers().toString()}");
    await viewModel.initUserData();
    isInfamily = viewModel.userData!['isInFamily'] ?? false;
    print(isInfamily);
    familyInviteCode = viewModel.familyInviteCode!;
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
    const Color whiteYellow = Color(0xFFFFE8C0);
    double screenWidth = MediaQuery.of(context).size.width;
    final TextTemplate ShareText = TextTemplate(
      text:
          '카카오톡 공유는 카카오 플랫폼 서비스의 대표 기능으로써 사용자의 모바일 기기에 설치된 카카오 플랫폼과 연동하여 다양한 기능을 실행할 수 있습니다.\n현재 이용할 수 있는 카카오톡 공유는 다음과 같습니다.\n카카오톡링크\n카카오톡을 실행하여 사용자가 선택한 채팅방으로 메시지를 전송합니다.',
      link: Link(
        webUrl: Uri.parse('https: //developers.kakao.com'),
        mobileWebUrl: Uri.parse('https: //developers.kakao.com'),
      ),
    );

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
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: whiteYellow,
          appBar: AppBar(
            title: const Text('가족 연결'),
            backgroundColor: whiteYellow,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '어떻게 오셨나요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      height: 0.03,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SvgPicture.asset("assets/images/SmileHeart.svg"),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: () async {
                      try {
                        bool isKakaoInstalled = await isKakaoTalkInstalled();
                        if (isKakaoInstalled) {
                          // 메시지 템플릿 설정
                          final defaultText = TextTemplate(
                            text:
                                "저랑 마음슝으로 가족 공유해요! 가족 초대 코드: $familyInviteCode",
                            link: Link(), // 텍스트만 전송하므로 빈 링크 객체 사용
                          );

                          // 카카오톡을 통해 메시지 전송
                          Uri uri = await ShareClient.instance
                              .shareDefault(template: defaultText);
                          await ShareClient.instance.launchKakaoTalk(uri);
                          print('카카오톡 공유 완료');
                        } else {
                          Clipboard.setData(ClipboardData(
                              text: viewModel.familyInviteCode.toString()));
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(23),
                                ),
                                child: Container(
                                  width: screenWidth - 10,
                                  height: 150,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 23),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(23),
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
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Center(
                                        child: Text(
                                          '가족코드가 복사되었습니다!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontFamily: 'SF Pro Text',
                                            fontWeight: FontWeight.w600,
                                            height: 0.06,
                                            letterSpacing: -0.41,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 25),
                                      const Center(
                                        child: SizedBox(
                                          width: 238,
                                          child: Text(
                                            '초대하고 싶은 가족에게 보내주세요',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontFamily: 'SF Pro Text',
                                              fontWeight: FontWeight.w400,
                                              height: 0.08,
                                              letterSpacing: -0.08,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          width: screenWidth - 50,
                                          height: 34,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFFE8BE),
                                            borderRadius:
                                                BorderRadius.circular(23),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              '확인했어요',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color(0xFFF74C37),
                                                fontSize: 17,
                                                fontFamily: 'SF Pro Text',
                                                fontWeight: FontWeight.w600,
                                                height: 0.08,
                                                letterSpacing: -0.41,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                          print("KakaoTalk is not installed.");
                        }
                      } catch (e) {
                        print('Error: $e');
                      }
                    },
                    child: Container(
                      width: 220,
                      height: 45,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '제가 ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    height: 0.05,
                                  ),
                                ),
                                TextSpan(
                                  text: '처음',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w700,
                                    height: 0.05,
                                  ),
                                ),
                                TextSpan(
                                  text: ' 왔어요',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    height: 0.05,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isInfamily == false)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showFamilyCode = true;
                        });
                      },
                      child: Container(
                        width: 270,
                        height: 45,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
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
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '가족의 초대',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w700,
                                      height: 0.05,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '로 왔어요',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w500,
                                      height: 0.05,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 50),
                  if (showFamilyCode && isInfamily == false)
                    Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 25.0),
                          child: const Text(
                            '가족코드 입력',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              height: 0.10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Row(
                            children: [
                              Container(
                                width: screenWidth / 1.5,
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 0),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        cursorColor: const Color(0xFFF1614F),
                                        onChanged: (value) {
                                          NewFamilyInviteCode =
                                              value; // 사용자가 입력한 값을 저장
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '가족코드 입력',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 17,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w600,
                                            height: 0.0,
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    _MyNickname = false;
                                    _foundnotfamilyinvitecode = false;
                                    _ExcessOfMembers = false;
                                    _error = false;
                                    print('버튼 누름');
                                    bool? foundfamilycode =
                                        await SearchFamilyCode(
                                            NewFamilyInviteCode);
                                    print("0");
                                    print(foundfamilycode);
                                    if (foundfamilycode == true) {
                                      print("1");
                                      bool? foundnickname =
                                          await NicknameDuplicate(
                                              NewFamilyInviteCode);
                                      print('중복 닉네임 $foundnickname');
                                      print("2");

                                      List<String> familyMembers =
                                          await getNewFamilyMembers(
                                              NewFamilyInviteCode);
                                      print("3");
                                      if (viewModel.familyInviteCode ==
                                          NewFamilyInviteCode) {
                                        setState(() {
                                          _MyNickname = true;
                                        });
                                        print("4");
                                      } else if (familyMembers.length >= 4) {
                                        print("5");

                                        setState(() {
                                          _ExcessOfMembers = true;
                                        });
                                        print("6");
                                      } else if (foundnickname == true) {
                                        print('닉네임 중복 확인');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CreateNewName(
                                              familyCode: NewFamilyInviteCode,
                                            ),
                                          ),
                                        );
                                      } else if (foundnickname == false) {
                                        print('코드 중복 안됨');
                                        setState(() {
                                          isLoading = true;
                                        });
                                        print("7");

                                        await firestore
                                            .collection('users')
                                            .doc(viewModel.userUID)
                                            .update({
                                          'inviteCode': NewFamilyInviteCode
                                        });
                                        print("8");
                                        await firestore
                                            .collection('families')
                                            .doc(NewFamilyInviteCode)
                                            .update({
                                          'members': FieldValue.arrayUnion([
                                            FirebaseAuth
                                                .instance.currentUser?.uid
                                          ])
                                        });
                                        print("9");
                                        DocumentSnapshot familyDoc =
                                            await firestore
                                                .collection('families')
                                                .doc(NewFamilyInviteCode)
                                                .get();
                                        print("10");
                                        List<String> memberUids =
                                            List<String>.from(
                                                familyDoc['members']);
                                        print("11");
                                        for (String uid in memberUids) {
                                          await firestore
                                              .collection('users')
                                              .doc(uid)
                                              .update({'isInFamily': true});
                                        }
                                        print("12");
                                        setState(() {
                                          isLoading = false;
                                        });
                                        print("13");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CreateComplete(),
                                          ),
                                        );
                                      } else {
                                        setState(() {
                                          print("14");
                                          _error = true;
                                        });
                                        print('알 수 없는 오류가 발생했습니다.');
                                      }
                                    } else {
                                      print("15");
                                      setState(() {
                                        _foundnotfamilyinvitecode = true;
                                      });
                                      print('16');
                                    }
                                  } catch (e) {
                                    print('Error: $e');
                                  }
                                },
                                child: Container(
                                  width: screenWidth / 5,
                                  height: 50,
                                  padding: const EdgeInsets.all(10),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
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
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '입력완료',
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
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        if (_foundnotfamilyinvitecode == true)
                          SizedBox(
                            width: screenWidth - 100,
                            child: const Text(
                              '입력하신 코드를 찾을 수 없습니다. 코드를 다시 확인해주세요.',
                              style: TextStyle(
                                color: Color(0xFFF74C37),
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (_MyNickname == true)
                          SizedBox(
                            width: screenWidth - 100,
                            child: const Text(
                              '자신의 초대코드는 입력할 수 없습니다. 다른 코드를 입력해주세요.',
                              style: TextStyle(
                                color: Color(0xFFF74C37),
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (_ExcessOfMembers)
                          SizedBox(
                            width: screenWidth - 100,
                            child: const Text(
                              '가족 가입은 4명 이하만 할 수 있습니다.',
                              style: TextStyle(
                                color: Color(0xFFF74C37),
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (_error)
                          SizedBox(
                            width: screenWidth - 100,
                            child: const Text(
                              '알 수 없는 오류가 발생했습니다. 개발자에게 문의해주세요.',
                              style: TextStyle(
                                color: Color(0xFFF74C37),
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  bool searchInviteCode(List<String> families) {
    if (families.contains('인바이트코드')) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool?> SearchFamilyCode(String inviteCode) async {
    try {
      DocumentSnapshot familyDoc = await FirebaseFirestore.instance
          .collection('families')
          .doc(inviteCode)
          .get();

      if (familyDoc.exists) {
        print('Family code found');
        return true;
      } else {
        print('Family code not found');
        return false;
      }
    } catch (e) {
      print('Error searching family code: $e');
      return false;
    }
  }

  Future<bool?> NicknameDuplicate(NewFamilyInviteCode) async {
    try {
      List familymembers = await getNewFamilyMembers(NewFamilyInviteCode);
      List MemberName = [];

      print('새가족 구성원: $familymembers');
      String UserNickname = viewModel.userData!['userId'];
      for (String member in familymembers) {
        DocumentSnapshot? familyData =
            await firestore.collection('users').doc(member).get();
        MemberName.add(familyData['userId']);
      }

      print(MemberName);

      for (String member in MemberName) {
        print(member);
        if (UserNickname == member) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error updating family code: $e');
      return false;
    }
  }

  Future<List<String>> getNewFamilyMembers(NewFamilyInviteCode) async {
    if (NewFamilyInviteCode != null) {
      DocumentSnapshot familyData =
          await firestore.collection('families').doc(NewFamilyInviteCode).get();
      List<String> members = List<String>.from(familyData['members']);
      return members;
    }
    return [];
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
