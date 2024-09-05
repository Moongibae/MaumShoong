import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'WishListComplete.dart';
import 'package:maumshoong/ViewModel.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

void main() => runApp(MaterialApp(home: WishListView()));

class WishListView extends StatefulWidget {
  @override
  _WishListView createState() => _WishListView();
}

class _WishListView extends State<WishListView> with TickerProviderStateMixin {
  final Color whiteYellow = const Color(0xFFFFE8C0);
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _leftTextColor;
  late Animation<Color?> _rightTextColor;
  final int strokeTextLimit = 100;
  String strokeInputText = '';
  final TextEditingController _WishListTextEditingcontroller =
      TextEditingController();
  int _currentLength = 0;
  bool isLoading = false;
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

  List<String> RecommendedMessage_parents_to_parents = [
    "나 챙겨줘서 항상 고마워",
    "사랑해❤️",
    "오늘 너무 고생 많았어",
    "난 늘 당신 편이야",
    "아까는 내가 미안했어",
    "평생 함께 하자",
    "당신과 함께라서 행복해",
    "늘 곁에 있어줘서 고마워",
    "앞으로도 함께 행복한 날들 보내자",
    "오늘도 수고했어",
    "당신이 있어서 너무 든든해",
    "밥은 꼭 챙겨먹으면서 해",
    "함께 더 많은 시간 보내자",
    "오늘 하루 화이팅~",
    "무엇이든 해낼 수 있을거야",
    "당신 덕분에 버틸 수 있었어",
    "당신이 나에게 힘이 돼",
    "너무 걱정하지 말자",
    "당신은 나에게 너무 소중한 존재야",
    "내가 뭐 도울 일 없을까?",
    "당신이 최고야",
    "응원할게!",
    "아까 해준 음식 너무 맛있었어",
    "함께 자주 식사하자",
    "건강 잘 챙겨",
    "맛있는 거 먹으러 가자",
    "앞으로 더 잘 할게",
    "당신을 만난 건 내게 행운이야",
    "당신 역시 잘 할 줄 알았어",
    "당신과 있으면 편안해",
    "다 잘 될 거야",
    "놀러가자",
    "당신 마음가는대로 해도 괜찮아",
    "좋은 추억 만들어가자",
    "당신은 참 멋진 사람이야",
    "산책하러 가자",
    "당신이랑 있으면 기분이 좋아져",
    "항상 나 지지해줘서 고마워",
    "오늘 아주 멋졌어",
    "내가 더 신경 써볼게",
    "나랑 결혼해줘서 고마워",
    "매번 말로 못해서 미안해. 사랑해",
    "애들 잘 키워줘서 고마워",
    "애들 키우느라 많이 힘들지?",
    "돈 버느라 많이 힘들지?",
    "당신 밖에 없어",
    "나랑 결혼해줘서 고마워",
    "많이 힘들텐데, 버텨줘서 고마워",
    "행복하게 살자",
    "내가 더 노력할게",
    "내가 더 잘할게"
  ];

  List<String> RecommendedMessage_childrens_to_childrens = [
    "나 챙겨줘서 고마워",
    "사랑해❤️",
    "오늘 너무 고생 많았어",
    "난 늘 네 편이야",
    "아까는 내가 미안했어",
    "잘 지내고 있지?",
    "사이 좋게 지내자",
    "내가 더 친절하게 말해볼게",
    "화이팅",
    "오늘도 수고했어",
    "밥은 챙겨 먹고 다녀라",
    "괴롭히는 애 있으면 바로 말해",
    "힘든 거 있으면 언제든 말해",
    "너라도 있어서 힘이 나",
    "우리 집에서 마음 편히 이야기 할 수 있는 사람이 있어서 정말 좋아",
    "엄마 아빠보다 너가 더 편해",
    "힘들 때마다 같이 있어줘서 고마워",
    "옆에 있어줘서 고마워",
    "덕분이야",
    "항상 도와줘서 고마워",
    "없었다면 되게 외로웠을 것 같아",
    "마음 털어 놓을 수 있는 사람이 있어서 참 좋아",
    "의도와 다르게 항상 나쁘게만 말하는 것 같아 미안해",
    "도와줄 게 있다면 언제든 말해줘",
    "생각보다 힘들지?",
    "요즘 많이 힘들지?",
    "요즘 고민 없어?",
    "공부 때문에 많이 힘들지?",
    "친구 관계 때문에 많이 힘들지?",
    "그냥 다 얘기해. 들어줄게",
    "나한테 털어놔",
    "힘들면 잠깐 쉬어도 돼",
    "걱정하지마. 다 잘 될거야",
    "도와줄게",
    "하고 싶은거 있어? 같이 해볼까?",
    "여기 같이 놀러가볼래?",
    "너가 내 가족이라 참 다행이야",
    "너가 내 가족이라 참 좋아",
    "우리 싸우지 말자",
    "사이좋게 지내자",
    "맨날 싸우지만, 많이 좋아한다",
    "어색하지만, 사랑해",
    "난 너가 자랑스러워",
    "이렇게 투닥투닥, 그렇게만 계속 같이 살자",
    "걱정하는 일 다 잘될거야",
    "힘든 일 있으면 말해",
    "걱정만 하지 말고 나 불러",
    "뭘 그렇게 고민해. 나한테 얘기해",
    "내가 모를 줄 알았어? 다 털어놔",
    "너밖에 없어"
  ];

