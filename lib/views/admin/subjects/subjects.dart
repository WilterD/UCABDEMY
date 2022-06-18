import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/views/admin/subjects/add_subjects.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';

class Subjects extends StatefulWidget {
  const Subjects({Key? key}) : super(key: key);

  @override
  State<Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {

  double sizeH = 0;
  double sizeW = 0;

  final CollectionReference subjectsCollection = FirebaseFirestore.instance.collection('subjects');

  @override
  void initState() {
    super.initState();
  }

  Future initialData() async{

  }

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
          title: 'MATERIAS',
          onTap: ()=>Navigator.of(context).pop(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>const AddSubjects(),),);
          },
          backgroundColor: UcabdemyColors.primary,
          child: Icon(Icons.add,color: Colors.white,size: sizeH * 0.03),
        ),
        backgroundColor: UcabdemyColors.primary_5,
        body: StreamBuilder<QuerySnapshot>(
          stream: subjectsCollection.snapshots(),
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
              Container(
                margin: const EdgeInsets.only(right: 20),
                width: 30,height: 30,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Image.asset('assets/image/${data['posImage']}.png').image,
                      fit: BoxFit.contain
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
              Expanded(
                child: Text(data['name'],style: UcademyStyles().stylePrimary(size: sizeH * 0.025,fontWeight: FontWeight.bold,)),
              ),
              IconButton(
                icon: Icon(Icons.edit,size: sizeH * 0.03,color: Colors.blue),
                onPressed: ()=>editSubjects(element: element),
              ),
              IconButton(
                icon: Icon(Icons.delete,size: sizeH * 0.03,color: Colors.red),
                onPressed: () => deleteSubjects(id: element.id.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future editSubjects({required QueryDocumentSnapshot element}) async{
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>AddSubjects(element: element),),);
  }

  Future deleteSubjects({required String id}) async{
    await subjectsCollection.doc(id).delete();
  }
}


