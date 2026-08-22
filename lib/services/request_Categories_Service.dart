import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/request_Category_model.dart';

class RequestCategoriesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Custom document ID ke sath save karne ka method
  Future<void> uploadRequestCategory(
    RequestCategoryModel requestCategoryModel, {
    String? customDocId, // Apni marzi ka ID / Name yahan aayega
  }) async {
    // Agar customDocId pass na ho to category ke name ko hi as ID use kar sakte hain
    final docId = customDocId ?? requestCategoryModel.name.trim().toLowerCase();

    await _firestore
        .collection('requestCategories')
        .doc(docId)
        .set(
          requestCategoryModel.toMap(),
          SetOptions(merge: true), // Safe update ke liye (agar document pehle se ho)
        );
  }

  // 2. Fetching service
  Future<QuerySnapshot<Map<String, dynamic>>> fetchRequestCategory({
    int limit = 5,
    DocumentSnapshot<Map<String, dynamic>>? lastdocument,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection("requestCategories")
        // .orderBy("createdAt", descending: true)
        .limit(limit);

    if (lastdocument != null) {
      query = query.startAfterDocument(lastdocument);
    }
    return await query.get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchAllCategories() async {
    return await _firestore.collection("requestCategories").get();
  }
}