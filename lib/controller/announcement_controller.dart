import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/announcement_model.dart';
import 'package:customer_care_webapp/services/announcement_service.dart';
import 'package:customer_care_webapp/services/cloudinary_storage.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AnnouncementController extends GetxController {
  TextEditingController searchController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  RxList<String> categoryList = <String>["Academic", "General", "Events"].obs;
  RxString selectedCategory = "".obs;

  RxList<String> priorityList = <String>["Low", "Medium", "High"].obs;
  RxString selectedPriority = "".obs;

  var isToggled = false.obs;
  final Rxn<DateTime> expireAt = Rxn<DateTime>();
  //global key
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  var isLoading = false.obs;
  var deletingId = "".obs;

  // Image picker and storage
  final ImagePicker _imagePicker = ImagePicker();
  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  //initilizing model
  final AnnouncementService _announcementService = AnnouncementService();
  final Rxn<String> selectedImageName = Rxn<String>();
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  RxList<AnnouncementModel> announcementList = <AnnouncementModel>[].obs;
  int pageSize = 5;

  RxBool hasNextPage = true.obs;
  
  Timer? _searchDebounce;
  final RxSet<String> togglingIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchfirstPage();
  }

  void clearImage() {
    selectedImageBytes.value = null;
    selectedImageName.value = null;
  }
//reset form
  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    selectedCategory.value = "";
    selectedPriority.value = "";
    selectedImageBytes.value = null;
    selectedImageName.value = null;
    expireAt.value = null;
  }
