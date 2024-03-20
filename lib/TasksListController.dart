import 'package:flutter/material.dart';
import 'package:get/get.dart';

//getx controller named TasksListController
class TasksListController extends GetxController {
  static TasksListController instance = Get.find();
  var editMode = false.obs;
  var editor = "".obs;

  //textfield controller
  TextEditingController authorController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  // TextEditingController dateController = TextEditingController();
  String date = "2021.01.01";
  TextEditingController timeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void enableEditMode() {
    if(authorController.value.text.isEmpty) {
      return;
    }

    editMode.value = true;
    editor.value = authorController.text;
  }
}