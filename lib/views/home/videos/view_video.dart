import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/provider/user_provider.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:video_player/video_player.dart';

class ViewVideo extends StatefulWidget {
  const ViewVideo({Key? key, required this.pathVideo, required this.title}) : super(key: key);
  final String pathVideo;
  final String title;

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
    _controller = VideoPlayerController.file(
        File(widget.pathVideo))..initialize().then((_) {
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
    return Scaffold(
      appBar: appBarWidget(
        sizeH: sizeH,
        title: widget.title,
        onTap: ()=>Navigator.of(context).pop(),
      ),
      backgroundColor: UcabdemyColors.primary_5,
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
          : Container(),
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

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}