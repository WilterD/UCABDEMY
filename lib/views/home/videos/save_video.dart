import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/provider/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ucabdemy/services/firebase/firebase_connection_students.dart';
import 'package:ucabdemy/services/firebase/firebase_connection_subjects.dart';
import 'package:ucabdemy/services/firebase/firebase_connection_teacher.dart';
import 'package:ucabdemy/services/http_connection.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/button_general.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';
import 'package:ucabdemy/widgets_utils/textfield_general.dart';
import 'package:ucabdemy/widgets_utils/toast_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SaveVideo extends StatefulWidget {
  const SaveVideo({Key? key, required this.idUser}) : super(key: key);
  final String idUser;

  @override
  State<SaveVideo> createState() => _SaveVideoState();
}

class _SaveVideoState extends State<SaveVideo> {

  double sizeH = 0;
  double sizeW = 0;
  VideoPlayerController? _controller;
  late UserProvider? userProvider;
  TextEditingController controllerTitle = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  bool loadSave = false;

  bool loadData = true;
  List<QueryDocumentSnapshot> listSubjects = [];
  QueryDocumentSnapshot? elementListSubjectsSelected;

  XFile? video;
  UploadTask? uploadTask;

  @override
  void initState() {
    super.initState();
    initialData();
  }

  Future initialData() async{

    List<QueryDocumentSnapshot> listSubjectsAll = await FirebaseConnectionSubjects().getAllSubjects();

    QueryDocumentSnapshot? dataUser;
    List<QueryDocumentSnapshot> listStudents = await FirebaseConnectionTeachers().getTeachers(id: widget.idUser);
    if(listStudents.isNotEmpty){
      dataUser = listStudents[0];
      List listSubjectsStudents = dataUser['subjects'] ?? [];

      for (var element in listSubjectsAll){
        if(listSubjectsStudents.contains(element.id)){
          listSubjects.add(element);
        }
      }
    }

    loadData = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;
    userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: appBarWidget(
        sizeH: sizeH,
        title: 'AGREGAR VIDEO',
        onTap: ()=>Navigator.of(context).pop(),
      ),
      backgroundColor: UcabdemyColors.primary_5,
      body: loadData ?
      Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: sizeH * 0.026),
          child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.04),
        ),
      ) :
      containerHome(),
    );
  }

  Widget containerHome(){
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: sizeH * 0.05,),
          addVideo(),
          SizedBox(height: sizeH * 0.05,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
            child: TextFieldGeneral(
              sizeH: sizeH,
              sizeW: sizeW,
              hintText: 'Título',
              labelStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.w500, color: Colors.grey),
              textEditingController: controllerTitle,
              initialValue: null,
              textInputType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
            ),
          ),
          SizedBox(height: sizeH * 0.025,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
            child: TextFieldGeneral(
              sizeH: sizeH,
              sizeW: sizeW,
              hintText: 'Descripción (Opcional)',
              maxLines: 50,
              padding: EdgeInsets.only(top: sizeH * 0.015,left: sizeW * 0.02,right: sizeW * 0.02),
              constraints: BoxConstraints(minHeight: sizeH * 0.15,maxHeight: sizeH * 0.15),
              labelStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.w500, color: Colors.grey),
              textEditingController: controllerDescription,
              initialValue: null,
              textInputType: TextInputType.multiline,
              textCapitalization: TextCapitalization.none,
            ),
          ),
          SizedBox(height: sizeH * 0.08,),
          textTitle(title: 'Seleccionar materia del video'),
          SizedBox(height: sizeH * 0.02,),
          selectedImage(),
          SizedBox(height: sizeH * 0.05,),
          loadSave ?
          progressUploadTask()
          // Container(
          //   margin: EdgeInsets.symmetric(vertical: sizeH * 0.026),
          //   child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.04),
          // )
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
              onPressed: ()=> saveData(),
            ),
          ),
        ],
      ),
    );
  }

  Widget textTitle({required String title}){
    return Container(
      width: sizeW,
      margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
      child: Text(title,style: UcademyStyles().stylePrimary(
        size: sizeH * 0.022,
        color: UcabdemyColors.primary,
        fontWeight: FontWeight.bold
      )),
    );
  }

  Widget addVideo(){
    return Column(
      children: [
        InkWell(
          onTap: () => recordVideo(),
          child: Container(
            width: sizeH * 0.3,
            height: sizeH * 0.3,
            margin: EdgeInsets.symmetric(horizontal: sizeW * 0.05),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            ),
            child: (_controller == null || !_controller!.value.isInitialized) ? Center(
              child: Icon(Icons.videocam,size: sizeH * 0.15,color: UcabdemyColors.primary),
            ) : ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
        ),
        (_controller == null || !_controller!.value.isInitialized) ? Container() :
        Container(
          width: sizeW,
          margin: EdgeInsets.symmetric(horizontal: sizeW * 0.05),
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  icon: Icon(
                      _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: _controller!.value.isPlaying ? Colors.red : Colors.green,
                      size: sizeH * 0.05),
                  onPressed: (){
                    setState(() {
                      _controller!.value.isPlaying
                          ? _controller!.pause()
                          : _controller!.play();
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Future recordVideo() async{
    ImagePicker _picker = ImagePicker();
    video = await _picker.pickVideo(source: ImageSource.camera,);
    if(video != null){
      _controller = VideoPlayerController.file(
          File(video!.path))..initialize().then((_) {

          _controller!.addListener(() {
            setState(() {});
          });
          setState(() {});
        });
    }
  }

  Widget selectedImage(){

    List<Widget> listW = [];
    for(int x = 0; x < listSubjects.length; x++){

      QueryDocumentSnapshot elementListSubjects = listSubjects[x];
      Map<String,dynamic> dataListSubjects = elementListSubjects.data() as Map<String,dynamic>;
      bool isSelected = false;
      if(elementListSubjectsSelected != null){
        isSelected = elementListSubjectsSelected!.id == elementListSubjects.id;
      }

      listW.add(
          InkWell(
            onTap: (){
              elementListSubjectsSelected = elementListSubjects;
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

  Widget progressUploadTask(){

    return uploadTask == null ? Container() :
    StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context,snapshot){
        if(snapshot.hasData){
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;
          return Container(
            height: sizeH * 0.05,
            margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1,vertical: sizeH * 0.02),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.green,
                  ),
                ),
                Center(
                  child: Text('${(100 * progress).roundToDouble()}%',
                      style: UcademyStyles().stylePrimary(size: sizeH * 0.02, color: Colors.white)),
                )
              ],
            ),
          );
        }
        return Container();
      },
    );

  }

  Future saveData() async{
    loadSave = true;
    setState(() {});

    FocusScope.of(context).requestFocus(FocusNode());

    String errorText = '';
    if(errorText.isEmpty && controllerTitle.text.isEmpty){
      errorText = 'Título no puede estar vacio';
    }
    if(errorText.isEmpty && elementListSubjectsSelected == null){
      errorText = 'Debe seleccionar una materia';
    }
    if(errorText.isEmpty && video == null){
      errorText = 'Debe agregar un video';
    }

    if(errorText.isEmpty){
      try{
        //SUBIR VIDEO

        String name = video!.path.split('/').last;
        final pathUpload = 'files/$name';
        final file = File(video!.path);

        final ref = FirebaseStorage.instance.ref().child(pathUpload);
        uploadTask = ref.putFile(file);
        setState(() {});

        final snapshot = await uploadTask!.whenComplete((){
          print('TERMINO');
        });
        final urlUpload = await snapshot.ref.getDownloadURL();

        //EDITAR MATERIA
        Map<String,dynamic> body = elementListSubjectsSelected!.data() as Map<String,dynamic>;
        List<dynamic> listStorage = [];
        if(body.containsKey('listStorage')){
          listStorage = body['listStorage'];
        }
        listStorage.add({
          'title' : controllerTitle.text,
          'description' : controllerDescription.text,
          'url' : urlUpload,
        });

        body['listStorage'] = listStorage;
        bool result = await FirebaseConnectionSubjects().editSubjects(id: elementListSubjectsSelected!.id,data: body);

        if(result){
          showAlert(text: 'Video guardado',color: Colors.green);
          await Future.delayed(const Duration(seconds: 2));
          Navigator.of(context).pop();
        }else{
          showAlert(text: 'No se guardar el video',color: Colors.redAccent);
        }
      }catch(e){
        print(e.toString());
        showAlert(text: 'Error al guardar video',color: Colors.redAccent);
      }
    }else{
      showAlert(text: errorText,color: Colors.redAccent);
    }

    loadSave = false;
    setState(() {});
  }

  // Future saveData() async{
  //   loadSave = true;
  //   setState(() {});
  //
  //   FocusScope.of(context).requestFocus(FocusNode());
  //
  //   String errorText = '';
  //   if(errorText.isEmpty && controllerTitle.text.isEmpty){
  //     errorText = 'Título no puede estar vacio';
  //   }
  //   if(errorText.isEmpty && video == null){
  //     errorText = 'Debe agregar un video';
  //   }
  //
  //   if(errorText.isEmpty){
  //
  //     try{
  //       Response response = await uploadVideo(pathVideo: video!.path);
  //       var value = jsonDecode(response.body);
  //       print('');
  //     }catch(e){
  //       print(e.toString());
  //     }
  //
  //     // String pathNew = '${controllerTitle.text}|${controllerDescription.text}|${video!.path}';
  //     // userProvider!.updateListVideos(pathNew: pathNew);
  //     // Navigator.of(context).pop();
  //   }else{
  //     showAlert(text: errorText,color: Colors.redAccent);
  //   }
  //
  //   loadSave = false;
  //   setState(() {});
  // }

  @override
  void dispose() {
    super.dispose();
    if(_controller != null){
      _controller!.dispose();
    }
  }
}