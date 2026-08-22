import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/announcement_model.dart';

class AnnouncementService {
  Future<void> uploadAnnouncement(AnnouncementModel announcementModel) async {
    await FirebaseFirestore.instance
        .collection('announcements')
        .add(announcementModel.toMap());
  }


  //fetching service
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<QuerySnapshot<Map<String, dynamic>>> fetchAnnouncement({
    int limit = 5,
    DocumentSnapshot<Map<String, dynamic>>? lastdocument,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection("announcements")
        .orderBy("createdAt",descending: true)
        .limit(limit);
    if (lastdocument != null) {
      query = query.startAfterDocument(lastdocument);
    }
    return await query.get();
  }
}