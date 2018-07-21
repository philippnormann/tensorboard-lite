import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:quiver/iterables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tensorboard_lite/pr.dart';
import 'package:tensorboard_lite/scalar.dart';

Future<Response> fetch(String path,
    {Map<String, String> params = const {}}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String url = prefs.getString('url') ?? '';
  String user = prefs.getString('user') ?? '';
  String password = prefs.getString('password') ?? '';
  String basicAuth = base64.encode(utf8.encode(user + ':' + password));
  Map<String, String> headers = {'authorization': 'Basic ' + basicAuth};
  Uri uri = Uri.parse(url + path).replace(queryParameters: params);
  return get(uri, headers: headers);
}

Future<List> fetchRuns() async {
  Response runRes = await fetch('/data/runs');
  return jsonDecode(runRes.body);
}

Map<String, List<String>> parseTags(String tagResBody) {
  Map<String, dynamic> tagsByRuns = jsonDecode(tagResBody);
  Map<String, List<String>> runsByTags = {};
  tagsByRuns.forEach((run, tags) {
    for (String tag in tags.keys) {
      runsByTags.putIfAbsent(tag, () => []).add(run);
    }
  });
  return runsByTags;
}

Future<Map> fetchTags(String plugin) async {
  Response tagRes = await fetch('/data/plugin/' + plugin + '/tags');
  if (tagRes.statusCode != 200) throw ClientException(tagRes.body);
  return parseTags(tagRes.body);
}

List<Scalar> parseScalar(String scalarResBody) {
  List<dynamic> scalarData = jsonDecode(scalarResBody);
  return scalarData.map((item) => Scalar(item[0], item[1], item[2])).toList();
}

Future<List<Scalar>> fetchScalar(String tag, String run) async {
  Response scalarRes = await fetch('/data/plugin/scalars/scalars',
      params: {'run': run, 'tag': tag});
  if (scalarRes.statusCode != 200) throw ClientException(scalarRes.body);
  return parseScalar(scalarRes.body);
}

Future<Map<String, List<Scalar>>> fetchScalars(String tag) async {
  List runs = await fetchRuns();
  Map scalarTags = await fetchTags('scalars');
  List<String> lossRuns = scalarTags[tag];
  Map<String, List<Scalar>> res = {};
  for (String run in runs) {
    if (lossRuns.contains(run)) {
      res[run] = await fetchScalar(tag, run);
    }
  }
  return res;
}

List<PRCurve> parsePRCurve(String prResBody) {
  List decodedResponse = jsonDecode(prResBody).values.first;
  List<PRCurve> prCurves = [];
  for (Map prCurveRes in decodedResponse) {
    List<PR> prSeries = [];
    int step = prCurveRes['step'];
    for (List pr_tuple in zip(
        [prCurveRes['precision'] as List, prCurveRes['recall'] as List])) {
      prSeries.add(PR(pr_tuple[0], pr_tuple[1]));
    }
    prCurves.add(PRCurve(step, prSeries));
  }
  return prCurves;
}

Future<List<PRCurve>> fetchPRCurve(String run) async {
  Response prRes = await fetch('/data/plugin/pr_curves/pr_curves',
      params: {'run': run, 'tag': 'pr_curve/0'});
  if (prRes.statusCode != 200) throw ClientException(prRes.body);
  return parsePRCurve(prRes.body);
}

Future<Map<String, List<PRCurve>>> fetchPRCurves() async {
  List runs = await fetchRuns();
  Map prTags = await fetchTags('pr_curves');
  List<String> prRuns = prTags['pr_curve/0'];
  Map<String, List<PRCurve>> res = {};
  for (String run in runs) {
    if (prRuns.contains(run)) {
      res[run] = await fetchPRCurve(run);
    }
  }
  return res;
}
