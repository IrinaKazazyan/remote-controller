import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:remote_controller/key_codes.dart';
import 'package:shared_preferences/shared_preferences.dart';

Socket sock;
SharedPreferences preferences;
bool isRegistered;
ScrollController myScrollController;
bool _keypadShown = false;
bool _playShown = false;
bool _volumeShown = true;

void main() async {
  String indexRequest = 'GET / HTTP/1.1\nConnection: close\n\n';
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setEnabledSystemUIOverlays([]);

  preferences = await SharedPreferences.getInstance();
  isRegistered = preferences.getBool("isConnected");
  if (isRegistered == null) {
    isRegistered = false;
  }

  if (isRegistered) {
    await connectTV();
  }

  return runApp(RemoteController());
}

Future connectTV() async {
  Socket.connect('2.57.217.111', 8000).then((socket) {
    sock = socket;
    print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

    isRegistered = true;
    preferences.setBool('isConnected', isRegistered);
    print('TAG preferences isConnected $isRegistered');

    socket.listen((data) {
      print(new String.fromCharCodes(data).trim());
    }, onDone: () {
      print("Done");
      socket.destroy();
    });
    //Send the request
    socket.write("");
  });
}

class RemoteController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('TAG isConnected = $isRegistered');

    if (isRegistered) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FlutterRemote',
        home: Scaffold(
          backgroundColor: Color(0XFF2e2e2e),
          body: MyHomePage(),
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FlutterRemote',
        home: Scaffold(
          backgroundColor: Color(0XFF2e2e2e),
          body: ScanScreen(),
        ),
      );
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//  bool _keypadShown = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        SystemChrome.setEnabledSystemUIOverlays([]);
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Color(0XFF2e2e2e),
        body: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    Widget bigCircle = new Container(
      width: 180.0,
      height: 180.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: new BoxDecoration(
        color: Color(0XFF2e2e2e),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          colors: [Color(0XFF1c1c1c), Color(0XFF383838)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0XFF1c1c1c),
            offset: Offset(5.0, 5.0),
            blurRadius: 10.0,
          ),
        ],
        shape: BoxShape.circle,
      ),
    );

    Widget bigCircle1 = Container(
      width: 100.0,
      height: 100.0,
      decoration: new BoxDecoration(
        border: Border.all(color: Colors.black54, width: 5.0),
        shape: BoxShape.circle,
      ),
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    IconButton(
                        icon: Icon(Icons.power_settings_new,
                            color: Colors.red, size: 30),
                        onPressed: () async {
                          sock.write(KeyCodes.KEY_POWEROFF);
                          sock.write("\n");
                        }),
                    SizedBox(
                      width: 25,
                    ),
                    IconButton(
                      icon: Icon(Icons.cast, size: 30, color: Colors.cyan),
                      onPressed: () async {
                        sock.destroy();
                        setState(() {
                          isRegistered = false;
                          preferences.setBool('isConnected', isRegistered);
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ScanScreen()),
                        );
                      }, //connectTv
                    ),
                    SizedBox(
                      width: 25,
                    ),
                    IconButton(
                        icon: Icon(Icons.volume_off,
                            color: _volumeShown ? Colors.white54 : Colors.red,
                            size: 30),
                        onPressed: () async {
                          sock.write(KeyCodes.KEY_MUTE);
                          sock.write("\n");
                          setState(() {
                            _volumeShown = !_volumeShown;
                          });
                        }),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: ControllerButton(
                          color: Colors.red,
                          onPressed: () async {
                            sock.write(KeyCodes.KEY_RED);
                            sock.write("\n");
                          } // async {await tv.sendKey(KEY_CODES.KEY_RED);},
                          ),
                    ),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: ControllerButton(
                          color: Colors.green,
                          onPressed: () async {
                            sock.write(KeyCodes.KEY_GREEN);
                            sock.write("\n");
                          } // async {await tv.sendKey(KEY_CODES.KEY_GREEN);},
                          ),
                    ),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: ControllerButton(
                          color: Colors.yellow,
                          onPressed: () async {
                            sock.write(KeyCodes.KEY_YELLOW);
                            sock.write("\n");
                          } // async {await tv.sendKey(KEY_CODES.KEY_YELLOW);},
                          ),
                    ),
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: ControllerButton(
                          color: Colors.blue,
                          onPressed: () async {
                            sock.write(KeyCodes.KEY_BLUE);
                            sock.write("\n");
                          } // async {await tv.sendKey(KEY_CODES.KEY_CYAN);},
                          ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ControllerButton(
                        child: Icon(Icons.skip_previous,
                            size: 20, color: Colors.white54),
                        onPressed: () async {
                          sock.write(KeyCodes.KEY_REW);
                          sock.write("\n");
                        } // async {await tv.sendKey(KEY_CODES.KEY_REWIND);},
                        ),
                    ControllerButton(
                        child: Icon(Icons.fast_rewind,
                            size: 20, color: Colors.white54),
                        onPressed: () async {
                          sock.write(KeyCodes.KEY_BACKWARD);
                          sock.write("\n");
                        } // async {await tv.sendKey(KEY_CODES.KEY_REWIND);},
                        ),
                    ControllerButton(
                        child: _playShown
                            ? Icon(Icons.play_arrow,
                                size: 30, color: Colors.white54)
                            : Icon(Icons.pause,
                                size: 30, color: Colors.white54),
                        onPressed: () async {
                          sock.write(KeyCodes.KEY_PLAYPAUSE);
                          sock.write("\n");
                          setState(() {
                            _playShown = !_playShown;
                          });
                        } // async {await tv.sendKey(KEY_CODES.KEY_PAUSE);},
                        ),
                    ControllerButton(
                        child: Icon(Icons.fast_forward,
                            size: 20, color: Colors.white54),
                        onPressed: () async {
                          sock.write(KeyCodes.KEY_FORWARD);
                          sock.write("\n");
                        } // async {await tv.sendKey(KEY_CODES.KEY_FF);},
                        ),
                    ControllerButton(
                        child: Icon(Icons.skip_next,
                            size: 20, color: Colors.white54),
                        onPressed: () async {
                          sock.write(KeyCodes.KEY_LIVE);
                          sock.write("\n");
                        } // async {await tv.sendKey(KEY_CODES.KEY_FF);},
                        ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                          bigCircle,
                          bigCircle1,
                          Positioned(
                            child: ControllerButton(
                              onPressed: () async {
                                sock.write(KeyCodes.KEY_MENU);
                                sock.write("\n");
                              },
                              child: Text(
                                "MENU",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white54),
                              ),
                            ),
                            top: 10.0,
                            left: 20.0,
                          ),
                          Positioned(
                            child: ControllerButton(
                              onPressed: () async {
                                sock.write(KeyCodes.KEY_BACK);
                                sock.write("\n");
                              },
                              child: Text(
                                "BACK",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white54),
                              ),
                            ),
                            top: 10.0,
                            right: 20.0,
                          ),
                          Positioned(
                            child: new CircleButton(
                                onTap: () async {
                                  sock.write(KeyCodes.KEY_UP);
                                  sock.write("\n");
                                },
                                iconData: Icons.arrow_drop_up,
                                size: 50),
                            top: 5.0,
                            left: 180.0,
                          ),
                          Positioned(
                            child: new CircleButton(
                                onTap: () async {
                                  sock.write(KeyCodes.KEY_LEFT);
                                  sock.write("\n");
                                },
                                iconData: Icons.arrow_left,
                                size: 50),
                            top: 75.0,
                            left: 110.0,
                          ),
                          Positioned(
                            child: new CircleButton(
                                onTap: () async {
                                  sock.write(KeyCodes.KEY_RIGHT);
                                  sock.write("\n");
                                },
                                iconData: Icons.arrow_right,
                                size: 50),
                            top: 75.0,
                            right: 110.0,
                          ),
                          Positioned(
                            child: new CircleButton(
                                onTap: () async {
                                  sock.write(KeyCodes.KEY_DOWN);
                                  sock.write("\n");
                                },
                                iconData: Icons.arrow_drop_down,
                                size: 50),
                            top: 145.0,
                            left: 180.0,
                          ),
                          Positioned(
                            child: MaterialButton(
                              height: 50,
                              minWidth: 50,
                              shape: CircleBorder(),
                              child: Text(
                                "OK",
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70),
                              ),
                              onPressed: () async {
                                sock.write(KeyCodes.KEY_OK);
                                sock.write("\n");
                              },
                            ),
                            top: 75.0,
                            left: 170.0,
                          ),
                          Positioned(
                            child: ControllerButton(
                              onPressed: () async {
                                sock.write(KeyCodes.KEY_EPG);
                                sock.write("\n");
                              },
                              child: Text(
                                "EPG ",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white54),
                              ),
                            ),
                            bottom: 10.0,
                            left: 20.0,
                          ),
                          Positioned(
                            child: ControllerButton(
                              onPressed: () async {
                                sock.write(KeyCodes.KEY_INFO);
                                sock.write("\n");
                              },
                              child: Text(
                                "INFO",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white54),
                              ),
                            ),
                            bottom: 10.0,
                            right: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
