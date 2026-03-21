import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CRUDService {
  static Future saveUserToken(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection("user_data")
        .doc(user.uid);

    DocumentSnapshot userDoc = await userDocRef.get();

    Map<String, dynamic> data = {
      "email": user.email,
      "token": token,
    };
    if (userDoc.exists) {
      // User exists, update only email and token
      await userDocRef.update(data);
      print("Document Updated for ${user.uid}");
    } else {
      // User does not exist, set role to "user"
      data["role"] = "user";
      data["address"] = "";
      data["full_name"] = "";
      data["phone_number"] = "";
      await userDocRef.set(data);
      print("Document Added for ${user.uid}");
    }
  }
}