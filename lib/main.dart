import 'package:flutter/material.dart';
import 'ContentView.dart';
import 'SignIn_SignUp/SignInView.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: 'c1ab006a801c850a8c4479cf446869fc');

  // SharedPreferences를 사용하여 로그인 상태 체크
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Firebase Authentication을 사용하여 현재 로그인된 사용자가 있는지 확인
  final user = FirebaseAuth.instance.currentUser;

  // 앱 실행
  runApp(MyApp(isLoggedIn: isLoggedIn && user != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: isLoggedIn ? ContentView() : SignInView(),
    );
  }
}