//                _tabSection(context)
              ],
            ),
          ),
          _tabSection(context)
        ],
      ),
    );
  }

  Widget _tabSection(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.7,
      width: MediaQuery.of(context).size.width,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Color(0XFF2e2e2e),
          bottomNavigationBar: Container(
            color: Color(0XFF2e2e2e),
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.white70,
              tabs: [
                Tab(icon: Icon(Icons.menu, size: 20.0)),
                Tab(icon: Icon(Icons.dialpad, size: 20.0)),
//                Tab(icon: Icon(Icons.keyboard, size: 20.0)),
              ],
            ),
          ),
          body: TabBarView(
            children: [_volume(context), _numbers(context)],
          ),
        ),
      ),
    );
  }

  Widget _numbers(BuildContext context) {
    _keypadShown = true;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
//        Container(margin: EdgeInsets.symmetric(vertical: 5.0),
//          child:
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ControllerButton(
                      child: Text(
                        "1",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_NUM1);
                        sock.write("\n");
                      } //async {await tv.sendKey(KEY_CODES.KEY_1);},
                      ),
                  ControllerButton(
                      child: Text(
                        "2",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_NUM2);
                        sock.write("\n");
                      } // async {await tv.sendKey(KEY_CODES.KEY_2);},
                      ),
                  ControllerButton(
                      child: Text(
                        "3",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_NUM3);
                        sock.write("\n");
                      } // async {await tv.sendKey(KEY_CODES.KEY_3);},
                      ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ControllerButton(
                      child: Text(
                        "4",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_NUM4);
                        sock.write("\n");
                      } //async {await tv.sendKey(KEY_CODES.KEY_4);},
                      ),
                  ControllerButton(
                      child: Text(
                        "5",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_NUM5);
                        sock.write("\n");
                      } //async {await tv.sendKey(KEY_CODES.KEY_5);},
                      ),
                  ControllerButton(
                      child: Text(
                        "6",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_NUM6);
                        sock.write("\n");
                      } // async {await tv.sendKey(KEY_CODES.KEY_6);},
                      ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ControllerButton(
                      child: Text(
                        "7",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_NUM7);
                        sock.write("\n");
                      } //async {await tv.sendKey(KEY_CODES.KEY_7);},
                      ),
                  ControllerButton(
                      child: Text(
                        "8",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_NUM8);
                        sock.write("\n");
                      } //async {await tv.sendKey(KEY_CODES.KEY_8);},
                      ),
                  ControllerButton(
                      child: Text(
                        "9",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_NUM9);
                        sock.write("\n");
                      } //async {await tv.sendKey(KEY_CODES.KEY_9);},
                      ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ControllerButton(
                      child:
                          Icon(Icons.keyboard, size: 20, color: Colors.white54),
                      onPressed: () {
                        SystemChannels.textInput.invokeMethod('TextInput.show');
                      } // async {await tv.sendKey(KEY_CODES.KEY_TOOLS);},
                      ),
                  ControllerButton(
                      child: Text(
                        "0",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_NUM0);
                        sock.write("\n");
                      } //async {await tv.sendKey(KEY_CODES.KEY_0);},
                      ),
                  ControllerButton(
                      child: Text(
                        "OK".toUpperCase(),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                      onPressed:
                          () {} //async {await tv.sendKey(KEY_CODES.KEY_GUIDE);},
                      ),
                ],
              ),
            ],
          ),
        ),
