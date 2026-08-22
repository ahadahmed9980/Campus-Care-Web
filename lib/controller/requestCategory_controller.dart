import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/request_Category_model.dart';
import 'package:customer_care_webapp/services/request_Categories_Service.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/state_manager.dart';
import 'package:go_router/go_router.dart';

class RequestcategoryController extends GetxController {
  TextEditingController searchController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController categoryIdController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  var isToggled = false.obs;
  var isLoading = false.obs;
  final RequestCategoriesService _requestCategoriesService =
      RequestCategoriesService();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  RxList<RequestCategoryModel> requestCategoryList =
      <RequestCategoryModel>[].obs;
  int pageSize = 5;

  RxBool hasNextPage = true.obs;
  @override
  void onInit() {
    super.onInit();
    fetchfirstPage();
  }

  @override
  void onClose() {
    super.onClose();
    descriptionController.dispose();
    categoryIdController.dispose();
    titleController.dispose();
    searchController.dispose();
  }

  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    categoryIdController.clear();
    isToggled.value = false;
  }

  //Page fetching service
  Future<void> fetchfirstPage({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (requestCategoryList.isNotEmpty && !forceRefresh) return;

    try {
      isLoading.value = true;
      if (forceRefresh) {
        lastDocument = null;
        hasNextPage.value = true;
      }
      final snapshot = await _requestCategoriesService.fetchRequestCategory(
        limit: pageSize,
      );

      // CHANGE 2: assignAll use karein taake list properly update ho aur UI react kare
      final fetchedList = snapshot.docs.map((doc) {
        return RequestCategoryModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
      requestCategoryList.assignAll(fetchedList);

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

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
      
      final snapshot = await _requestCategoriesService.fetchRequestCategory(
        limit: pageSize,
        lastdocument: lastDocument,
      );

      final newUsers = snapshot.docs.map((doc) {
        return RequestCategoryModel.fromMap(doc.data(), docId: doc.id);
      }).toList();

      requestCategoryList.addAll(newUsers);

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

  //submit form
  Future<bool> submitform(BuildContext context) async {
    try {
      isLoading.value = true;

      // 2. Current live time generate karein
      final currentTimestamp = DateTime.now();

      // 3. Model prepare karein
      final RequestCategoryModel _requestCategoryModel = RequestCategoryModel(
        name: titleController.text,
        description: descriptionController.text,
        isActive: isToggled.value,
        createdAt: currentTimestamp,
        updatedAt: currentTimestamp,
      );

      //  Firebase  par save
      await _requestCategoriesService.uploadRequestCategory(
        customDocId: categoryIdController.text.toLowerCase(),
        _requestCategoryModel,
      );
      // await _announcementService.uploadAnnouncement(announcementModel);

      //  Close dialog & reset
      if (context.mounted) {
        context.pop();
      }
      _resetForm();

      // Refresh list to fetch newly uploaded category
      await fetchfirstPage(forceRefresh: true);

      Get.snackbar(
        "Success",
        "Category published successfully!",
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

  //toggle publish
  Future<void> togglePublishStatus(
    RequestCategoryModel item,
    bool newValue,
  ) async {
    try {
      if (item.id == null || item.id!.isEmpty) return;
      //fetching the required data

      final reference = FirebaseFirestore.instance
          .collection('requestCategories')
          .doc(item.id);
      //assigning new value

      await reference.update({
        'isActive': newValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await reference.get();
      //
      final index = requestCategoryList.indexWhere(
        (categories) => categories.id == item.id,
      );
      if (snapshot.exists && index != -1) {
        requestCategoryList[index] = RequestCategoryModel.fromMap(
          snapshot.data()!,
          docId: snapshot.id,
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
    }
  }

  //delete
  Future<void> deleteCategory(RequestCategoryModel item) async {
    if (item.id == null || item.id!.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection("requestCategories")
          .doc(item.id)
          .delete();
      //deleting from list
      requestCategoryList.removeWhere((element) {
        return element.id == item.id;
      });
      Get.snackbar(
        "Success",
        "Category deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (err) {
      debugPrint('error $err');
      Get.snackbar(
        "Error",
        "Failed to delete category: $err",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
