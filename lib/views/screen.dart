import 'package:flutter/material.dart';
import 'package:weather/views/top_bar.dart';
import '../models/weather_api.dart';

const white = Color.fromARGB(255, 255, 255, 255);
const borderColor = Color.fromARGB(50, 255, 225, 255);
const String errorMsg =
    "Sorry, could not retrieve weather data from your phone.";

class WeatherMain extends StatefulWidget {
  final int index;

  const WeatherMain(this.index, {Key? key}) : super(key: key);

  @override
  _WeatherMain createState() => _WeatherMain();
}

class _WeatherMain extends State<WeatherMain> {
  late Future<WeatherParent> futureWeather;

  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeatherFutureAll();
  }

  Widget build(BuildContext context) {
    return FutureBuilder<WeatherParent>(
        future: futureWeather,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Menu Options
            List<Widget> _widgetOtions = <Widget>[
              WeatherListWeekly(snapshot.data!.weatherWeekly),
              WeatherListHourly(snapshot.data!.weatherHourly)
            ];

            return Column(children: [
              // Weather Top
              SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "${snapshot.data!.weatherTemp.temperature} ${snapshot.data!.weatherTemp.temperatureSign}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: white,
                              fontSize: 64)),
                      Text(
                          "${snapshot.data!.weatherTemp.location.city}, ${snapshot.data!.weatherTemp.location.state}",
                          style: const TextStyle(color: white, fontSize: 16)),
                      Text(snapshot.data!.weatherTemp.forecast,
                          style: const TextStyle(color: white, fontSize: 24))
                    ],
                  )),
              Expanded(flex: 1, child: _widgetOtions.elementAt(widget.index)),
            ]);
          } else if (snapshot.hasError) {
            return const Center(
                child: Text(errorMsg, style: TextStyle(color: whiteColor)));
          }
          return const Center(
              child: SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    color: whiteColor,
                  )));
        });
  }
}

class WeatherListWeekly extends StatelessWidget {
  final WeatherFuture weekly;

  const WeatherListWeekly(this.weekly, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          ColorTile tileColor =
              backgroundFromWeather(weekly.weathers[index].forecast);

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
                    child: Text(weekly.weathers[index].name,
                        style: TextStyle(
                            fontSize: 12, color: tileColor.textColor))),
                Expanded(
                    child: Text(weekly.weathers[index].forecast,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, color: tileColor.textColor))),
                SizedBox(
                    width: 40,
                    child: Text(
                        "${weekly.weathers[index].temperature} ${weekly.weathers[index].temperatureSign}",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: tileColor.textColor)))
              ])));
        },
        itemCount: weekly.weathers.length,
      )
    ]));
  }
}

class WeatherListHourly extends StatelessWidget {
  final WeatherFuture hourly;

  const WeatherListHourly(this.hourly, {Key? key}) : super(key: key);

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

    return "${(hour) < 10 ? "  " : ""}$hour:00 $timeOfDay $day";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        ColorTile tileColor =
            backgroundFromWeather(hourly.weathers[index].forecast);

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
                  child: Text(_hourlyText(hourly.weathers[index].time),
                      style:
                          TextStyle(fontSize: 12, color: tileColor.textColor))),
              Expanded(
                  child: Text(hourly.weathers[index].forecast,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 12, color: tileColor.textColor))),
              SizedBox(
                  width: 40,
                  child: Text(
                      "${hourly.weathers[index].temperature} ${hourly.weathers[index].temperatureSign}",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: tileColor.textColor)))
            ])));
      },
      itemCount: hourly.weathers.length,
    ));
  }
}

ColorTile backgroundFromWeather(String weather) {
  weather = weather.toLowerCase();
  for (MapEntry e in weatherColorMap.entries) {
    if (weather.contains(e.key)) {
      ColorTile bg = e.value;
      for (MapEntry a in weatherColorMapAlpha.entries) {
        if (weather.contains(a.key)) {
          return ColorTile(bg.bgColor.withOpacity(a.value), bg.textColor);
        }
      }
      return bg;
    }
  }

  return const ColorTile(backgroundStartColor, whiteColor);
}
