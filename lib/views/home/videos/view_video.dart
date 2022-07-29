import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/provider/user_provider.dart';
import 'package:ucabdemy/services/firebase/firebase_connection_subjects.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';
import 'package:ucabdemy/widgets_utils/dialog_alert.dart';
import 'package:ucabdemy/widgets_utils/toast_widget.dart';
import 'package:video_player/video_player.dart';

class ViewVideo extends StatefulWidget {
  const ViewVideo({Key? key, required this.pathVideo, required this.title, required this.elementList, required this.indexPos}) : super(key: key);
  final String pathVideo;
  final String title;
  final QueryDocumentSnapshot elementList;
  final int indexPos;

  @override
  State<ViewVideo> createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {

  double sizeH = 0;
  double sizeW = 0;
  late VideoPlayerController _controller;
  late UserProvider? userProvider;
  String title = '';

  @override
  void initState() {
    super.initState();
    title = widget.title;
    _controller = VideoPlayerController.network(
        widget.pathVideo,)..initialize().then((_) {
        _controller.setLooping(true);
        _controller.addListener(() {
          setState(() {});
        });
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;

    userProvider = Provider.of<UserProvider>(context);
    bool isTeacher = userProvider?.isTeacher ?? false;

    return Scaffold(
      appBar: appBarWidget(
        sizeH: sizeH,
        title: widget.title,
        onTap: ()=>Navigator.of(context).pop(),
        actions: isTeacher ? [
          IconButton(onPressed: (){
            deleteVideo();
          }, icon: Icon(Icons.delete,size: sizeH * 0.025,color: Colors.red,))
        ] : []
      ),
      backgroundColor: UcabdemyColors.primary_4,
      body: containerHome(),
      floatingActionButton: floatingActionButton(),
    );
  }

  Widget containerHome(){
    return Center(
      child: _controller.value.isInitialized
          ? AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      )
          : Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: sizeH * 0.026),
          child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.04),
        ),
      ),
    );
  }

  Widget floatingActionButton(){
    return FloatingActionButton(
      backgroundColor: UcabdemyColors.primary,
      onPressed: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
      child: Icon(
        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
      ),
    );
  }

  Future deleteVideo()async{
    bool? resultAlert = await alertDeleteVideo(context);
    if(resultAlert != null && resultAlert){
      try{
        await FirebaseStorage.instance.refFromURL(widget.pathVideo).delete();

        Map<String,dynamic> body = widget.elementList.data() as Map<String,dynamic>;
        List<dynamic> listStorage = [];
        if(body.containsKey('listStorage')){
          listStorage = body['listStorage'];
        }
        listStorage.removeAt(widget.indexPos);
        body['listStorage'] = listStorage;
        bool result = await FirebaseConnectionSubjects().editSubjects(id: widget.elementList.id,data: body);
        if(result){
          showAlert(text: 'Video eliminado guardado',color: Colors.green);
          Navigator.of(context).pop();
        }else{
          showAlert(text: 'No se pudo eliminar el video',color: Colors.redAccent);
        }
      }catch(e){
        print(e.toString());
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}