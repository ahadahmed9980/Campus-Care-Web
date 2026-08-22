import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<QuerySnapshot<Map<String, dynamic>>> fetchUser({
    int limit = 5,
    DocumentSnapshot<Map<String, dynamic>>? lastdocument,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection("users")
        // .orderBy("fullName")
        .limit(limit);
    if (lastdocument != null) {
      query = query.startAfterDocument(lastdocument);
    }
    return await query.get();
  }
}
