import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/campusinfo_model.dart';
import 'package:customer_care_webapp/models/day_timing_model.dart';
import 'package:customer_care_webapp/services/campus_info_service.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/state_manager.dart';
import 'package:go_router/go_router.dart';

class CampusController extends GetxController {
  TextEditingController searchController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController buildingController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  RxList<String> campusinfoCategoryList = <String>[
    "University Offices",
    "Academic Facilities",
    "Student Services",
    "Library",
    "Health & Medical",
    "IT Services",
    "Emergency Contacts",
    "Campus Facilities",
    "Transportation",
    "Food & Dining",
    "Sports & Recreation",
    "Other",
    "Hostel Office",
  ].obs;
  RxString selectedCategory = "".obs;
  var isToggled = false.obs;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  var isLoading = false.obs;
  CampusInformationModel campusInfoModel = CampusInformationModel();
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  RxList<CampusInformationModel> campusInfoList =
      <CampusInformationModel>[].obs;
  int pageSize = 5;

  RxBool hasNextPage = true.obs;
  //timing
  final timings = <DayTimingModel>[
    DayTimingModel(name: "Monday"),
    DayTimingModel(name: "Tuesday"),
    DayTimingModel(name: "Wednesday"),
    DayTimingModel(name: "Thursday"),
    DayTimingModel(name: "Friday"),
    DayTimingModel(name: "Saturday"),
  ].obs;

  @override
  void onInit() {
    fetchfirstPage();
    super.onInit();
  }


  //reset form
 void _resetForm() {
  // 1. Clear all text controllers
  titleController.clear();
  descriptionController.clear();
  phoneController.clear();
  emailController.clear();
  websiteController.clear();
  buildingController.clear();
  floorController.clear();
  roomController.clear();

  // 2. Reset reactive variables
  selectedCategory.value = '';
  isToggled.value = false;

  // 3. Reset timings list
  for (var day in timings) {
    day.isOpen = false;
    day.open = null;
    day.close = null;
  }
  timings.refresh(); // UI update karne ke liye
}
  //dispose to prtect data leakage
  @override
  void onClose() {
    searchController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    floorController.dispose();
    roomController.dispose();
    buildingController.dispose();

    super.onClose();
  }

  //date picker
  Future<void> openTimePicker(BuildContext context, int index) async {
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

    timings[index].open = time;
    timings.refresh();
  }

  Future<void> closeTimePicker(BuildContext context, int index) async {
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

    timings[index].close = time;
    timings.refresh();
  }
  //converting timing list to map

  Map<String, dynamic> getFormattedTimings() {
    final Map<String, dynamic> map = {};
    for (var day in timings) {
      map[day.name.toLowerCase()] = {
        'isOpen': day.isOpen,
        'open': (day.isOpen && day.open != null)
            ? '${day.open!.hour.toString().padLeft(2, '0')}:${day.open!.minute.toString().padLeft(2, '0')}'
            : null,
        'close': (day.isOpen && day.close != null)
            ? '${day.close!.hour.toString().padLeft(2, '0')}:${day.close!.minute.toString().padLeft(2, '0')}'
            : null,
      };
    }
    return map;
  }

  //fetching service
  Future<void> fetchfirstPage({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (campusInfoList.isNotEmpty && !forceRefresh) return;

    try {
      isLoading.value = true;
      if (forceRefresh) {
        lastDocument = null;
        hasNextPage.value = true;
      }
      final snapshot = await CampusInfoService().fetchCampusinfo(
        limit: pageSize,
      );

      // CHANGE 2: assignAll use karein taake list properly update ho aur UI react kare
      final fetchedList = snapshot.docs.map((doc) {
        return CampusInformationModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
      campusInfoList.assignAll(fetchedList);

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

      final snapshot = await CampusInfoService().fetchCampusinfo(
        limit: pageSize,
        lastdocument: lastDocument,
      );

      final newUsers = snapshot.docs.map((doc) {
        return CampusInformationModel.fromMap(doc.data(), docId: doc.id);
      }).toList();

      campusInfoList.addAll(newUsers);

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

  //uploadingservice;
  Future<bool> submitform(BuildContext context) async {
    try {
      isLoading.value = true;

      //  Current live time generate 
      final currentTimestamp = DateTime.now();

      // Model prepare 
      final CampusInformationModel _campusinfoModel = CampusInformationModel(
        title: titleController.text,
        description: descriptionController.text,
        category: selectedCategory.value,
        phone: phoneController.text,
        email: emailController.text,
        website: websiteController.text,
        building: buildingController.text,
        room: roomController.text,
        floor: floorController.text,
        isActive: isToggled.value,
        createdAt: currentTimestamp,
        updatedAt: currentTimestamp,
        timings: Map.fromEntries(
          timings.map(
            (day) => MapEntry(day.name.toLowerCase(), {
              'isOpen': day.isOpen,
              'open': (day.isOpen && day.open != null)
                  ? '${day.open!.hour.toString().padLeft(2, '0')}:${day.open!.minute.toString().padLeft(2, '0')}'
                  : null,
              'close': (day.isOpen && day.close != null)
                  ? '${day.close!.hour.toString().padLeft(2, '0')}:${day.close!.minute.toString().padLeft(2, '0')}'
                  : null,
            }),
          ),
        ),
      );

      //  Firebase  par save
      await CampusInfoService().uploadCampusinfo(
        _campusinfoModel
       
    
      );
     

      //  Close dialog & reset
      if (context.mounted) {
        context.pop();
      }
      _resetForm();

      // Refresh list to fetch newly uploaded category
      await fetchfirstPage(forceRefresh: true);

      Get.snackbar(
        "Success",
        "Campus info published successfully!",
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

  //toggle publish status
  Future<void> togglePublishStatus(
    CampusInformationModel item,
    bool newValue,
  ) async {
    try {
      if (item.id == null || item.id!.isEmpty) return;

      final reference = FirebaseFirestore.instance
          .collection('campusInformation')
          .doc(item.id);

      await reference.update({
        'isActive': newValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await reference.get();
      final index = campusInfoList.indexWhere(
        (info) => info.id == item.id,
      );
      if (snapshot.exists && index != -1) {
        campusInfoList[index] = CampusInformationModel.fromMap(
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
  Future<void> deleteCampusInfo(CampusInformationModel item) async {
    if (item.id == null || item.id!.isEmpty) return;
    try {
      await CampusInfoService().deleteCampusinfo(item.id!);
      
      //deleting from list
      campusInfoList.removeWhere((element) {
        return element.id == item.id;
      });
      Get.snackbar(
        "Success",
        "Campus info deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (err) {
      debugPrint('error $err');
      Get.snackbar(
        "Error",
        "Failed to delete campus info: $err",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
