import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/request_model.dart';
import 'package:customer_care_webapp/services/fetch_request_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestController extends GetxController {
  TextEditingController searchrbar = TextEditingController();
  FetchRequestService fetchRequestService = FetchRequestService();
  final RxList<RequestModel> requestList = <RequestModel>[].obs;
  var isLoading = false.obs;
  final int pageSize = 5;
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  bool hasNextPage = true;

  @override
  void onInit() {
    super.onInit();
    fetchFirstPage();
  }

  @override
  void dispose() {
    searchrbar.dispose();
    super.dispose();
  }

  RxList<String> status = [
    "All Status",
    'Submitted',
    "In Progress",
    'Under Review',
    'Resolved',
  ].obs;
  RxString selectedStatus = "All Status".obs;

  // fetching pages
  Future<void> fetchFirstPage() async {
    try {
      isLoading.value = true;
      final snapshot = await fetchRequestService.fetchingRequest(
        limit: pageSize,
      );
      requestList.value = snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data(), doc.id);
      }).toList();
      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }
      hasNextPage = snapshot.docs.length == pageSize;
    } catch (err, stack) {
      print("Error fetching first page of requests: $err");
      print(stack);
    } finally {
      isLoading.value = false;
    }
  }

  //fetch next page
  Future<void> fetchNextPage() async {
    if (!hasNextPage || lastDocument == null) {
      return;
    }
    try {
      isLoading.value = true;
      final snapshot = await fetchRequestService.fetchingRequest(
        limit: pageSize,
        lastDocumnt: lastDocument,
      );
      requestList.value = snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data(), doc.id);
      }).toList();
      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }
      hasNextPage = snapshot.docs.length == pageSize;
    } catch (err, stack) {
      print("Error fetching next page of requests: $err");
      print(stack);
    } finally {
      isLoading.value = false;
    }
  }
}
