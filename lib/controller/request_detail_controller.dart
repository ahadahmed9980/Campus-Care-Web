import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/request_model.dart';
import 'package:customer_care_webapp/models/request_status_history_model.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestDetailController extends GetxController {
  var isLoading = false.obs;
  var isRemarksLoading = false.obs;
  var isDepartmentLoading = false.obs;
  var isStatusLoading = false.obs;
  var isError = false.obs;
  final TextEditingController resolutionInfo = TextEditingController();

  // Stored states
  final Rxn<RequestModel> request = Rxn<RequestModel>();
  final RxString categoryName = "Loading Category...".obs;
  final RxString departmentName = "Loading Department...".obs;
  final RxString userName = "Loading User...".obs;
  final RxList<RequestStatusHistoryModel> statusHistory =
      <RequestStatusHistoryModel>[].obs;

  RxList<String> departmentNames = <String>[].obs;
  var selectedDepartmentName = "".obs;
  Map<String, String> departmentNameToId = {};

  RxList<String> status = [
    'Submitted',
    'Under Review',
    "In Progress",
    'Resolved',
    'Closed',
  ].obs;
  var selectedStatus = "Under Review".obs;

  Future<void> fetchRequestDetails(String requestId) async {
    try {
      isLoading.value = true;
      isError.value = false;

      // 1. Fetch Request
      final reqDoc = await FirebaseFirestore.instance
          .collection("requests")
          .doc(requestId)
          .get();
      if (!reqDoc.exists || reqDoc.data() == null) {
        isError.value = true;
        return;
      }
      final requestModel = RequestModel.fromMap(reqDoc.data()!, reqDoc.id);
      request.value = requestModel;
      resolutionInfo.text = requestModel.resolutionInfo;

      // Safe case-insensitive mapping
      final matchedStatus = status.firstWhere(
        (s) =>
            s.trim().toLowerCase() == requestModel.status.trim().toLowerCase(),
        orElse: () => '',
      );

      if (matchedStatus.isNotEmpty) {
        selectedStatus.value = matchedStatus;
      } else {
        status.insert(0, requestModel.status);
        selectedStatus.value = requestModel.status;
      }

      // 2. Fetch Category
      if (requestModel.categoryId.isNotEmpty) {
        final catDoc = await FirebaseFirestore.instance
            .collection("requestCategories")
            .doc(requestModel.categoryId)
            .get();
        if (catDoc.exists && catDoc.data() != null) {
          categoryName.value =
              catDoc.data()!['name'] as String? ?? 'Unknown Category';
        } else {
          categoryName.value = 'Unknown Category';
        }
      } else {
        categoryName.value = 'No Category';
      }

      // 3. Fetch Department
      if (requestModel.assignedDepartmentId.isNotEmpty) {
        final deptDoc = await FirebaseFirestore.instance
            .collection("departments")
            .doc(requestModel.assignedDepartmentId)
            .get();
        if (deptDoc.exists && deptDoc.data() != null) {
          departmentName.value =
              deptDoc.data()!['name'] as String? ?? 'Unknown Department';
        } else {
          departmentName.value = 'Unknown Department';
        }
      } else {
        departmentName.value = 'No Department';
      }

      // 4. Fetch User Name
      if (requestModel.userId.isNotEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(requestModel.userId)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          userName.value =
              userDoc.data()!['fullName'] as String? ?? 'Unknown User';
        } else {
          userName.value = 'Unknown User';
        }
      } else {
        userName.value = 'Unknown User';
      }

      // 5. Fetch Status History
      final historySnapshot = await FirebaseFirestore.instance
          .collection("requests")
          .doc(requestId)
          .collection("statusHistory")
          .orderBy("createdAt", descending: false)
          .get();

      final historyList = historySnapshot.docs.map((doc) {
        return RequestStatusHistoryModel.fromMap(doc.data(), doc.id);
      }).toList();
      statusHistory.assignAll(historyList);

      // 6. Fetch all departments
      await fetchDepartments();
    } catch (e) {
      debugPrint("Error fetching request details: $e");
      isError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDepartments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("departments")
          .get();
      final List<String> names = [];
      final Map<String, String> nameToId = {};

      for (var doc in snapshot.docs) {
        final name = doc.data()['name'] as String? ?? '';
        if (name.isNotEmpty) {
          names.add(name);
          nameToId[name] = doc.id;
        }
      }
      departmentNames.assignAll(names);
      departmentNameToId = nameToId;

      // If selectedDepartmentName is empty but we have request assignedDepartmentId, match it from nameToId map!
      final req = request.value;
      if (req != null && req.assignedDepartmentId.isNotEmpty) {
        final matchedName = departmentNameToId.entries
            .firstWhere(
              (entry) => entry.value == req.assignedDepartmentId,
              orElse: () => const MapEntry('', ''),
            )
            .key;
        if (matchedName.isNotEmpty) {
          selectedDepartmentName.value = matchedName;
        }
      }
    } catch (e) {
      debugPrint("Error fetching departments in detail page: $e");
    }
  }

  Future<void> updateAssignedDepartment(String deptName) async {
    final req = request.value;
    if (req == null) return;

    final deptId = departmentNameToId[deptName];
    if (deptId == null) return;

    try {
      isDepartmentLoading.value = true;
      final now = Timestamp.now();

      await FirebaseFirestore.instance
          .collection("requests")
          .doc(req.id)
          .update({'assignedDepartmentId': deptId, 'updatedAt': now});

      // Also add to history!
      final historyData = {
        'status': req.status,
        'message': 'Assigned department updated to: $deptName',
        'changedBy': 'Admin',
        'changedByRole': 'admin',
        'createdAt': now,
      };

      await FirebaseFirestore.instance
          .collection("requests")
          .doc(req.id)
          .collection("statusHistory")
          .add(historyData);

      selectedDepartmentName.value = deptName;
      // refresh request details
      await fetchRequestDetails(req.id);

      Get.snackbar(
        "Success",
        "Assigned department updated to $deptName",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint("Error updating assigned department: $e");
      Get.snackbar(
        "Error",
        "Failed to update department: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDepartmentLoading.value = false;
    }
  }

  Future<void> updateStatus(String newStatus) async {
    final currentRequest = request.value;
    if (currentRequest == null) return;

    try {
      isStatusLoading.value = true;
      final now = Timestamp.now();

      final Map<String, dynamic> updateData = {
        'status': newStatus,
        'updatedAt': now,
      };

      String resolutionInfo = "";
      String resolvedBy = "";
      Timestamp? resolvedAt;

      if (newStatus == 'Resolved') {
        resolutionInfo = "Resolved by Admin via Panel";
        resolvedBy = "Admin";
        resolvedAt = now;

        updateData['resolutionInfo'] = resolutionInfo;
        updateData['resolvedBy'] = resolvedBy;
        updateData['resolvedAt'] = resolvedAt;
      }

      // 1. Update request document in Firestore
      await FirebaseFirestore.instance
          .collection("requests")
          .doc(currentRequest.id)
          .update(updateData);

      // 2. Add history document to statusHistory subcollection
      final historyData = {
        'status': newStatus,
        'message': newStatus == 'Resolved'
            ? 'Request resolved: $resolutionInfo'
            : 'Status updated to $newStatus',
        'changedBy': 'Admin',
        'changedByRole': 'admin',
        'createdAt': now,
      };

      await FirebaseFirestore.instance
          .collection("requests")
          .doc(currentRequest.id)
          .collection("statusHistory")
          .add(historyData);

      // 3. Refresh details locally to update UI
      await fetchRequestDetails(currentRequest.id);
    } catch (e) {
      debugPrint("Error updating request status: $e");
    } finally {
      isStatusLoading.value = false;
    }
  }

  // helper color status
  Color getStepColor(
    String stepName,
    String? currentStatus,
    Color activeColor,
  ) {
    if (currentStatus == null) return AppColors.grey;

    int currentIndex = status.indexOf(currentStatus);
    int stepIndex = status.indexOf(stepName);

    if (stepIndex <= currentIndex && currentIndex != -1) {
      return activeColor;
    }
    return AppColors.grey;
  }

  //line color
  Color getLineColor(
    String stepName,
    String? currentStatus,
    Color activeColor,
  ) {
    if (currentStatus == null) return Colors.transparent;
    int currentIndex = status.indexOf(currentStatus);
    int stepIndex = status.indexOf(stepName);

    if (stepIndex < currentIndex && currentIndex != -1) {
      return activeColor;
    }
    return Colors.transparent;
  }

  Future<void> updateResolutionInfo() async {
    final req = request.value;
    if (req == null) return;
    
    final text = resolutionInfo.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        "Warning",
        "Remarks cannot be empty",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isRemarksLoading.value = true;
      final now = Timestamp.now();
      
      await FirebaseFirestore.instance.collection("requests").doc(req.id).update({
        'resolutionInfo': text,
        'updatedAt': now,
      });
      
      // Also add to history!
      final historyData = {
        'status': req.status,
        'message': 'Remarks added: $text',
        'changedBy': 'Admin',
        'changedByRole': 'admin',
        'createdAt': now,
      };

      await FirebaseFirestore.instance
          .collection("requests")
          .doc(req.id)
          .collection("statusHistory")
          .add(historyData);
          
      // refresh request details
      await fetchRequestDetails(req.id);
      
      Get.snackbar(
        "Success",
        "Remarks updated successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint("Error updating remarks: $e");
      Get.snackbar(
        "Error",
        "Failed to update remarks: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isRemarksLoading.value = false;
    }
  }

  @override
  void onClose() {
    resolutionInfo.dispose();
    super.onClose();
  }
}
