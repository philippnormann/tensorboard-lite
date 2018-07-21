import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatelessWidget {
  final prefs = SharedPreferences.getInstance();

  Widget buildSettings(
      BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
    if (snapshot.hasData) {
      String url = snapshot.data.getString('url');
      String user = snapshot.data.getString('user');
      String password = snapshot.data.getString('password');

      return Column(children: [
        TextField(
          controller: TextEditingController(text: url),
          decoration: InputDecoration(labelText: 'URL'),
          onChanged: (String value) {
            url = value;
          },
        ),
        TextField(
          controller: TextEditingController(text: user),
          decoration: InputDecoration(labelText: 'Username'),
          onChanged: (String value) {
            user = value;
          },
        ),
        TextField(
          controller: TextEditingController(text: password),
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
          onChanged: (String value) {
            password = value;
          },
        ),
        Padding(
            padding: EdgeInsets.only(top: 32.0),
            child: RaisedButton(
              color: Colors.orange.shade800,
              textColor: Colors.white,
              child: Text('Save'),
              onPressed: () {
                snapshot.data.setString('url', url);
                snapshot.data.setString('user', user);
                snapshot.data.setString('password', password);
                Navigator.pop(context);
              },
            ))
      ]);
    } else {
      return CircularProgressIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 250.0,
        child: FutureBuilder(future: prefs, builder: buildSettings));
  }
}
