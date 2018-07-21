import 'package:tensorboard_lite/api.dart';
import 'package:tensorboard_lite/scalar.dart';
import 'package:test/test.dart';

void main() {
  test('parseTags returns a mapping of tags to their associated runs', () {
    const String tagResponse = """
      {
        ".": {
          "loss": {
            "displayName": "loss",
            "description": ""
          },
          "global_step/sec": {
            "displayName": "global_step/sec",
            "description": ""
          }
        },
        "eval_validation": {
          "loss": {
            "displayName": "loss",
            "description": ""
          }
        }
      }
    """;
    Map answer = parseTags(tagResponse);
    Map expected = {
      'loss': ['.', 'eval_validation'],
      'global_step/sec': ['.']
    };
    expect(answer, expected);
  });
  test('parseScalar returns a list of scalars', () {
    const String scalarResponse = """
      [
        [
          1531438062.2614567,
          658,
          0.03936580568552017
        ],
        [
          1531439796.405049,
          1330,
          0.039980724453926086
        ],
        [
          1531441554.8927119,
          2045,
          0.03478126972913742
        ]
      ]
    """;
    List answer = parseScalar(scalarResponse);
    List expected = [
      Scalar(1531438062.2614567, 658, 0.03936580568552017),
      Scalar(1531439796.405049, 1330, 0.039980724453926086),
      Scalar(1531441554.8927119, 2045, 0.03478126972913742)
    ];
    expect(answer, expected);
  });
}
