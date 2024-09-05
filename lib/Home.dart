import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'package:intl/intl.dart' as intl;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'WishList/WishListView.dart';
import 'Post/Posting.dart';
import 'MailBoxView.dart';
import 'Retrospect/RetrospectiveCheck.dart';
import 'ViewModel.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int HeartCount = 0;
  final whiteYellow = const Color(0xFFFFE8C0);
  final ViewModel viewModel = ViewModel();
  Map<String, int> UserData = {};
  Map<String, int> familyMembers = {};
  Map<String, int> Members = {};
  String selectedMember = "";
  String DailyMessage = "";
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  bool canSendMSG = true;
  bool readAlarm = false;
  bool retrospect = true;
  bool isInfamily = false;
  double ProgressState = 0.0;
  late Map<String, WishListItem> WishList = {};
  String selectedLoadingMessage = "";

  @override
  void initState() {
    super.initState();
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

  MSGReadAlarm() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("families")
        .doc(viewModel.familyInviteCode)
        .collection('Messages')
        .doc(viewModel.userData!['userId'])
        .collection('messages')
        .get();
    if (snapshot.docs.isNotEmpty) {
      for (final DocumentSnapshot doc in snapshot.docs) {
        if (doc['read'] == false) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> initializeData() async {
    try {
      selectedLoadingMessage =
          dailyMessages[Random().nextInt(dailyMessages.length)];
      print("가족 멤버: ${viewModel.getFamilyMembers().toString()}");
      await viewModel.initUserData();
      await Future.delayed(const Duration(seconds: 2)); // 네트워크 호출을 가정한 지연
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      familyMembers[viewModel.userData!['userId']] =
          viewModel.userData!['profile'];
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      Members = await viewModel.getFamilyData()!;
      isInfamily = viewModel.userData!['isInFamily'];
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      Members.remove(viewModel.userData!['userId']);
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      familyMembers.addAll(Members);
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      UserData = viewModel.getUserData()!;
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      print('테스트디버깅: ${viewModel.getFamilyRoles.toString()}');
      await RefreshdailyMessage();
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      String? dailyMessage = await getDailyMessage();
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      DailyMessage = dailyMessage ?? "";
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      selectedMember = familyMembers.keys.first;
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      WishList = await viewModel.GetFamilyWishList(); // 인자가 필요한 경우 수정 필요
      print("위시리스트: ${WishList}");
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      await checkAndUpdateHeartCount();
      HeartCount = await getHeartCount();
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      readAlarm = await MSGReadAlarm();
      setState(() {
        ProgressState += 0.07692307692;
        print(ProgressState);
      });
      print(readAlarm);
      retrospect = await viewModel.RetrospectAlarm();
      print(retrospect);
    } catch (e) {
      print(e);
    }
  }

  RefreshdailyMessage() async {
    DocumentSnapshot familydata = await firestore
        .collection('families')
        .doc(viewModel.familyInviteCode)
        .get();

    // 문서가 존재하는지 확인
    if (!familydata.exists) {
      // 문서가 존재하지 않을 경우, 새 문서를 생성
      await firestore
          .collection('families')
          .doc(viewModel.familyInviteCode)
          .set({
        "dailyMessage": dailyMessages[Random().nextInt(dailyMessages.length)],
        "lastDailyMessageUpdate": DateTime.now().toString().substring(0, 10),
      });
    } else {
      final data = familydata.data() as Map<String, dynamic>? ?? {};
      final lastUpdate = data['lastDailyMessageUpdate'];
      if (lastUpdate == null ||
          lastUpdate != DateTime.now().toString().substring(0, 10)) {
        await firestore
            .collection('families')
            .doc(viewModel.familyInviteCode)
            .update({
          "dailyMessage": dailyMessages[Random().nextInt(dailyMessages.length)]
        });
      }
    }
  }

  getDailyMessage() async {
    RefreshdailyMessage();
    DocumentSnapshot familydata = await firestore
        .collection('families')
        .doc(viewModel.familyInviteCode)
        .get();

    // 문서의 존재 여부를 확인합니다.
    if (familydata.exists) {
      // 문서 데이터를 Map<String, dynamic>으로 캐스팅합니다.
      Map<String, dynamic> data =
          familydata.data() as Map<String, dynamic>? ?? {};

      // 이제 '[]' 연산자를 사용하여 필드에 안전하게 접근할 수 있습니다.
      var dailyMessage = data['dailyMessage'];
      if (dailyMessage != null) {
        // 'dailyMessage' 필드 값이 존재하면 출력합니다.
        print(dailyMessage);
        return dailyMessage;
      } else {
        // 'dailyMessage' 필드 값이 null인 경우, 적절한 처리를 수행합니다.
        print("dailyMessage 필드 값이 존재하지 않습니다.");
      }
    } else {
      // 문서가 존재하지 않는 경우, 적절한 처리를 수행합니다.
      print("${viewModel.familyInviteCode}에 해당하는 문서가 존재하지 않습니다.");
    }
  }

  Future<int> getHeartCount() async {
    DocumentSnapshot familydata = await firestore
        .collection('families')
        .doc(viewModel.familyInviteCode)
        .get();

    if (familydata.exists) {
      Map<String, dynamic> data =
          familydata.data() as Map<String, dynamic>? ?? {};
      if (data.containsKey('heartCount')) {
        var getHeartCount = data['heartCount'];
        if (getHeartCount != null) {
          print(getHeartCount);
          return getHeartCount;
        }
      }
      print("HeartCount field does not exist.");
    } else {
      print("${viewModel.familyInviteCode} document does not exist.");
    }
    return 0;
  }

  Future<void> checkAndUpdateHeartCount() async {
    DocumentSnapshot familyData = await firestore
        .collection('families')
        .doc(viewModel.familyInviteCode)
        .get();

    if (familyData.exists) {
      Map<String, dynamic> data =
          familyData.data() as Map<String, dynamic>? ?? {};
      String? lastUpdateStr = data['lastDailyMessageUpdate'];
      int heartCount = data['heartCount'] ?? 0;

      if (lastUpdateStr != null) {
        DateTime lastUpdate = DateTime.parse(lastUpdateStr);
        DateTime today = DateTime.now();

        // 날짜 차이를 계산
        int daysDifference = today.difference(lastUpdate).inDays;

        if (daysDifference >= 2) {
          // 접속하지 않은 날만큼 하트를 감소시킴
          int newHeartCount = max(0, heartCount - daysDifference);
          await firestore
              .collection('families')
              .doc(viewModel.familyInviteCode)
              .update({
            'heartCount': newHeartCount,
            'lastDailyMessageUpdate': today.toString().substring(0, 10),
          });
          setState(() {
            HeartCount = newHeartCount;
          });
        } else {
          // lastDailyMessageUpdate 필드를 업데이트하여 오늘 날짜로 설정
          await firestore
              .collection('families')
              .doc(viewModel.familyInviteCode)
              .update({
            'lastDailyMessageUpdate': today.toString().substring(0, 10),
          });
        }
      } else {
        // lastDailyMessageUpdate 필드가 없는 경우 오늘 날짜로 설정
        await firestore
            .collection('families')
            .doc(viewModel.familyInviteCode)
            .update({
          'lastDailyMessageUpdate': DateTime.now().toString().substring(0, 10),
        });
      }
    }
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

  double getTextWidth(String text, double fontSize) {
    final textStyle = TextStyle(fontSize: fontSize);
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width + 41;
  }

  Widget chooseHeartWidget() {
    if (HeartCount <= 5) {
      return SvgPicture.asset("assets/images/heart1.svg");
    } else if (HeartCount <= 10) {
      return SvgPicture.asset("assets/images/heart2.svg");
    } else if (HeartCount <= 20) {
      return SvgPicture.asset("assets/images/heart3.svg");
    } else if (HeartCount <= 30) {
      return SvgPicture.asset("assets/images/heart4.svg");
    } else if (HeartCount <= 50) {
      return SvgPicture.asset("assets/images/heart5.svg");
    } else {
      return SvgPicture.asset("assets/images/heart5.svg");
    }
  }

  Future<bool> CanSendMSG(String selectFamilyName) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DateTime today = DateTime.now();
    intl.DateFormat dateFormatter = intl.DateFormat('yyyy-MM-dd');
    String todayString = dateFormatter.format(today);

    try {
      print("Flutter 선택 가족: $selectFamilyName");
      String documentsPath =
          "families/${viewModel.familyInviteCode}/Messages/$selectFamilyName/messages";

      QuerySnapshot querySnapshot = await db.collection(documentsPath).get();
      bool documentFound = false;
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        String? senderNickname = document.get("sender");
        if (senderNickname == viewModel.userData!['userId']) {
          Timestamp timestamp = document.get("timestamp");
          DateTime date = timestamp.toDate();
          String documentDateString = dateFormatter.format(date);

          if (documentDateString == todayString) {
            documentFound = true;
            break;
          }
        }
      }
      return documentFound;
    } catch (error) {
      print("Error fetching invite code or nickname: $error");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
      body: Stack(
        children: [
          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RetrospectiveCheck()),
                                    );
                                    HapticFeedback.lightImpact();
                                  },
                                  child: SvgPicture.asset(retrospect
                                      ? "assets/images/Remind.svg"
                                      : "assets/images/Remind_Notification.svg"),
                                ),
                                const Spacer(),
                                Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            255, 250, 240, 1),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 0,
                                            blurRadius: 1,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      width: getTextWidth(
                                          HeartCount.toString(), 15),
                                      height: 25,
                                    ),
                                    Positioned.fill(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              'assets/images/heart.svg'),
                                          const SizedBox(width: 5),
                                          Text(
                                            HeartCount.toString(),
                                            style: const TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MailBoxView()),
                                    );
                                    HapticFeedback.lightImpact();
                                  },
                                  child: SvgPicture.asset(readAlarm
                                      ? "assets/images/Stroke_Notification.svg"
                                      : "assets/images/Stroke.svg"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    DailyMessage,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                chooseHeartWidget(),
                              ],
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
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
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: screenWidth - 20,
                                      height: 100,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 15),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFFFE8BE),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(37),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children:
                                          familyMembers.entries.map((entry) {
                                        return GestureDetector(
                                          onTap: () async {
                                            HapticFeedback.lightImpact();
                                            setState(() {
                                              selectedMember = entry.key;
                                            });
                                            selectedMember = entry.key;
                                            await CanSendMSG(selectedMember);
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AnimatedScale(
                                                scale:
                                                    selectedMember == entry.key
                                                        ? 1.17
                                                        : 1,
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                child: Container(
                                                  width: 55,
                                                  height: 55,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: selectedMember ==
                                                              entry.key
                                                          ? const Color(
                                                              0xFFF66F70)
                                                          : Colors.white,
                                                      width: 1.5,
                                                    ),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x29000000),
                                                        blurRadius: 8,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  margin:
                                                      const EdgeInsets.all(15),
                                                  child: _buildProfileImage(
                                                      entry.value),
                                                ),
                                              ),
                                              Transform.translate(
                                                offset: const Offset(0, -9),
                                                child: Text(
                                                  entry.key,
                                                  style: const TextStyle(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: screenHeight - 400,
                                  child: SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "$selectedMember의 위시리스트",
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(children: [
                                          Center(
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: screenWidth - 30,
                                                  height: WishList[
                                                              selectedMember] ==
                                                          null
                                                      ? 300
                                                      : null,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 25,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            23),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x4C000000),
                                                        blurRadius: 2,
                                                        offset: Offset(0, 0),
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: selectedMember !=
                                                              null &&
                                                          WishList[
                                                                  selectedMember] ==
                                                              null
                                                      ? Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Center(
                                                              child: SvgPicture
                                                                  .asset(
                                                                      "assets/images/EmptyHeart.svg"),
                                                            ),
                                                            const SizedBox(
                                                                height: 15),
                                                            const Center(
                                                                child: Text(
                                                              '등록된 Wish List가 없어요\n지금 가족에게 듣고 싶은 말들을 등록해 보세요!',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Pretendard',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            )),
                                                          ],
                                                        )
                                                      : Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children:
                                                              List.generate(
                                                            WishList[selectedMember]
                                                                    ?.message
                                                                    .length ??
                                                                0,
                                                            (index) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            7),
                                                                child:
                                                                    Container(
                                                                  width:
                                                                      screenWidth -
                                                                          60,
                                                                  height: 62,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          25,
                                                                      vertical:
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            23),
                                                                    boxShadow: const [
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
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const SizedBox(
                                                                          width:
                                                                              5),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          WishList[selectedMember]!
                                                                              .message[index],
                                                                          style:
                                                                              const TextStyle(fontSize: 17),
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
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
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 150),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.95),
                  child: FutureBuilder<bool>(
                    future: CanSendMSG(selectedMember),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == true) {
                        return Container();
                      }
                      return Container(
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
                            if (selectedMember.isEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WishListView()),
                              );
                            } else if (selectedMember ==
                                familyMembers.keys.first) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WishListView()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Posting(
                                        selectedMember: selectedMember)),
                              );
                            }
                            HapticFeedback.mediumImpact();
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
                          child: Text.rich(
                            familyMembers.isEmpty
                                ? const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '마음표현 ',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '보내기',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  )
                                : selectedMember == familyMembers.keys.first
                                    ? const TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '마음표현 ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '등록하기',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '마음표현 ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '보내기',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Row(children: [
                    const Spacer(),
                    if (readAlarm) SvgPicture.asset('assets/images/arrive.svg'),
                  ]),
                ),
              ],
            ),
          ),
          if (isInfamily == false)
            GestureDetector(
              onTap: () {
                setState(() {
                  isInfamily = !isInfamily;
                });
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  const Center(
                    child: Text(
                      '탭해서 홈화면으로 가기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        height: 0.10,
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Center(
                        child: Padding(
                            padding: EdgeInsets.only(top: screenHeight / 1.3),
                            child: SvgPicture.asset(
                                'assets/images/FamilyLinkRecommendation.svg')),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
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
    );
  }
}
