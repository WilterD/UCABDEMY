import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/services/authenticate_firebase.dart';
import 'package:ucabdemy/services/firebase/firebase_connection_subjects.dart';
import 'package:ucabdemy/services/firebase/firebase_connection_teacher.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/button_general.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';
import 'package:ucabdemy/widgets_utils/textfield_general.dart';
import 'package:ucabdemy/widgets_utils/toast_widget.dart';

class AddTeacher extends StatefulWidget {
  const  AddTeacher({Key? key, this.element}) : super(key: key);

  final QueryDocumentSnapshot? element;

  @override
  State<AddTeacher> createState() => _AddTeacherState();
}

class _AddTeacherState extends State<AddTeacher> {

  double sizeH = 0;
  double sizeW = 0;
  bool loadLogin = false;
  bool viewPass = false;
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  Map<String,dynamic>? data;
  int posImage = 1;
  bool isEdit = false;

  List<QueryDocumentSnapshot> listSubjects = [];
  Map<String,bool> mapSelectedSubjects = {};


  @override
  void initState() {
    super.initState();
    isEdit = widget.element != null;
    if(isEdit){
      data = widget.element!.data() as Map<String,dynamic>;
      controllerName.text = data!['name'];
      List listS = data!['subjects'];
      for (var elementS in listS) {
        mapSelectedSubjects[elementS] = true;
      }
    }
    initialData();
  }

  Future initialData() async{
    listSubjects = await FirebaseConnectionSubjects().getAllSubjects();
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
                child: Text(widget.element != null ? 'Editar profesor' : 'Agregar profesor',style: UcademyStyles().stylePrimary(size: sizeH * 0.03,color: UcabdemyColors.primary,fontWeight: FontWeight.bold,),textAlign: TextAlign.center),
              ),
              SizedBox(height: sizeH * 0.05,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
                child: TextFieldGeneral(
                  sizeH: sizeH,
                  sizeW: sizeW,
                  hintText: 'Nombre',
                  labelStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.w500, color: Colors.grey),
                  textEditingController: controllerName,
                  initialValue: null,
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                ),
              ),
              if(!isEdit)...[
                SizedBox(height: sizeH * 0.025,),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
                  child: TextFieldGeneral(
                    sizeH: sizeH,
                    sizeW: sizeW,
                    hintText: 'Correo',
                    labelStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.w500, color: Colors.grey),
                    textEditingController: controllerEmail,
                    initialValue: null,
                    textInputType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                  ),
                ),
                SizedBox(height: sizeH * 0.025,),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
                  child: TextFieldGeneral(
                    sizeH: sizeH,
                    sizeW: sizeW,
                    hintText: 'Contraseña',
                    labelStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.w500, color: Colors.grey),
                    textEditingController: controllerPass,
                    initialValue: null,
                    textInputType: TextInputType.visiblePassword,
                    obscure: !viewPass,
                    suffixIcon: InkWell(
                      onTap: (){
                        setState(() {
                          viewPass = !viewPass;
                        });
                      },
                      child: Icon(viewPass ? Icons.remove_red_eye_outlined : Icons.remove_red_eye),
                    ),
                  ),
                ),
              ],
              SizedBox(height: sizeH * 0.025,),
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
                  title: widget.element != null ? 'Editar' : 'agregar',
                  height: sizeH * .06,
                  width: sizeW * .8,
                  borderColor: UcabdemyColors.primary,
                  textStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.bold,color: Colors.white),
                  onPressed: ()=>isEdit ? editTeacher() : saveTeacher(),
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

  Future<void> saveTeacher() async{

    loadLogin = true;
    setState(() {});

    FocusScope.of(context).requestFocus(FocusNode());

    String errorText = '';

    if(errorText.isEmpty && controllerName.text.isEmpty){
      errorText = 'Nombre no puede estar vacio';
    }
    if(errorText.isEmpty && controllerEmail.text.isEmpty){
      errorText = 'Correo no puede estar vacio';
    }
    if(errorText.isEmpty && controllerPass.text.isEmpty){
      errorText = 'Contraseña no puede estar vacia';
    }

    List<String> listIdSubjects = [];
    mapSelectedSubjects.forEach((key, value) {
      if(value){
        listIdSubjects.add(key);
      }
    });

    if(listIdSubjects.isEmpty){
      errorText = 'Debe seleccionar al menos una materia';
    }

    if(errorText.isEmpty){
      try{
        Map<String,dynamic> data = await AuthenticateFirebaseUser().registerFirebase(email: controllerEmail.text, password: controllerPass.text,alias: controllerName.text);
        if(data.containsKey('user')){
          Map<String,dynamic> body = {
            'name' : controllerName.text,
            'uid' : data['user'].uid,
            'subjects' : listIdSubjects,
          };
          bool result = await FirebaseConnectionTeachers().createTeacher(body);
          if(result){
            showAlert(text: widget.element != null ? 'Editado' : 'Creado',color: Colors.green);
            Navigator.of(context).pop();
          }else{
            showAlert(text: widget.element != null ? 'No se pudo editar' : 'No se pudo crear',color: Colors.redAccent);
          }
        }else{
          String error = data.containsKey('error') ? data['error'] : 'Problemas de conexión con el servidor';
          showAlert(text: error,color: Colors.redAccent);
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

  Future<void> editTeacher() async{

    loadLogin = true;
    setState(() {});

    FocusScope.of(context).requestFocus(FocusNode());

    String errorText = '';

    if(errorText.isEmpty && controllerName.text.isEmpty){
      errorText = 'Nombre no puede estar vacio';
    }

    List<String> listIdSubjects = [];
    mapSelectedSubjects.forEach((key, value) {
      if(value){
        listIdSubjects.add(key);
      }
    });

    if(listIdSubjects.isEmpty){
      errorText = 'Debe seleccionar al menos una materia';
    }

    if(errorText.isEmpty){
      try{
        Map<String,dynamic> body = {
          'name' : controllerName.text,
          'uid' : data!['uid'],
          'subjects' : listIdSubjects,
        };
        bool result = await FirebaseConnectionTeachers().editTeacher(data: body,id: widget.element!.id);
        if(result){
          showAlert(text: 'Editado',color: Colors.green);
          Navigator.of(context).pop();
        }else{
          showAlert(text: 'No se pudo editar',color: Colors.redAccent);
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
