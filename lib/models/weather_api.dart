// ignore: file_names
// ignore_for_file: unnecessary_this

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

Future<WeatherTemp> fetchWeather() async {
  Position position = await determinePosition();

  final response = await http.get(Uri.parse(
      'https://api.weather.gov/points/${position.latitude},${position.longitude}'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    WeatherSite site = WeatherSite.fromJson(jsonDecode(response.body));

    WeatherTemp temp =
        await fetchWeatherTemperature(site.siteHour, site.location);

    return temp;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load WeatherSite');
  }
}

Future<WeatherFuture> fetchWeatherFutureAll() async {
  Position position = await determinePosition();

  final response = await http.get(Uri.parse(
      'https://api.weather.gov/points/${position.latitude},${position.longitude}'));

  log("${position.latitude} : ${position.longitude}");

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    WeatherSite site = WeatherSite.fromJson(jsonDecode(response.body));

    WeatherFuture temp = await fetchWeatherFuture(site.siteWeek, site.location);

    return temp;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load WeatherSite');
  }
}

Future<WeatherFuture> fetchWeatherFutureHourly() async {
  Position position = await determinePosition();

  final response = await http.get(Uri.parse(
      'https://api.weather.gov/points/${position.latitude},${position.longitude}'));

  log("${position.latitude} : ${position.longitude}");

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    WeatherSite site = WeatherSite.fromJson(jsonDecode(response.body));

    WeatherFuture temp = await fetchWeatherFuture(site.siteHour, site.location);

    return temp;
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
    developer.log(uri);
    throw Exception('Failed to load WeatherSite');
  }
}

Future<http.Response> fetchWeatherPlace() {
  return http.get(Uri.parse('https://api.weather.gov/points/43.9140,-69.9670'));
}

Future<http.Response> fetchWeatherTempe(String weatherPoint) {
  return http.get(Uri.parse(weatherPoint));
}

class WeatherSite {
  final String siteWeek;
  final String siteHour;
  final Location location;

  const WeatherSite(
      {required this.siteWeek, required this.siteHour, required this.location});