  List<String> RecommendedMessage_parents_to_children = [
    "오늘 하루도 화이팅! 언제나 응원하고 있다 ㅎㅎ",
    "수고했어! 오늘도",
    "좀 오글거리지만, 사랑한다 ㅎ",
    "고생 많았어! 하루쯤은 쉬는 날도 있어야지~",
    "누가 뭐라고 해도 열심히 하는 것 자체가 잘하는 것이다~!!",
    "어제 얘기해준 힘든 일, 오늘은 잊고 오늘의 태양을 맞이하자",
    "조금만 더 힘내자, 사랑해",
    "너무 멋있고 장하다!",
    "집에 들어가서 가족들 얼굴 볼 생각하니까 설렌다",
    "헛된 노력은 없으니, 오늘도 잘한 거야",
    "사랑한단 말을 주저 없이 할 수 있길~~ 사랑해!",
    "누가 뭐래도 넌 정말 최고",
    "어디를 가든지, 무엇을 하든지 언제나 함께 있을게.",
    "네가 뭘 해도 항상 네 편이니까 하고 싶은 거 마음껏 하면 좋겠다",
    "네가 세상에 있어서 너무 감사해",
    "가장 어두운 시간은 해 뜨기 직전. 해 뜰 때까지 조금 더 화이팅!",
    "너의 노력을 모두가 믿고 있어. 화이팅!",
    "항상 감사하는 마음으로 살자 ㅎㅎ 사랑해",
    "너무 특별한 사람, 날 행복하게 해 줘서 고마워",
    "사랑하는 우리 가족! 오늘도 다들 열심히 하는 모습이 멋지다!!",
    "넌 정말 특별한 사람이야",
    "너무 걱정하지 말고 그냥 최선을 다하자 :)",
    "사랑해~ 네가 최고야^^",
    "힘들지? 그래도 점점 성장하는 게 보여서 대견하다",
    "네 선택을 항상 존중한다^^",
    "너만의 속도를 존중해",
    "충분히 잘하고 있어 :) 너무 멋지다!",
    "무엇을 하든 너를 믿고 응원해",
    "오~ 역시 최고야!",
    "힘들지 ㅠㅠ 오늘도 수고 많았어",
    "내가 제일 힘들 때 옆에 있어 줘서 고마워",
    "지금도 너무 잘 하고 있어",
    "무슨 결정을 해도 믿어줄게",
    "항상 응원한다!",
    "하루하루 살아가는 것 자체가 너무 빛이 난다.",
    "사랑한다는 말로도 부족할 만큼 사랑한다 ㅎㅎ",
    "기운 넘치는 하루가 되기를 바랄게!",
    "항상 네가 있어서 힘이 돼",
    "행복한 일들 가득한 하루 되길!",
    "선물같이 나에게 와줘서 고마워",
    "있는 그 자체로도 너무너무 사랑해",
    "오늘 하루도 행복한 하루 보내~",
    "어떤 고난이 닥쳐도 꿈을 포기하지 마. 우린 항상 너의 편인 거 알지?",
    "성공할 필요 없어. 있는 그대로 행복해줘. 그거 하나만 바랄게",
    "떨 필요 없어. 이렇게나 너의 편이 많은걸",
    "꿈꾸는 것 모두 잘될 거야. 속도에 무서워할 필요 없단다",
    "너무너무 고생 많았어. 수고했다",
    "꽃길만 있다고 말해줄 순 없지만, 앞서 걸어줄게. 걱정하지 말고 내딛어봐",
    "어려워할 필요 없어, 그저 앞만 보고 시작해 봐. 걸음마도 그렇게 잘 해냈잖아",
    "내겐 너 하나뿐이야. 사랑해~",
    "나에게 찾아와준 순간부터, 내 모든 세상은 너뿐이었어",
    "그렇게 하나, 하나 해 나가면 되는 거야. 무서워할 필요 없어. 내가 있잖아",
    "힘들었지? 일로 와 안아줄게",
    "언제 이렇게 컸어. 눈물 날 정도로 잘 컸네!",
    "천천히 시간을 갖고, 다 해봐. 할 수 있어",
    "있는 그대로 사랑해",
    "대견해",
    "늦은 밤까지 고생이 많아",
    "조금만 더 파이팅 하자! 할 수 있어",
    "괜찮아 다 괜찮아. 그럴 수도 있는 거야",
    "뭐 먹고 싶은 거 있어? 뭐 해줄까?",
    "실수하면 어때? 내가 있잖아",
    "기다리고 있을게. 언제나 찾아오렴",
    "힘들기도 했지만, 네 덕분에 매 순간 행복했어",
    "힘든 하루였지?",
    "좀 쉬어가는 순간도 있는 거야~ 조급해할 필요 없어",
    "그런 날도 있는 거야. 그런 순간도 있는 거야",
    "아무도 어떻게 될지 몰라. 그러니 다 해봐",
    "최고보단 최선을. 최선을 다했다면 그걸로 되었다",
    "정말 잘했어~",
    "항상 사랑한다🧡",
    "넌 지금도 잘하고 있어🙆",
    "오늘도 수고 많았어🤗",
    "괜찮아 다 잘될 거야",
    "태어나줘서 고마워💗",
    "넌 잘할 수 있을 거야!",
    "우리 같이 놀러 가자!",
    "넌 최고의 선물이야",
    "엄마는 너를 믿어",
    "그 정도면 충분해~",
    "푹 쉬어🫶",
    "우리 00이 엄청 멋지더라~",
    "우리 앞으로도 행복하게 지내자~",
    "힘들면 엄마한테 말해도 돼",
    "항상 건강해야 해",
    "항상 웃는 얼굴로 날 반겨줘서 고마워~",
    "많이 힘들 텐데 조금만 더 화이팅 해 보자! ",
    "바빠도 밥은 꼭 챙겨 먹어~",
    "하는 일 다 잘됐으면 좋겠다. 항상 응원할게",
    "오늘 하루도 잘 보내~",
    "누가 뭐래도 엄마는 네 편이야:)",
    "엄마가 항상 사랑하는 거 알지?",
    "힘내!!⊹",
    "너무 무리는 하지 마ㅜㅜ",
    "엄마는 네가 참 기특해",
    "걱정하지 마, 충분히 잘하고 있어",
    "오늘 우리 같이 밥 먹자",
    "말은 못 했는데 아까 좀 멋있었어..ㅋㅋ",
    "같이 맛있는 거 먹자~",
    "요즘 힘들었지? 곧 괜찮아질 거야",
    "엄마가 내 엄마라서 좋아𓈒𓏸 𓂂𓈒 ♡ ",
    "네 맘대로 해도 괜찮아",
    "정말 열심히 했네~",
    "네가 정말 자랑스러워✹",
    "넌 최고야ᰔ",
    "우리 산책하러 가자⋰˚✩",
    "너는 정말 소중해",
    "잘했고, 잘해왔고, 잘할 거야",
    "네가 하고 싶은 대로 해도 돼"
  ];

