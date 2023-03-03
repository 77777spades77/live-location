import 'dart:async';
import 'package:newfeautre/loc.dart';
import 'package:newfeautre/mymap.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loci;
import 'package:newfeautre/loc.dart';
import 'package:newfeautre/repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:newfeautre/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initGetIt();
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final loci.Location location = loci.Location();
  StreamSubscription<loci.LocationData>? _locationSubscription;
  final repository = locator<Repository>();


  @override
  void initState() {
    super.initState();
    //_requestPermission();
    location.changeSettings(interval: 100, accuracy: loci.LocationAccuracy.high);
 //   location.enableBackgroundMode(enable: true);
   // _listenLocation();
  }

  @override
  void dispose() {
    //_stopListening();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('live location tracker'),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                _listenLocation();
              },
              child: Text('enable live location')),
          TextButton(
              onPressed: () {
                _stopListening();
              },
              child: Text('stop live location')),
         IconButton(
                            icon: Icon(Icons.directions),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      MyMap()));
                            },
           ),
        ],
      ),
    );
  }



  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loci.LocationData currentlocation) async {
      try {
        final loc Loc = loc(longi: currentlocation.longitude.toString(),
            lat: currentlocation.latitude.toString(),
            userid: 'hari');
        Map<dynamic, dynamic> locmap = Loc.toMap();
        repository.addloc(locmap);
      }catch(e){
        print(e);
      }
    });
  }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}