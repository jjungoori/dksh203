import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dksh203/main.dart';

//firestore items to taskItem function
// TaskItem taskItemFromFirestore(DocumentSnapshot doc) {
//   return TaskItem(
//     title: !doc['title'] ? "" : doc['title'],
//     date: !doc['date'] ? "" : doc['date'],
//     time: !doc['time'] ? "" : doc['time'],
//   );
// }

Map<String, dynamic> addPair(Map<String, dynamic> data, String id) {
  data['id'] = id;
  return data;
}


class DataController extends GetxController {
  // Firestore 인스턴스
  static DataController instance = Get.find();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 데이터 컬렉션 이름
  final String collectionName = 'items';

  // 데이터 목록
  var dataList = [].obs;
  // get datas => this.dataList.value;

  // 데이터 가져오기
  Future getData() async {
    try {
      // 컬렉션에서 데이터 가져오기
      var querySnapshot = await firestore.collection(collectionName).get();

      // 데이터 목록 업데이트
      dataList.value = querySnapshot.docs.map((doc) => addPair(doc.data(), doc.id)).toList();
      print(dataList.value);
    } catch (e) {
      print(e);
    }
  }

  Future addDataWithFormat({String title = "Unknown", String date = "3000.01.01", String time = "1", String author="Unknown", String description = "No further information."}) async {
    try {
      // 컬렉션에 데이터 추가
      await firestore.collection(collectionName).add({
        'title': title.isNotEmpty ? title : "Unknown",
        'date': date.isNotEmpty ? date : "3000.01.01",
        'time': time.isNotEmpty ? time : "1",
        'author': author.isNotEmpty ? author : "Unknown",
        'description': description.isNotEmpty ? description : "...",
      });

      // 데이터 목록 새로고침
      getData();
    } catch (e) {
      print(e);
    }
  }

  // 데이터 추가하기
  Future addData(Map<String, dynamic> data) async {
    try {
      // 컬렉션에 데이터 추가
      await firestore.collection(collectionName).add(data);

      // 데이터 목록 새로고침
      getData();
    } catch (e) {
      print(e);
    }
  }

  // 데이터 수정하기
  Future updateData(String docId, Map<String, dynamic> data) async {
    try {
      // 컬렉션의 특정 문서 업데이트
      await firestore.collection(collectionName).doc(docId).update(data);

      // 데이터 목록 새로고침
      getData();
    } catch (e) {
      print(e);
    }
  }

  // 데이터 삭제하기
  Future deleteData(String docId) async {
    try {
      // 컬렉션의 특정 문서 삭제
      await firestore.collection(collectionName).doc(docId).delete();

      // 데이터 목록 새로고침
      getData();
    } catch (e) {
      print(e);
    }
  }
}
