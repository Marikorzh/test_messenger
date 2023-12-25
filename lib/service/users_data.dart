import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:test_messenger/main.dart';

class UserData {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DatabaseReference databaseReference;
  static String? currentUser;

  UserData()
      : databaseReference = FirebaseDatabase.instance.ref().child('users');

  Future<String> uploadImageToStorage(String fileName, Uint8List file) async{
    Reference reference = _storage.ref().child(fileName);
    UploadTask uploadTask = reference.putData(file);
    TaskSnapshot snapshot  = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<List<String>> readDataUser() async {
    List<String> uidList = [];
    //Completer<List<String>> completer = Completer();

    // Перевірка, чи не додано вже слухача, щоб уникнути подвійних викликів
    if (databaseReference.onValue != null) {
      databaseReference.onValue.listen((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        Map<dynamic, dynamic>? values = dataSnapshot.value as Map?;
        values?.forEach((key, values) {
          print('uid: ${values['uid']}');
          uidList.add(values['uid']);
          print('name: ${values['name']}');
        });

      //   completer.complete(
      //       uidList); // Повідомляємо про завершення асинхронної операції
      });
    }

    return uidList;
  }

  Future<AuthData> re3(String userId) async {
    AuthData authData = AuthData(uid: userId, name: "An", id: "0000", avatarLink: "");
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('users/$userId').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>?;

      authData.name = data?['name'];
      authData.uid = data?['uid'];
      authData.id = data?['id'];
      authData.avatarLink = data?['avatarLink'];
    } else {
      throw StateError('No data available.');
    }
    return authData;
  }

  void updateUserData(String userId, String newName) async{

    // Only update the name, leave the age and address!
    await databaseReference.ref.child(userId).update({
      "name": newName,
    });
  }

  void updateUserPhoto(String userId, String filePath) async{

    await databaseReference.ref.child(userId).update({
      "avatarLink": filePath,
    });
  }

  void setUserOnlineStatus(String userId, bool isOnline) {
    DatabaseReference databaseReference =
    FirebaseDatabase.instance.ref().child('users/$userId');

    databaseReference.update({
      'status': isOnline ? "online" : ServerValue.timestamp,
    });
  }

  void createRecord(String uidUser) {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('users');

    databaseReference.child(uidUser.substring(0,4)).set({
      'uid': uidUser,
      'name': 'Anonym',
      'avatarLink' : "https://firebasestorage.googleapis.com/v0/b/messegertest-49096.appspot.com/o/StandartPhoto.jpg?alt=media&token=8efa95ed-3118-4d42-aff2-64a8eb018be6",
      "position" : "Worker",
      "id" : uidUser.substring(0,4),
      "status" : "online",
    });
  }

   Future<List<String>> fetchItemsByUserId(String userId) async {
    try {
      // Отримати DataSnapshot за допомогою методу once()
      var dataSnapshot = await databaseReference.orderByChild('users').equalTo(userId).once();

      // Перевірка, чи є значення та повернення його (або пустий список, якщо значення відсутнє)
      Map<dynamic, dynamic>? values = dataSnapshot as Map?;
      List<String> items = [];

      if (values != null) {
        values.forEach((key, value) {
          items.add(value.toString());
        });
      }

      return items;
    } catch (e) {
      print('Помилка при отриманні значень з бази даних: $e');
      return [];
    }
  }
}
