import 'dart:typed_data';

import 'package:customer_care_webapp/models/announcement_model.dart';
import 'package:customer_care_webapp/services/announcement_service.dart';
import 'package:customer_care_webapp/services/cloudinary_storage.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  var isLoading = false.obs;

  // Image picker and storage
  final ImagePicker _imagePicker = ImagePicker();
  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  final Rxn<String> selectedImageName = Rxn<String>();

  final AnnouncementService _announcementService = AnnouncementService();

  void clearImage() {
    selectedImageBytes.value = null;
    selectedImageName.value = null;
  }

  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    selectedCategory.value = "";
    selectedPriority.value = "";
    selectedImageBytes.value = null;
    selectedImageName.value = null;
    expireAt.value = null;
  }

  @override
  void onClose() {
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

        // if (uploadedImageUrl == null) {
        //   Get.snackbar(
        //     "Upload Error",
        //     "Image upload nahi ho saki, dobara koshish karein.",
        //     backgroundColor: Colors.red,
        //     colorText: Colors.white,
        //   );
        //   return false;
        // }
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

      return true; // Success
    } catch (e) {
      print("Firebase Upload Error: $e");
      Get.snackbar(
        "Error",
        "Upload failed: $e",
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
}