import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class EditProfileController extends GetxController {
  final _box = GetStorage();
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final locationController = TextEditingController();
  final websiteController = TextEditingController();
  final emailController = TextEditingController();

  final RxBool isSaving = false.obs;
  final RxBool hasChanges = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentData();
    _watchChanges();
  }

  void _loadCurrentData() {
    nameController.text = _box.read('user_name') ?? 'Deeen Code';
    usernameController.text = '@Deeen_crypto';
    bioController.text = 'DeFi enthusiast · Long-term holder · BTC & ETH maxi';
    locationController.text = 'Lagos, Nigeria';
    websiteController.text = 'Deeencrypto.io';
    emailController.text = _box.read('user_email') ?? 'Deeen@email.com';
  }

  void _watchChanges() {
    for (final c in [
      nameController,
      usernameController,
      bioController,
      locationController,
      websiteController,
    ]) {
      c.addListener(() => hasChanges.value = true);
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    _box.write('user_name', nameController.text);
    _box.write('user_email', emailController.text);
    isSaving.value = false;
    hasChanges.value = false;
    Get.back();
    Get.snackbar(
      '✅ Profile Updated',
      'Your profile has been saved successfully.',
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  String? validateName(String? v) {
    if (v == null || v.isEmpty) return 'Name is required';
    if (v.length < 2) return 'Too short';
    return null;
  }

  String? validateUsername(String? v) {
    if (v == null || v.isEmpty) return 'Username is required';
    return null;
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    locationController.dispose();
    websiteController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
