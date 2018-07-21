import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:quiver/core.dart';

class ScalarChart extends StatelessWidget {
  final Map<String, List<Scalar>> scalarRuns;
  final String scalarTag;

  ScalarChart(this.scalarRuns, this.scalarTag);

  @override
  Widget build(BuildContext context) {
    double maxStep = 0.0;
    double maxValue = 0.0;
    List<charts.Series<Scalar, num>> seriesList = [];
    scalarRuns.forEach((String run, List<Scalar> scalarSeries) {
      seriesList.add(createScalarSeries(scalarSeries, run));
      maxStep = max(maxStep, scalarSeries.last.step.toDouble());
      maxValue = max(maxValue,
          scalarSeries.map((step) => step.value).reduce((a, b) => max(a, b)));
    });

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: Text(
            scalarTag[0].toUpperCase() + scalarTag.substring(1),
            style: Theme.of(context).textTheme.title,
          ),
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: charts.LineChart(seriesList,
                primaryMeasureAxis: charts.NumericAxisSpec(
                    viewport: charts.NumericExtents(0.0, maxValue),
                    tickProviderSpec: charts.BasicNumericTickProviderSpec(
                        desiredMinTickCount: 3,
                        desiredMaxTickCount: 9,
                        dataIsInWholeNumbers: false,
                        zeroBound: false)),
                domainAxis: charts.NumericAxisSpec(
                    viewport: charts.NumericExtents(0.0, maxStep),
                    tickProviderSpec: charts.BasicNumericTickProviderSpec(
                        desiredMinTickCount: 3,
                        desiredMaxTickCount: 9,
                        dataIsInWholeNumbers: false,
                        zeroBound: false)),
                animate: true),
          ),
        ),
      ],
    );
  }
}

charts.Series<Scalar, num> createScalarSeries(List<Scalar> data, String id) {
  return new charts.Series<Scalar, num>(
      id: id,
      domainFn: (Scalar scalar, _) => scalar.step,
      measureFn: (Scalar scalar, _) => scalar.value,
      data: data);
}

class Scalar {
  final double timestamp;
  final int step;
  final double value;

  Scalar(this.timestamp, this.step, this.value);

  bool operator ==(other) =>
      other is Scalar &&
      timestamp == other.timestamp &&
      step == other.step &&
      value == other.value;

  int get hashCode => hash3(timestamp.hashCode, step.hashCode, value.hashCode);
}
