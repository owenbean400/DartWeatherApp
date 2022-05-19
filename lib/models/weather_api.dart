// ignore: file_names
// ignore_for_file: unnecessary_this

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// Global API Calling
Future<WeatherParent> fetchWeatherFutureAll() async {
  Position position = await determinePosition();

  final response = await http.get(Uri.parse(
      'https://api.weather.gov/points/${position.latitude},${position.longitude}'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    WeatherSite site = WeatherSite.fromJson(jsonDecode(response.body));

    WeatherFuture weekly =
        await fetchWeatherFuture(site.siteWeek, site.location);
    WeatherFuture hourly =
        await fetchWeatherFuture(site.siteHour, site.location);
    WeatherTemp temp =
        await fetchWeatherTemperature(site.siteHour, site.location);

    return WeatherParent(hourly, weekly, temp);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load WeatherSite');
  }
}

Future<WeatherTemp> fetchWeatherTemperature(
    String uri, Location location) async {
  final response = await http.get(Uri.parse(uri));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return WeatherTemp.fromJson(jsonDecode(response.body), location);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load WeatherSite');
  }
}

Future<WeatherFuture> fetchWeatherFuture(String uri, Location location) async {
  final response = await http.get(Uri.parse(uri));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return WeatherFuture.fromJson(jsonDecode(response.body), location);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load WeatherSite');
  }
}

class WeatherParent {
  final WeatherFuture weatherHourly;
  final WeatherFuture weatherWeekly;
  final WeatherTemp weatherTemp;

  const WeatherParent(this.weatherHourly, this.weatherWeekly, this.weatherTemp);
}

class WeatherSite {
  final String siteWeek;
  final String siteHour;
  final Location location;

  const WeatherSite(
      {required this.siteWeek, required this.siteHour, required this.location});

  factory WeatherSite.fromJson(Map<String, dynamic> json) {
    return WeatherSite(
        siteWeek: json['properties']['forecast'],
        siteHour: json['properties']['forecastHourly'],
        location: Location(
            json['properties']['relativeLocation']['properties']['city'],
            json['properties']['relativeLocation']['properties']['state']));
  }
}

class WeatherTemp {
  final String temperature;
  final String temperatureSign;
  final String name;
  final String forecast;
  final bool isDay;
  final Location location;
  final String time;

  const WeatherTemp(
      {required this.temperature,
      required this.temperatureSign,
      required this.name,
      required this.forecast,
      required this.isDay,
      required this.location,
      required this.time});

  String getTemperature() {
    return "${this.temperature} ${this.temperatureSign}";
  }

  String getName() {
    return name;
  }

  factory WeatherTemp.fromJson(Map<String, dynamic> json, Location loc) {
    List<dynamic> periods = json['properties']['periods'] as List;

    return WeatherTemp(
        temperature: periods[0]['temperature'].toString(),
        temperatureSign: periods[0]['temperatureUnit'] as String,
        name: periods[0]['name'] as String,
        forecast: periods[0]['shortForecast'] as String,
        isDay: periods[0]['isDaytime'] as bool,
        time: periods[0]['startTime'] as String,
        location: loc);
  }
}

class WeatherFuture {
  final List<WeatherTemp> weathers;

  const WeatherFuture({required this.weathers});

  factory WeatherFuture.fromJson(Map<String, dynamic> json, Location loc) {
    List<dynamic> periods = json['properties']['periods'] as List;

    List<WeatherTemp> list = [];

    for (var element in periods) {
      list.add(WeatherTemp(
          temperature: element['temperature'].toString(),
          temperatureSign: element['temperatureUnit'] as String,
          name: element['name'] as String,
          forecast: element['shortForecast'],
          isDay: element['isDaytime'] as bool,
          time: element['startTime'] as String,
          location: loc));
    }

    return WeatherFuture(weathers: list);
  }
}

class Location {
  final String city;
  final String state;

  Location(this.city, this.state);

  String getPlace() {
    return "${this.city}, ${this.state}";
  }
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
