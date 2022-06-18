import 'package:flutter/material.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';

AppBar appBarWidget({
  double sizeH = 10,
  void Function()? onTap,
  String title = '',
  Color colorIcon = Colors.white,
  TextStyle? styleTitle,
  TextAlign alignTitle = TextAlign.center,
  Color backgroundColor = UcabdemyColors.primary,
  double elevation = 5,
  IconData icon = Icons.arrow_back_ios,
  bool centerTitle = true,
  List<Widget> actions = const [],
  bool elevationActive = true,
  Widget? leadingW,
  }){

  styleTitle = styleTitle ?? UcademyStyles().stylePrimary(size: sizeH * 0.023,color: Colors.white,fontWeight: FontWeight.bold);

  Widget leadingW2 = leadingW ?? InkWell(
    child: Icon(icon,size: sizeH * 0.03,color: colorIcon,),
    onTap: onTap,
  );

  return AppBar(
    backgroundColor: backgroundColor,
    elevation: elevation,
    leading: elevationActive ?  leadingW2 : Container(),
    centerTitle: centerTitle,
    title: Text(title,style: styleTitle,textAlign: alignTitle,),
    actions: actions,
  );
}