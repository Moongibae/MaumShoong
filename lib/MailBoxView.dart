import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maumshoong/ViewModel.dart';
import 'dart:math' as math;
import 'dart:math';

class MailBoxView extends StatefulWidget {
  @override
  _MailBoxViewState createState() => _MailBoxViewState();
}

class _MailBoxViewState extends State<MailBoxView>
    with TickerProviderStateMixin {
  ViewModel viewModel = ViewModel();
  bool isLoading = false;
  late Future<List<MessageItem>> messagesFuture;
  int currentIndex = 0;
  Map<String, Color> colors = {
    "Pink": const Color(0xFFFFA4C2),
    "Red": const Color(0xFFFF6250),
    "Yellow": const Color(0xFFFFC621),
    "Green": const Color(0xFF00AF7B),
    "Blue": const Color(0xFF4D80BD),
  };
  late PageController controller;
  late AnimationController _animationController;

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
        controller = PageController();
        controller.addListener(() {
          int currentPage = controller.page!.round();
          if (currentPage != currentIndex) {
            currentIndex = currentPage;
            updateReadStatus(currentIndex);
          }
        });
        messagesFuture = getMessages().then((messages) {
          setState(() {
            isLoading = false;
          });
          if (messages.isNotEmpty) {
            updateReadStatus(0);
          }
          print("메시지: ${messages[0].message}");
          return messages;
        });
      }
    });
  }

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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void updateReadStatus(int index) async {
    try {
      List<MessageItem> messages = await getMessages();
      var messageDocRef = FirebaseFirestore.instance
          .collection("families")
          .doc(viewModel.familyInviteCode)
          .collection("Messages")
          .doc(viewModel.userData!['userId'])
          .collection('messages')
          .doc(messages[index].id);

      await messageDocRef.update({"read": true});
    } catch (error) {
      print("Failed to update read status: $error");
    }
  }

  Future<void> toggleHeartStatus(String messageId, String docId) async {
    try {
      var messageDocRef = FirebaseFirestore.instance
          .collection("families")
          .doc(viewModel.familyInviteCode)
          .collection("Messages")
          .doc(viewModel.userData!['userId'])
          .collection('messages')
          .doc(docId);

      var messageSnapshot = await messageDocRef.get();
      if (messageSnapshot.exists) {
        var currentLike = messageSnapshot.get("like");
        await messageDocRef.update({"like": !currentLike});
      }
    } catch (error) {
      print("Failed to update heart status: $error");
    }
  }

  Future<List<MessageItem>> getMessages() async {
    print('메시지 가져오기 ${viewModel.familyInviteCode}');
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("families")
        .doc(viewModel.familyInviteCode)
        .collection("Messages")
        .doc(viewModel.userData!['userId'])
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .get();

    List<MessageItem> messages = [];

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        MessageItem message = MessageItem(
          id: doc.id,
          color: data.containsKey('color') ? data['color'] : "null",
          emoji: data.containsKey('emoji') ? data['emoji'] : "null",
          like: data.containsKey('like') ? data['like'] : "null",
          message: data.containsKey('message') ? data['message'] : "null",
          SelectedWritingPad: data.containsKey('SelectedWritingPad')
              ? data['SelectedWritingPad']
              : "null",
          read: data.containsKey('read') ? data['read'] : false,
          sender: data.containsKey('sender') ? data['sender'] : false,
          timestamp: data.containsKey('timestamp') ? data['timestamp'] : "null",
        );
        messages.add(message);
      }
    }
    return messages;
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
    }

    return Scaffold(
      backgroundColor: whiteYellow,
      appBar: AppBar(
        backgroundColor: whiteYellow,
        leading: IconButton(
          icon: SvgPicture.asset('assets/images/Back.svg'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<MessageItem>>(
        future: messagesFuture,
        builder: (context, snapshot) {
          List<MessageItem> messages = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: buildGradientCircularProgressIndicator(),
            );
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/images/EmptyHeart.svg"),
                  const SizedBox(height: 50),
                  const Text(
                    '아직 받은 메시지 카드가 없어요',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 23,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 0.05,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 380,
                  child: PageView.builder(
                      controller: controller,
                      itemCount: messages.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        MessageItem message = messages[index];
                        if (message.emoji != "null" &&
                            message.message != "null" &&
                            message.sender != "null" &&
                            message.color != "null" &&
                            message.SelectedWritingPad == "null") {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: screenWidth - 30,
                                height: 340,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: colors[message.color],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          message.emoji.toString(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'Pretendard',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'To. ${viewModel.userData!['userId']}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w400,
                                        height: 0.09,
                                      ),
                                    ),
                                    const SizedBox(height: 50),
                                    SvgPicture.asset(
                                        "assets/images/QuotesRight.svg"),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: screenWidth - 100,
                                      child: Text(
                                        message.message.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w500,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    SvgPicture.asset(
                                        "assets/images/QuotesLeft.svg"),
                                    const SizedBox(height: 50),
                                    Text(
                                      'From. ${message.sender}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else if (message.emoji == "null" &&
                            message.message != "null" &&
                            message.sender != "null" &&
                            message.color == "null" &&
                            message.SelectedWritingPad != "null") {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                  width: screenWidth - 30,
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
                                    children: [
                                      Stack(
                                        children: [
                                          Center(
                                            child: SvgPicture.asset(
                                              'assets/images/WritingPad${message.SelectedWritingPad}.svg',
                                              width: screenWidth - 50,
                                              height: 340.0,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 60),
                                              child: Text(
                                                'To. ${viewModel.userData!['userId']}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 140, left: 15),
                                            child: Center(
                                              child: SizedBox(
                                                width: screenWidth - 150,
                                                child: Text(
                                                  message.message,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 300),
                                            child: Center(
                                              child: Text(
                                                "From. ${message.sender}",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w700,
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
                            ],
                          );
                        }
                      }),
                ),
                const SizedBox(height: 20),
                Text(
                  '${currentIndex + 1}/${messages.length}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: messages[currentIndex].read
                        ? const Color(0xFF8E8E8E)
                        : const Color(0xFFF66F70),
                    fontSize: 13,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 0.30,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      messages[currentIndex].like =
                          !messages[currentIndex].like;
                      toggleHeartStatus(
                          messages[currentIndex].id, messages[currentIndex].id);
                    });
                    HapticFeedback.mediumImpact();
                  },
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: messages[currentIndex].like
                          ? SvgPicture.asset("assets/images/Union.fill.svg")
                          : SvgPicture.asset("assets/images/Union.svg"),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
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
