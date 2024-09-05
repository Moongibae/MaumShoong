import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'RetrospectiveDetailCheck.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maumshoong/ViewModel.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/services.dart';

class RetrospectiveJournal extends StatefulWidget {
  @override
  _RetrospectiveJournalState createState() => _RetrospectiveJournalState();
}

class _RetrospectiveJournalState extends State<RetrospectiveJournal>
    with TickerProviderStateMixin {
  List datesList = [];
  bool isLoading = false;
  ViewModel viewModel = ViewModel();
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
    await viewModel.initUserData(); // 이 호출이 비동기적으로 완료될 때까지 기다립니다.
    if (viewModel.familyInviteCode != null) {
      datesList = await fetchAllDatesFromRetrospective();
    } else {
      print('familyInviteCode is null');
    }
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
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    '우리가족의 마음 표현 회고일지',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 0.07,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              SingleChildScrollView(
                child: Container(
                  width: screenWidth - 30,
                  height:
                      datesList.isNotEmpty ? datesList.length * 80 + 100 : 200,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
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
                      for (var i = 0; i < datesList.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RetrospectiveDetailCheck(
                                    Date: datesList[i],
                                  ),
                                ),
                              );
                              HapticFeedback.lightImpact();
                            },
                            child: Stack(
                              children: [
                                Container(
                                  height: 66,
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
                                        color: Color(0x4C000000),
                                        blurRadius: 2,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      datesList[i],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w400,
                                        height: 3.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (datesList.isEmpty)
                        Column(children: [
                          SvgPicture.asset("assets/images/EmptyHeart.svg"),
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
                        ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100)
            ],
          ),
        ),
      );
    }
  }

  Future<List<String>> fetchAllDatesFromRetrospective() async {
    if (viewModel.familyInviteCode == null) {
      print("Error: Invite Code not available.");
      return [];
    }

    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference retrospectiveRef = db
        .collection("families")
        .doc(viewModel.familyInviteCode)
        .collection("Retrospective");
    List<String> categories = ["Need", "Like", "Hate"];
    Set<String> datesSet = {};

    DateFormat dateFormatter = DateFormat("yyyy년 MM월");
    DateTime start = dateFormatter.parse("2024년 02월");
    DateTime now = DateTime.now();
    List<String> allDates = [];

    // '2024년 02월'부터 현재까지 모든 날짜를 생성
    while (start.isBefore(now)) {
      allDates.add(dateFormatter.format(start));
      start = DateTime(start.year, start.month + 1);
    }

    // 생성된 모든 날짜에 대해 각 카테고리가 존재하는지 확인
    for (String date in allDates) {
      bool dateExists = false;

      for (String category in categories) {
        try {
          // 각 날짜의 카테고리 컬렉션에 문서가 존재하는지 확인
          QuerySnapshot snapshot =
              await retrospectiveRef.doc(date).collection(category).get();
          if (snapshot.docs.isNotEmpty) {
            dateExists = true;
            break; // 하나라도 문서가 있다면, 그 날짜는 유효함
          }
        } catch (e) {
          print("Error fetching documents from $category for $date: $e");
        }
      }

      if (dateExists) {
        // 해당 날짜에 어떤 카테고리라도 문서가 존재하면, 날짜를 집합에 추가
        datesSet.add(date);
      }
    }
    print(datesSet.toList()..sort());
    return datesSet.toList()..sort();
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
