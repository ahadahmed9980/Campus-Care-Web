import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/announcement_model.dart';

class AnnouncementService {
  Future<void> uploadAnnouncement(AnnouncementModel announcementModel) async {
    await FirebaseFirestore.instance
        .collection('announcements')
        .add(announcementModel.toMap());
  }
}