  List<String> RecommendedMessage_children_to_parents = [
    "오늘 아침에, 잘 다녀오라는 인사 한마디가 큰 힘이 됐어요",
    "오늘도 열심히 노력하는 모습에 저도 힘을 얻어가요",
    "항상 곁에 있어 줘서 고마워요!",
    "밥 잘 챙겨 먹고 다니세요!",
    "가족들의 지지가 항상 힘이 돼요",
    "어디를 가든지, 무엇을 하든지 언제나 함께 있을게요.",
    "존재 자체로 너무 빛이 나는 사람~!! 오늘도 사랑해요.",
    "이야기할 때 너무 편하럼, 힘든일이 있을 때 제가 이야기할 수 있는 사람이 되었으면 좋겠어요",
    "저에게도 기대주세요",
    "OO로 살아주셔서 감사합니다",
    "사랑해요💛",
    "고마워요",
    "해준 음식 너무 맛있었어요😉",
    "내가 항상 사랑하는 거 알지?",
    "저번에 나 도와줘서 고마웠어!",
    "같이 있어서 행복해!",
    "말은 못 했는데 아까 좀 멋있었어..ㅋㅋ",
    "내 부모님이라서 좋아𓈒𓏸 𓂂𓈒 ♡ ",
    "곁에 있어서 든든해",
    "최고!",
    "우리 산책하러 가자⋰˚✩",
    "나 챙겨줘서 항상 고마워"
  ];

