import 'package:flutter/material.dart';
import 'package:weather/views/top_bar.dart';
import '../models/weather_api.dart';
import 'dart:developer' as developer;

const white = Color.fromARGB(255, 255, 255, 255);
const borderColor = Color.fromARGB(50, 255, 225, 255);
const String errorMsg =
    "Sorry, could not retrieve weather data from your phone.";

class Main extends StatelessWidget {
  final int index;

  const Main(this.index, {Key? key}) : super(key: key);

  static const List<Widget> _widgetOtions = <Widget>[
    WeatherFutureListWeekly(),
    WeatherFutureListHourly()
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 200, child: WeatherMain()),
      Expanded(flex: 1, child: _widgetOtions.elementAt(index)),
    ]);
  }
}

class WeatherMain extends StatefulWidget {
  const WeatherMain({Key? key}) : super(key: key);

  @override
  _WeatherMain createState() => _WeatherMain();
}

class _WeatherMain extends State<WeatherMain> {
  late Future<WeatherTemp> futureWeather;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    futureWeather = fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherTemp>(
      future: futureWeather,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  "${snapshot.data!.temperature} ${snapshot.data!.temperatureSign}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: white, fontSize: 64)),
              Text(
                  "${snapshot.data!.location.city}, ${snapshot.data!.location.state}",
                  style: const TextStyle(color: white, fontSize: 16)),
              Text(snapshot.data!.forecast,
                  style: const TextStyle(color: white, fontSize: 24))
            ],
          );
        } else if (snapshot.hasError) {
          return const Expanded(
              child: Center(
                  child: Text(errorMsg, style: TextStyle(color: whiteColor))));
        }
        return const Expanded(
            child: Center(
                child: SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      color: whiteColor,
                    ))));
      },
    );
  }
}

class WeatherFutureListWeekly extends StatefulWidget {
  const WeatherFutureListWeekly({Key? key}) : super(key: key);

  @override
  State<WeatherFutureListWeekly> createState() =>
      _WeatherFutureListWeeklyState();
}

class _WeatherFutureListWeeklyState extends State<WeatherFutureListWeekly> {
  late Future<WeatherFuture> futureWeatherfuture;

  @override
  void initState() {
    super.initState();
    futureWeatherfuture = fetchWeatherFutureAll();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
            top: BorderSide(
          color: borderColor,
        )),
      ),
      child: FutureBuilder<WeatherFuture>(
        future: futureWeatherfuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var items = snapshot.data!.weathers;
            return Expanded(
                child: SingleChildScrollView(
                    child: Column(children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  ColorTile tileColor =
                      backgroundFromWeather(items[index].forecast);

                  return Container(
                      decoration: BoxDecoration(
                        color: tileColor.bgColor,
                        border: const Border(
                            bottom: BorderSide(
                          color: borderColor,
                        )),
                      ),
                      child: ListTile(
                          title: Row(children: [
                        SizedBox(
                            width: 130,
                            child: Text(items[index].name,
                                style: TextStyle(
                                    fontSize: 12, color: tileColor.textColor))),
                        Expanded(
                            child: Text(items[index].forecast,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12, color: tileColor.textColor))),
                        SizedBox(
                            width: 40,
                            child: Text(
                                "${items[index].temperature} ${items[index].temperatureSign}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: tileColor.textColor)))
                      ])));
                },
                itemCount: items.length,
              )
            ])));
          } else if (snapshot.hasError) {
            return const SizedBox(
                height: 200,
                width: double.infinity,
                child: Expanded(
                    child: Center(
                        child: Text(
                  errorMsg,
                  style: TextStyle(color: white),
                ))));
          }
          return const SizedBox(
              height: 200,
              width: double.infinity,
              child: Expanded(
                  child: Center(
                      child: SizedBox(
                          height: 100,
                          width: 100,
                          child:
                              CircularProgressIndicator(color: whiteColor)))));
        },
      ),
    );
  }
}

class WeatherFutureListHourly extends StatefulWidget {
  const WeatherFutureListHourly({Key? key}) : super(key: key);

  @override
  State<WeatherFutureListHourly> createState() =>
      _WeatherFutureListHourlyState();
}

class _WeatherFutureListHourlyState extends State<WeatherFutureListHourly> {
  late Future<WeatherFuture> futureWeatherfuture;

  @override
  void initState() {
    super.initState();
    futureWeatherfuture = fetchWeatherFutureHourly();
  }

  String _hourlyText(String dt) {
    var now = DateTime.parse(dt).toLocal();

    String day = "";
    String timeOfDay = (now.hour < 12) ? "AM" : "PM";
    int hour = (now.hour < 12) ? now.hour + 1 : now.hour - 11;

    switch (now.weekday) {
      case 1:
        day = "Mon";
        break;
      case 2:
        day = "Tues";
        break;
      case 3:
        day = "Wed";
        break;
      case 4:
        day = "Thur";
        break;
      case 5:
        day = "Fri";
        break;
      case 6:
        day = "Sat";
        break;
      case 7:
        day = "Sun";
        break;
    }
    developer.log(
        "str: $dt hr: $hour, realHr: ${now.hour}, Week ${now.weekday}, realWeek: $day");

    return "${(hour) < 10 ? "  " : ""}$hour:00 $timeOfDay $day";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
            top: BorderSide(
          color: borderColor,
        )),
      ),
      child: FutureBuilder<WeatherFuture>(
        future: futureWeatherfuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var items = snapshot.data!.weathers;
            return Expanded(
                child: SingleChildScrollView(
                    child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                ColorTile tileColor =
                    backgroundFromWeather(items[index].forecast);

                return Container(
                    decoration: BoxDecoration(
                      color: tileColor.bgColor,
                      border: const Border(
                          bottom: BorderSide(
                        color: borderColor,
                      )),
                    ),
                    child: ListTile(
                        title: Row(children: [
                      SizedBox(
                          width: 110,
                          child: Text(_hourlyText(items[index].time),
                              style: TextStyle(
                                  fontSize: 12, color: tileColor.textColor))),
                      Expanded(
                          child: Text(items[index].forecast,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12, color: tileColor.textColor))),
                      SizedBox(
                          width: 40,
                          child: Text(
                              "${items[index].temperature} ${items[index].temperatureSign}",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: tileColor.textColor)))
                    ])));
              },
              itemCount: items.length,
            )));
          } else if (snapshot.hasError) {
            return const SizedBox(
                height: 200,
                width: double.infinity,
                child: Expanded(
                    child: Center(
                        child: Text(
                  errorMsg,
                  style: TextStyle(color: white),
                ))));
          }
          return const SizedBox(
              height: 200,
              width: double.infinity,
              child: Expanded(
                  child: Center(
                      child: SizedBox(
                          height: 100,
                          width: 100,
                          child:
                              CircularProgressIndicator(color: whiteColor)))));
        },
      ),
    );
  }
}

ColorTile backgroundFromWeather(String weather) {
  weather = weather.toLowerCase();
  for (MapEntry e in weatherColorMap.entries) {
    developer.log(e.key);
    developer.log(weather);
    if (weather.contains(e.key)) {
      ColorTile bg = e.value;
      for (MapEntry a in weatherColorMapAlpha.entries) {
        developer.log(a.key);
        developer.log(weather);
        if (weather.contains(a.key)) {
          developer.log(a.value.toString());
          return ColorTile(bg.bgColor.withOpacity(a.value), bg.textColor);
        }
      }
      return bg;
    }
  }

  return const ColorTile(backgroundStartColor, whiteColor);
}
