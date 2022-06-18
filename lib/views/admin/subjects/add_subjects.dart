import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/services/firebase/firebase_connection_subjects.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/button_general.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';
import 'package:ucabdemy/widgets_utils/textfield_general.dart';
import 'package:ucabdemy/widgets_utils/toast_widget.dart';

class AddSubjects extends StatefulWidget {
  const AddSubjects({Key? key, this.element}) : super(key: key);

  final QueryDocumentSnapshot? element;

  @override
  State<AddSubjects> createState() => _AddSubjectsState();
}

class _AddSubjectsState extends State<AddSubjects> {

  double sizeH = 0;
  double sizeW = 0;
  bool loadLogin = false;
  bool viewPass = false;
  TextEditingController controllerName = TextEditingController();
  Map<String,dynamic>? data;
  int posImage = 1;

  @override
  void initState() {
    super.initState();
    if(widget.element != null){
      data = widget.element!.data() as Map<String,dynamic>;
      controllerName.text = data!['name'];
      posImage = data!['posImage'];
    }
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
        backgroundColor: UcabdemyColors.primary_5,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: sizeH * 0.15,),
              //iconApp(),
              SizedBox(
                width: sizeW,
                child: Text(widget.element != null ? 'Editar materia' : 'Agregar materia',style: UcademyStyles().stylePrimary(size: sizeH * 0.03,color: UcabdemyColors.primary,fontWeight: FontWeight.bold,),textAlign: TextAlign.center),
              ),
              SizedBox(height: sizeH * 0.15,),
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
                  onPressed: ()=>loginUser(),
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
    for(int x = 1; x < 51; x++){
      listW.add(
        InkWell(
          onTap: (){
            posImage = x;
            setState(() {});
          },
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            width: 70,height: 70,
            decoration: BoxDecoration(
              color: posImage == x ? Colors.blue : Colors.transparent,
              image: DecorationImage(
                image: Image.asset('assets/image/$x.png').image,
                fit: BoxFit.contain
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        )
      );
    }


    return Container(
      width: sizeW,
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: listW
        ),
      ),
    );
  }

  Future<void> loginUser() async{

    loadLogin = true;
    setState(() {});

    FocusScope.of(context).requestFocus(FocusNode());

    String errorText = '';
    if(errorText.isEmpty && controllerName.text.isEmpty){
      errorText = 'Nombre no puede estar vacio';
    }

    if(errorText.isEmpty){

      bool result = false;
      try{
        Map<String,dynamic> body = {
          'name' : controllerName.text,
          'posImage' : posImage,
          'inConference' : false,
        };

        if(widget.element != null){
          //EDITAR MATERIA
          result = await FirebaseConnectionSubjects().editSubjects(id: widget.element!.id,data: body);
        }else{
          //CREAR MATERIA
          result = await FirebaseConnectionSubjects().createSubjects(body);
        }
        if(result){
          showAlert(text: widget.element != null ? 'Editado' : 'Creado',color: Colors.green);
          Navigator.of(context).pop();
        }else{
          showAlert(text: widget.element != null ? 'No se pudo editar' : 'No se pudo crear',color: Colors.redAccent);
        }
      }catch(e){
        showAlert(text: 'Error',color: Colors.redAccent);
      }
    }else{
      showAlert(text: errorText,color: Colors.redAccent);
    }
    loadLogin = false;
    setState(() {});
  }
}
