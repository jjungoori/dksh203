import 'package:dksh203/DataController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'TasksListController.dart';

class AppLoadingController extends GetxController with GetSingleTickerProviderStateMixin{
  AnimationController? animationController;

  bool enabled = false;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void onClose() {
    animationController!.dispose();
    super.onClose();
  }

  void startAnimation() {
    // animationController!.reset();
    animationController!.forward();
  }
}

void main() async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(DataController());
  Get.put(TasksListController());
  DataController.instance.getData();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var appFadeController = Get.put(AppLoadingController());
    appFadeController.startAnimation();
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FadeTransition(opacity: Tween<double>(begin: 0, end: 1).animate(appFadeController.animationController!), child: MyHomePage()),
    );
  }
}



class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {

    // var items = [
    //   TaskItem(
    //     title: '수학',
    //     date: '2024.03.20',
    //     time: '1',
    //   ),
    //   TaskItem(
    //     title: '과학',
    //     date: '2021.10.11',
    //     time: '2',
    //   ),
    //   TaskItem(
    //     title: '영어',
    //     date: '2021.10.12',
    //     time: '1',
    //   ),
    //   TaskItem(
    //     title: '영어',
    //     date: '2021.10.12',
    //     time: '1',
    //   ),
    //   TaskItem(
    //     title: '영어',
    //     date: '2021.10.12',
    //     time: '1',
    //   ),
    // ];


    return Scaffold(
      backgroundColor: Color(0xff111111),
      body: Center(
        child: FittedBox(
          child: Column(
            children: [
              Text(
                '2학년 3반',
                style: TextStyle(
                  color: Color(0xff999999),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '예정된 수행평가',
                style: TextStyle(
                  color: Color(0xffeeeeee),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  //round, black, shadow
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xff101010),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff222222),
                      blurRadius: 10,
                      spreadRadius: 8,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Obx(
                      () => Tasks(taskItems: sortAndPopTaskItem(List.generate(DataController.instance.dataList.value.length, (index){
                        var data = DataController.instance.dataList.value[index];
                        return TaskItem(
                          title: data['title'],
                          date: data['date'],
                          time: data['time'],
                          description: data['description'],
                          id: data['id'],
                        );
                      }))),
                  )
                )
              ),
              SizedBox(height: 16),
              Obx(() => SizedBox(
                width: 400,
                child: TasksListController.instance.editMode.value
                    ? SizedBox(
                  width: 400,
                      child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                      Flexible(child: MyButton(title: "그만하기", onPressed: (){
                        TasksListController.instance.editMode.value = false;
                      }), flex: 1),
                      SizedBox(width: 16),
                      Expanded(child: MyButton(title: "추가하기", onPressed: (){
                        //bottom sheet with getx
                        Get.bottomSheet(
                          Container(
                            padding: EdgeInsets.all(16),
                            color: Color(0xff111111),
                            child: Column(
                              children: [
                                MyTextField.build(labelText: "과목", controller: TasksListController.instance.titleController),
                                SizedBox(height: 16),
                                // MyTextField.build(labelText: "날짜", controller: TasksListController.instance.dateController),
                                GestureDetector(
                                    onTap: (){
                                      Future<DateTime?> selectedDate = showDatePicker(
                                        builder: (BuildContext context, Widget? child) {
                                          return Theme(
                                            data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(
                                              primary: Color(0xffeeeeee),
                                              onPrimary: Color(0xff333333),
                                              // surface: Color(0xff333333),
                                              // onSurface: Color(0xffeeeeee),
                                            )),
                                            child: child!,
                                          );
                                        },
                                        context: context,
                                        initialDate: DateTime.now(), // Start with today's date
                                        firstDate: DateTime(2000), // Limit selection to after year 2000 (optional)
                                        lastDate: DateTime(2100), // Limit selection to before year 2100 (optional)
                                      );
                                      selectedDate.then((value) {
                                        if(value != null){
                                          TasksListController.instance.date.value = value.year.toString()+"."+value.month.toString().padLeft(2,"0")+"."+value.day.toString().padLeft(2,"0");
                                        }
                                      });
                                    },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0), // Adjust as needed
                                      border: Border.all(
                                        color: Color(0xff333333),
                                        width: 2.0,
                                      ),
                                    ),
                                    width: double.infinity,
                                    height: 50,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0), // Adjust as needed
                                      child: Obx(()=>Text(
                                        TasksListController.instance.date.value, // Replace with your desired text
                                        style: TextStyle(
                                          color: Color(0xffeeeeee),
                                        ),
                                      ),)
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                MyTextField.build(labelText: "N 교시", controller: TasksListController.instance.timeController),
                                SizedBox(height: 16),
                                MyTextField.build(labelText: "세부 설명", controller: TasksListController.instance.descriptionController),
                                SizedBox(height: 16),
                                // MyTextField.build(labelText: "작성자", controller: TasksListController.instance.authorController),
                                // SizedBox(height: 16),
                                MyButton(title: "추가하기", onPressed: (){
                                  DataController.instance.addDataWithFormat(
                                    title: TasksListController.instance.titleController.text,
                                    date: TasksListController.instance.date.value,
                                    time: TasksListController.instance.timeController.text,
                                    author: TasksListController.instance.authorController.text,
                                    description: TasksListController.instance.descriptionController.text
                                  );
                                  TasksListController.instance.titleController.clear();
                                  // TasksListController.instance.dateController.clear();
                                  TasksListController.instance.descriptionController.clear();
                                  TasksListController.instance.timeController.clear();
                                  TasksListController.instance.authorController.clear();
                                  Get.back();
                                }),
                              ],
                            ),
                          ),
                        );
                      }), flex: 2,)
                  ],),
                    )
                    : MyButton(
                  title: "목록 수정하기",
                  onPressed: () {
                    //show popup with getx
                    Get.defaultDialog(

                      title: "학번 남기기",
                      titleStyle: TextStyle(
                        color: Color(0xffeeeeee),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      confirm: MyButton(
                        title: "확인",
                        onPressed: () {
                          TasksListController.instance.enableEditMode();
                          Get.back();
                        },
                      ),
                      backgroundColor: Color(0xff111111),
                      content: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: MyTextField.build(labelText: "20300 홍길동", controller: TasksListController.instance.authorController),
                      ),
                    );
                  },
                ),
              ))
            ],
          ),
        ),
      )
    );
  }
}

