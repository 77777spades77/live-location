import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong/latlong.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:newfeautre/loc.dart';
import 'package:newfeautre/repository.dart';
import 'package:newfeautre/injection.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {

  final PopupController _popupController = PopupController();
  MapController _mapController = MapController();
  double _zoom = 15;
  List _locs = [];
  List<Marker> allMarkers = [];



  Future<void> getdata() async {
    try{
    _locs =  await locator<Repository>().getLocation('hari');
    for (var loc in _locs){
      allMarkers.add(
        Marker(
          point: latLng.LatLng(
              double.parse(loc.lat),double.parse(loc.longi)
          ),
          width: 80,
          height: 80,
          builder: (context) => Column(
            children: [
              Text(loc.time,style: TextStyle(fontSize: 10,fontWeight: FontWeight.normal),),
              SizedBox(height: 5,),
              const Icon(
                Icons.location_history,
                color: Colors.red,
                size: 25,
              ),
            ],
          ),
        ),
      );
    };
    }catch(e){
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getdata(),
      builder:(context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
        return Center(child: CircularProgressIndicator(color: Colors.blue,),);
        }


        return allMarkers.isEmpty?
        Scaffold(
          appBar: AppBar(
            title: Text('Map'),
          ),
          body: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: latLng.LatLng(13.0827,80.2707),
              //bounds: LatLngBounds.fromPoints(_latLngList),
              zoom: _zoom,
              interactiveFlags: InteractiveFlag.all - InteractiveFlag.rotate,
            ),
            nonRotatedChildren: [
              TileLayer(
                minZoom: 2,
                maxZoom: 18,
                backgroundColor: Colors.black,
                // errorImage: ,
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),
        )
            :Scaffold(
          appBar: AppBar(
            title: Text('Map'),
          ),
          body: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: latLng.LatLng(double.parse(_locs[0].lat), double.parse(_locs[0].longi)),
              //bounds: LatLngBounds.fromPoints(_latLngList),
              zoom: _zoom,
              interactiveFlags: InteractiveFlag.all - InteractiveFlag.rotate,
            ),
            nonRotatedChildren: [
              TileLayer(
                minZoom: 2,
                maxZoom: 18,
                backgroundColor: Colors.black,
                // errorImage: ,
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: allMarkers
              ),
            ],
          ),
        );

      }
    );
  }}


/*[
Marker(
point: latLng.LatLng(9.9252, 78.1198),
width: 80,
height: 80,
builder: (context) =>
const Icon(
Icons.location_history,
color: Colors.red,
size: 25,
),
),
],*/