import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class PRCurveChart extends StatefulWidget {
  final Map<String, List<PRCurve>> prCurveRuns;

  PRCurveChart(this.prCurveRuns);

  @override
  PRCurveChartState createState() {
    return new PRCurveChartState();
  }
}

int getMaxNestedLen(List<List> nestedList) {
  return nestedList.map((l) => l.length).reduce((l1, l2) => max(l1, l2));
}

class PRCurveChartState extends State<PRCurveChart> {
  double sliderVal;

  PRCurveChartState();

  @override
  Widget build(BuildContext context) {
    int maxLen = getMaxNestedLen(widget.prCurveRuns.values.toList());
    if (sliderVal == null) sliderVal = (maxLen - 1).toDouble();
    List<charts.Series<dynamic, num>> seriesList = [];
    widget.prCurveRuns.forEach((String run, List<PRCurve> prCurves) {
      if (prCurves.length > sliderVal.round()) {
        seriesList.add(createPRSeries(prCurves[sliderVal.round()].series, run));
      } else {
        seriesList.add(createPRSeries(prCurves.last.series, run));
      }
    });

    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'PR curve',
          style: Theme.of(context).textTheme.title,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'Step ' +
              widget.prCurveRuns.values
                  .toList()
                  .first[sliderVal.round()]
                  .step
                  .toString(),
          style: Theme.of(context).textTheme.body2,
        ),
      ),
      Flexible(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: charts.LineChart(seriesList,
            primaryMeasureAxis: charts.NumericAxisSpec(
                viewport: charts.NumericExtents(0.0, 1.0),
                tickProviderSpec: charts.BasicNumericTickProviderSpec(
                    desiredTickCount: 11,
                    dataIsInWholeNumbers: false,
                    zeroBound: false)),
            domainAxis: charts.NumericAxisSpec(
                viewport: charts.NumericExtents(0.0, 1.0),
                tickProviderSpec: charts.BasicNumericTickProviderSpec(
                    desiredTickCount: 11,
                    dataIsInWholeNumbers: false,
                    zeroBound: false)),
            animate: true),
      )),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Slider(
            value: sliderVal,
            min: 0.0,
            divisions: maxLen,
            max: (maxLen - 1).toDouble(),
            onChanged: (x) => setState(() {
                  sliderVal = x;
                })),
      ),
    ]);
  }
}

charts.Series<PR, num> createPRSeries(List<PR> data, id) {
  return new charts.Series<PR, num>(
      id: id,
      domainFn: (PR pr, _) => pr.recall,
      measureFn: (PR pr, _) => pr.precision,
      data: data);
}

class PRCurve {
  final int step;
  final List<PR> series;

  PRCurve(this.step, this.series);
}

class PR {
  final double precision;
  final double recall;

  PR(this.precision, this.recall);
}
