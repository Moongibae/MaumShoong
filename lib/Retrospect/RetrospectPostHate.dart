import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'RetrospectPostNeed.dart';
import 'package:maumshoong/ViewModel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class RetrospectPostHate extends StatefulWidget {
  final String from;
  final String situation;
  final String when;
  final String feeling;
  final List<MessageItem> messages;
  final List<MessageItem> LikeMessages;
  final List<String> dropdownList;

  RetrospectPostHate(
      {Key? key,
      required this.from,
      required this.situation,
      required this.when,
      required this.feeling,
      required this.messages,
      required this.LikeMessages,
      required this.dropdownList});

  @override
  _RetrospectPostHate createState() => _RetrospectPostHate();
}

class _RetrospectPostHate extends State<RetrospectPostHate>
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
  final TextEditingController _controllerNext = TextEditingController();
  String selectedDropdown = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    selectedDropdown = widget.dropdownList[0];

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
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    _pageControllerLike.dispose();
    super.dispose();
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
                    _controllerFeeling.text.isEmpty ||
                    _controllerNext.text.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RetrospectPostNeed(
                                Like_from: widget.from,
                                Like_situation: widget.situation,
                                Like_when: widget.when,
                                Like_feeling: widget.feeling,
                                messages: widget.messages,
                                LikeMessages: widget.LikeMessages,
                                Hate_from: selectedDropdown,
                                Hate_situation: _controllerSituation.text,
                                Hate_when: _controllerWhen.text,
                                Hate_feeling: _controllerFeeling.text,
                                Hate_next: _controllerNext.text,
                                dropdownList: widget.dropdownList,
                              )),
                    );
                    HapticFeedback.mediumImpact();
                  },
            child: Text(
              '다음',
              style: TextStyle(
                color: _controllerSituation.text.isEmpty ||
                        _controllerWhen.text.isEmpty ||
                        _controllerFeeling.text.isEmpty ||
                        _controllerNext.text.isEmpty
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
                            // 첫 번째 원
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white, // 나머지 페이지일 때 흰색
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
                                      color: Color(0xFFBABABA), // 현재 페이지일 때 흰색
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
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF66F70), // 나머지 페이지일 때 흰색
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
                                      color: Colors.white, // 나머지 페이지일 때 검은색
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
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white, // 나머지 페이지일 때 흰색
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
                                      color:
                                          Color(0xFFBABABA), // 나머지 페이지일 때 검은색
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
                        '한 달 동안 받았던 마음 표현 중 \n가장 아쉬웠던 것은?',
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
                        if (widget.LikeMessages.isNotEmpty)
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
                                        widget.LikeMessages.length,
                                        (index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30, vertical: 10),
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
                                                  if (widget.LikeMessages[index]
                                                      .emoji.isNotEmpty) ...[
                                                    Container(
                                                      width: 42,
                                                      height: 42,
                                                      decoration: BoxDecoration(
                                                        color: colors[widget
                                                            .LikeMessages[index]
                                                            .color],
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          widget
                                                              .LikeMessages[
                                                                  index]
                                                              .emoji,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Pretendard',
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 15),
                                                  ],
                                                  Expanded(
                                                    child: Text(
                                                      widget.LikeMessages[index]
                                                          .message,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                      maxLines: 2,
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
                                ),
                                Text(
                                    '${_currentPageWishList + 1}/${widget.LikeMessages.length}'),
                              ],
                            ),
                          ),
                      if (widget.LikeMessages.isEmpty && isSwitch == false)
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
                        if (widget.messages.isNotEmpty)
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
                                        widget.messages.length,
                                        (index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30, vertical: 10),
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
                                                  if (widget.messages[index]
                                                      .emoji.isNotEmpty) ...[
                                                    Container(
                                                      width: 42,
                                                      height: 42,
                                                      decoration: BoxDecoration(
                                                        color: colors[widget
                                                            .messages[index]
                                                            .color],
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          widget.messages[index]
                                                              .emoji,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Pretendard',
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 15),
                                                  ],
                                                  Expanded(
                                                    child: Text(
                                                      widget.messages[index]
                                                          .message,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                      maxLines: 2,
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
                                ),
                                Text(
                                    '${_currentPageRecommended + 1}/${widget.messages.length}'),
                              ],
                            ),
                          ),
                      if (widget.messages.isEmpty && isSwitch == true)
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
                height: 330,
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
                            padding: const EdgeInsets.symmetric(horizontal: 25),
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
                                return widget.dropdownList.map((String item) {
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
                            padding: const EdgeInsets.symmetric(horizontal: 25),
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
                            padding: const EdgeInsets.symmetric(horizontal: 25),
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
                            padding: const EdgeInsets.symmetric(horizontal: 25),
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
                      const SizedBox(height: 30),
                      Row(children: [
                        const Text(
                          '다음에는',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            height: 0.13,
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: _controllerNext.text.isEmpty
                              ? calculateTextWidth(
                                    "바라는 마음 표현를 작성해주세요.",
                                    const TextStyle(
                                      color: Color(0xFF8E8E8E),
                                      fontSize: 15,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ) +
                                  35
                              : calculateTextWidth(
                                    _controllerNext.text,
                                    const TextStyle(
                                      color: Color(0xFF8E8E8E),
                                      fontSize: 15,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ) +
                                  50,
                          height: 31,
                          padding: const EdgeInsets.symmetric(horizontal: 25),
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

                              controller: _controllerNext,
                              decoration: const InputDecoration(
                                hintText: '바라는 마음 표현를 작성해주세요.',
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
                              maxLength: 10, // 입력 글자수를 10자로 제한
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
                      ]),
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

  double calculateTextWidth(String text, TextStyle textStyle) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width + 20;
  }
}
