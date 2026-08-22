import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/department_model.dart';

class DepartmentService {
  Future<void> uploadDepartmentInfo(DepartmentModel departmentModel) async {
    await FirebaseFirestore.instance
        .collection('departments')
        .add(departmentModel.toMap());
  }

  Future<void> deleteDepartmentinfo(String docId) async {
    await FirebaseFirestore.instance
        .collection('departments')
        .doc(docId)
        .delete();
  }


  //fetching service
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<QuerySnapshot<Map<String, dynamic>>> fetchDepartmentinfo({
    int limit = 5,
    DocumentSnapshot<Map<String, dynamic>>? lastdocument,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection("departments")
        .orderBy("name",descending: true)
        .limit(limit);
    if (lastdocument != null) {
      query = query.startAfterDocument(lastdocument);
    }
    return await query.get();
  }
}