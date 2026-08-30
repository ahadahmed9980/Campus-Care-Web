import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/department_model.dart';
import 'package:customer_care_webapp/services/department_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class DepartmentController extends GetxController {
  TextEditingController searchController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  TextEditingController emailController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  var isToggled = false.obs;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  var isLoading = false.obs;
  var deletingId = "".obs;
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  RxList<DepartmentModel> departmentList = <DepartmentModel>[].obs;
  int pageSize = 5;

  RxBool hasNextPage = true.obs;
  final RxSet<String> togglingIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchfirstPage();
  }

  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    phoneController.clear();
    emailController.clear();
    websiteController.clear();
    codeController.clear();
    isToggled.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    codeController.dispose();

    super.onClose();
  }

  // Page fetching service
  Future<void> fetchfirstPage({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (departmentList.isNotEmpty && !forceRefresh) return;

    try {
      isLoading.value = true;
      if (forceRefresh) {
        lastDocument = null;
        hasNextPage.value = true;
      }
      final snapshot = await DepartmentService().fetchDepartmentinfo(
        limit: pageSize,
      );
      departmentList.value = snapshot.docs.map((doc) {
        return DepartmentModel.fromMap(doc.data(), docId: doc.id);
      }).toList();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      // Update RxBool
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
      final snapshot = await DepartmentService().fetchDepartmentinfo(
        limit: pageSize,
        lastdocument: lastDocument,
      );

      final newUsers = snapshot.docs.map((doc) {
        return DepartmentModel.fromMap(doc.data(), docId: doc.id);
      }).toList();

      departmentList.addAll(newUsers);

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

  // Cloudinary and Firebase upload function
  Future<bool> submitform(BuildContext context) async {
    try {
      isLoading.value = true;
      final currentTimestamp = DateTime.now();

      final DepartmentModel deptModel = DepartmentModel(
        name: titleController.text.trim(),
        code: codeController.text.trim(),
        description: descriptionController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        website: websiteController.text.trim(),
        isActive: isToggled.value,
        createdAt: currentTimestamp,
        updatedAt: currentTimestamp,
      );

      await DepartmentService().uploadDepartmentInfo(deptModel);

      if (context.mounted) {
        context.pop();
      }
      _resetForm();

      // Refresh list to fetch newly uploaded department
      await fetchfirstPage(forceRefresh: true);

      Get.snackbar(
        "Success",
        "Department published successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true; // Success
    } catch (e) {
      debugPrint("Department Upload Error: $e");
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

  //toogle from table
  Future<void> togglePublishStatus(DepartmentModel item, bool newValue) async {
    if (item.id == null || item.id!.isEmpty) return;
    if (togglingIds.contains(item.id)) return;

    try {
      togglingIds.add(item.id!);

      final reference = FirebaseFirestore.instance
          .collection('departments')
          .doc(item.id);

      await reference.update({
        'isActive': newValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await reference.get();
      final index = departmentList.indexWhere((dept) => dept.id == item.id);
      if (snapshot.exists && index != -1) {
        departmentList[index] = DepartmentModel.fromMap(
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
    } finally {
      togglingIds.remove(item.id);
    }
  }

  //delete department
  Future<void> deleteDepartmentInfo(DepartmentModel item) async {
    if (item.id == null || item.id!.isEmpty) return;
    try {
      deletingId.value = item.id!;
      await DepartmentService().deleteDepartmentinfo(item.id!);

      //deleting from list
      departmentList.removeWhere((element) {
        return element.id == item.id;
      });
      Get.snackbar(
        "Success",
        "Department deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (err) {
      debugPrint('error $err');
      Get.snackbar(
        "Error",
        "Failed to delete department: $err",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      deletingId.value = "";
    }
  }
}