//dispose to prtect data leakage
  @override
  void onClose() {
    _searchDebounce?.cancel();
    descriptionController.dispose();
    titleController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // Cloudinary and Firebase upload function
  Future<bool> submitform(BuildContext context) async {
    try {
      isLoading.value = true;
      String? uploadedImageUrl;

      // 1. Agar image select hui hai to Cloudinary par upload kro
      if (selectedImageBytes.value != null) {
        uploadedImageUrl = await CloudinaryService.uploadImage(
          bytes: selectedImageBytes.value!,
          fileName: selectedImageName.value,
        );
      }

      // 2. Current live time generate karein
      final currentTimestamp = DateTime.now();

      // 3. Model prepare karein
      final AnnouncementModel announcementModel = AnnouncementModel(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: selectedCategory.value,
        priority: selectedPriority.value,
        isPublished: isToggled.value,
        expiresAt: expireAt.value,
        createdAt: currentTimestamp,
        updatedAt: currentTimestamp,
        imageUrl: uploadedImageUrl ?? "",
      );

      //  Firebase  par save
      await _announcementService.uploadAnnouncement(announcementModel);

      //  Close dialog & reset
      if (context.mounted) {
        context.pop();
      }
      _resetForm();

      // Refresh list to fetch newly uploaded announcement
      await fetchfirstPage(forceRefresh: true);

      Get.snackbar(
        "Success",
        "Announcement published successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true; // Success
    } catch (e) {
      debugPrint("Firebase Upload Error: $e");
      Get.snackbar(
        "Error",
        "Upload failed: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ExpiredAt Date Picker function
  Future<void> expireAtPicker(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;
    if (!context.mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    expireAt.value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  // Pick image function
  Future<void> chooseImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();

        if (bytes.lengthInBytes > 5 * 1024 * 1024) {
          Get.snackbar(
            "File Too Large",
            "Image size 5MB se kam hona chahiye",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
          );
          return;
        }

        selectedImageBytes.value = bytes;
        selectedImageName.value = pickedFile.name;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Image pick nahi ho saki: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  // Page fetching service
  Future<void> fetchfirstPage({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (announcementList.isNotEmpty && !forceRefresh) return;

    try {
      isLoading.value = true;
      if (forceRefresh) {
        lastDocument = null;
        hasNextPage.value = true;
      }
      final snapshot = await _announcementService.fetchAnnouncement(
        limit: pageSize,
      );
      announcementList.value = snapshot.docs.map((doc) {
        return AnnouncementModel.fromMap(doc.data(), id: doc.id);
      }).toList();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      // Update RxBool // if the value of doc length == page size has next page = true  5==5 3!=5
      hasNextPage.value = snapshot.docs.length == pageSize;
    } catch (err) {
      debugPrint("Error fetching first page: $err");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNextPage() async {
    if (!hasNextPage.value || lastDocument == null || isLoading.value) {
      return;
    }
    try {
      isLoading.value = true;
      final snapshot = await _announcementService.fetchAnnouncement(
        limit: pageSize,
        lastdocument: lastDocument,
      );

      final newUsers = snapshot.docs.map((doc) {
        return AnnouncementModel.fromMap(doc.data(), id: doc.id);
      }).toList();

      announcementList.addAll(newUsers);

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      // Update RxBool
      hasNextPage.value = snapshot.docs.length == pageSize;
    } catch (err) {
      debugPrint("Error fetching next page: $err");
    } finally {
      isLoading.value = false;
    }
  }

  //delete announcement
  Future<void> deleteannouncement(AnnouncementModel item) async {
    if (item.id == null || item.id!.isEmpty) return;
    try {
      deletingId.value = item.id!;
      await FirebaseFirestore.instance
          .collection("announcements")
          .doc(item.id)
          .delete();
      //deleting from list
      announcementList.removeWhere((element) {
        return element.id == item.id;
      });
      Get.snackbar(
        "Success",
        "Announcement deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (err) {
      debugPrint('error $err');
      Get.snackbar(
        "Error",
        "Failed to delete announcement: $err",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      deletingId.value = "";
    }
  }

  //toogle from table
  Future<void> togglePublishStatus(
    AnnouncementModel item,
    bool newValue,
  ) async {
    if (item.id == null || item.id!.isEmpty) return;
    if (togglingIds.contains(item.id)) return;

    try {
      togglingIds.add(item.id!);
      //fetching the required data

      final reference = FirebaseFirestore.instance
          .collection('announcements')
          .doc(item.id);
      //assigning new value

      await reference.update({
        'isPublished': newValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await reference.get();
      //
      final index = announcementList.indexWhere(
        (announcement) => announcement.id == item.id,
      );
      if (snapshot.exists && index != -1) {
        announcementList[index] = AnnouncementModel.fromMap(
          snapshot.data()!,
          id: snapshot.id,
        );
      }
      Get.snackbar(
        "Success",
        "Publish status updated successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('error $e');
      Get.snackbar(
        "Error",
        "Failed to update publish status: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      togglingIds.remove(item.id);
    }
  }

  void searchAnnouncements(String queryVal) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      await _executeSearch(queryVal);
    });
  }

  Future<void> _executeSearch(String queryVal) async {
    final queryText = queryVal.trim();
    if (queryText.isEmpty) {
      fetchfirstPage(forceRefresh: true);
      return;
    }

    try {
      isLoading.value = true;
      final capitalizedQuery = queryText.isEmpty 
          ? "" 
          : queryText[0].toUpperCase() + queryText.substring(1);

      final snapshot = await FirebaseFirestore.instance
          .collection("announcements")
          .where('title', isGreaterThanOrEqualTo: queryText)
          .where('title', isLessThanOrEqualTo: '$queryText\uf8ff')
          .limit(pageSize)
          .get();

      final list = snapshot.docs.map((doc) {
        return AnnouncementModel.fromMap(doc.data(), id: doc.id);
      }).toList();

      if (capitalizedQuery != queryText) {
        final capSnapshot = await FirebaseFirestore.instance
            .collection("announcements")
            .where('title', isGreaterThanOrEqualTo: capitalizedQuery)
            .where('title', isLessThanOrEqualTo: '$capitalizedQuery\uf8ff')
            .limit(pageSize)
            .get();
            
        for (var doc in capSnapshot.docs) {
          final ann = AnnouncementModel.fromMap(doc.data(), id: doc.id);
          if (!list.any((a) => a.id == ann.id)) {
            list.add(ann);
          }
        }
      }

      announcementList.assignAll(list);
      lastDocument = null;
      hasNextPage.value = false;
    } catch (e) {
      debugPrint("Error searching announcements: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