//        ),
      ],
    );
  }

  Widget _volume(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ControllerButton(
              borderRadius: 15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MaterialButton(
                      height: 50,
                      minWidth: 50,
                      shape: CircleBorder(),
                      child: Icon(Icons.keyboard_arrow_up,
                          size: 20, color: Colors.white54),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_VOLUMEUP);
                        sock.write("\n");
                      } // async {await tv.sendKey(KEY_CODES.KEY_VOLUP);},
                      ),
//                  MaterialButton(
//                      height: 50,
//                      minWidth: 50,
//                      shape: CircleBorder(),
//                      child: Text(
//                        "VOL",
//                        style: TextStyle(
//                            fontSize: 11,
//                            fontWeight: FontWeight.bold,
//                            color: Colors.white54),
//                      ),
//                      onPressed: () async {
//                        sock.write(KeyCodes.KEY_MUTE);
//                        sock.write("\n");
//                      } // async {await tv.sendKey(KEY_CODES.KEY_MUTE);},
//                      ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      "VOL",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54),
                    ),
                  ),
                  MaterialButton(
                      height: 50,
                      minWidth: 50,
                      shape: CircleBorder(),
                      child: Icon(Icons.keyboard_arrow_down,
                          size: 20, color: Colors.white54),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_VOLUMEDOWN);
                        sock.write("\n");
                      } // async {await tv.sendKey(KEY_CODES.KEY_VOLDOWN);},
                      ),
                ],
              ),
            ),
            Column(
              children: [
                ControllerButton(
                  borderRadius: 15,
                  onPressed: () async {
                    sock.write(KeyCodes.KEY_PLAYPAUSE);
                    sock.write("\n");
                    setState(() {
                      _playShown = !_playShown;
                    });
                  },
                  child: _playShown
                      ? Icon(Icons.play_arrow, size: 20, color: Colors.white54)
                      : Icon(Icons.pause,
                          size: 20,
                          color: Colors
                              .white54), // async {await tv.sendKey(KEY_CODES.KEY_HOME);},
                ),
                SizedBox(height: 35),
                ControllerButton(
                    borderRadius: 15,
                    child: Icon(Icons.star, size: 20, color: Colors.white54),
                    onPressed: () async {
                      sock.write(KeyCodes.KEY_FAVOURITE);
                      sock.write("\n");
                    } // async {await tv.sendKey(KEY_CODES.KEY_MORE);},
                    ),
              ],
            ),
            ControllerButton(
              borderRadius: 15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MaterialButton(
                      height: 40,
                      minWidth: 40,
                      shape: CircleBorder(),
                      child: Icon(Icons.keyboard_arrow_up,
                          size: 20, color: Colors.white54),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_CHUP);
                        sock.write("\n");
                      } // async {await tv.sendKey(KEY_CODES.KEY_CHUP);},
                      ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      "CHAN",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54),
                    ),
                  ),
                  MaterialButton(
                      height: 50,
                      minWidth: 50,
                      shape: CircleBorder(),
                      child: Icon(Icons.keyboard_arrow_down,
                          size: 20, color: Colors.white54),
                      onPressed: () async {
                        sock.write(KeyCodes.KEY_CHDOWN);
                        sock.write("\n");
                      } // async {await tv.sendKey(KEY_CODES.KEY_CHDOWN);},
                      ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ControllerButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;
  final Color color;

  const ControllerButton(
      {Key key, this.child, this.borderRadius = 30, this.color, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        color: Color(0XFF2e2e2e),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          colors: [Color(0XFF1c1c1c), Color(0XFF383838)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0XFF1c1c1c),
            offset: Offset(5.0, 5.0),
            blurRadius: 10.0,
          ),
          BoxShadow(
            color: Color(0XFF404040),
            offset: Offset(-5.0, -5.0),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            // shape: BoxShape.circle,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            gradient: const LinearGradient(
                begin: Alignment.topLeft,
                colors: [Color(0XFF303030), Color(0XFF1a1a1a)]),
          ),
          child: MaterialButton(
            color: color,
            minWidth: 0,
            onPressed: onPressed,
            shape: CircleBorder(),
            child: child,
          ),
        ),
      ),
    );
  }
}

class ScanScreen extends StatefulWidget {
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<ScanScreen> {
  String scanResult = "";

  @override
  initState() {
    super.initState();
  }

  Future scanQRCode() async {
    try {
      String cameraScanResult = await scanner.scan();
      setState(() {
        scanResult = cameraScanResult;
      });
      await connectTV();
    } on PlatformException catch (e) {
      if (e.code == scanner.CameraAccessDenied) {
        setState(() {
          this.scanResult = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.scanResult = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.scanResult =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.scanResult = 'Unknown error: $e');
    }
    print('TAG  scanResult $scanResult');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('QR Code Scanner'),
        ),
        backgroundColor: Color(0XFF2e2e2e),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: () async {
                      scanQRCode();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    },
                    child: const Text('START CAMERA SCAN')),
              ),
            ],
          ),
        ));
  }
}

class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final IconData iconData;
  final double size;
  final Colors colors;

  const CircleButton(
      {Key key, this.onTap, this.iconData, this.size, this.colors})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new InkResponse(
      onTap: onTap,
      child: new Container(
        child: new Icon(
          iconData,
          size: 50,
          color: Colors.white60,
        ),
      ),
    );
  }
}
