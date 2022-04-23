import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/weatherAPI.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';
import 'dart:developer' as developer;

import 'DataGraph.dart';

const white = Color.fromARGB(255, 255, 255, 255);
const borderColor = Color.fromARGB(50, 255, 225, 255);

class Main extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(children: const [
      SizedBox(height: 200, child: WeatherMain()),
      Expanded(flex: 1, child: WeatherFutureList()),
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
  void initState() {
    super.initState();
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
          return const Text('Error loading weather');
        }
        return const Expanded(child: CircularProgressIndicator());
      },
    );
  }
}

class WeatherFutureList extends StatefulWidget {
  const WeatherFutureList({Key? key}) : super(key: key);

  @override
  State<WeatherFutureList> createState() => _WeatherFutureListState();
}

class _WeatherFutureListState extends State<WeatherFutureList> {
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
              developer.log("${now}");
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
                            width: 150,
                            child: Text(items[index].name,
                                style: const TextStyle(
                                    fontSize: 16, color: white))),
                        Expanded(
                            child: Text(items[index].forecast,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 16, color: white))),
                        SizedBox(
                            width: 50,
                            child: Text(
                                "${items[index].temperature} ${items[index].temperatureSign}",
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontSize: 16,
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
            return const Text('Error loading weather');
          }
          return const SizedBox(
              height: 200,
              width: double.infinity,
              child: Expanded(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}
