import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:intl/intl.dart' as intl;

class WishListItem {
  final String id;
  final List<String> sender;
  final List<String> emoji;
  final List<String> color;
  final List<String> message;
  final List<DateTime> timestamp;

  WishListItem({
    required this.id,
    required this.sender,
    required this.emoji,
    required this.color,
    required this.message,
    required this.timestamp,
  });
}

class MessageItem {
  final String id;
  final String color;
  final String emoji;
  bool like;
  final String message;
  final bool read;
  final String sender;
  final Timestamp timestamp;
  final String SelectedWritingPad;

  MessageItem({
    required this.id,
    required this.color,
    required this.emoji,
    required this.like,
    required this.message,
    required this.read,
    required this.sender,
    required this.timestamp,
    required this.SelectedWritingPad,
  });
}

class ViewModel {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userUID = FirebaseAuth.instance.currentUser?.uid;
  DocumentSnapshot? userData;
  String? familyInviteCode;
  Map<String, int>? familyData;
  bool isLoading = false;

  Future<void> initUserData() async {
    if (userUID != null) {
      userData = await firestore.collection('users').doc(userUID).get();
      familyInviteCode = userData?['inviteCode'];
      print("유저 데이터: ${userData!['isInFamily'].toString()}");
      familyData = await getFamilyData();
      print("가족 데이터: ${familyData.toString()}");
      print('유저 정보: ${getUserData()}');
    }
  }

  Map<String, int>? getUserData() {
    if (userData != null) {
      return {
        userData!['userId']: userData!['profile'],
      };
    }
    return null;
  }

  Future<List<String>> getFamilyMembers() async {
    if (familyInviteCode != null) {
      DocumentSnapshot familyData =
          await firestore.collection('families').doc(familyInviteCode).get();
      List<String> members = List<String>.from(familyData['members']);
      return members;
    }
    return [];
  }

  getFamilyData() async {
    if (familyInviteCode != null) {
      Map<String, int> familyMembersData = {};
      List<String> familyMembers = await getFamilyMembers();
      for (String member in familyMembers) {
        DocumentSnapshot? familyData =
            await firestore.collection('users').doc(member).get();

        if (familyData.exists) {
          familyMembersData[familyData['userId']] = familyData['profile'];
        }
      }
      return familyMembersData;
    }
  }

  Future<Map<String, WishListItem>> GetFamilyWishList() async {
    final DateTime oneWeekAgo =
        DateTime.now().subtract(const Duration(days: 7));

    if (familyInviteCode != null) {
      final familyMemebers = await getFamilyData();
      Map<String, WishListItem> wishList = {};
      for (String selectFamily in familyMemebers.keys) {
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection("families")
            .doc(familyInviteCode) // Now checked to be non-empty.
            .collection("Messages")
            .doc(selectFamily) // Now checked to be non-empty.
            .collection("WishList")
            .where("timestamp", isGreaterThanOrEqualTo: oneWeekAgo)
            .get();

        snapshot.docs.forEach((document) {
          final Map<String, dynamic>? data =
              document.data() as Map<String, dynamic>?;
          final String sender = data?['sender'] as String? ?? '';
          final String? emoji = data?['emoji'] as String?;
          final String? color = data?['color'] as String?;
          final String? message = data?['message'] as String?;
          final DateTime? timestamp =
              (data?['timestamp'] as Timestamp?)?.toDate();
          wishList[selectFamily] = WishListItem(
            id: document.id,
            sender: [sender]..addAll(wishList[selectFamily]?.sender ?? []),
            emoji: [emoji ?? '']..addAll(wishList[selectFamily]?.emoji ?? []),
            color: [color ?? '']..addAll(wishList[selectFamily]?.color ?? []),
            message: [message ?? '']
              ..addAll(wishList[selectFamily]?.message ?? []),
            timestamp: [timestamp ?? DateTime.now()]..addAll(
                wishList[selectFamily]?.timestamp ??
                    []), // Added null check and default value
          );
        });
      }
      return wishList; // Added return statement
    }
    throw Exception('Family invite code is null.'); // Added throw statement
  }

  Future<void> sendMessage({
    required String sender,
    required String recipient,
    required String inviteCode,
    required String emoji,
    required String color,
    required String message,
  }) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> messageData = {
      "sender": sender,
      "emoji": emoji,
      "color": color,
      "message": message,
      "read": false,
      "timestamp": FieldValue.serverTimestamp(),
    };