  List<String> DisplayRecommendedMessage = [];

  final ViewModel viewModel = ViewModel();

  Widget buildGradientCircularProgressIndicator() {
    return RotationTransition(
      turns: _animationController,
      child: GradientCircularProgressIndicator(
        radius: 50,
        strokeWidth: 10.0,
      ),
    );
  }

  Future<void> initializeData() async {
    print("가족 멤버: ${viewModel.getFamilyMembers()}");
    await viewModel.initUserData();
    viewModel.getMessages();
    Map<String, bool> UserRoles = await viewModel.getFamilyRoles(
        (viewModel.getUserData()?.keys.toList() ?? '')
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', ''));
    setState(() {
      if (UserRoles["Father"] == true ||
          UserRoles["Mother"] == true ||
          UserRoles["Spouse"] == true) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(viewModel.userUID)
            .update({
          'roles': {'parents': true, 'children': false}
        });
      }

      if (UserRoles["BoyBrother"] == true ||
          UserRoles["BoySister"] == true ||
          UserRoles["Daughter"] == true ||
          UserRoles["GirlBrother"] == true ||
          UserRoles["GirlSister"] == true ||
          UserRoles["Son"] == true ||
          UserRoles["YoungerBrother"] == true) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(viewModel.userUID)
            .update({
          'roles': {'parents': false, 'children': true}
        });
      }

      if (UserRoles["children"] == true) {
        DisplayRecommendedMessage.addAll(
            RecommendedMessage_parents_to_children);
      }

      if (UserRoles["parents"] == true) {
        DisplayRecommendedMessage.addAll(
            RecommendedMessage_children_to_parents);
      }
    });
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

    initializeData().then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });

    // 기존 초기화 코드
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    initializeData();

    _controller.addListener(() {
      setState(() {
        _currentLength = _WishListTextEditingcontroller.text.length;
      });
    });

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _WishListTextEditingcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      var appBar = AppBar(
        backgroundColor: whiteYellow,
        leading: IconButton(
          icon: SvgPicture.asset('assets/images/Back.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _WishListTextEditingcontroller.text.isEmpty
                ? null
                : () {
                    viewModel.AddWishList(
                      _WishListTextEditingcontroller.text,
                      viewModel.userData!['userId'],
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WishListComplete(),
                      ),
                    );
                    HapticFeedback.mediumImpact();
                  },
            child: Text(
              '추가할래요',
              style: TextStyle(
                color: _WishListTextEditingcontroller.text.isEmpty
                    ? Colors.grey
                    : Colors.black,
                fontSize: 20,
              ),
            ),
          ),
        ],
      );
      return Scaffold(
        backgroundColor: whiteYellow,
        appBar: appBar,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: screenWidth - 30,
                  height: 160,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 23),
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
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          cursorColor: const Color(0xFFF1614F),
                          controller: _WishListTextEditingcontroller,
                          onChanged: (text) {
                            setState(() {
                              _currentLength = text.length;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: '이 마음 표현 받고 싶어요',
                            hintStyle: TextStyle(
                              color: Color(0xFF8E8E8E),
                              fontSize: 17,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          maxLength: 100,
                          style: const TextStyle(
                            color: Color(0xFF8E8E8E),
                            fontSize: 17,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: null,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          '$_currentLength/100',
                          style: const TextStyle(
                            color: Color(0xFF8E8E8E),
                            fontSize: 15,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        SvgPicture.asset(
                          'assets/images/Suggestion.svg',
                        ),
                        const Spacer(),
                      ],
                    ),
                    if (DisplayRecommendedMessage.isNotEmpty)
                      Expanded(
                        child: Stack(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: DisplayRecommendedMessage.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    bottom: 10,
                                    top:
                                        index == 0 ? 30 : 0, // 첫 번째 메시지에만 추가 간격
                                  ),
                                  child: Container(
                                    width: screenWidth - 40,
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
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(
                                        DisplayRecommendedMessage[index],
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 20, // 그라데이션 높이
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      whiteYellow,
                                      whiteYellow.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (DisplayRecommendedMessage.isEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          SvgPicture.asset("assets/images/EmptyHeart.svg"),
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: screenWidth - 40,
                            child: const Text(
                              '추천 마음표현을 가져올 수 없습니다. 마음우체부에게 문의해주세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
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
