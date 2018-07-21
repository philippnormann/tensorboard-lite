import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tensorboard_lite/api.dart';
import 'package:tensorboard_lite/pr.dart';
import 'package:tensorboard_lite/scalar.dart';
import 'package:tensorboard_lite/settings.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'TensorBoard Lite',
      theme: new ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: Colors.orange[800],
        accentColor: Colors.orange[800],
      ),
      home: new TensorBoard(),
    );
  }
}

class TensorBoard extends StatefulWidget {
  @override
  TensorBoardState createState() => new TensorBoardState();
}

class TensorBoardState extends State<TensorBoard> {
  Future<Map> lossReq = fetchScalars('loss');
  Future<Map> prReq = fetchPRCurves();
  double sliderVal;
  TimeOfDay lastUpdated = TimeOfDay.now();

  void updateState() {
    setState(() {
      lastUpdated = TimeOfDay.now();
      lossReq = fetchScalars('loss');
      prReq = fetchPRCurves();
    });
  }

  Widget buildPRChart(BuildContext context, AsyncSnapshot<Map> snapshot) {
    if (snapshot.hasData) {
      Map<String, List<PRCurve>> prCurveRuns = snapshot.data;
      return PRCurveChart(prCurveRuns);
    } else if (snapshot.hasError) {
      return Text("${snapshot.error}");
    }
    return Center(
        child: SizedBox.fromSize(
      child: CircularProgressIndicator(),
      size: Size(50.0, 50.0),
    ));
  }

  Widget buildLossChart(BuildContext context, AsyncSnapshot<Map> snapshot) {
    if (snapshot.hasData) {
      Map<String, List<Scalar>> lossRuns = snapshot.data;
      return new ScalarChart(lossRuns, 'loss');
    } else if (snapshot.hasError) {
      return Text("${snapshot.error}");
    }
    return Center(
        child: SizedBox.fromSize(
      child: CircularProgressIndicator(),
      size: Size(50.0, 50.0),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('TensorBoard Lite'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return new AlertDialog(
                        title: new Text('Settings',
                            style: Theme.of(context).textTheme.title),
                        content: SettingsView());
                  },
                );
              },
            )
          ],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
              child: SizedBox(
                height: 300.0,
                child: Card(
                    child: FutureBuilder(
                        future: lossReq, builder: buildLossChart)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 400.0,
                child: Card(
                    child: FutureBuilder(future: prReq, builder: buildPRChart)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 64.0),
              child: Column(children: [
                Text('Last Updated: ' + lastUpdated.format(context))
              ]),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: FutureBuilder(
            future: lossReq,
            builder: (BuildContext conttext, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Theme(
                    data: ThemeData(accentColor: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(21.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    ));
              } else {
                return Icon(Icons.refresh);
              }
            },
          ),
          mini: false,
          onPressed: updateState,
        ));
  }
}
