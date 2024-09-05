import 'package:flutter/material.dart';
import 'package:maumshoong/SignIn_SignUp/SignUpView.dart';
import 'package:maumshoong/SignIn_SignUp/SignUpCompleted.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

String generateRandomCode() {
  final random = Random();
  const int min = 100000;
  const int max = 999999;
  final code = random.nextInt(max - min + 1) + min;
  final randomChar =
      String.fromCharCodes(List.generate(1, (_) => random.nextInt(26) + 65));
  return '$code$randomChar';
}

class FamilyRolesCheck extends StatefulWidget {
  final String nickname;
  final bool checkMale;
  final bool checkFemale;
  final String year;
  final String month;
  final int ProfileIndex;
  final String UID;

  FamilyRolesCheck({
    Key? key,
    required this.nickname,
    required this.checkMale,
    required this.checkFemale,
    required this.year,
    required this.month,
    required this.ProfileIndex,
    required this.UID,
  }) : super(key: key);

  @override
  _FamilyRolesCheckState createState() => _FamilyRolesCheckState();
}

class UserRoles {
  static bool parents = false;
  static bool children = false;
}

class _FamilyRolesCheckState extends State<FamilyRolesCheck> {
  bool isLoading = false;
  bool navigateToContentView = false;
  bool showAlert = false;
  bool canGoToContentView = false;
  String alertTitle = "";
  String alertMessage = "";
  final whiteYellow = const Color(0xFFFFE8C0);
  late String nickname;
  late bool checkMale;
  late bool checkFemale;
  late String year;
  late String month;
  late int ProfileIndex = 0;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoding = false;
  late String FamilyInviteCode;

  void onPressed() async {
    setState(() {
      isLoading = true;
    });

    setState(() {
      isLoading = false;
      if (canGoToContentView) {
        navigateToContentView = true;
      } else {
        showAlert = true;
      }
    });
  }

  void SignUp() async {
    try {
      isLoding = true;
      await firestore.collection('users').doc(widget.UID).set({
        'email': "소셜 가입",
        'birthMonth': month,
        'birthYear': year,
        'gender': checkFemale ? '여성' : '남성',
        'inviteCode': FamilyInviteCode,
        'isInFamily': false,
        'profile': ProfileIndex,
        'userId': nickname,
        'roles': {
          'parents': UserRoles.parents,
          'children': UserRoles.children,
        }
      });

      await firestore.collection('families').doc(FamilyInviteCode).set({
        'inviteCode': FamilyInviteCode,
        'members': [widget.UID],
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      isLoding = false;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpCompleted(),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    nickname = widget.nickname;
    checkMale = widget.checkMale;
    checkFemale = widget.checkFemale;
    year = widget.year;
    month = widget.month;
    ProfileIndex = widget.ProfileIndex;
    UserRoles.parents = false;
    UserRoles.children = false;
    FamilyInviteCode = generateRandomCode();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '우리 가족 안에서 나의 역할은 무엇인가요?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                '*추천 마음 표현를 띄울 때 사용됩니다.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  setState(() {
                    UserRoles.children = !UserRoles.children;
                    UserRoles.parents = false;
                  });
                },
                child: Container(
                  width: screenWidth - 48,
                  height: 35,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: UserRoles.children ? whiteYellow : Colors.white,
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
                      borderRadius: BorderRadius.circular(23),
                    ),
                  ),
                  child: const SizedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '자녀',
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
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    UserRoles.parents = !UserRoles.parents;
                    UserRoles.children = false;
                  });
                },
                child: Container(
                  width: screenWidth - 48,
                  height: 35,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: UserRoles.parents ? whiteYellow : Colors.white,
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
                      borderRadius: BorderRadius.circular(23),
                    ),
                  ),
                  child: const SizedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '부모',
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
                ),
              ),
              const Spacer(),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFF1614F),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: UserRoles.parents || UserRoles.children
                    ? () {
                        if (widget.UID.toString() == "") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpView(
                                nickname: nickname,
                                checkMale: checkMale,
                                checkFemale: checkFemale,
                                year: year,
                                month: month,
                                ProfileIndex: ProfileIndex,
                                parents: UserRoles.parents,
                                children: UserRoles.children,
                              ),
                            ),
                          );
                          print(nickname);
                        } else if (widget.UID.toString() != "") {
                          SignUp();
                        }
                      }
                    : null,
                child: Container(
                  height: 45,
                  width: screenWidth - 22,
                  decoration: BoxDecoration(
                    color: UserRoles.parents || UserRoles.children
                        ? const Color.fromRGBO(255, 231, 191, 1)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      widget.UID.toString() == "" ? '다음' : "회원가입",
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.bold,
                        height: 0.10,
                        color: UserRoles.parents || UserRoles.children
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
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
