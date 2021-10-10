import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(new MaterialApp(
      home: new HomePage(),
      debugShowCheckedModeBanner: false,
    ));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = new TextEditingController();

  Future<Null> getUserDetails() async {
    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'x-apikey': "5c5c7076f210985199db5488",
      'cache-control': "no-cache"
    });
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      setState(() {
        _userDetails = [];
        _searchResult = [];
        for (Map user in responseJson) {
          _userDetails.add(UserDetails.fromJson(user));
        }
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  void initState() {
    super.initState();

    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Home'),
        elevation: 0.0,
        actions: [
          TextButton(
              onPressed: getUserDetails,
              child: Text(
                'refresh',
                style: new TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            color: Theme.of(context).primaryColor,
            child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(
                    controller: controller,
                    decoration: new InputDecoration(
                        hintText: 'Search', border: InputBorder.none),
                    onChanged: onSearchTextChanged,
                  ),
                  trailing: new IconButton(
                    icon: new Icon(Icons.cancel),
                    onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
          ),
          new Expanded(
            child: _searchResult.length != 0 || controller.text.isNotEmpty
                ? new ListView.builder(
                    itemCount: _searchResult.length,
                    itemBuilder: (context, i) {
                      return new Card(
                        child: new ListTile(
                          title: new Text('name: ' +
                              _searchResult[i].name +
                              ' ' +
                              _searchResult[i].surname),
                          trailing: new Text('City: ${_searchResult[i].city}'),
                        ),
                        margin: const EdgeInsets.all(0.0),
                      );
                    },
                  )
                : new ListView.builder(
                    itemCount: _userDetails.length,
                    itemBuilder: (context, index) {
                      return new Card(
                        child: new ListTile(
                          title: new Text('name: ' +
                              _userDetails[index].name +
                              ' ' +
                              _userDetails[index].surname),
                          trailing:
                              new Text('City: ${_userDetails[index].city}'),
                        ),
                        margin: const EdgeInsets.all(0.0),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _userDetails.forEach((userDetail) {
      if (userDetail.city.toLowerCase().contains(text.toLowerCase()))
        _searchResult.add(userDetail);
    });

    setState(() {});
  }
}

List<UserDetails> _searchResult = [];

List<UserDetails> _userDetails = [];

final String url = 'https://exercise-646d.restdb.io/rest/group-1';

class UserDetails {
  String userId;
  String name;
  String surname;
  int age;
  String city;
  int id;
  dynamic parentid;

  UserDetails(
      {this.userId,
      this.name,
      this.surname,
      this.age,
      this.city,
      this.id,
      this.parentid});
  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return new UserDetails(
      userId: json["_id"],
      name: json["NAME"],
      surname: json["SURNAME"],
      age: json["AGE"],
      city: json["CITY"],
      id: json["ID"],
      parentid: json["PARENTID"],
    );
  }
}