  factory WeatherSite.fromJson(Map<String, dynamic> json) {
    log("${json['properties']['relativeLocation']['properties']['city']}, ${json['properties']['relativeLocation']['properties']['state']}");
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

/*
var test = [
  {number: 1, name: This Afternoon, startTime: 2022-04-17T12:00:00-04:00, endTime: 2022-04-17T18:00:00-04:00, isDaytime: true, temperature: 46, temperatureUnit: F, temperatureTrend: null, windSpeed: 15 mph, windDirection: NW, icon: https://api.weather.gov/icons/land/day/rain_showers,50?size=medium, shortForecast: Scattered Rain Showers, detailedForecast: Scattered rain showers. Mostly cloudy, with a high near 46. Northwest wind around 15 mph, with gusts as high as 25 mph. Chance of precipitation is 50%. New rainfall amounts less than a tenth of an inch possible.}, 
  {number: 2, name: Tonight, startTime: 2022-04-17T18:00:00-04:00, endTime: 2022-04-18T06:00:00-04:00, isDaytime: false, temperature: 29, temperatureUnit: F, temperatureTrend: null, windSpeed: 10 to 15 mph, windDirection: NW, icon: https://api.weather.gov/icons/land/night/rain_showers,50/sct?size=medium, shortForecast: Scattered Rain Showers then Partly Cloudy, detailedForecast: Scattered rain showers before 8pm. Partly cloudy, with a low around 29. Northwest wind 10 to 15 mph, with gusts as high as 25 mph. Chance of precipitation is 50%. New rainfall amounts less than a tenth of an inch possible.},
  {number: 3, name: Monday, startTime: 2022-04-18T06:00:00-04:00, endTime: 2022-04-18T18:00:00-04:00, isDaytime: true, temperature: 53, temperatureUnit: F, temperatureTrend: null, windSpeed: 5 to 10 mph, windDirection: NW, icon: https://api.weather.gov/icons/land/day/few?size=medium, shortForecast: Sunny, detailedForecast: Sunny, with a high near 53. Northwest wind 5 to 10 mph.}, 
  {number: 4, name: Monday Night, startTime: 2022-04-18T18:00:00-04:00, endTime: 2022-04-19T06:00:00-04:00, isDaytime: false, temperature: 32, temperatureUnit: F, temperatureTrend: null, windSpeed: 7 mph, windDirection: SE, icon: https://api.weather.gov/icons/land/night/bkn/snow,60?size=medium, shortForecast: Mostly Cloudy then Light Snow Likely, detailedForecast: Snow likely after 1am. Mostly cloudy, with a low around 32. Southeast wind around 7 mph. Chance of precipitation is 60%. New snow accumulation of less than half an inch possible.},
   {number: 5, name: Tuesday, startTime: 2022-04-19T06:00:00-04:00, endTime: 2022-04-19T18:00:00-04:00, isDaytime: true, temperature: 43, temperatureUnit: F, temperatureTrend: null, windSpeed: 8 to 15 mph, windDirection: E, icon: https://api.weather.gov/icons/land/day/snow,100?size=medium, shortForecast: Snow, detailedForecast: Snow before 9am, then rain and snow. Cloudy, with a high near 43. East wind 8 to 15 mph. Chance of precipitation is 100%. New snow accumulation of 1 to 2 inches possible.}, {number: 6, name: Tuesday Night, startTime: 2022-04-19T18:00:00-04:00, endTime: 2022-04-20T06:00:00-04:00, isDaytime: false, temperature: 32, temperatureUnit: F, temperatureTrend: null, windSpeed: 6 to 12 mph, windDirection: NW, icon: https://api.weather.gov/icons/land/night/snow,80/snow,20?size=medium, shortForecast: Chance Rain And Snow, detailedForecast: Rain before 9pm, then a chance of rain and snow between 9pm and 1am, then a slight chance of rain and snow showers between 1am and 3am. Mostly cloudy, with a low around 32. Northwest wind 6 to 12 mph. Chance of precipitation is 80%. New snow accumulation of less than half an inch possible.}, {number: 7, name: Wednesday, startTime: 2022-04-20T06:00:00-04:00, endTime: 2022-04-20T18:00:00-04:00, isDaytime: true, temperature: 48, temperatureUnit: F, temperatureTrend: null, windSpeed: 12 to 18 mph, windDirection: W, icon: https://api.weather.gov/icons/land/day/sct?size=medium, shortForecast: Mostly Sunny, detailedForecast: Mostly sunny, with a high near 48. West wind 12 to 18 mph, with gusts as high as 29 mph.}, {number: 8, name: Wednesday Night, startTime: 2022-04-20T18:00:00-04:00, endTime: 2022-04-21T06:00:00-04:00, isDaytime: false, temperature: 28, temperatureUnit: F, temperatureTrend: null, windSpeed: 3 to 13 mph, windDirection: W, icon: https://api.weather.gov/icons/land/night/few?size=medium, shortForecast: Mostly Clear, detailedForecast: Mostly clear, with a low around 28.}, {number: 9, name: Thursday, startTime: 2022-04-21T06:00:00-04:00, endTime: 2022-04-21T18:00:00-04:00, isDaytime: true, temperature: 53, temperatureUnit: F, temperatureTrend: null, windSpeed: 2 to 14 mph, windDirection: S, icon: https://api.weather.gov/icons/land/day/bkn/rain_showers,20?size=medium, shortForecast: Mostly Cloudy then Slight Chance Rain Showers, detailedForecast: A slight chance of rain showers after 4pm. Mostly cloudy, with a high near 53. Chance of precipitation is 20%.}, {number: 10, name: Thursday Night, startTime: 2022-04-21T18:00:00-04:00, endTime: 2022-04-22T06:00:00-04:00, isDaytime: false, temperature: 38, temperatureUnit: F, temperatureTrend: null, windSpeed: 8 to 12 mph, windDirection: SW, icon: https://api.weather.gov/icons/land/night/rain_showers,20?size=medium, shortForecast: Slight Chance Rain Showers, detailedForecast: A slight chance of rain showers. Mostly cloudy, with a low around 38. Chance of precipitation is 20%.}, {number: 11, name: Friday, startTime: 2022-04-22T06:00:00-04:00, endTime: 2022-04-22T18:00:00-04:00, isDaytime: true, temperature: 55, temperatureUnit: F, temperatureTrend: null, windSpeed: 9 to 15 mph, windDirection: W, icon: https://api.weather.gov/icons/land/day/rain_showers,20/sct?size=medium, shortForecast: Slight Chance Rain Showers then Mostly Sunny, detailedForecast: A slight chance of rain showers before 8am. Mostly sunny, with a high near 55. Chance of precipitation is 20%.}, {number: 12, name: Friday Night, startTime: 2022-04-22T18:00:00-04:00, endTime: 2022-04-23T06:00:00-04:00, isDaytime: false, temperature: 32, temperatureUnit: F, temperatureTrend: null, windSpeed: 9 to 13 mph, windDirection: NW, icon: https://api.weather.gov/icons/land/night/sct?size=medium, shortForecast: Partly Cloudy, detailedForecast: Partly cloudy, with a low around 32.}, {number: 13, name: Saturday, startTime: 2022-04-23T06:00:00-04:00, endTime: 2022-04-23T18:00:00-04:00, isDaytime: true, temperature: 55, temperatureUnit: F, temperatureTrend: null, windSpeed: 10 mph, windDirection: NW, icon: https://api.weather.gov/icons/land/day/sct?size=medium, shortForecast: Mostly Sunny, detailedForecast: Mostly sunny, with a high near 55.}, {number: 14, name: Saturday Night, startTime: 2022-04-23T18:00:00-04:00, endTime: 2022-04-24T06:00:00-04:00, isDaytime: false, temperature: 32, temperatureUnit: F, temperatureTrend: null, windSpeed: 5 to 8 mph, windDirection: N, icon: https://api.weather.gov/icons/land/night/rain_showers,20/snow,20?size=medium, shortForecast: Slight Chance Rain Showers then Slight Chance Rain And Snow Showers, detailedForecast: A slight chance of rain showers between 8pm and 2am, then a slight chance of rain and snow showers. Mostly cloudy, with a low around 32. Chance of precipitation is 20%.}]
*/
