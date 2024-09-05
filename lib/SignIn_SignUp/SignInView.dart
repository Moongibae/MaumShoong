import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'AgreeView.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:maumshoong/ContentView.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'
    as kakao_user;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  kakao_user.KakaoSdk.init(nativeAppKey: 'c1ab006a801c850a8c4479cf446869fc');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInView(),
    );
  }
}

class SignInView extends StatefulWidget {
  @override
  _SignInViewState createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _authentication = firebase_auth.FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  bool isLoginFailed = false;
  String _errorMessage = '';

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkButtonState);
    _passwordController.addListener(_checkButtonState);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkButtonState() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _signInWithKakao() async {
    try {
      bool isInstalled = await kakao_user.isKakaoTalkInstalled();
      kakao_user.OAuthToken token;
      if (isInstalled) {
        token = await kakao_user.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao_user.UserApi.instance.loginWithKakaoAccount();
      }

      final provider = firebase_auth.OAuthProvider('oidc.kakao');
      final credential = provider.credential(
        idToken: token.idToken ?? '',
        accessToken: token.accessToken,
      );

      final userCredential =
          await _authentication.signInWithCredential(credential);
      final UID = userCredential.user!.uid;

      if (userCredential.additionalUserInfo!.isNewUser) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgreeView(UID: UID),
          ),
        );
      } else {
        final userSnapshot = await firestore.collection('users').doc(UID).get();
        if (userSnapshot.exists) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ContentView(),
              fullscreenDialog: true,
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgreeView(UID: UID),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = '카카오 로그인에 실패했습니다. 다시 시도해주세요.';
        isLoginFailed = true;
      });
    }
  }

  Future<void> _signInWithApple() async {
    try {
      if (kIsWeb) {
        setState(() {
          _errorMessage = '웹에서는 애플 로그인을 지원하지 않습니다.';
        });
        return;
      }

      if (await SignInWithApple.isAvailable()) {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
            redirectUri: Uri.parse(
                'https://maumshoong.com/callbacks/sign_in_with_apple'),
            clientId: 'com.heartmailers4.maumshoong',
          ),
        );

        final oAuthProvider = firebase_auth.OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        final userCredential =
            await _authentication.signInWithCredential(credential);
        final UID = userCredential.user?.uid;

        if (UID != null) {
          final userSnapshot =
              await firestore.collection('users').doc(UID).get();

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('UID', UID);

          if (!userSnapshot.exists) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AgreeView(UID: UID),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ContentView(),
                fullscreenDialog: true,
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = 'UID를 가져오는 데 실패했습니다. 다시 시도해주세요.';
          });
        }
      } else {
        setState(() {
          _errorMessage = '애플 로그인을 지원하지 않는 기기입니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '애플 로그인에 실패했습니다. 다시 시도해주세요.';
      });
      print(e);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          _errorMessage = '구글 로그인을 취소했습니다.';
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      final UID = userCredential.user?.uid;

      if (UID != null) {
        final userSnapshot = await firestore.collection('users').doc(UID).get();

        if (!userSnapshot.exists) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgreeView(UID: UID),
            ),
          );
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('UID', UID);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ContentView(),
              fullscreenDialog: true,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'UID를 가져오는 데 실패했습니다. 다시 시도해주세요.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '구글 로그인에 실패했습니다. 다시 시도해주세요.';
      });
      print('구글 로그인 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double circleSize = screenWidth * 1.1;
    double circlePosition = screenHeight * 0.1;

    return Scaffold(
      key: _scaffoldKey,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.5,
                      child: Stack(
                        children: [
                          Positioned(
                            top: -circlePosition * 1.9,
                            left: screenWidth / 2 - circleSize / 2,
                            child: Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFE8BE),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: circleSize / 4.3,
                            left: screenWidth / 1.65 - circleSize / 5,
                            child: SvgPicture.asset("assets/images/LOGO.svg"),
                          ),
                          Positioned(
                            top: circleSize / 2.5,
                            left: screenWidth / 1.9 - circleSize / 5,
                            child: SvgPicture.asset(
                                "assets/images/SmileHeart.svg"),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            width: screenWidth - 22,
                            height: 50,
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
                                _checkButtonState();
                              },
                              decoration: const InputDecoration(
                                hintText: '이메일을 입력해주세요.',
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
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            width: screenWidth - 22,
                            height: 50,
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
                                _checkButtonState();
                              },
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: '비밀번호를 입력해주세요.',
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
                        ),
                        SizedBox(
                          width: screenWidth - 22,
                          height: 65,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: TextButton(
                              onPressed: _isButtonEnabled
                                  ? () async {
                                      try {
                                        await _authentication
                                            .signInWithEmailAndPassword(
                                          email: _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                        );
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        await prefs.setBool('isLoggedIn', true);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ContentView(),
                                            fullscreenDialog: true,
                                          ),
                                        );
                                      } catch (e) {
                                        setState(() {
                                          _errorMessage =
                                              '이메일 또는 비밀번호를 다시 확인해주세요.';
                                          isLoginFailed = true;
                                        });
                                      }
                                    }
                                  : null,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.disabled)) {
                                      return Colors.grey; // 비활성 상태일 때 회색
                                    }
                                    return const Color.fromRGBO(255, 231, 191,
                                        1); // 활성 상태일 때 WhiteYellow 색상
                                  },
                                ),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.disabled)) {
                                      return Colors.white; // 비활성 상태일 때 흰색
                                    }
                                    return Colors.black; // 활성 상태일 때 검은색
                                  },
                                ),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                overlayColor: MaterialStateProperty.all<Color>(
                                  const Color(0x4C000000),
                                ),
                              ),
                              child: const Text(
                                '로그인',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.bold, // 볼드 처리
                                  height: 0.10,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (isLoginFailed || _errorMessage.isNotEmpty)
                          SizedBox(
                            width: screenWidth - 50,
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _signInWithKakao,
                              child: SvgPicture.asset(
                                  "assets/images/kakao_talk.svg"),
                            ),
                            if (Platform.isIOS)
                              const SizedBox(
                                width: 30,
                              ),
                            if (Platform.isIOS)
                              GestureDetector(
                                onTap: () {
                                  _signInWithApple();
                                },
                                child:
                                    SvgPicture.asset("assets/images/Apple.svg"),
                              ),
                            const SizedBox(width: 30),
                            GestureDetector(
                              onTap: () {
                                _signInWithGoogle();
                              },
                              child:
                                  SvgPicture.asset("assets/images/Google.svg"),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AgreeView(
                                  UID: "",
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          child: const Text(
                            '회원가입하기',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
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
        ),
      ),
    );
  }
}
