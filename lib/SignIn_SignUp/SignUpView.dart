import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maumshoong/SignIn_SignUp/SignUpCompleted.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/services.dart';
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

class SignUpView extends StatefulWidget {
  final String nickname;
  final bool checkMale;
  final bool checkFemale;
  final String year;
  final String month;
  final int ProfileIndex;
  final bool parents;
  final bool children;

  SignUpView({
    Key? key,
    required this.nickname,
    required this.checkMale,
    required this.checkFemale,
    required this.year,
    required this.month,
    required this.ProfileIndex,
    required this.parents,
    required this.children,
  }) : super(key: key);

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _checkPasswordController =
      TextEditingController();
  bool _isButtonEnabled = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String nickname;
  late bool checkMale;
  late bool checkFemale;
  late String year;
  late String month;
  late int ProfileIndex;
  late bool spouse;
  bool _isLoading = false;
  String _errorMessage = '';
  late String FamilyInviteCode;

  @override
  void initState() {
    super.initState();
    nickname = widget.nickname;
    checkMale = widget.checkMale;
    checkFemale = widget.checkFemale;
    year = widget.year;
    month = widget.month;
    ProfileIndex = widget.ProfileIndex;
    FamilyInviteCode = generateRandomCode();
  }

  Future<void> _signUpWithKakao() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      kakao.OAuthToken token;
      // 카카오톡으로 로그인
      if (await kakao.isKakaoTalkInstalled()) {
        try {
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
        } catch (error) {
          print('카카오톡으로 로그인 실패 $error');
          if (error is PlatformException && error.code == 'CANCELED') {
            setState(() {
              _errorMessage = '로그인이 취소되었습니다.';
            });
            return;
          }
          // 카카오톡 로그인 실패 시 웹으로 로그인 시도
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        }
      } else {
        // 카카오톡이 설치되어 있지 않으면 웹으로 로그인
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      }

