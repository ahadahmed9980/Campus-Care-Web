import 'package:cloud_firestore/cloud_firestore.dart';

class FetchRequestService {
  /// Must match the mobile app: FirebaseFirestore.instance.collection('requests')
  static const String requestsCollection = 'requests';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection(requestsCollection);

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAllRequests() {
    return _requests.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchRequests(
    Query<Map<String, dynamic>> query,
  ) {
    return query.snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchingRequest({
    int limit = 5,
    DocumentSnapshot<Map<String, dynamic>>? lastDocumnt,
  }) async {
    Query<Map<String, dynamic>> query = _requests
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (lastDocumnt != null) {
      query = query.startAfterDocument(lastDocumnt);
    }
    return await query.get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchAllRequests() async {
    return await _requests.get();
  }
}