//custom textfield with white color
class MyTextField
{
  static Widget build({
    required String labelText,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: Color(0xffeeeeee),
      ),
      cursorColor: Color(0xff999999),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Color(0xff444444),
        ),
        //cursor color
        // cursorColor: Color(0xff333333),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff333333),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff444444),
            width: 2,
          ),
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {

  var title;
  var onPressed;

  MyButton
  ({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xffeeeeee),
            fontSize: 20,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: Color(0xff333333),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

//function sort taskItem with date
List<TaskItem> sortAndPopTaskItem(List<TaskItem> taskItems){
  taskItems.sort((a, b) {
    String formattedStringA = a.date.replaceAll('.', '');
    String formattedStringB = b.date.replaceAll('.', '');
    return DateTime.parse(formattedStringA).compareTo(DateTime.parse(formattedStringB));
  });
  bool isExpired(DateTime date){
    return DateTime.now().isAfter(date) && !isSameWeek(date);
  }
  taskItems.removeWhere((element) => isExpired(DateTime.parse(element.date.replaceAll('.',  ''))));
  return taskItems;
}


class Tasks extends StatelessWidget {

  final List<TaskItem> taskItems;

  Tasks
  ({
    super.key,
    required this.taskItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: taskItems,
    );
  }
}

//func weekday to korean
String WeekdayToKorean(int week){
  switch(week){
    case 1:
      return "월";
    case 2:
      return "화";
    case 3:
      return "수";
    case 4:
      return "목";
    case 5:
      return "금";
    case 6:
      return "토";
    case 7:
      return "일";
      default:
        return "error";
  }
}

//func is same week to now
bool isSameWeek(DateTime date){
  DateTime now = DateTime.now();
  if(now.year == date.year && now.month == date.month && now.day == date.day){
    return true;
  }
  return false;
}

// TaskItem
class TaskItem extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String description;
  final String id;

  TaskItem({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.description,
    required this.id
  });


  @override
  Widget build(BuildContext context) {

    String formattedString = date.replaceAll('.', '');
    final weekend = WeekdayToKorean(DateTime.parse(formattedString).weekday);

    return Obx(() => Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children:[
                  Text(
                    title,
                    style: TextStyle(
                      color: Color(0xffeeeeee),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 16),
                  if(isSameWeek(DateTime.parse(formattedString).add(Duration(days: -1))))
                    Sticker(color: Color(0xffffcc00)),
                  if(isSameWeek(DateTime.parse(formattedString)))
                    Sticker(color: Colors.red)
                ]
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    weekend+"요일 "+time+"교시",
                    style: TextStyle(
                      color: Color(0xffeeeeee),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    child: Text(
                      description,
                      style: TextStyle(
                        color: Color(0xff888888),
                        fontSize: 16,
                      ),
                    ),
                    width: 164,
                    height: 22,
                  )
                ],
              ),
              Text(
                date,
                style: TextStyle(
                  color: Color(0xff888888),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Spacer(),
          if(TasksListController.instance.editMode.value)
            ElevatedButton(onPressed: (){
              DataController.instance.firestore.collection(DataController.instance.collectionName).doc(id).delete();
              DataController.instance.getData();
            }, child: Text("X"),
              style: ElevatedButton.styleFrom(
                primary: Color(0xff333333),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
        ],
      ),
    ));
  }
}

//red, yellow sticker widget
class Sticker extends StatelessWidget {
  final Color color;

  Sticker({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

