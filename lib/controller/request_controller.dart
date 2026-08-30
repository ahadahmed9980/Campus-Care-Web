import 'dart:async';
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
  RxBool hasNextPage = true.obs;

  RxList<String> status = [
    "All Status",
    'Submitted',
    "In Progress",
    'Under Review',
    'Resolved',
  ].obs;
  RxString selectedStatus = "All Status".obs;

  RxList<String> priority = ["All Priority", "low", "medium", 'high'].obs;
  RxString selectedPriority = "All Priority".obs;

  RxList<String> categories = ["All Categories"].obs;
  RxString selectedCategory = "All Categories".obs;

  Timer? _searchDebounce;
  bool _isResettingFilters = false;

  @override
  void onInit() {
    super.onInit();
    fetchFirstPage();
    fetchCategories();

    // Listen to filter changes and automatically refresh requests
    selectedStatus.listen((val) {
      if (_isResettingFilters) return;
      searchrbar.clear();
      fetchFirstPage(forceRefresh: true);
    });
    selectedPriority.listen((val) {
      if (_isResettingFilters) return;
      searchrbar.clear();
      fetchFirstPage(forceRefresh: true);
    });
    selectedCategory.listen((val) {
      if (_isResettingFilters) return;
      searchrbar.clear();
      fetchFirstPage(forceRefresh: true);
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchrbar.dispose();
    super.onClose();
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("requestCategories")
          .get();
      final list = snapshot.docs
          .map((doc) => doc.data()['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      categories.assignAll(["All Categories", ...list]);
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  // fetching pages
  Future<void> fetchFirstPage({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (requestList.isNotEmpty && !forceRefresh) return;

    try {
      isLoading.value = true;
      if (forceRefresh) {
        lastDocument = null;
        hasNextPage.value = true;
      }

      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
        "requests",
      );

      if (selectedStatus.value != "All Status") {
        query = query.where("status", isEqualTo: selectedStatus.value);
      }
      if (selectedPriority.value != "All Priority") {
        final p = selectedPriority.value;
        final capitalizedPriority = p[0].toUpperCase() + p.substring(1);
        query = query.where("priority", isEqualTo: capitalizedPriority);
      }
      if (selectedCategory.value != "All Categories") {
        // Find category ID by name
        final catSnapshot = await FirebaseFirestore.instance
            .collection("requestCategories")
            .where("name", isEqualTo: selectedCategory.value)
            .limit(1)
            .get();
        if (catSnapshot.docs.isNotEmpty) {
          query = query.where(
            "categoryId",
            isEqualTo: catSnapshot.docs.first.id,
          );
        } else {
          requestList.clear();
          lastDocument = null;
          hasNextPage.value = false;
          return;
        }
      }

      final snapshot = await query.limit(pageSize).get();
      requestList.value = snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data(), doc.id);
      }).toList();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }
      hasNextPage.value = snapshot.docs.length == pageSize;
    } catch (err) {
      debugPrint("Error fetching first page of requests: $err");
    } finally {
      isLoading.value = false;
    }
  }

  //fetch next page
  Future<void> fetchNextPage() async {
    if (!hasNextPage.value || lastDocument == null || isLoading.value) {
      return;
    }
    try {
      isLoading.value = true;
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
        "requests",
      );

      if (selectedStatus.value != "All Status") {
        query = query.where("status", isEqualTo: selectedStatus.value);
      }
      if (selectedPriority.value != "All Priority") {
        final p = selectedPriority.value;
        final capitalizedPriority = p[0].toUpperCase() + p.substring(1);
        query = query.where("priority", isEqualTo: capitalizedPriority);
      }
      if (selectedCategory.value != "All Categories") {
        final catSnapshot = await FirebaseFirestore.instance
            .collection("requestCategories")
            .where("name", isEqualTo: selectedCategory.value)
            .limit(1)
            .get();
        if (catSnapshot.docs.isNotEmpty) {
          query = query.where(
            "categoryId",
            isEqualTo: catSnapshot.docs.first.id,
          );
        } else {
          return;
        }
      }

      query = query.startAfterDocument(lastDocument!).limit(pageSize);
      final snapshot = await query.get();

      final newRequests = snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data(), doc.id);
      }).toList();
      requestList.addAll(newRequests);

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }
      hasNextPage.value = snapshot.docs.length == pageSize;
    } catch (err) {
      debugPrint("Error fetching next page of requests: $err");
    } finally {
      isLoading.value = false;
    }
  }

  void searchRequests(String queryVal) {
    final queryText = queryVal.trim();
    if (queryText.isNotEmpty) {
      _isResettingFilters = true;
      selectedStatus.value = "All Status";
      selectedPriority.value = "All Priority";
      selectedCategory.value = "All Categories";
      _isResettingFilters = false;
    }
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      await _executeSearch(queryVal);
    });
  }

  Future<void> _executeSearch(String queryVal) async {
    final queryText = queryVal.trim();
    if (queryText.isEmpty) {
      fetchFirstPage(forceRefresh: true);
      return;
    }

    try {
      isLoading.value = true;
      final capitalizedQuery = queryText.isEmpty
          ? ""
          : queryText[0].toUpperCase() + queryText.substring(1);

      final snapshot = await FirebaseFirestore.instance
          .collection("requests")
          .where('title', isGreaterThanOrEqualTo: queryText)
          .where('title', isLessThanOrEqualTo: '$queryText\uf8ff')
          .limit(pageSize)
          .get();

      final list = snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data(), doc.id);
      }).toList();

      if (capitalizedQuery != queryText) {
        final capSnapshot = await FirebaseFirestore.instance
            .collection("requests")
            .where('title', isGreaterThanOrEqualTo: capitalizedQuery)
            .where('title', isLessThanOrEqualTo: '$capitalizedQuery\uf8ff')
            .limit(pageSize)
            .get();

        for (var doc in capSnapshot.docs) {
          final req = RequestModel.fromMap(doc.data(), doc.id);
          if (!list.any((r) => r.id == req.id)) {
            list.add(req);
          }
        }
      }

      requestList.assignAll(list);
      lastDocument = null;
      hasNextPage.value = false;
    } catch (e) {
      debugPrint("Error searching requests: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
