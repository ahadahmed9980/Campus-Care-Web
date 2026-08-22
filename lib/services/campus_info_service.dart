import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/campusinfo_model.dart';

class CampusInfoService {
  Future<void> uploadCampusinfo(CampusInformationModel campusinfoModel) async {
    await FirebaseFirestore.instance
        .collection('campusInformation')
        .add(campusinfoModel.toMap());
  }

  Future<void> deleteCampusinfo(String docId) async {
    await FirebaseFirestore.instance
        .collection('campusInformation')
        .doc(docId)
        .delete();
  }


  //fetching service
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<QuerySnapshot<Map<String, dynamic>>> fetchCampusinfo({
    int limit = 5,
    DocumentSnapshot<Map<String, dynamic>>? lastdocument,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection("campusInformation")
        .orderBy("title",descending: true)
        .limit(limit);
    if (lastdocument != null) {
      query = query.startAfterDocument(lastdocument);
    }
    return await query.get();
  }
}