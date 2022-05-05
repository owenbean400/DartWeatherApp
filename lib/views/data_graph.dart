import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EndPointGraph extends StatelessWidget {
  List<charts.Series<dynamic, DateTime>> seriesList;
  final bool animate;

  EndPointGraph(this.seriesList, {Key? key, required this.animate})
      : super(key: key);

  factory EndPointGraph.withSampleData() {
    return EndPointGraph(_createSampleData(), animate: false);
  }

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(seriesList,
        defaultRenderer:
            charts.LineRendererConfig(includeArea: true, stacked: true),
        primaryMeasureAxis: const charts.NumericAxisSpec(
            tickProviderSpec:
                charts.BasicNumericTickProviderSpec(zeroBound: false),
            renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                    color: charts.MaterialPalette.white, fontSize: 20),
                lineStyle: null,
                labelOffsetFromAxisPx: 20,
                axisLineStyle: null)),
        domainAxis: const charts.DateTimeAxisSpec(
            renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                    color: charts.MaterialPalette.white, fontSize: 20),
                lineStyle: null,
                labelOffsetFromAxisPx: 20,
                axisLineStyle: null)),
        animate: animate);
  }

  static List<charts.Series<WeatherPoint, DateTime>> _createSampleData() {
    final data = [
      WeatherPoint(DateTime(2017, 9, 19), 5),
      WeatherPoint(DateTime(2017, 9, 26), 25),
      WeatherPoint(DateTime(2017, 10, 3), 100),
      WeatherPoint(DateTime(2017, 10, 10), 75),
    ];

    return [
      charts.Series(
          id: "Weather",
          colorFn: (_, __) => charts.MaterialPalette.white,
          domainFn: (WeatherPoint weatherPoint, _) => weatherPoint.time,
          measureFn: (WeatherPoint weatherPoint, _) => weatherPoint.temp,
          data: data)
    ];
  }
}

class WeatherPoint {
  final DateTime time;
  int temp;

  WeatherPoint(this.time, this.temp);
}
