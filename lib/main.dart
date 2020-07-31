import 'dart:convert';

import 'package:fa_covid19/country.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(CovidApp());
}

class CovidApp extends StatefulWidget {
  @override
  _CovidAppState createState() => _CovidAppState();
}

final scaffoldState = GlobalKey<ScaffoldState>();

class _CovidAppState extends State<CovidApp> {
  String _totalConfirmed = "TỔNG SỐ CA NHIỄM";
  String _totalDeaths = "TỬ VONG";
  String _totalRecovered = "KHỎI";
  String _currentlyInfected = "ĐANG NHIỄM";
  String _countryName = "THẾ GIỚI";
  Country _country = Country("NULL", "NULL", 0, 0, 0);
  Future<List<Country>> _futureCountry;
  List<Country> countries;
  int _indexCountry = 0;
  DateTime dt = DateTime.now();
  var nf = NumberFormat("###,###,###,###");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureCountry = _getData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "COVID 19",
      home: Scaffold(
        key: scaffoldState,
        appBar: AppBar(
          title: Text("COVID 19"),
          actions: <Widget>[
            MaterialButton(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.explore,
                    color: Colors.white,
                  ),
                  Text(
                    " Quốc gia",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              onPressed: () {
                scaffoldState.currentState.showBottomSheet((context) {
                  if (countries.length > 0) {
                    return FractionallySizedBox(
                      heightFactor: 0.65,
                      widthFactor: 1.0,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: Text(
                              "MÃ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            title: Text("TÊN QUỐC GIA",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Text(_totalConfirmed,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: countries.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Text(
                                    countries[index].countryCode,
                                  ),
                                  title: Text(countries[index].countryName),
                                  trailing: Text(countries[index]
                                      .totalConfirmed
                                      .toString()),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _indexCountry = index;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                });
              },
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: FutureBuilder(
            future: _futureCountry,
            builder: (context, snap) {
              if (snap.hasData) {
                //   http.Response response = snap as http.Response;
                //   print("Hello" + response.body);
                countries = snap.data;
                _country = countries[_indexCountry];
                // print(countries.length);
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image.asset(
                        "images/covid19.png",
                        height: 200,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                          Text(
                            " " + _country.countryName,
                            style: TextStyle(
                                fontSize: 28.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      _boxData(_totalConfirmed, _country.totalConfirmed,
                          Colors.red, 1.0, 0.0),
                      Wrap(
                        children: <Widget>[
                          _boxData(
                              _currentlyInfected,
                              _country.totalConfirmed -
                                  _country.totalRecovered -
                                  _country.totalDeaths,
                              Colors.orange,
                              0.333,
                              0.0),
                          _boxData(_totalRecovered, _country.totalRecovered,
                              Colors.green, 0.333, 0.0),
                          _boxData(_totalDeaths, _country.totalDeaths,
                              Colors.grey, 0.333, 0.0)
                        ],
                      ),
                      Text(
                        "Nguồn cấp: COVID19API (" +
                            DateFormat("dd-MM-yyyy").format(dt) +
                            ")",
                        style: TextStyle(
                            color: Colors.deepOrangeAccent,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                );
              } else {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text(
                        "Nếu tải quá lâu, vui lòng kiểm tra kết nối internet của bạn!")
                  ],
                ));
              }
            }),
      ),
    );
  }

  Widget _boxData(String title, int data, MaterialColor color, double fracWidth,
      double fracHeight) {
    return FractionallySizedBox(
      widthFactor: fracWidth,
      child: Card(
        elevation: 0.5,
        color: color,
        child: Container(
          padding: EdgeInsets.all(2.0),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 1.0,
                child: Container(
                    padding:
                        EdgeInsets.only(top: 15, bottom: 15),
                    color: Colors.white,
                    child: Text(
                      nf.format(data).toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: color,
                      ),
                      textAlign: TextAlign.center,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Country>> _getData() async {
    // print("_getData");
    List<Country> listCountry = List<Country>();
    http.Client client = http.Client();
    final res = await client.get("https://api.covid19api.com/summary");
    var jsonData = jsonDecode(res.body);
    var jsonGlobal = jsonData['Global'];
    var jsonCountries = jsonData['Countries'];
    dt = DateTime.parse(jsonData['Date']);
    listCountry.add(Country("Thế giới", "Global", jsonGlobal['TotalConfirmed'],
        jsonGlobal['TotalDeaths'], jsonGlobal['TotalRecovered']));
    final parsed = jsonCountries.cast<Map<String, dynamic>>();
    var temp = parsed.map<Country>((json) => Country.fromJson(json)).toList();
    listCountry.addAll(temp);
    // print(listCountry.length);
    return listCountry;
  }
}
