import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

Future<Forecast> fetchAlbum() async {
  //http://www.7timer.info/bin/civillight.php?lon=-97.9&lat=22.3&ac=0&unit=metric&output=json&tzshift=0
  final response = await http.get('http://www.7timer.info/bin/api.pl?lon=-97.872&lat=22.282&product=civillight&output=json');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Forecast.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}


  class Forecast {
  final String product;
  final String init;
  final List<dynamic> dataseries;

  Forecast({this.product, this.init, this.dataseries});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      product: json['product'],
      init: json['init'],
      dataseries: json['dataseries'],
    );
  }
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperatura Tampico',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Temperatura Tampico'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Future<Forecast> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Widget weatherToiImg(String weather){
    switch(weather){
      case "clear":
        return Image.asset("images/clear.png", width: 50,height: 50,);
      case "oshower":
        return Image.asset("images/rain.png", width: 50,height: 50,);
      default:
        return Text("Desconectado");
    }
  }

  Widget airToMS(int airCategory){
    var msjs = ["",
      "calmado",
      "ligero",
      "moderado",
      "fresco",
      "fuerte",
      "vendaval",
      "tormenta",
      "huracan"];
    return Row(
      children: [
        Image.asset("image/wind.png",width: 25,height: 25,),
        Text(msjs[airCategory]),
      ],
    );
  }

  Widget dayForecast(Forecast forecast, int day){
    var fecha_dt = DateTime.parse(forecast.dataseries[day]["date"].toString());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(fecha_dt.day.toString()+"/"+fecha_dt.month.toString()+"/"+fecha_dt.year.toString()),
              Column(children: [
                Text("Max: "+forecast.dataseries[day]["temp2m"]["max"].toString()),
                Text("Min: "+forecast.dataseries[day]["temp2m"]["min"].toString()),
              ],),
              weatherToiImg(forecast.dataseries[day]["weather"]),
              airToMS(forecast.dataseries[day]["wind10m_max"]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: FutureBuilder<Forecast>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    dayForecast(snapshot.data, 0),
                    dayForecast(snapshot.data, 1),
                    dayForecast(snapshot.data, 2),
                    dayForecast(snapshot.data, 3),
                    dayForecast(snapshot.data, 4),
                    dayForecast(snapshot.data, 5),
                    dayForecast(snapshot.data, 6),
                  ],
                  mainAxisAlignment: MainAxisAlignment.start,
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          )
      ),
    );
  }
}
