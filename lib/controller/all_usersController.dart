import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/user_model.dart';
import 'package:customer_care_webapp/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AllUserscontroller extends GetxController {
  TextEditingController searchcontroller = TextEditingController();
  UserService userService = UserService();
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  
  RxList<UserModel> userList = <UserModel>[].obs;
  var isLoading = false.obs;
  int pageSize = 5;
  
 
  RxBool hasNextPage = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchfirstPage();
  }

  @override
  void dispose() {
    searchcontroller.dispose();
    super.dispose();
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
}