    DocumentReference messageDocRef = db
        .collection("families")
        .doc(inviteCode)
        .collection("Messages")
        .doc(recipient)
        .collection("messages")
        .doc();

    try {
      await messageDocRef.set(messageData);
      print("Message successfully sent to $recipient");
    } catch (e) {
      print("Error adding document: $e");
    }
  }

  Future<void> AddWishList(
    String message,
    String Name,
  ) async {
    String generateRandomCode(int length) {
      const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final random = Random();
      return List.generate(
              length, (index) => characters[random.nextInt(characters.length)])
          .join();
    }

    if (familyInviteCode != null) {
      await firestore
          .collection('families')
          .doc(familyInviteCode)
          .collection('Messages')
          .doc(Name)
          .collection('WishList')
          .doc(generateRandomCode(10))
          .set({
        'sender': userData!['userId'],
        'like': false,
        'read': false,
        'message': message,
        'timestamp': DateTime.now(),
      });
    }
  }

  Future<void> AddMSG(
    String message,
    String SelectedWritingPad,
    String Name,
  ) async {
    String generateRandomCode(int length) {
      const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final random = Random();
      return List.generate(
              length, (index) => characters[random.nextInt(characters.length)])
          .join();
    }

    if (familyInviteCode != null) {
      await firestore
          .collection('families')
          .doc(familyInviteCode)
          .collection('Messages')
          .doc(Name)
          .collection('messages')
          .doc(generateRandomCode(10))
          .set({
        'sender': userData!['userId'],
        'SelectedWritingPad': SelectedWritingPad,
        'like': false,
        'read': false,
        'message': message,
        'timestamp': DateTime.now(),
      });
    }
    if (familyInviteCode != null) {
      await firestore
          .collection('families')
          .doc(familyInviteCode)
          .update({'heartCount': FieldValue.increment(2)});
    }
  }

  Future<Map<String, bool>> getFamilyRoles(String name) async {
    if (familyInviteCode != null) {
      List<String> familyMembers = await getFamilyMembers();
      for (String member in familyMembers) {
        DocumentSnapshot familyDataSnapshot =
            await firestore.collection('users').doc(member).get();
        print('가족 역할 프린트: ${familyDataSnapshot['roles']}');

        if (familyDataSnapshot['userId'] == name) {
          var rolesDynamic =
              familyDataSnapshot['roles'] as Map<String, dynamic>;
          var rolesBool =
              rolesDynamic.map((key, value) => MapEntry(key, value as bool));
          return rolesBool;
        }
      }
    }
    return {};
  }

  Future<QuerySnapshot?> getMessages() async {
    if (familyInviteCode != null) {
      QuerySnapshot querySnapshot = await firestore
          .collection('families')
          .doc(familyInviteCode)
          .collection('Messages')
          .doc(userData!['userId'])
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();
      querySnapshot.docs.forEach((result) {
        print("가져온 데이터: ${result.data()}");
      });
      return querySnapshot;
    }
    return null;
  }

  Future<bool> RetrospectAlarm() async {
    final now = DateTime.now();
    final formattedDate = intl.DateFormat('yyyy년 MM월').format(now);

    final QuerySnapshot? snapshotHate = await FirebaseFirestore.instance
        .collection("families")
        .doc(familyInviteCode)
        .collection('Retrospective')
        .doc(formattedDate)
        .collection('Hate')
        .where('writer', isEqualTo: userData!['userId'])
        .get()
        .catchError((error) => null);

    final QuerySnapshot? snapshotLike = await FirebaseFirestore.instance
        .collection("families")
        .doc(familyInviteCode)
        .collection('Retrospective')
        .doc(formattedDate)
        .collection('Like')
        .where('writer', isEqualTo: userData!['userId'])
        .get()
        .catchError((error) => null);

    final QuerySnapshot? snapshotNeed = await FirebaseFirestore.instance
        .collection("families")
        .doc(familyInviteCode)
        .collection('Retrospective')
        .doc(formattedDate)
        .collection('Need')
        .where('writer', isEqualTo: userData!['userId'])
        .get()
        .catchError((error) => null);

    if (snapshotHate == null || snapshotLike == null || snapshotNeed == null) {
      return false;
    }

    bool hasHate = snapshotHate.docs.isNotEmpty;
    bool hasLike = snapshotLike.docs.isNotEmpty;
    bool hasNeed = snapshotNeed.docs.isNotEmpty;

    return hasHate || hasLike || hasNeed;
  }
}
