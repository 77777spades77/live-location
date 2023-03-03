//http://7c53-35-221-42-54.ngrok.io
import 'dart:async';
import 'package:http/http.dart' show Client;
import 'dart:convert';
import 'package:newfeautre/loc.dart';

class ApiProvider {
  Client client = Client();
  static String stageHost = '48d8-104-199-124-7.ngrok.io';
  Uri Locationgetpost = Uri(scheme: 'http', host: stageHost, path: '/api/location-add');

  Future<List> getLocation(String userid) async {
    final queryParameters = {'userid':userid};
    Uri Locationget = Uri(scheme: 'http', host: stageHost, path: '/api/location-get',queryParameters: queryParameters);
    List<loc> locs = [];
    final response = await client.get(
      Locationget,
      headers: {
        "Access-Control-Allow-Origin": "*", // Required for CORS support to work
        "Access-Control-Allow-Credentials": 'true', // Required for cookies, authorization headers with HTTPS
        "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
      },
    );
    final Map result = json.decode(response.body);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      for (Map<String, dynamic> json_ in result["data"]) {
        try {
          loc Loc = loc.fromJson(json_);
          locs.add(Loc);
        } catch (Exception) {
          print(Exception);
        }
      }
      return locs;
    } else {
      // If that call was not successful, throw an error.
      throw Exception(result["status"]);
    }

    }

  /// Add a Group
  Future addloc(Map<dynamic,dynamic> data) async {
    final response = await client.post(
      Locationgetpost,
      headers: {
         "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final Map result = json.decode(response.body);
      loc Loc = loc.fromJson(result["data"]);
      //print("Group: " + addedGroup.name + " added");
      return Loc;
    } else {
      // If that call was not successful, throw an error.
      final Map result = json.decode(response.body);
      print(result["status"]);
      throw Exception(result["status"]);
    }
  }
}