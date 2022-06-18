import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/provider/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/button_general.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';
import 'package:ucabdemy/widgets_utils/textfield_general.dart';
import 'package:ucabdemy/widgets_utils/toast_widget.dart';
import 'package:video_player/video_player.dart';

class SaveVideo extends StatefulWidget {
  const SaveVideo({Key? key}) : super(key: key);

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

  XFile? video;

  @override
  void initState() {
    super.initState();
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
      body: containerHome(),
    );
  }

  Widget containerHome(){
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: sizeH * 0.1,),
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
          SizedBox(height: sizeH * 0.05,),
          addVideo(),
          SizedBox(height: sizeH * 0.05,),
          loadSave ?
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
              onPressed: ()=> saveData(),
            ),
          ),
        ],
      ),
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



    //userProvider!.updateListVideos(pathNew: video2.path);
  }

  Future saveData() async{
    loadSave = true;
    setState(() {});

    FocusScope.of(context).requestFocus(FocusNode());

    String errorText = '';
    if(errorText.isEmpty && controllerTitle.text.isEmpty){
      errorText = 'Título no puede estar vacio';
    }
    if(errorText.isEmpty && video == null){
      errorText = 'Debe agregar un video';
    }

    if(errorText.isEmpty){
      String pathNew = '${controllerTitle.text}|${controllerDescription.text}|${video!.path}';
      userProvider!.updateListVideos(pathNew: pathNew);
      Navigator.of(context).pop();
    }else{
      showAlert(text: errorText,color: Colors.redAccent);
    }

    loadSave = false;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    if(_controller != null){
      _controller!.dispose();
    }
  }
}