      // Firebase OIDC 방식으로 사용자 생성
      final firebase_auth.OAuthCredential credential =
          firebase_auth.OAuthProvider('oidc.kakao').credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );

      try {
        firebase_auth.UserCredential userCredential = await firebase_auth
            .FirebaseAuth.instance
            .signInWithCredential(credential);

        if (userCredential.additionalUserInfo!.isNewUser) {
          firebase_auth.User? user =
              firebase_auth.FirebaseAuth.instance.currentUser;

          // 파이어스토어에 사용자 정보 저장
          await firestore.collection('users').doc(user?.uid).set({
            'email': user?.email,
            'birthMonth': month,
            'birthYear': year,
            'gender': checkFemale ? '여성' : '남성',
            'inviteCode': FamilyInviteCode,
            'isInFamily': false,
            'profile': ProfileIndex,
            'userId': nickname,
            'roles': {
              'parents': widget.parents,
              'children': widget.children,
            }
          });

          await firestore.collection('families').doc(FamilyInviteCode).set({
            'inviteCode': FamilyInviteCode,
            'members': [user?.uid]
          });

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpCompleted(),
            ),
          );
        } else {
          // 이메일 중복 등의 에러 처리
          print('Failed to create user: $e');
          setState(() {
            _errorMessage = '이미 사용중인 이메일이거나 잘못된 이메일 형식입니다.';
          });
        }
      } catch (e) {
        // 이메일 중복 등의 에러 처리
        print('Failed to create user: $e');
        setState(() {
          _errorMessage = '이미 사용중인 이메일이거나 잘못된 이메일 형식입니다.';
        });
      }
    } catch (e) {
      print('Failed to sign up with Kakao: $e');
      setState(() {
        _errorMessage = '카카오톡 로그인에 실패했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUpWithApple() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final firebase_auth.OAuthProvider oAuthProvider =
          firebase_auth.OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);

      firebase_auth.User? user =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (userCredential.additionalUserInfo!.isNewUser) {
        // 파이어스토어에 사용자 정보 저장
        await firestore.collection('users').doc(user?.uid).set({
          'email': user?.email,
          'birthMonth': month,
          'birthYear': year,
          'gender': checkFemale ? '여성' : '남성',
          'inviteCode': FamilyInviteCode,
          'isInFamily': false,
          'profile': ProfileIndex,
          'userId': nickname,
          'roles': {
            'parents': widget.parents,
            'children': widget.children,
          }
        });

        await firestore.collection('families').doc(FamilyInviteCode).set({
          'inviteCode': FamilyInviteCode,
          'members': [user?.uid]
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('UID', user?.uid ?? '');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpCompleted(),
          ),
        );
      } else {
        // 이미 존재하는 사용자에 대한 처리
        setState(() {
          _errorMessage = '이미 사용중인 이메일이거나 잘못된 이메일 형식입니다.';
        });
      }
    } catch (e) {
      print('Failed to sign up with Apple: $e');
      setState(() {
        _errorMessage = '애플 로그인에 실패했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUpWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() {
          _errorMessage = '구글 로그인을 취소했습니다.';
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final firebase_auth.OAuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);

      if (userCredential.additionalUserInfo!.isNewUser) {
        // 파이어스토어에 사용자 정보 저장
        await firestore
            .collection('users')
            .doc(firebase_auth.FirebaseAuth.instance.currentUser?.uid)
            .set({
          'email': _emailController.text,
          'birthMonth': month,
          'birthYear': year,
          'gender': checkFemale ? '여성' : '남성',
          'inviteCode': FamilyInviteCode,
          'isInFamily': false,
          'profile': ProfileIndex,
          'userId': nickname,
          'roles': {
            'parents': widget.parents,
            'children': widget.children,
          }
        });
        firestore.collection('families').doc(FamilyInviteCode).set({
          'inviteCode': FamilyInviteCode,
          'members': [firebase_auth.FirebaseAuth.instance.currentUser?.uid]
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpCompleted(),
          ),
        );
      } else {
        // 이미 존재하는 사용자에 대한 처리
        setState(() {
          _errorMessage = '이미 사용중인 이메일이거나 잘못된 이메일 형식입니다.';
        });
      }
    } catch (e) {
      print('Failed to sign up with Google: $e');
      setState(() {
        _errorMessage = '구글 로그인에 실패했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset("assets/images/Back.svg"),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("회원가입"),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        const Text("이메일",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Container(
                          width: screenWidth - 22,
                          height: 45,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 0),
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
                          child: TextField(
                            cursorColor: const Color(0xFFF1614F),
                            controller: _emailController,
                            onChanged: (value) {
                              setState(() {
                                _isButtonEnabled = _emailController
                                        .text.isNotEmpty &&
                                    _passwordController.text.isNotEmpty &&
                                    _checkPasswordController.text.isNotEmpty;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: '이메일을 입력하세요',
                              hintStyle: TextStyle(
                                color: Color(0xFFBDBDBD),
                                fontSize: 17,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 0.10,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text("비밀번호",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Container(
                          width: screenWidth - 22,
                          height: 45,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 0),
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
                          child: TextField(
                            cursorColor: const Color(0xFFF1614F),
                            controller: _passwordController,
                            onChanged: (value) {
                              setState(() {
                                _isButtonEnabled = _emailController
                                        .text.isNotEmpty &&
                                    _passwordController.text.isNotEmpty &&
                                    _checkPasswordController.text.isNotEmpty;
                              });
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: '비밀번호를 입력하세요',
                              hintStyle: TextStyle(
                                color: Color(0xFFBDBDBD),
                                fontSize: 17,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 0.10,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: screenWidth - 22,
                          height: 45,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 0),
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
                          child: TextField(
                            cursorColor: const Color(0xFFF1614F),
                            controller: _checkPasswordController,
                            onChanged: (value) {
                              setState(() {
                                _isButtonEnabled = _emailController
                                        .text.isNotEmpty &&
                                    _passwordController.text.isNotEmpty &&
                                    _checkPasswordController.text.isNotEmpty;
                              });
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: '비밀번호를 입력하세요',
                              hintStyle: TextStyle(
                                color: Color(0xFFBDBDBD),
                                fontSize: 17,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 0.10,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFF1614F),
                              ),
                            ),
                          ),
                        if (_errorMessage.isNotEmpty)
                          Center(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _signUpWithKakao,
                              child: SvgPicture.asset(
                                  "assets/images/kakao_talk.svg"),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            GestureDetector(
                              onTap: () {
                                _signUpWithApple();
                              },
                              child:
                                  SvgPicture.asset("assets/images/Apple.svg"),
                            ),
                            const SizedBox(width: 30),
                            GestureDetector(
                              onTap: () {
                                _signUpWithGoogle();
                              },
                              child:
                                  SvgPicture.asset("assets/images/Google.svg"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: GestureDetector(
                  onTap: _isButtonEnabled
                      ? () async {
                          if (_passwordController.text ==
                              _checkPasswordController.text) {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = '';
                            });
                            try {
                              await firebase_auth.FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text);
                              await firestore
                                  .collection('users')
                                  .doc(firebase_auth
                                      .FirebaseAuth.instance.currentUser?.uid)
                                  .set({
                                'email': _emailController.text,
                                'birthMonth': month,
                                'birthYear': year,
                                'gender': checkFemale ? '여성' : '남성',
                                'inviteCode': FamilyInviteCode,
                                'isInFamily': false,
                                'profile': ProfileIndex,
                                'userId': nickname,
                                'roles': {
                                  'parents': widget.parents,
                                  'children': widget.children,
                                }
                              });
                              firestore
                                  .collection('families')
                                  .doc(FamilyInviteCode)
                                  .set({
                                'inviteCode': FamilyInviteCode,
                                'members': [
                                  firebase_auth
                                      .FirebaseAuth.instance.currentUser?.uid
                                ]
                              });
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('isLoggedIn', true);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpCompleted(),
                                ),
                              );
                            } catch (e) {
                              print('Failed to create user: $e');
                              setState(() {
                                _errorMessage = '이미 사용중인 이메일이거나 잘못된 이메일 형식입니다.';
                              });
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          } else {
                            setState(() {
                              _errorMessage = '비밀번호가 일치하지 않습니다.';
                            });
                          }
                        }
                      : null,
                  child: Container(
                    width: screenWidth - 22,
                    height: 45,
                    decoration: BoxDecoration(
                      color: _isButtonEnabled
                          ? const Color.fromRGBO(255, 231, 191, 1)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.bold,
                          height: 0.10,
                          color: _isButtonEnabled ? Colors.black : Colors.white,
                        ),
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
