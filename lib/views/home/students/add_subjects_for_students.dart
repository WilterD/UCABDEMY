import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/services/firebase/firebase_connection_students.dart';
import 'package:ucabdemy/services/firebase/firebase_connection_subjects.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/button_general.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';
import 'package:ucabdemy/widgets_utils/toast_widget.dart';

class AddSubjectsForStudent extends StatefulWidget {
  const  AddSubjectsForStudent({Key? key, required this.idUser}) : super(key: key);

  final String idUser;

  @override
  State<AddSubjectsForStudent> createState() => _AddSubjectsForStudentState();
}

class _AddSubjectsForStudentState extends State<AddSubjectsForStudent> {

  double sizeH = 0;
  double sizeW = 0;
  bool loadLogin = false;
  bool loadData = true;
  Map<String,dynamic>? data;

  List<QueryDocumentSnapshot> listSubjects = [];
  Map<String,bool> mapSelectedSubjects = {};
  QueryDocumentSnapshot? dataUser;


  @override
  void initState() {
    super.initState();
    initialData();
  }

  Future initialData() async{

    listSubjects = await FirebaseConnectionSubjects().getAllSubjects();
    for (var element in listSubjects) {
      mapSelectedSubjects[element.id] = false;
    }

    List<QueryDocumentSnapshot> listStudents = await FirebaseConnectionStudents().getStudent(id: widget.idUser);
    if(listStudents.isNotEmpty){
      dataUser = listStudents[0];
    }else{
      await FirebaseConnectionStudents().createStudent({'uid' : widget.idUser, 'listSubjects' : []});
      listStudents = await FirebaseConnectionStudents().getStudent(id: widget.idUser);
      dataUser = listStudents[0];
    }

    List listSubjectsStudents = dataUser!['listSubjects'];
    for (var element in listSubjectsStudents) {
      mapSelectedSubjects[element] = true;
    }

    loadData = false;
    setState(() {});
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
          title: 'PROFESOR',
          onTap: ()=>Navigator.of(context).pop(),
        ),
        backgroundColor: UcabdemyColors.primary_5,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: sizeH * 0.05,),
              //iconApp(),
              SizedBox(
                width: sizeW,
                child: Text('Seleccionar mis materias',style: UcademyStyles().stylePrimary(size: sizeH * 0.03,color: UcabdemyColors.primary,fontWeight: FontWeight.bold,),textAlign: TextAlign.center),
              ),
              SizedBox(height: sizeH * 0.05,),
              selectedImage(),
              SizedBox(height: sizeH * 0.04,),
              loadLogin ?
              Container(
                margin: EdgeInsets.symmetric(vertical: sizeH * 0.026),
                child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.04),
              )
                  :
              Container(
                margin: EdgeInsets.symmetric(vertical: sizeH * 0.02),
                child: ButtonGeneral(
                  backgroundColor: UcabdemyColors.primary,
                  radius: 10,
                  title: 'Guardar',
                  height: sizeH * .06,
                  width: sizeW * .8,
                  borderColor: UcabdemyColors.primary,
                  textStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.bold,color: Colors.white),
                  onPressed: ()=> save(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget selectedImage(){

    List<Widget> listW = [];
    for(int x = 0; x < listSubjects.length; x++){

      QueryDocumentSnapshot elementListSubjects = listSubjects[x];
      Map<String,dynamic> dataListSubjects = elementListSubjects.data() as Map<String,dynamic>;
      bool isSelected = mapSelectedSubjects[elementListSubjects.id] ?? false;

      listW.add(
        InkWell(
          onTap: (){
            if(mapSelectedSubjects.containsKey(elementListSubjects.id)){
              mapSelectedSubjects[elementListSubjects.id] = !mapSelectedSubjects[elementListSubjects.id]!;
            }else{
              mapSelectedSubjects[elementListSubjects.id] = true;
            }
            setState(() {});
          },
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 70,height: 70,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  image: DecorationImage(
                      image: Image.asset('assets/image/${dataListSubjects['posImage']}.png').image,
                      fit: BoxFit.contain
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
              SizedBox(
                width: sizeW * 0.3,
                child: Text(dataListSubjects['name'],textAlign: TextAlign.center,
                style: UcademyStyles().stylePrimary(size: sizeH * 0.02,fontWeight: FontWeight.w400,)),
              )
            ],
          ),
        )
      );
    }
    return Container(
      width: sizeW,
      height: sizeH * 0.4,
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: sizeW * 0.05),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: listW,
        ),
      ),
    );
  }

  Future<void> save() async{

    loadLogin = true;
    setState(() {});

    FocusScope.of(context).requestFocus(FocusNode());

    String errorText = '';

    List<String> listIdSubjects = [];
    mapSelectedSubjects.forEach((key, value) {
      if(value){
        listIdSubjects.add(key);
      }
    });

    if(errorText.isEmpty){
      try{
        Map<String,dynamic> body = {
          'ref' : dataUser!['ref'],
          'uid' : widget.idUser,
          'listSubjects' : listIdSubjects
        };
        bool res = await FirebaseConnectionStudents().editStudent(id: dataUser!['ref'],data: body);
        if(res){
          showAlert(text: 'Guardado',color: Colors.green);
          Navigator.of(context).pop();
        }else{
          showAlert(text: 'No se pudo guardar',color: Colors.redAccent);
        }
      }catch(e){
        showAlert(text: 'Error de conexión con el servidor',color: Colors.redAccent);
      }
    }else{
      showAlert(text: errorText,color: Colors.redAccent);
    }
    loadLogin = false;
    setState(() {});
  }
}
