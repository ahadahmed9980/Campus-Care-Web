import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/user_model.dart';
import 'package:customer_care_webapp/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllUserscontroller extends GetxController {
  TextEditingController searchcontroller = TextEditingController();
  UserService userService = UserService();
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  
  RxList<UserModel> userList = <UserModel>[].obs;
  var isLoading = false.obs;
  var deletingId = "".obs;
  int pageSize = 5;
  
 
  RxBool hasNextPage = true.obs;

  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    fetchfirstPage();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchcontroller.dispose();
    super.onClose();
  }

  Future<void> fetchfirstPage({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (userList.isNotEmpty && !forceRefresh) return;

    try {
      isLoading.value = true;
      if (forceRefresh) {
        lastDocument = null;
        hasNextPage.value = true;
      }
      final snapshot = await userService.fetchUser(limit: pageSize);
      userList.value = snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), docId: doc.id);
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
      final snapshot = await userService.fetchUser(
        limit: pageSize,
        lastdocument: lastDocument,
      );
      
      final newUsers = snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
      
      userList.addAll(newUsers);
      
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

  void searchUsers(String queryVal) {
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
      //captial the first word
      final capitalizedQuery = queryText.isEmpty 
          ? "" 
          : queryText[0].toUpperCase() + queryText.substring(1);
//search
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where('fullName', isGreaterThanOrEqualTo: queryText)
          .where('fullName', isLessThanOrEqualTo: '$queryText\uf8ff')
          .limit(pageSize)
          .get();
          //converting to object so we can use it

      final list = snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
      //checking if user eter small if its available in db show it 

      if (capitalizedQuery != queryText) {
        final capSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .where('fullName', isGreaterThanOrEqualTo: capitalizedQuery)
            .where('fullName', isLessThanOrEqualTo: '$capitalizedQuery\uf8ff')
            .limit(pageSize)
            .get();
            
        for (var doc in capSnapshot.docs) {
          final user = UserModel.fromMap(doc.data(), docId: doc.id);
          if (!list.any((u) => u.id == user.id)) {
            list.add(user);
          }
        }
      }

      userList.assignAll(list);
      lastDocument = null;
      hasNextPage.value = false;
    } catch (e) {
      debugPrint("Error searching users: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(UserModel user) async {
    if (user.id == null || user.id!.isEmpty) return;
    try {
      deletingId.value = user.id!;
      
      // Delete user document from Firestore (this triggers auth delete if trigger exists)
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.id)
          .delete();
          
      // Remove from local list
      userList.removeWhere((element) => element.id == user.id);
      
      Get.snackbar(
        "Success",
        "User deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (err) {
      debugPrint("Error deleting user: $err");
      Get.snackbar(
        "Error",
        "Failed to delete user: $err",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      deletingId.value = "";
    }
  }
}