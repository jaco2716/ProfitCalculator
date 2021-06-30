import 'package:flutter/material.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:video_player/video_player.dart';

class VideoAppGuidePage extends StatefulWidget {
  const VideoAppGuidePage({Key key}) : super(key: key);

  @override
  _VideoAppGuidePageState createState() => _VideoAppGuidePageState();
}

class _VideoAppGuidePageState extends State<VideoAppGuidePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('App Guide'),
          // toolbarHeight: 40,
        ),
        // appBar: MyAppBarWithCalc('App Guide'),
        body: _AppGuideAssetVideo()
        //
        // //assets/videos/ProfitDemoTest.MP4
        );
  }
}

class _AppGuideAssetVideo extends StatefulWidget {
  @override
  _AppGuideAssetVideoState createState() => _AppGuideAssetVideoState();
}

class _AppGuideAssetVideoState extends State<_AppGuideAssetVideo> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    try {
      _controller = VideoPlayerController.asset('assets/videos/ProfCalculatorGuide.MP4');

      _controller.addListener(() {
        setState(() {});
      });
      _controller.setLooping(false);
      _controller.initialize().then((_) => setState(() {}));
      // _controller.play();
    } catch (e) {
      print('error loading video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Please watch this 5 minute video on\nhow to use the app.',
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Container(
                color: Colors.blue[700],
                padding: EdgeInsets.all(5),
                // height: MediaQuery.of(context).size.height - 60,
                // width: 300,
                height: MediaQuery.of(context).size.height - 220,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_controller),
                      _ControlsOverlay(controller: _controller),
                      Container(
                          height: 30,
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            padding: EdgeInsets.all(5),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            // Container(
            //   width: 20,
            //   height: 200,
            //   color: Colors.red,
            // )
            // MyIconButton(
            //     height: 55,
            //     tileIcon: Icon(Icons.close),
            //     tileTitle: 'Close',
            //     compact: true,
            //     myOnPressed: () {
            //       Navigator.of(context).pop();
            //     }),
            // Container(
            //   padding: EdgeInsets.all(10),
            //   width: double.infinity,
            //   height: 70,
            //   child: ElevatedButton(onPressed: () {
            //     Navigator.of(context).pop();
            //   }, child: Text('Close')),
            // )
          ],
        ),
      );
    } catch (e) {
      print('Error loading video $e');
      return Text('Error loading video.');
    }
  }
}

class _ControlsOverlay extends StatelessWidget {
  // final VideoPlayerController controller;

  const _ControlsOverlay({this.controller});

  // static const _examplePlaybackRates = [
  //   0.25,
  //   0.5,
  //   1.0,
  //   1.5,
  //   2.0,
  //   3.0,
  //   5.0,
  //   10.0,
  // ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        // Align(
        //   alignment: Alignment.topRight,
        //   child: PopupMenuButton<double>(
        //     initialValue: controller.value.playbackSpeed,
        //     tooltip: 'Playback speed',
        //     onSelected: (speed) {
        //       controller.setPlaybackSpeed(speed);
        //     },
        //     itemBuilder: (context) {
        //       return [
        //         for (final speed in _examplePlaybackRates)
        //           PopupMenuItem(
        //             value: speed,
        //             child: Text('${speed}x'),
        //           )
        //       ];
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(
        //         // Using less vertical padding as the text is also longer
        //         // horizontally, so it feels like it would need more spacing
        //         // horizontally (matching the aspect ratio of the video).
        //         vertical: 12,
        //         horizontal: 16,
        //       ),
        //       child: Text('${controller.value.playbackSpeed}x'),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
