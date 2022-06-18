import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/views/admin/teacher/add_teacher.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';

class Teachers extends StatefulWidget {
  const Teachers({Key? key}) : super(key: key);

  @override
  State<Teachers> createState() => _TeachersState();
}

class _TeachersState extends State<Teachers> {

  double sizeH = 0;
  double sizeW = 0;

  final CollectionReference teachersCollection = FirebaseFirestore.instance.collection('teachers');

  @override
  Widget build(BuildContext context) {

    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: appBarWidget(
          sizeH: sizeH,
          title: 'PROFESORES',
          onTap: ()=>Navigator.of(context).pop(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>const AddTeacher(),),);
          },
          backgroundColor: UcabdemyColors.primary,
          child: Icon(Icons.add,color: Colors.white,size: sizeH * 0.03),
        ),
        backgroundColor: UcabdemyColors.primary_5,
        body: StreamBuilder<QuerySnapshot>(
          stream: teachersCollection.snapshots(),
          builder: (context,snapshot){
            if (snapshot.data == null){
              return Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: sizeH * 0.026),
                  child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.04),
                ),
              );
            }

            List<Widget> listW = [];

            for (var element in snapshot.data!.docs) {
              listW.add(
                containerSubjects(element)
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: listW,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget containerSubjects(QueryDocumentSnapshot element){

    Map<String,dynamic> data = element.data() as Map<String,dynamic>;

    return SizedBox(
      width: sizeW,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(data['name'],style: UcademyStyles().stylePrimary(size: sizeH * 0.025,fontWeight: FontWeight.bold,)),
              ),
              IconButton(
                icon: Icon(Icons.edit,size: sizeH * 0.03,color: Colors.blue),
                onPressed: ()=>editTeacher(element: element),
              ),
              IconButton(
                icon: Icon(Icons.delete,size: sizeH * 0.03,color: Colors.red),
                onPressed: () => deleteTeacher(id: element.id.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future editTeacher({required QueryDocumentSnapshot element}) async{
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>AddTeacher(element: element),),);
  }

  Future deleteTeacher({required String id}) async{
    await teachersCollection.doc(id).delete();
  }
}


