import 'package:flutter/material.dart';
import 'package:weather/views/top_bar.dart';
import '../models/weather_api.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:developer' as developer;

import 'data_graph.dart';

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
            List<WeatherPoint> weatherGraphHigh = [];
            DateTime now = DateTime.utc(
                DateTime.now().year, DateTime.now().month, DateTime.now().day);
            now = now.add(const Duration(hours: 4));

            if (snapshot.data!.weathers[0].isDay) {
              now = now.add(const Duration(hours: 12));
            }

            developer.log(now.toString());

            for (var i = 0; i < snapshot.data!.weathers.length; i++) {
              developer.log("$now");
              weatherGraphHigh.add(WeatherPoint(
                  now, int.parse(snapshot.data!.weathers[i].temperature)));
              now = now.add(const Duration(hours: 12));
            }

            var items = snapshot.data!.weathers;
            return Expanded(
                child: SingleChildScrollView(
                    child: Column(children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                          color: borderColor,
                        )),
                      ),
                      child: ListTile(
                          title: Row(children: [
                        SizedBox(
                            width: 110,
                            child: Text(items[index].name,
                                style: const TextStyle(
                                    fontSize: 12, color: white))),
                        Expanded(
                            child: Text(items[index].forecast,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: white))),
                        SizedBox(
                            width: 40,
                            child: Text(
                                "${items[index].temperature} ${items[index].temperatureSign}",
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: white)))
                      ])));
                },
                itemCount: items.length,
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                  height: 200,
                  child: EndPointGraph([
                    charts.Series(
                        id: "Weather Graph",
                        colorFn: (_, __) =>
                            charts.Color.fromHex(code: "#f5f9ff"),
                        areaColorFn: (_, __) =>
                            charts.Color.fromHex(code: "#d4e7ff"),
                        strokeWidthPxFn: (dynamic weatherPoint, _) => 6,
                        radiusPxFn: (dynamic weatherPoint, _) => 2,
                        data: weatherGraphHigh,
                        domainFn: (dynamic weatherPoint, _) =>
                            weatherPoint.time,
                        measureFn: (dynamic weatherPoint, _) =>
                            weatherPoint.temp),
                  ], animate: false))
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
                return Container(
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                        color: borderColor,
                      )),
                    ),
                    child: ListTile(
                        title: Row(children: [
                      SizedBox(
                          width: 90,
                          child: Text(_hourlyText(items[index].time),
                              style:
                                  const TextStyle(fontSize: 12, color: white))),
                      Expanded(
                          child: Text(items[index].forecast,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontSize: 12, color: white))),
                      SizedBox(
                          width: 40,
                          child: Text(
                              "${items[index].temperature} ${items[index].temperatureSign}",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: white)))
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
