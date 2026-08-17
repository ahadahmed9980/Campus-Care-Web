import 'package:cloud_firestore/cloud_firestore.dart';

class FetchRequestService {
  //creating instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //collection name

  Future<QuerySnapshot<Map<String, dynamic>>> fetchingRequest({
    int limit = 5,
    //current page k last document ko temp save kr lia
    DocumentSnapshot<Map<String, dynamic>>? lastDocumnt,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection("requests")
        // .orderBy('createdAt', descending: true)
        .limit(limit);
    if (lastDocumnt != null) {
      //initially
      query = query.startAfterDocument(lastDocumnt);
    }
    return await query.get();
  }
}
