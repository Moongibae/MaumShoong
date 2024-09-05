import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'CustomProfileView.dart';

class AgreeView extends StatefulWidget {
  final String UID;
  AgreeView({
    Key? key,
    required this.UID,
  }) : super(key: key);
  @override
  _AgreeViewState createState() => _AgreeViewState();
}

class _AgreeViewState extends State<AgreeView> {
  bool ageCheck = false;
  bool useCheck = false;
  bool privacyCheck = false;
  bool allAgreementCheck = false;
  bool nextIsActive = false;

  final whiteGray = const Color(0xFFE5E5E5);
  final whiteYellow = const Color(0xFFFFE8C0);
  final privacyURL =
      "https://observant-gasoline-c62.notion.site/c972ee106ab043c0a1f7b0ba8bf3d13e?pvs=4";
  final agreeURL =
      "https://heartmailers4.notion.site/heartmailers4/26f9d78ab6bb4ef5807624c5f425426b";

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset("assets/images/Back.svg"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title:
            const Text("서비스 이용 약관 동의", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.transparent,
              child: ListTile(
                leading: GestureDetector(
                  onTap: () => setState(() {
                    allAgreementCheck = !allAgreementCheck;
                    ageCheck = allAgreementCheck;
                    useCheck = allAgreementCheck;
                    privacyCheck = allAgreementCheck;
                  }),
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor:
                        allAgreementCheck ? whiteYellow : whiteGray,
                    child: allAgreementCheck
                        ? SvgPicture.asset('assets/images/Check.svg',
                            width: 12, height: 12)
                        : Container(),
                  ),
                ),
                title: const Text(
                  "약관 전체 동의",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Divider(
              color: whiteGray,
              thickness: 1,
              height: 0,
              indent: 20,
              endIndent: 20,
            ),
            _buildAgreementOption(
              "만 14세 이상입니다.",
              ageCheck,
              () => setState(() {
                ageCheck = !ageCheck;
                if (!ageCheck) {
                  allAgreementCheck = false;
                } else {
                  if (ageCheck && useCheck && privacyCheck) {
                    allAgreementCheck = true;
                  }
                }
              }),
              enabled: true,
            ),
            _buildAgreementOption(
              "(필수) 서비스 이용약관",
              useCheck,
              () => setState(() {
                useCheck = !useCheck;
                if (!useCheck) {
                  allAgreementCheck = false;
                } else {
                  if (ageCheck && useCheck && privacyCheck) {
                    allAgreementCheck = true;
                  }
                }
              }),
              onTap: () => _launchURL(agreeURL),
              enabled: ageCheck,
              showImage: true,
            ),
            _buildAgreementOption(
              "(필수) 개인정보 처리 방침",
              privacyCheck,
              () => setState(() {
                privacyCheck = !privacyCheck;
                if (!privacyCheck) {
                  allAgreementCheck = false;
                } else {
                  if (ageCheck && useCheck && privacyCheck) {
                    allAgreementCheck = true;
                  }
                }
              }),
              onTap: () => _launchURL(privacyURL),
              enabled: ageCheck,
              showImage: true,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(15),
        child: GestureDetector(
          onTap: () {
            if (useCheck && privacyCheck) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomProfileView(
                    UID: widget.UID,
                  ),
                ),
              );
            }
          },
          child: Container(
            width: screenWidth - 30,
            height: 45,
            decoration: BoxDecoration(
              color: useCheck && privacyCheck ? whiteYellow : Colors.grey,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                "다음",
                style: TextStyle(
                  color: useCheck && privacyCheck ? Colors.black : Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementOption(String title, bool value, VoidCallback onChanged,
      {VoidCallback? onTap, bool enabled = true, bool showImage = false}) {
    return ListTile(
      leading: GestureDetector(
        onTap: enabled ? onChanged : null,
        child: CircleAvatar(
          radius: 10,
          backgroundColor: value ? whiteYellow : whiteGray,
          child: value
              ? SvgPicture.asset('assets/images/Check.svg',
                  width: 12, height: 12)
              : Container(),
        ),
      ),
      title: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (showImage) ...[
              SvgPicture.asset(
                'assets/images/Move.svg',
                height: 20,
                width: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
