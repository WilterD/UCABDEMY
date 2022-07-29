import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class JitsiMeetVideo extends StatefulWidget {

  const JitsiMeetVideo({Key? key,required this.nameRoom, this.videoMuted = false}) : super(key: key);
  final String nameRoom;
  final bool videoMuted;

  @override
  _JitsiMeetVideoState createState() => _JitsiMeetVideoState();
}

class _JitsiMeetVideoState extends State<JitsiMeetVideo>{

  String nameRooms = '';
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  InAppWebViewController? webViewController;
  String url = "";
  final urlController = TextEditingController();
  double progress = 0;

  @override
  void initState() {
    super.initState();
    initialData();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  Future initialData() async{
    nameRooms = widget.nameRoom;
    setState(() {});
    meet();

  }

  @override
  void dispose() {
    super.dispose();
  }

  Future meet() async {
    _joinMeeting();
    // try{
    //   //bool res = await laun.launchUrl(Uri(path: 'https://meet.jit.si/${widget.nameRoom}'));
    //   Uri _url = Uri.parse('https://meet.jit.si/${widget.nameRoom}');
    //   if (!await laun.launchUrl(_url)) throw 'Could not launch $_url';
    //   print('');
    // }catch(e){
    //   print(e.toString());
    // }

    // try{
    //   if (await canLaunch('https://meet.jit.si/${widget.nameRoom}')) {
    //     // Launch the App
    //     await launch('https://meet.jit.si/${widget.nameRoom}',);
    //   }
    // }catch(e){
    //   print(e.toString());
    // }
  }

  @override
  Widget build(BuildContext context) {

    debugPrint('https://meet.jit.si/${widget.nameRoom}');

    //return Scaffold();

    // return Scaffold(
    //   body: InAppWebView(
    //     key: webViewKey,
    //     initialUrlRequest: URLRequest(url: Uri.parse('https://meet.jit.si/${widget.nameRoom}')),
    //     initialOptions: options,
    //     pullToRefreshController: pullToRefreshController,
    //     onWebViewCreated: (controller) {
    //       webViewController = controller;
    //     },
    //     onLoadStart: (controller, url) {
    //       setState(() {
    //         this.url = url.toString();
    //         urlController.text = this.url;
    //       });
    //     },
    //     androidOnPermissionRequest: (controller, origin, resources) async {
    //       return PermissionRequestResponse(
    //           resources: resources,
    //           action: PermissionRequestResponseAction.GRANT);
    //     },
    //     shouldOverrideUrlLoading: (controller, navigationAction) async {
    //       var uri = navigationAction.request.url!;
    //
    //       if (![ "http", "https", "file", "chrome",
    //         "data", "javascript", "about"].contains(uri.scheme)) {
    //         if (await canLaunch(url)) {
    //           // Launch the App
    //           await launch(
    //             url,
    //           );
    //           // and cancel the request
    //           return NavigationActionPolicy.CANCEL;
    //         }
    //       }
    //
    //       return NavigationActionPolicy.ALLOW;
    //     },
    //     onLoadStop: (controller, url) async {
    //       pullToRefreshController.endRefreshing();
    //       setState(() {
    //         this.url = url.toString();
    //         urlController.text = this.url;
    //       });
    //     },
    //     onLoadError: (controller, url, code, message) {
    //       pullToRefreshController.endRefreshing();
    //     },
    //     onProgressChanged: (controller, progress) {
    //       if (progress == 100) {
    //         pullToRefreshController.endRefreshing();
    //       }
    //       setState(() {
    //         this.progress = progress / 100;
    //         urlController.text = this.url;
    //       });
    //     },
    //     onUpdateVisitedHistory: (controller, url, androidIsReload) {
    //       setState(() {
    //         this.url = url.toString();
    //         urlController.text = this.url;
    //       });
    //     },
    //     onConsoleMessage: (controller, consoleMessage) {
    //       print(consoleMessage);
    //     },
    //   ),
    // );

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: const Scaffold(
        backgroundColor: UcabdemyColors.primary_4,
      ),
    );
  }

  Future _joinMeeting() async {
    try{
      String? serverUrl = 'https://meet.jit.si/';
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        FeatureFlagEnum.ADD_PEOPLE_ENABLED: false,
        FeatureFlagEnum.CALL_INTEGRATION_ENABLED: false,
        FeatureFlagEnum.RECORDING_ENABLED: true,
        FeatureFlagEnum.INVITE_ENABLED: false,
        FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE: true
      };
      featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      var options = JitsiMeetingOptions(room: widget.nameRoom)
        ..serverURL = serverUrl
        ..subject = nameRooms
        ..userDisplayName = nameRooms
        ..audioOnly = false
        ..videoMuted = widget.videoMuted
        ..audioMuted = false
        ..featureFlags.addAll(featureFlags);

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(
            onError: (message) {
              debugPrint('JITSI : Error con el mensaje: $message');
              debugPrint("${options.room} Error con el mensaje: $message");
            },
            onConferenceJoined: (message) {
              debugPrint('JITSI : unido con mensaje: $message');
              debugPrint("${options.room} unido con mensaje: $message");
            },
            onConferenceWillJoin: (message) {
              debugPrint('JITSI : se unirá con el mensaje: $message');
              debugPrint("${options.room} se unirá con el mensaje: $message");
            },
            onConferenceTerminated: (message) async {
              debugPrint('JITSI : terminado con mensaje: $message');
              debugPrint("${options.room} terminado con mensaje: $message");
              Navigator.of(context).pop();
            },
            genericListeners: [
              JitsiGenericListener(
                  eventName: 'readyToClose',
                  callback: (dynamic message) {
                    debugPrint('JITSI : readyToClose callback');
                    debugPrint("readyToClose callback");
                  }),
            ]),
      );
    }catch(e){
      debugPrint(e.toString());
    }
  }
}
